from .conftest import SEED_REQUEST_IDS, find_request


def test_seeded_supplier_requests_are_visible(api):
    request_numbers = set()
    for request_id in SEED_REQUEST_IDS.values():
        detail = api.get(
            f"requests/{request_id}",
            actor_subject_id="REV_PRIYA_SUB",
            actor_roles="REVIEWER",
        )
        request_numbers.add(detail["request_number"])

    assert {"REQ-SEED-001", "REQ-SEED-002", "REQ-SEED-003"}.issubset(request_numbers)


def test_requester_can_create_and_submit_request(api):
    created = api.post(
        "requests",
        actor_subject_id="REQ_AMINA_SUB",
        actor_roles="REQUESTER",
        requester_display_name="Amina Requester",
        requester_email="amina.requester@example.com",
        supplier_name="Atlas Test Services",
        supplier_type="COMPANY",
        country_code="AE",
        address_line1="12 Demo Road",
        city="Dubai",
        contact_person="Sara Khan",
        contact_email="sara.khan@atlas.example",
        contact_phone="+971-50-555-1000",
        business_unit="PROCUREMENT",
        business_justification="Temporary facilities service supplier for UAE site readiness.",
        product_service_category="Facilities services",
        expected_annual_spend="42000",
        currency_code="USD",
        tax_registration_number="AE-TAX-NEW-123",
        site_name="Dubai Main",
        site_address_line1="12 Demo Road",
        site_city="Dubai",
        site_country_code="AE",
    )

    request_id = created["request_id"]
    submitted = api.post(
        f"requests/{request_id}/submit",
        actor_subject_id="REQ_AMINA_SUB",
        actor_roles="REQUESTER",
    )

    assert submitted["status"] in {"UNDER_REVIEW", "VALIDATION_FAILED"}


def test_request_detail_contains_latest_assessment_json(api):
    row = find_request(api, "REQ-SEED-001")
    detail = api.get(
        f"requests/{row['request_id']}",
        actor_subject_id="REV_PRIYA_SUB",
        actor_roles="REVIEWER",
    )

    assert detail["status"] == "UNDER_REVIEW"
    assert detail["validation_results_json"]
    assert detail["duplicate_matches_json"]
    assert detail["risk_factors_json"]


def test_correction_required_request_exposes_edit_action(api):
    row = find_request(api, "REQ-SEED-002")
    detail = api.get(
        f"requests/{row['request_id']}",
        actor_subject_id="REQ_AMINA_SUB",
        actor_roles="REQUESTER",
    )

    assert detail["status"] == "CORRECTION_REQUIRED"
    assert "EDIT" in detail["allowed_actions"]
