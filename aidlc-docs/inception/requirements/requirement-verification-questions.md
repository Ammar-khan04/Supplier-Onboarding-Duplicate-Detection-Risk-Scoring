# Requirement Verification Questions

Please answer each question by filling in the letter choice after the `[Answer]:` tag. If none of the options match, choose `X` and describe your preference after the tag.

## Question 1
What should be the primary delivery target for this project?

A) Prototype only, optimized for a three-week demo with realistic flows and mockable integrations

B) MVP, with prototype scope plus stronger security, deployment, and maintainability foundations

C) Production-ready implementation, including hardened security, observability, deployment automation, and operational runbooks

X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 2
How should Oracle Fusion ERP be represented during implementation?

A) Use mock Fusion payloads and mock responses only, while documenting the real OIC/Fusion integration pattern

B) Build OIC integration interfaces against real Fusion APIs if access is available, with mock fallback

C) Implement only local ATP/ORDS behavior now and defer Fusion/OIC implementation to a later phase

X) Other (please describe after [Answer]: tag below)

[Answer]: b

## Question 3
Which AI service should be used for risk explanations and recommended actions?

A) Oracle Generative AI

B) OpenAI API

C) AWS Bedrock

D) Mocked AI response generator for the prototype, with prompt design documented

X) Other (please describe after [Answer]: tag below)

[Answer]: Gemini

## Question 4
What authentication and authorization depth is expected for phase one?

A) Simple prototype roles with seeded users or environment-level access only

B) Oracle Identity Cloud Service / OCI IAM integration for real role-based access

C) Application-level role simulation only, with production identity integration documented as a limitation

X) Other (please describe after [Answer]: tag below)

[Answer]: c

## Question 5
How strict should duplicate detection be in phase one?

A) Explainable rules plus lightweight fuzzy matching for name/address/domain, exact matching for tax ID and bank account

B) Rules only, with no fuzzy matching

C) Advanced fuzzy matching with weighted scoring, threshold configuration, and match reason breakdowns

X) Other (please describe after [Answer]: tag below)

[Answer]: A - Transcript requires more than exact supplier name matching, but not an extremely advanced matching engine.

## Question 6
How should supplier request corrections be handled?

A) Reviewer rejects or marks request as needing correction, and requester edits/resubmits the same request

B) Reviewer rejects only, and requester creates a new request

C) Reviewer can directly edit submitted request data before approval

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 7
What should the prototype do with attachments and supplier documents?

A) Capture document metadata and missing-document flags only, no file upload

B) Support actual upload and storage of attachments

C) Exclude attachments completely from phase one

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 8
Should the prototype support multiple supplier sites?

A) One supplier with one site only

B) One supplier with optional multiple sites

C) Multiple sites should be designed but only one site implemented

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 9
What should be the expected source of existing supplier master data for duplicate checking?

A) Seeded mock supplier master data in ATP

B) Periodic OIC sync from Fusion into ATP

C) Both: seeded data for demo plus documented OIC sync design

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 10
Should security extension rules be enforced for this project?

A) Yes - enforce all security rules as blocking constraints

B) No - skip security rules for the prototype

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 11
Should the resiliency baseline be applied to this project?

A) Yes - apply resiliency baseline as design-time guidance

B) No - skip resiliency baseline for the prototype

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 12
Should property-based testing rules be enforced for this project?

A) Yes - enforce property-based testing rules for business logic and data transformations

B) Partial - enforce property-based testing only for pure functions and serialization round-trips

C) No - skip property-based testing rules

X) Other (please describe after [Answer]: tag below)

[Answer]: A
