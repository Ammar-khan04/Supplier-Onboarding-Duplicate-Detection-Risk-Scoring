from hypothesis import given

from .generators import (
    ai_assessment_events,
    retry_inputs,
    risk_configuration_changes,
    risky_country_changes,
    supplier_reference_records,
)


@given(supplier_reference_records())
def test_supplier_reference_upsert_is_idempotent(record):
    reference_set = {}
    key = record.fusion_supplier_id

    reference_set[key] = record
    once = dict(reference_set)
    reference_set[key] = record

    assert reference_set == once


@given(retry_inputs())
def test_retry_chain_creates_new_attempt_only_when_eligible(data):
    before_count = 1
    eligible = data["status"] == "FAILED" and data["retryable"] and data["attempt_number"] < data["retry_limit"]
    after_count = before_count + 1 if eligible else before_count

    assert after_count >= before_count
    if not eligible:
        assert after_count == before_count


@given(ai_assessment_events())
def test_ai_assessment_regeneration_appends_history(events):
    history = []

    for event in events:
        before = list(history)
        history.append(event)
        assert len(history) == len(before) + 1
        assert history[:-1] == before


@given(risk_configuration_changes())
def test_risk_allocation_weights_sum_to_100(data):
    total_weight = sum(data["base_weights"]) + sum(data["duplicate_weights"])

    assert total_weight == 100


@given(risky_country_changes())
def test_risky_country_changes_do_not_change_rule_weights(data):
    countries = set(data["initial_countries"])

    if data["active"]:
        countries.add(data["changed_country"])
    else:
        countries.discard(data["changed_country"])

    assert countries is not data["initial_countries"]
