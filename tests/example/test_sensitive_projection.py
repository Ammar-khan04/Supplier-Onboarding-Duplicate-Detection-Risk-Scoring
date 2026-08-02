from .conftest import find_request, items


def test_request_detail_exposes_last_four_not_bank_fingerprint(api):
    row = find_request(api, "REQ-SEED-001")
    detail = api.get(
        f"requests/{row['request_id']}",
        actor_subject_id="REV_PRIYA_SUB",
        actor_roles="REVIEWER",
    )

    assert detail["bank_account_last_four"] == "8899"
    assert "bank_account_fingerprint" not in detail
    assert "PK-IBAN-445566778899" not in str(detail)


def test_supplier_request_list_does_not_expose_bank_hashes(api):
    rows = items(api.get("requests", actor_subject_id="REV_PRIYA_SUB", actor_roles="REVIEWER"))
    serialized = str(rows).lower()

    assert "bank_account_fingerprint" not in serialized
    assert "pk-iban-445566778899" not in serialized


def test_admin_log_uses_payload_references_not_raw_payloads(api):
    rows = items(api.get("integration-logs", actor_subject_id="ADM_LINDA_SUB", actor_roles="ADMIN"))

    assert rows
    assert all("payload_reference" in row for row in rows)
    assert all("bank_account_raw" not in str(row) for row in rows)
