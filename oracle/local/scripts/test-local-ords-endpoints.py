#!/usr/bin/env python3
import json
import os
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
BASE_URL = os.environ.get(
    "ORDS_BASE_URL",
    f"http://localhost:{ORDS_PORT}/ords/supplier-onboarding/v1",
).rstrip("/")
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
    except urllib.error.URLError as exc:
        raise ApiError(f"{method} {url} failed: {exc}") from exc

    if status not in expected:
        raise ApiError(f"{method} {url} returned HTTP {status}, expected {expected}: {payload}")

    if not payload:
        return {}

    try:
        return json.loads(payload)
    except json.JSONDecodeError as exc:
        raise ApiError(f"{method} {url} returned non-JSON payload: {payload}") from exc


def get(path, query=None):
    return request("GET", path, query=query)


def post(path, data, expected=(200, 201)):
    return request("POST", path, data=data, expected=expected)


def put(path, data=None, expected=(200,), query=None):
    return request("PUT", path, data=data, expected=expected, query=query)


def items(payload):
    return payload.get("items", [])


def require(condition, message):
    if not condition:
        raise AssertionError(message)


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


def find_job(request_id, integration_type, status):
    payload = get("integration-jobs", query={"type": integration_type, "status": status, "limit": "100"})
    matches = [row for row in items(payload) if int(row.get("request_id") or -1) == int(request_id)]
    require(matches, f"No {status} {integration_type} job found for request {request_id}")
    matches.sort(key=lambda row: int(row["job_id"]), reverse=True)
    return matches[0]


def create_request(token, suffix):
    supplier_name = f"AIDLC Live Test {suffix} {token}"
    payload = post(
        "requests",
        {
            "actor_subject_id": "REQ_AMINA_SUB",
            "actor_roles": "REQUESTER",
            "requester_display_name": "Amina Requester",
            "requester_email": "amina.requester@example.com",
            "supplier_name": supplier_name,
            "supplier_type": "COMPANY",
            "country_code": "US",
            "address_line1": "100 Endpoint Test Avenue",
            "address_line2": "Suite 12",
            "city": "Austin",
            "state_or_province": "TX",
            "postal_code": "78701",
            "contact_person": "Taylor Endpoint",
            "contact_email": f"{token.lower()}-{suffix.lower()}@example.com",
            "contact_phone": "+1-555-0100",
            "business_unit": "PROCUREMENT",
            "business_justification": f"Live endpoint and DB persistence test {token} {suffix}",
            "product_service_category": "Technology Services",
            "expected_annual_spend": "125000",
            "currency_code": "USD",
            "tax_registration_number": f"TAX-{token}-{suffix}",
            "bank_country_code": "US",
            "bank_currency_code": "USD",
            "bank_account_raw": f"99000000{token[-6:]}",
            "site_name": "Austin Intake",
            "site_address_line1": "100 Endpoint Test Avenue",
            "site_city": "Austin",
            "site_country_code": "US",
        },
    )
    request_id = int(payload["request_id"])
    print(f"OK POST /requests -> request_id={request_id}")
    return request_id, supplier_name


def add_document(request_id, token, suffix):
    payload = post(
        f"requests/{request_id}/documents",
        {
            "actor_subject_id": "REQ_AMINA_SUB",
            "actor_roles": "REQUESTER",
            "document_type": "TAX_FORM",
            "file_name": f"{token}-{suffix}-tax-form.pdf",
            "mime_type": "application/pdf",
        },
    )
    document_id = int(payload["document_id"])
    print(f"OK POST /requests/{request_id}/documents -> document_id={document_id}")
    return document_id


def submit_request(request_id):
    payload = post(
        f"requests/{request_id}/submit",
        {
            "actor_subject_id": "REQ_AMINA_SUB",
            "actor_roles": "REQUESTER",
        },
    )
    require(payload.get("status") == "UNDER_REVIEW", f"Expected UNDER_REVIEW after submit, got {payload}")
    print(f"OK POST /requests/{request_id}/submit -> UNDER_REVIEW")


def approve_request(request_id):
    post(
        f"requests/{request_id}/review",
        {
            "actor_subject_id": "REV_PRIYA_SUB",
            "actor_roles": "REVIEWER",
            "decision": "APPROVE",
            "reason": "Live endpoint test approval",
        },
    )
    print(f"OK POST /requests/{request_id}/review -> APPROVE")


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
    detail = get(
        f"requests/{request_id}",
        query={"actor_subject_id": "REV_PRIYA_SUB", "actor_roles": "REVIEWER"},
    )
    require(
        int(detail["reviewer_adjustment_points"]) == points,
        f"Justification-risk adjustment readback failed: {detail}",
    )
    require(
        float(detail["risk_score"]) >= float(detail["deterministic_risk_score"]),
        f"Adjusted risk score did not preserve deterministic score: {detail}",
    )
    print(f"OK POST /requests/{request_id}/justification-risk-adjustment -> +{points}")


def claim_and_complete(job_id, status, token, retryable="N", ai_summary=None):
    result_query = {
        "job_status": status,
        "response_reference": f"RESP-{token}-{job_id}",
        "error_type": "LIVE_TEST_ERROR" if status == "FAILED" else "",
        "error_message": "Live test retryable failure" if status == "FAILED" else "",
        "retryable": retryable,
        "fusion_supplier_id": f"FUSION-{token}",
        "fusion_supplier_number": f"FSN-{token}",
    }
    if ai_summary:
        result_query.update(
            {
                "ai_summary": ai_summary,
                "ai_recommended_actions": "Reviewer should verify duplicate and risk evidence before approval.",
                "justification_quality": "MEDIUM",
                "model_name": "gemini-live-test",
            }
        )

    post(
        f"integration-jobs/{job_id}/claim",
        {
            "oic_instance_id": f"OIC-LIVE-{token}",
            "correlation_id": f"CORR-{token}-{job_id}",
        },
    )
    print(f"OK POST /integration-jobs/{job_id}/claim")
    put(
        f"integration-jobs/{job_id}/result",
        query=result_query,
    )
    print(f"OK PUT /integration-jobs/{job_id}/result -> {status}")


def main():
    token = os.environ.get("AIDLC_TEST_TOKEN", f"T{int(time.time())}")
    print(f"Using ORDS base: {BASE_URL}")
    print(f"Using test token: {token}")

    require(get("").get("service_name") == "supplier-onboarding-ords", "Base service index failed")
    require(get("health").get("status") == "ok", "Health endpoint failed")
    require("items" in get("requests"), "Requests collection failed")
    require("items" in get("risk-rules"), "Risk rules collection failed")
    require("items" in get("high-risk-countries"), "High-risk countries collection failed")
    require("items" in get("integration-logs", query={"actor_subject_id": "ADM_LINDA_SUB", "actor_roles": "ADMIN"}), "Integration logs failed")
    print("OK read endpoints")

    happy_request_id, happy_supplier_name = create_request(token, "SUCCESS")
    detail = get(
        f"requests/{happy_request_id}",
        query={"actor_subject_id": "REQ_AMINA_SUB", "actor_roles": "REQUESTER"},
    )
    require(detail["supplier_name"] == happy_supplier_name, "Created request detail did not match")
    print(f"OK GET /requests/{happy_request_id}")

    put(
        f"requests/{happy_request_id}",
        query={
            "actor_subject_id": "REQ_AMINA_SUB",
            "actor_roles": "REQUESTER",
            "contact_phone": "+1-555-0199",
            "business_justification": f"Updated live endpoint test justification {token}",
            "expected_annual_spend": "130000",
        },
    )
    detail = get(
        f"requests/{happy_request_id}",
        query={"actor_subject_id": "REQ_AMINA_SUB", "actor_roles": "REQUESTER"},
    )
    require(detail["contact_phone"] == "+1-555-0199", "Updated request phone did not persist")
    require(float(detail["expected_annual_spend"]) == 130000, "Updated request spend did not persist")
    print(f"OK PUT /requests/{happy_request_id}")

    document_id = add_document(happy_request_id, token, "SUCCESS")
    document = get(f"requests/{happy_request_id}/documents/{document_id}")
    require(int(document["document_id"]) == document_id, "Document readback failed")
    print(f"OK GET /requests/{happy_request_id}/documents/{document_id}")

    submit_request(happy_request_id)
    ai_job = post(
        f"requests/{happy_request_id}/ai-regeneration",
        {
            "actor_subject_id": "REV_PRIYA_SUB",
            "actor_roles": "REVIEWER",
        },
    )
    ai_job_id = int(ai_job["job_id"])
    print(f"OK POST /requests/{happy_request_id}/ai-regeneration -> job_id={ai_job_id}")
    claim_and_complete(ai_job_id, "SUCCEEDED", token, ai_summary=f"Gemini live test summary for {token}.")
    apply_justification_adjustment(
        happy_request_id,
        5,
        "Gemini advisory and reviewer judgment found the justification needs added scrutiny.",
    )

    approve_request(happy_request_id)
    fusion_job = find_job(happy_request_id, "FUSION_CREATE", "READY")
    claim_and_complete(int(fusion_job["job_id"]), "SUCCEEDED", token)

    retry_request_id, retry_supplier_name = create_request(token, "RETRY")
    retry_document_id = add_document(retry_request_id, token, "RETRY")
    require(retry_document_id > 0, "Retry document was not created")
    submit_request(retry_request_id)
    approve_request(retry_request_id)
    failed_fusion_job = find_job(retry_request_id, "FUSION_CREATE", "READY")
    failed_fusion_job_id = int(failed_fusion_job["job_id"])
    claim_and_complete(failed_fusion_job_id, "FAILED", token, retryable="Y")
    retry_job = post(
        f"requests/{retry_request_id}/retry",
        {
            "actor_subject_id": "ADM_LINDA_SUB",
            "actor_roles": "ADMIN",
        },
    )
    retry_job_id = int(retry_job["job_id"])
    print(f"OK POST /requests/{retry_request_id}/retry -> job_id={retry_job_id}")

    post(
        "supplier-reference/batch",
        {
            "fusion_supplier_id": f"REF-{token}",
            "supplier_number": f"REFNUM-{token}",
            "supplier_name": f"AIDLC Reference Supplier {token}",
            "supplier_type": "COMPANY",
            "sync_id": f"SYNC-{token}",
        },
    )
    print("OK POST /supplier-reference/batch")

    put(
        "risk-rules/HIGH_EXPECTED_SPEND",
        query={
            "actor_subject_id": "ADM_LINDA_SUB",
            "actor_roles": "ADMIN",
            "weight": "5",
            "active": "Y",
        },
    )
    print("OK PUT /risk-rules/HIGH_EXPECTED_SPEND")

    country_code = "XZ"
    put(
        f"high-risk-countries/{country_code}",
        query={
            "actor_subject_id": "ADM_LINDA_SUB",
            "actor_roles": "ADMIN",
            "active": "Y",
            "reason": f"Live endpoint test country {token}",
            "source": "Live endpoint test",
        },
    )
    print(f"OK PUT /high-risk-countries/{country_code}")

    require(any(row["country_code"] == country_code for row in items(get("high-risk-countries"))), "High-risk country readback failed")
    require(any(row["rule_code"] == "HIGH_EXPECTED_SPEND" for row in items(get("risk-rules"))), "Risk rule readback failed")
    require(
        any(
            int(row.get("job_id") or -1) == retry_job_id
            for row in items(get("integration-jobs", query={"type": "FUSION_CREATE", "status": "READY"}))
        ),
        "Retry job readback failed",
    )
    print("OK readback after writes")

    verification_sql = f"""
select 'REQUEST_ROWS=' || count(*) from supplier_app.supplier_request where supplier_name like {sql_literal('AIDLC Live Test % ' + token)};
select 'SUCCESS_STATUS=' || status || ',FUSION=' || nvl(fusion_supplier_number, 'NULL') from supplier_app.supplier_request where request_id = {happy_request_id};
select 'RETRY_STATUS=' || status from supplier_app.supplier_request where request_id = {retry_request_id};
select 'DOCUMENT_ROWS=' || count(*) from supplier_app.request_document where request_id in ({happy_request_id}, {retry_request_id});
select 'ASSESSMENT_ROWS=' || count(*) from supplier_app.request_assessment where request_id in ({happy_request_id}, {retry_request_id});
select 'AI_ROWS=' || count(*) from supplier_app.ai_assessment where request_id = {happy_request_id} and status = 'SUCCEEDED';
select 'ADJUSTMENT_POINTS=' || reviewer_adjustment_points || ',DETERMINISTIC=' || deterministic_risk_score || ',FINAL=' || risk_score from supplier_app.request_assessment where request_id = {happy_request_id} and is_latest = 'Y';
select 'JUSTIFICATION_ACTION_ROWS=' || count(*) from supplier_app.action_history where request_id = {happy_request_id} and action = 'APPLY_JUSTIFICATION_RISK';
select 'ACTION_ROWS=' || count(*) from supplier_app.action_history where request_id in ({happy_request_id}, {retry_request_id});
select 'INTEGRATION_ROWS=' || count(*) from supplier_app.integration_job where request_id in ({happy_request_id}, {retry_request_id});
select 'RETRY_PARENT=' || parent_job_id || ',RETRY_STATUS=' || status from supplier_app.integration_job where job_id = {retry_job_id};
select 'SUPPLIER_REF_ROWS=' || count(*) from supplier_app.fusion_supplier_ref where fusion_supplier_id = {sql_literal('REF-' + token)};
select 'HIGH_RISK_XZ=' || active || ',SOURCE=' || source_name from supplier_app.high_risk_country_config where country_code = 'XZ';
select 'RISK_RULE_UPDATED_BY=' || updated_by_subject_id || ',TOTAL=' || (select sum(weight_points) from supplier_app.risk_rule_config where active = 'Y') from supplier_app.risk_rule_config where rule_code = 'HIGH_EXPECTED_SPEND';
select 'INVALID_OBJECTS=' || count(*) from dba_objects where owner = 'SUPPLIER_APP' and status <> 'VALID';
"""
    verification_lines = db_query_lines(verification_sql)
    for line in verification_lines:
        print(f"DB {line}")

    expected_fragments = [
        "REQUEST_ROWS=2",
        "SUCCESS_STATUS=CREATED_IN_FUSION",
        "FUSION=FSN-",
        "RETRY_STATUS=INTEGRATION_FAILED",
        "DOCUMENT_ROWS=2",
        "ASSESSMENT_ROWS=2",
        "AI_ROWS=1",
        "ADJUSTMENT_POINTS=5",
        "JUSTIFICATION_ACTION_ROWS=1",
        "SUPPLIER_REF_ROWS=1",
        "HIGH_RISK_XZ=Y",
        "RISK_RULE_UPDATED_BY=ADM_LINDA_SUB,TOTAL=100",
        "INVALID_OBJECTS=0",
    ]
    joined = "\n".join(verification_lines)
    for fragment in expected_fragments:
        require(fragment in joined, f"Missing DB verification fragment: {fragment}\n{joined}")

    print("PASS live ORDS endpoint writes are persisted in the Oracle database")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        sys.exit(1)
