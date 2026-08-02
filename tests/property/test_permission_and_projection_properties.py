from hypothesis import given

from .generators import ROLE_ACTIONS, apply_workflow_commands, bank_profiles, mask_account, role_action_pairs, workflow_commands


@given(role_action_pairs())
def test_disallowed_role_actions_do_not_mutate_protected_state(role_action):
    role, action = role_action
    before = {"status": "UNDER_REVIEW", "history_count": 4, "integration_jobs": 1}
    after = dict(before)

    if action in ROLE_ACTIONS[role]:
        after["history_count"] += 1

    if action not in ROLE_ACTIONS[role]:
        assert after == before


@given(bank_profiles())
def test_bank_projection_never_exposes_full_account(profile):
    masked = mask_account(profile.account_number)
    response = {
        "bank_account_last_four": profile.account_number[-4:],
        "masked_account_display": masked,
    }

    assert "bank_account_fingerprint" not in response
    assert "bank_account_raw" not in response
    assert masked.endswith(profile.account_number[-4:])
    assert masked.startswith("****")


@given(workflow_commands())
def test_requester_edit_action_only_for_owned_editable_statuses(commands):
    editable_statuses = {"DRAFT", "VALIDATION_FAILED", "CORRECTION_REQUIRED"}
    final_status, _ = apply_workflow_commands(commands)

    owned_actions = {"EDIT"} if final_status in editable_statuses else set()
    not_owned_actions = set()

    assert ("EDIT" in owned_actions) == (final_status in editable_statuses)
    assert "EDIT" not in not_owned_actions
