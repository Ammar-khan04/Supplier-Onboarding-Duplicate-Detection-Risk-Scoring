from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, FrozenSet, Iterable, List, Tuple

from hypothesis import strategies as st


STATUSES = (
    "DRAFT",
    "SUBMITTED",
    "VALIDATION_FAILED",
    "UNDER_REVIEW",
    "CORRECTION_REQUIRED",
    "APPROVED",
    "REJECTED",
    "DUPLICATE",
    "SUBMITTED_TO_FUSION",
    "CREATED_IN_FUSION",
    "INTEGRATION_FAILED",
)

ALLOWED_TRANSITIONS: FrozenSet[Tuple[str, str, str]] = frozenset(
    {
        ("DRAFT", "SUBMIT", "SUBMITTED"),
        ("VALIDATION_FAILED", "EDIT", "DRAFT"),
        ("VALIDATION_FAILED", "SUBMIT", "SUBMITTED"),
        ("CORRECTION_REQUIRED", "SUBMIT", "SUBMITTED"),
        ("SUBMITTED", "VALIDATION_FAILED", "VALIDATION_FAILED"),
        ("SUBMITTED", "VALIDATION_PASSED", "UNDER_REVIEW"),
        ("UNDER_REVIEW", "APPROVE", "APPROVED"),
        ("UNDER_REVIEW", "REJECT", "REJECTED"),
        ("UNDER_REVIEW", "MARK_DUPLICATE", "DUPLICATE"),
        ("UNDER_REVIEW", "REQUEST_CORRECTION", "CORRECTION_REQUIRED"),
        ("APPROVED", "SUBMIT_TO_FUSION", "SUBMITTED_TO_FUSION"),
        ("SUBMITTED_TO_FUSION", "FUSION_SUCCESS", "CREATED_IN_FUSION"),
        ("SUBMITTED_TO_FUSION", "INTEGRATION_FAILED", "INTEGRATION_FAILED"),
        ("INTEGRATION_FAILED", "RETRY_ACCEPTED", "SUBMITTED_TO_FUSION"),
    }
)

ROLE_ACTIONS: Dict[str, FrozenSet[str]] = {
    "REQUESTER": frozenset({"CREATE_REQUEST", "EDIT_OWN_REQUEST", "SUBMIT_OWN_REQUEST", "UPLOAD_DOCUMENT", "VIEW_OWN_REQUEST"}),
    "REVIEWER": frozenset({"VIEW_REVIEW_QUEUE", "APPROVE_REQUEST", "REJECT_REQUEST", "REQUEST_CORRECTION", "MARK_DUPLICATE", "REGENERATE_AI"}),
    "ADMIN": frozenset({"VIEW_INTEGRATION_LOGS", "RETRY_TECHNICAL_FAILURE", "MAINTAIN_RISK_RULES", "MAINTAIN_HIGH_RISK_COUNTRIES"}),
}


@dataclass(frozen=True)
class SupplierRequestPayload:
    supplier_name: str
    supplier_type: str
    country_code: str
    business_unit: str
    contact_person: str
    contact_email: str
    address_line1: str
    city: str
    business_justification: str
    product_service_category: str
    expected_annual_spend: int
    tax_registration_number: str


@dataclass(frozen=True)
class BankProfile:
    account_number: str
    bank_country_code: str


@dataclass(frozen=True)
class SupplierReferenceRecord:
    fusion_supplier_id: str
    supplier_number: str
    supplier_name: str
    tax_registration_number: str
    country_code: str


country_codes = st.sampled_from(["US", "GB", "PK", "AE", "CA", "IR", "SY"])
supplier_types = st.sampled_from(["COMPANY", "INDIVIDUAL", "GOVERNMENT"])
business_units = st.sampled_from(["PROCUREMENT", "LOGISTICS", "FINANCE", "OPERATIONS"])


def email_addresses():
    local = st.text("abcdefghijklmnopqrstuvwxyz0123456789._", min_size=3, max_size=20).filter(lambda s: not s.startswith("."))
    domain = st.sampled_from(["example.com", "supplier.example", "demo.test"])
    return st.builds(lambda left, right: f"{left}@{right}", local, domain)


def supplier_request_payloads():
    names = st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789&.-", min_size=3, max_size=80).map(str.strip).filter(bool)
    justifications = st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789,.-", min_size=12, max_size=240).map(str.strip).filter(bool)
    tax_ids = st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-", min_size=4, max_size=30)
    return st.builds(
        SupplierRequestPayload,
        supplier_name=names,
        supplier_type=supplier_types,
        country_code=country_codes,
        business_unit=business_units,
        contact_person=names,
        contact_email=email_addresses(),
        address_line1=st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789.-", min_size=5, max_size=90).map(str.strip).filter(bool),
        city=st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ", min_size=3, max_size=40).map(str.strip).filter(bool),
        business_justification=justifications,
        product_service_category=st.sampled_from(["Facilities", "IT services", "Logistics", "Industrial supplies"]),
        expected_annual_spend=st.integers(min_value=0, max_value=5_000_000),
        tax_registration_number=tax_ids,
    )


def bank_profiles():
    return st.builds(
        BankProfile,
        account_number=st.text("0123456789", min_size=4, max_size=24),
        bank_country_code=country_codes,
    )


def role_action_pairs():
    roles = st.sampled_from(list(ROLE_ACTIONS))
    actions = st.sampled_from(sorted({action for actions_for_role in ROLE_ACTIONS.values() for action in actions_for_role} | {"DELETE_REQUEST", "APPROVE_AS_ADMIN"}))
    return st.tuples(roles, actions)


def workflow_commands():
    actions = sorted({action for _, action, _ in ALLOWED_TRANSITIONS} | {"UPDATE", "INVALID_SKIP_REVIEW"})
    return st.lists(st.sampled_from(actions), min_size=0, max_size=30)


def supplier_reference_records():
    return st.builds(
        SupplierReferenceRecord,
        fusion_supplier_id=st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-", min_size=4, max_size=40),
        supplier_number=st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-", min_size=4, max_size=40),
        supplier_name=st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789&.-", min_size=3, max_size=80).map(str.strip),
        tax_registration_number=st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-", min_size=4, max_size=30),
        country_code=country_codes,
    )


def retry_inputs():
    return st.fixed_dictionaries(
        {
            "retryable": st.booleans(),
            "status": st.sampled_from(["FAILED", "SUCCEEDED", "CLAIMED", "CANCELLED"]),
            "attempt_number": st.integers(min_value=1, max_value=6),
            "retry_limit": st.integers(min_value=1, max_value=5),
        }
    )


def ai_assessment_events():
    return st.lists(
        st.fixed_dictionaries(
            {
                "request_version": st.integers(min_value=1, max_value=20),
                "summary": st.text("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789,.-", min_size=1, max_size=120),
                "status": st.sampled_from(["SUCCEEDED", "FAILED"]),
            }
        ),
        min_size=1,
        max_size=30,
    )


def risk_configuration_changes():
    return st.fixed_dictionaries(
        {
            "base_weights": st.sampled_from(
                [
                    [10, 5, 10, 15, 5, 5, 5],
                    [8, 7, 10, 15, 5, 5, 5],
                    [12, 3, 10, 15, 5, 5, 5],
                ]
            ),
            "duplicate_weights": st.sampled_from(
                [
                    [20, 15, 10],
                    [18, 17, 10],
                    [15, 20, 10],
                ]
            ),
        }
    )


def risky_country_changes():
    return st.fixed_dictionaries(
        {
            "initial_countries": st.sets(country_codes, min_size=0, max_size=5),
            "changed_country": country_codes,
            "active": st.booleans(),
        }
    )


def apply_workflow_commands(commands: Iterable[str]) -> Tuple[str, List[Tuple[str, str, str]]]:
    status = "DRAFT"
    transitions: List[Tuple[str, str, str]] = []

    for action in commands:
        match = next((transition for transition in ALLOWED_TRANSITIONS if transition[0] == status and transition[1] == action), None)
        if match:
            transitions.append(match)
            status = match[2]

    return status, transitions


def normalize_payload(payload: SupplierRequestPayload) -> dict:
    return {
        "supplier_name": payload.supplier_name,
        "supplier_type": payload.supplier_type.upper(),
        "country_code": payload.country_code.upper(),
        "business_unit": payload.business_unit.upper(),
        "contact_person": payload.contact_person,
        "contact_email": payload.contact_email.lower(),
        "address_line1": payload.address_line1,
        "city": payload.city,
        "business_justification": payload.business_justification,
        "product_service_category": payload.product_service_category,
        "expected_annual_spend": payload.expected_annual_spend,
        "tax_registration_number": payload.tax_registration_number,
    }


def mask_account(account_number: str) -> str:
    return "****" + account_number[-4:]
