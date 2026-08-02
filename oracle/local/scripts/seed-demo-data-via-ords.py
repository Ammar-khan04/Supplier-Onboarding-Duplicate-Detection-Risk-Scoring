#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))


def load_env_file(path):
    values = {}
    if not os.path.exists(path):
        return values
    with open(path, "r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"').strip("'")
    return values


ENV = load_env_file(os.path.join(LOCAL_DIR, ".env"))
ORDS_PORT = ENV.get("ORDS_PORT", os.environ.get("ORDS_PORT", "8080"))
BASE_URL = os.environ.get("ORDS_BASE_URL", f"http://localhost:{ORDS_PORT}/ords/supplier-onboarding/v1").rstrip("/")
DB_CONTAINER = os.environ.get("DB_CONTAINER_NAME", ENV.get("DB_CONTAINER_NAME", "supplier-oracle-db"))


class ApiError(RuntimeError):
    pass


def request(method, path, data=None, expected=(200,), query=None):
    url = f"{BASE_URL}/{path.lstrip('/')}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    body = None
    headers = {"Accept": "application/json"}
    if data is not None:
        body = urllib.parse.urlencode(data).encode("utf-8")
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    req = urllib.request.Request(url, data=body, method=method.upper(), headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            payload = response.read().decode("utf-8")
            status = response.status
    except urllib.error.HTTPError as exc:
        payload = exc.read().decode("utf-8", errors="replace")
        raise ApiError(f"{method} {url} returned HTTP {exc.code}: {payload}") from exc
    if status not in expected:
        raise ApiError(f"{method} {url} returned HTTP {status}, expected {expected}: {payload}")
    return json.loads(payload) if payload else {}


def get(path, query=None):
    return request("GET", path, query=query)


def post(path, data, expected=(200, 201)):
    return request("POST", path, data=data, expected=expected)


def put(path, data=None, expected=(200,), query=None):
    return request("PUT", path, data=data, expected=expected, query=query)


def items(payload):
    return payload.get("items", [])


def sql_literal(value):
    return "'" + str(value).replace("'", "''") + "'"


def db_query_lines(sql):
    sqlplus_input = "\n".join(
        [
            "set heading off feedback off pagesize 0 verify off trimspool on linesize 32767",
            "alter session set container = FREEPDB1;",
            sql,
            "exit",
        ]
    )
    result = subprocess.run(
        ["docker", "exec", "-i", DB_CONTAINER, "bash", "-lc", "sqlplus -s / as sysdba"],
        input=sqlplus_input,
        text=True,
        cwd=LOCAL_DIR,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"SQL verification failed:\nSTDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}")
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def safe_email(label, token):
    slug = re.sub(r"[^a-z0-9]+", "-", label.lower()).strip("-")
    return f"demo-{slug}-{token.lower()}@example.com"


def base_request(label, token):
    return {
        "actor_subject_id": "REQ_AMINA_SUB",
        "actor_roles": "REQUESTER",
        "requester_display_name": "Amina Requester",
        "requester_email": "amina.requester@example.com",
        "supplier_name": f"Demo Supplier {label} {token}",
        "supplier_type": "COMPANY",
        "country_code": "US",
        "address_line1": "400 Demo Market Street",
        "address_line2": "Suite 500",
        "city": "Austin",
        "state_or_province": "TX",
        "postal_code": "78701",
        "contact_person": f"{label} Contact",
        "contact_email": safe_email(label, token),
        "contact_phone": "+1-555-0200",
        "business_unit": "PROCUREMENT",
        "business_justification": f"Demo data for supervisor walkthrough: {label}.",
        "product_service_category": "Technology Services",
        "expected_annual_spend": "185000",
        "currency_code": "USD",
        "tax_registration_number": f"DEMO-TAX-{token}-{label.replace(' ', '').upper()}",
        "bank_country_code": "US",
        "bank_currency_code": "USD",
        "bank_account_raw": f"77000000{token[-6:]}",
        "site_name": "Austin Demo Site",
        "site_address_line1": "400 Demo Market Street",
        "site_city": "Austin",
        "site_country_code": "US",
    }


def create_request(label, token, overrides=None):
    payload = base_request(label, token)
    if overrides:
        payload.update(overrides)
    result = post("requests", payload)
    request_id = int(result["request_id"])
    print(f"SEEDED {label}: request_id={request_id}")
    return request_id


def add_document(request_id, token, label):
    result = post(
        f"requests/{request_id}/documents",
        {
            "actor_subject_id": "REQ_AMINA_SUB",
            "actor_roles": "REQUESTER",
            "document_type": "TAX_FORM",
            "file_name": f"demo-{token}-{label.lower().replace(' ', '-')}.pdf",
            "mime_type": "application/pdf",
        },
    )
    print(f"  document_id={result['document_id']}")
    return int(result["document_id"])


def submit_request(request_id):
    result = post(
        f"requests/{request_id}/submit",
        {"actor_subject_id": "REQ_AMINA_SUB", "actor_roles": "REQUESTER"},
    )
    print(f"  submitted_status={result.get('status')}")
    return result.get("status")


def review_request(request_id, decision, reason):
    post(
        f"requests/{request_id}/review",
        {
            "actor_subject_id": "REV_PRIYA_SUB",
            "actor_roles": "REVIEWER",
            "decision": decision,
            "reason": reason,
        },
    )
    print(f"  reviewer_decision={decision}")


def apply_justification_adjustment(request_id, points, reason):
    post(
        f"requests/{request_id}/justification-risk-adjustment",
        {
            "actor_subject_id": "REV_PRIYA_SUB",
            "actor_roles": "REVIEWER",
            "points": str(points),
            "reason": reason,
        },
    )
    print(f"  justification_adjustment=+{points}")


def find_job(request_id, integration_type, status="READY"):
    payload = get("integration-jobs", query={"type": integration_type, "status": status, "limit": "100"})
    matches = [row for row in items(payload) if int(row.get("request_id") or -1) == int(request_id)]
    if not matches:
        raise RuntimeError(f"No {status} {integration_type} job found for request {request_id}")
    matches.sort(key=lambda row: int(row["job_id"]), reverse=True)
    return int(matches[0]["job_id"])


def complete_job(job_id, token, status, retryable="N", ai=False):
    post(
        f"integration-jobs/{job_id}/claim",
        {
            "oic_instance_id": f"OIC-DEMO-{token}",
            "correlation_id": f"DEMO-CORR-{token}-{job_id}",
        },
    )
    query = {
        "job_status": status,
        "response_reference": f"DEMO-RESP-{token}-{job_id}",
        "error_type": "DEMO_FAILURE" if status == "FAILED" else "",
        "error_message": "Demo Fusion create failure for retry walkthrough" if status == "FAILED" else "",
        "retryable": retryable,
        "fusion_supplier_id": f"DEMO-FUSION-{token}",
        "fusion_supplier_number": f"DEMO-FSN-{token}",
    }
    if ai:
        query.update(
            {
                "ai_summary": f"Gemini demo summary for {token}: justification is specific enough for reviewer review.",
                "ai_recommended_actions": "Review supplier identity, tax evidence, bank metadata, and duplicate signals before final approval.",
                "justification_quality": "HIGH",
                "model_name": "gemini-demo",
            }
        )
    put(f"integration-jobs/{job_id}/result", query=query)
    print(f"  integration_job={job_id} result={status}")


def main():
    token = os.environ.get("AIDLC_DEMO_TOKEN", f"DEMO{int(time.time())}")
    print(f"Using ORDS base: {BASE_URL}")
    print(f"Using demo token: {token}")

    if get("health").get("status") != "ok":
        raise RuntimeError("ORDS health check failed")

    draft_id = create_request("Draft", token)

    validation_id = create_request(
        "Validation Failed",
        token,
        {
            "tax_registration_number": "",
            "bank_account_raw": "",
        },
    )
    validation_status = submit_request(validation_id)
    if validation_status != "VALIDATION_FAILED":
        raise RuntimeError(f"Expected VALIDATION_FAILED, got {validation_status}")

    under_review_id = create_request("Under Review", token)
    add_document(under_review_id, token, "Under Review")
    submit_request(under_review_id)
    ai_job_id = post(
        f"requests/{under_review_id}/ai-regeneration",
        {"actor_subject_id": "REV_PRIYA_SUB", "actor_roles": "REVIEWER"},
    )["job_id"]
    complete_job(int(ai_job_id), token, "SUCCEEDED", ai=True)
    apply_justification_adjustment(
        under_review_id,
        5,
        "Demo reviewer confirmed Gemini's business-justification concern warrants added scrutiny.",
    )

    correction_id = create_request("Correction Required", token)
    add_document(correction_id, token, "Correction Required")
    submit_request(correction_id)
    review_request(correction_id, "REQUEST_CORRECTION", "Please add clearer site ownership details before approval.")

    success_id = create_request("Fusion Created", token)
    add_document(success_id, token, "Fusion Created")
    submit_request(success_id)
    review_request(success_id, "APPROVE", "Demo approval for Fusion create success.")
    success_job_id = find_job(success_id, "FUSION_CREATE")
    complete_job(success_job_id, token, "SUCCEEDED")

    failure_id = create_request("Integration Failed", token)
    add_document(failure_id, token, "Integration Failed")
    submit_request(failure_id)
    review_request(failure_id, "APPROVE", "Demo approval for Fusion create failure and retry.")
    failure_job_id = find_job(failure_id, "FUSION_CREATE")
    complete_job(failure_job_id, token, "FAILED", retryable="Y")
    retry_job = post(
        f"requests/{failure_id}/retry",
        {"actor_subject_id": "ADM_LINDA_SUB", "actor_roles": "ADMIN"},
    )["job_id"]
    print(f"  retry_job={retry_job}")

    post(
        "supplier-reference/batch",
        {
            "fusion_supplier_id": f"DEMO-REF-{token}",
            "supplier_number": f"DEMO-REFNUM-{token}",
            "supplier_name": f"Demo Existing Supplier {token}",
            "supplier_type": "COMPANY",
            "sync_id": f"DEMO-SYNC-{token}",
        },
    )
    print("SEEDED supplier reference via ORDS")

    put(
        "risk-rules/HIGH_EXPECTED_SPEND",
        query={"actor_subject_id": "ADM_LINDA_SUB", "actor_roles": "ADMIN", "weight": "5", "active": "Y"},
    )
    put(
        "high-risk-countries/ZZ",
        query={
            "actor_subject_id": "ADM_LINDA_SUB",
            "actor_roles": "ADMIN",
            "active": "Y",
            "reason": f"Demo risky-country entry {token}",
            "source": "Demo seed through ORDS",
        },
    )
    print("SEEDED admin configuration via ORDS")

    verification_sql = f"""
select 'DEMO_REQUEST_ROWS=' || count(*) from supplier_app.supplier_request where supplier_name like {sql_literal('Demo Supplier % ' + token)};
select 'DEMO_DRAFT=' || count(*) from supplier_app.supplier_request where request_id = {draft_id} and status = 'DRAFT';
select 'DEMO_VALIDATION_FAILED=' || count(*) from supplier_app.supplier_request where request_id = {validation_id} and status = 'VALIDATION_FAILED';
select 'DEMO_UNDER_REVIEW=' || count(*) from supplier_app.supplier_request where request_id = {under_review_id} and status = 'UNDER_REVIEW';
select 'DEMO_CORRECTION=' || count(*) from supplier_app.supplier_request where request_id = {correction_id} and status = 'CORRECTION_REQUIRED';
select 'DEMO_CREATED=' || count(*) from supplier_app.supplier_request where request_id = {success_id} and status = 'CREATED_IN_FUSION';
select 'DEMO_FAILED=' || count(*) from supplier_app.supplier_request where request_id = {failure_id} and status = 'INTEGRATION_FAILED';
select 'DEMO_DOCUMENT_ROWS=' || count(*) from supplier_app.request_document where request_id in ({under_review_id},{correction_id},{success_id},{failure_id});
select 'DEMO_ASSESSMENT_ROWS=' || count(*) from supplier_app.request_assessment where request_id in ({validation_id},{under_review_id},{correction_id},{success_id},{failure_id});
select 'DEMO_AI_ROWS=' || count(*) from supplier_app.ai_assessment where request_id = {under_review_id} and status = 'SUCCEEDED';
select 'DEMO_ADJUSTMENT_POINTS=' || reviewer_adjustment_points from supplier_app.request_assessment where request_id = {under_review_id} and is_latest = 'Y';
select 'DEMO_ACTION_ROWS=' || count(*) from supplier_app.action_history where request_id in ({draft_id},{validation_id},{under_review_id},{correction_id},{success_id},{failure_id});
select 'DEMO_INTEGRATION_ROWS=' || count(*) from supplier_app.integration_job where request_id in ({under_review_id},{success_id},{failure_id});
select 'DEMO_SUPPLIER_REF_ROWS=' || count(*) from supplier_app.fusion_supplier_ref where fusion_supplier_id = {sql_literal('DEMO-REF-' + token)};
select 'DEMO_RISK_COUNTRY_ZZ=' || active || ',SOURCE=' || source_name from supplier_app.high_risk_country_config where country_code = 'ZZ';
select 'DEMO_RISK_TOTAL=' || sum(weight_points) from supplier_app.risk_rule_config where active = 'Y';
"""
    for line in db_query_lines(verification_sql):
        print(f"DB {line}")

    print("PASS demo data seeded through ORDS and verified in Oracle")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        sys.exit(1)
