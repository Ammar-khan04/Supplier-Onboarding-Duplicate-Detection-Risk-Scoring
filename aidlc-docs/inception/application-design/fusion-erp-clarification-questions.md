# Fusion ERP Clarification Questions

These questions capture Oracle Fusion ERP and OIC integration details that were not fully specified in the discovery transcript. The answers will guide Units Generation, Functional Design, Infrastructure Design, and Code Generation.

Please answer each question by filling in the letter choice after the `[Answer]:` tag. If none of the options match, choose `X` and describe your preference after the tag.

## Question 1
Which Oracle Fusion supplier creation interface should the design target?

A) Fusion REST APIs for Supplier creation

B) Fusion SOAP services / FBDI import process

C) OIC should abstract the exact Fusion interface for now, with payloads kept Fusion-like until access is confirmed

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 2
Should supplier creation from OIC to Fusion be synchronous or asynchronous?

A) Synchronous: OIC waits for Fusion response and immediately returns supplier number or error

B) Asynchronous: OIC submits request, then updates ATP later when Fusion processing completes

C) Hybrid: synchronous for prototype/mock flows, asynchronous-ready design for real Fusion

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 3
What is the expected supplier creation scope in Fusion for phase one?

A) Supplier header only

B) Supplier header plus one supplier site

C) Supplier header plus one site plus contact and bank information where available

X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 4
How should supplier sites map to Fusion?

A) Use one site tied to the selected business unit / intended operating unit

B) Use one generic procurement/payables site for prototype purposes

C) Capture site data in ATP but defer exact Fusion site mapping until Fusion configuration is known

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 5
How should business unit mapping to Fusion be handled?

A) Use a configurable ATP lookup table mapping request business units to Fusion business units / IDs

B) Hardcode a small set of demo mappings for the prototype

C) Defer business unit mapping until Fusion environment metadata is available

X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 6
Should bank information be sent to Fusion during supplier creation in phase one?

A) Yes, send bank information when provided and valid

B) No, capture and validate bank information in ATP only, but do not send it to Fusion in phase one

C) Include bank information only in mock/demo payloads, not real Fusion submissions until security review

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 7
How should sensitive bank data be represented in ATP and integration logs?

A) Store full protected value for matching/integration, but display and log only masked values

B) Store only masked values in ATP for prototype, so matching is simplified

C) Store a hash/token for duplicate matching and masked value for display; avoid storing full bank account number

X) Other (please describe after [Answer]: tag below)

[Answer]: It should be fully available to the intended user

## Question 8
What Fusion response data must be stored in ATP after supplier creation?

A) Supplier number only

B) Supplier number, supplier ID, site ID, status, response timestamp, and message

C) Full Fusion response payload plus parsed supplier number/status fields

X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 9
How should Fusion business errors be handled?

A) Treat Fusion validation errors as business-correctable failures requiring requester/reviewer correction

B) Treat all Fusion failures as integration failures for support review

C) Classify errors into business-correctable vs technical using configurable error codes/messages

X) Other (please describe after [Answer]: tag below)

[Answer]: B but log them in a file for transparency

## Question 10
How should OIC retry behavior be designed?

A) Manual retry only from the reviewer OIC/Fusion log area

B) Automatic retry for transient technical errors plus manual retry from the reviewer OIC/Fusion log area

C) No retry in phase one; only log errors

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 11
How often should existing Fusion supplier master data sync into ATP for duplicate checking?

A) On-demand/manual sync for prototype

B) Scheduled daily sync

C) Scheduled hourly or more frequent sync

X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 12
What supplier master fields must be synchronized from Fusion into ATP for duplicate detection?

A) Basic fields only: supplier name, supplier number, country, tax registration

B) Expanded duplicate fields: name, supplier number, country, tax registration, address, email/domain, phone, site, and masked/hash bank reference where allowed

C) Sync all available supplier master fields for prototype flexibility

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 13
How should mock Fusion behavior be represented?

A) Static mock success and failure JSON payloads

B) Configurable mock scenarios for success, validation failure, duplicate-like rejection, timeout, and invalid business unit/site mapping

C) No mock layer; wait for Fusion access

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 14
Which Fusion/OIC environment assumptions should the design make?

A) One shared prototype environment

B) Separate development and test environments

C) Development, test, and production-like environment separation

X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 15
What should happen after Fusion successfully creates the supplier?

A) Mark request Created in Fusion and show supplier number only

B) Mark request Created in Fusion, show supplier number, and lock request from further edits

C) Mark request Created in Fusion, show supplier number, lock edits, and retain full audit/status history

X) Other (please describe after [Answer]: tag below)

[Answer]: It should return all data
