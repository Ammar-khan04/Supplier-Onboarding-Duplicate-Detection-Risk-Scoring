from .conftest import items


def test_risk_allocation_matches_finalized_model(api):
    rows = items(api.get("risk-rules", actor_subject_id="ADM_LINDA_SUB", actor_roles="ADMIN"))

    active_total = sum(row["weight"] for row in rows if row["active"] == "Y")

    assert active_total == 100


def test_admin_can_view_high_risk_country_list(api):
    rows = items(api.get("high-risk-countries", actor_subject_id="ADM_LINDA_SUB", actor_roles="ADMIN"))
    country_codes = {row["country_code"] for row in rows if row["active"] == "Y"}

    assert {"IR", "KP", "SY"}.issubset(country_codes)


def test_admin_integration_logs_show_retryable_failure(api):
    rows = items(api.get("integration-logs", actor_subject_id="ADM_LINDA_SUB", actor_roles="ADMIN"))

    assert any(row["status"] == "FAILED" and row["retryable"] == "Y" for row in rows)
    assert all("payload_reference" in row for row in rows)
