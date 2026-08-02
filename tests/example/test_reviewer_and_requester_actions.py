from .conftest import find_request, items


def test_reviewer_detail_contains_review_actions(api):
    row = find_request(api, "REQ-SEED-001")
    detail = api.get(
        f"requests/{row['request_id']}",
        actor_subject_id="REV_PRIYA_SUB",
        actor_roles="REVIEWER",
    )

    assert detail["status"] == "UNDER_REVIEW"
    assert "APPROVE" in detail["allowed_actions"]
    assert "REJECT" in detail["allowed_actions"]
    assert "REQUEST_CORRECTION" in detail["allowed_actions"]
    assert "MARK_DUPLICATE" in detail["allowed_actions"]


def test_requester_list_is_limited_to_their_subject(api):
    payload = api.get("requests", actor_subject_id="REQ_AMINA_SUB", actor_roles="REQUESTER")
    rows = items(payload)

    assert rows
    assert all(row["requester_subject_id"] == "REQ_AMINA_SUB" for row in rows)


def test_gemini_assessment_is_advisory_only(api):
    row = find_request(api, "REQ-SEED-001")
    detail = api.get(
        f"requests/{row['request_id']}",
        actor_subject_id="REV_PRIYA_SUB",
        actor_roles="REVIEWER",
    )

    assert detail["latest_ai_summary"]
    assert "risk_adjustment" not in str(detail).lower()
