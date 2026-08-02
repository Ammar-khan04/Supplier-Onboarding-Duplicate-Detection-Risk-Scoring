from hypothesis import given

from .generators import ALLOWED_TRANSITIONS, apply_workflow_commands, supplier_request_payloads, workflow_commands, normalize_payload


@given(workflow_commands())
def test_generated_workflow_sequences_only_apply_allowed_transitions(commands):
    _, transitions = apply_workflow_commands(commands)

    assert all(transition in ALLOWED_TRANSITIONS for transition in transitions)


@given(workflow_commands())
def test_fusion_created_states_require_prior_approval(commands):
    final_status, transitions = apply_workflow_commands(commands)
    visited_statuses = [transition[2] for transition in transitions]

    if final_status in {"SUBMITTED_TO_FUSION", "CREATED_IN_FUSION"}:
        assert "APPROVED" in visited_statuses


@given(supplier_request_payloads())
def test_request_payload_round_trip_preserves_supported_fields(payload):
    stored = normalize_payload(payload)
    read_back = dict(stored)

    assert read_back == stored
    assert read_back["supplier_name"] == payload.supplier_name
    assert read_back["contact_email"] == payload.contact_email.lower()
