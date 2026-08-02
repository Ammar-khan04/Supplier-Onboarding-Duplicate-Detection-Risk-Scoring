# Business Flow: Supplier Onboarding, Duplicate Detection & Risk Scoring

## Plain Summary

The system controls new supplier onboarding from request submission through review and Oracle Fusion ERP creation.

The main flow is:

Requester submits a supplier request -> system validates and checks duplicate/risk -> Gemini explains risk and reviews the business justification -> reviewer may add justification-risk points and then decides -> OIC sends approved supplier to Fusion -> Fusion returns success or failure -> users track final status.

## Prototype Role Model

For the current Visual Builder prototype, the UI has three selectable roles:

- `Requester`: creates, corrects, submits, and tracks supplier requests.
- `Reviewer`: handles procurement/master-data review, finance checks, compliance/risk checks, duplicate/risk decisions, and supplier governance concerns.
- `Admin`: handles IT/support responsibilities from the transcript, including OIC/Fusion logs, technical failure diagnostics, payload references, responses, error messages, timestamps, retry counts, and retry of eligible failed requests.

The original transcript personas for Finance, Compliance, and Supplier Data Governance are still valid stakeholder concerns under Reviewer. IT Support is represented as Admin.

## Who Does What

### 1. Requester Creates the Supplier Request

The requester is a business user who needs a new supplier created.

They open the Oracle Visual Builder application and enter supplier details:

- Supplier name
- Supplier type
- Country
- Address
- Contact person
- Contact email
- Phone number
- Business unit
- Business justification
- Product or service category
- Expected annual spend
- Tax registration number where applicable
- Bank information where available
- One supplier site
- Supporting supplier documents or attachments

The request is saved into Oracle ATP through ORDS APIs.

At this point, no supplier is created in Oracle Fusion ERP.

## 2. System Validates the Request

After submission, the system validates the request.

It checks:

- Required fields are present
- Address is complete
- Contact email is present
- Tax registration is present where applicable
- Bank country mismatch
- Business justification is present for Gemini review
- Supplier site or business unit mapping is valid
- Expected documents are present where applicable

If validation fails, the request status becomes `Validation Failed`.

The requester can correct the request and resubmit it.

## 3. System Checks for Duplicate Suppliers

The system compares the new request against existing supplier master data.

Existing supplier data is synchronized from Oracle Fusion ERP into ATP through OIC.

Duplicate detection checks:

- Same tax registration number
- Same bank account
- Similar supplier name
- Similar address
- Same country
- Same email domain
- Same phone number

Example:

`ABC Technologies Ltd.` may match `ABC Tech Limited`.

The system does not automatically reject the request. It flags possible matches for human review.

## 4. System Calculates Risk

The system calculates a supplier risk level:

- Low
- Medium
- High
- Critical

Risk increases when:

- Tax registration is missing
- Bank information is missing or suspicious
- Bank country differs from supplier country
- Supplier is from a high-risk country
- Supplier is from an Admin-managed risky-country list
- Gemini flags the business justification as risky and the Reviewer confirms extra points
- Expected annual spend is high
- Same tax ID already exists
- Same bank account already exists
- Duplicate risk is high

The risk score must be explainable. Reviewers should see the reasons behind the score.

## 5. Gemini Generates an Explanation
//look into it
//Dont use AI for validation and assign weights to validation


Gemini generates a short business-readable explanation.

Example:

`Medium risk due to missing tax registration and bank country mismatch. Recommended action: request tax certificate and confirm bank details.`

Gemini can:

- Explain risk
- Explain duplicate reasons
- Flag risky, vague, unsupported, or insufficient business justification
- Recommend follow-up actions
- Summarize missing information

Gemini cannot:

- Approve the request
- Reject the request
- Create suppliers in Fusion
- Add risk points without Reviewer confirmation
- Make final business decisions

AI is advisory only.

If Gemini flags the business justification as risky, the Reviewer reads the original justification and Gemini rationale. The Reviewer can leave the score unchanged or apply `+3`, `+5`, or `+10` extra risk points. Those points are added to the previously calculated deterministic risk score and recorded as a human review action.

## 6. Reviewer Reviews the Request

A procurement or master data reviewer opens the reviewer dashboard.

They can see:

- Pending requests
- Under-review requests
- High-risk requests
- Duplicate-risk requests
- Validation issues
- Risk score
- Risk reasons
- Gemini explanation
- Uploaded documents
- Possible duplicate suppliers
- Duplicate match reasons

The reviewer can:

- Approve the request
- Reject the request
- Mark the request as duplicate
- Request correction from the requester

The system never creates a supplier automatically just because a request was submitted.

## 7. If Correction Is Needed

If information is missing or unclear, the reviewer requests correction.

The request goes back to the requester.

The requester updates the information and resubmits.

Then these checks run again:

- Validation
- Duplicate detection
- Risk scoring
- Gemini explanation
- Manual review

Correction does not bypass review.

## 8. If the Request Is Duplicate

If the reviewer determines the request is duplicate, they can reject it or mark it as duplicate.

The reviewer can reference the existing supplier that should be used instead.

The requester can see which existing supplier to use.

No new supplier is created in Fusion.

## 9. If the Request Is Approved

If the reviewer approves the request, the system sends it to OIC.

OIC transforms the staged ATP request into a Fusion-compatible supplier payload.

OIC submits the supplier creation request to Oracle Fusion ERP.

Fusion remains the supplier master system of record.

## 10. Fusion Returns a Response

If Fusion succeeds:

- Fusion returns a supplier number
- ATP stores the Fusion response
- Request status becomes `Created in Fusion`
- Requester and reviewer can see the supplier number. Admin can inspect related integration logs when needed.

If Fusion fails:

- Request status becomes `Integration Failed`
- Error details are stored
- OIC instance ID is stored
- Payload reference is stored
- Fusion response is stored
- Error message is stored
- Retry count is stored

## 11. Admin Handles Integration Failures

In the prototype, the admin uses the OIC/Fusion log area for support-style diagnostics.

The admin can see:

- Failed integrations
- OIC instance ID
- Payload reference
- Fusion response
- Error message
- Timestamp
- Retry count

If the issue is technical, the admin can retry.

Technical failures include:

- Fusion API unavailable
- OIC timeout
- Temporary connection issue

If the issue is business-related, such as missing site or invalid business unit mapping, the request data must be corrected first.

Retry cannot bypass validation, duplicate review, risk review, or approval.

## 12. Reviewer Uses Finance and Compliance Evidence

Finance concerns included in the Reviewer role:

- Duplicate suppliers
- Same bank account warnings
- Bank country mismatch
- Fusion supplier number
- Failed supplier creation
- Payables and reporting impact

Compliance concerns included in the Reviewer role:

- High-risk country
- Missing tax registration
- Gemini-flagged business justification risk and Reviewer-applied points
- Duplicate risk
- Gemini risk explanation
- Recommended follow-up actions

## End-to-End Flow

```text
Requester creates supplier request
        |
        v
Request is saved in ATP through ORDS
        |
        v
System validates request data
        |
        v
System checks duplicate suppliers
        |
        v
System calculates risk score
        |
        v
Gemini generates risk, duplicate, and business-justification explanation
        |
        v
Reviewer may apply +3, +5, or +10 justification-risk points
        |
        v
Reviewer reviews request
        |
        v
Reviewer approves, rejects, marks duplicate, or requests correction
        |
        v
If approved, OIC sends supplier payload to Fusion
        |
        v
Fusion creates supplier or returns an error
        |
        v
System updates status and stores logs
        |
        v
Requester, reviewer, and admin see the status relevant to their role
```

## One-Line Flow

Requester submits -> system validates and scores -> Gemini explains -> reviewer may add justification-risk points -> reviewer decides -> OIC integrates -> Fusion becomes source of truth -> admin handles technical failures and logs.
