# Story Generation Plan

## Purpose

Generate user-centered stories and personas for the Supplier Onboarding, Duplicate Detection & Risk Scoring project based on the approved requirements.

## Source Artifacts

- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/requirements/requirement-verification-questions.md`
- `Customer Requirement Discovery Call Transcript-Integration ERP.pdf`

## Recommended Story Approach

Use a hybrid **User Journey-Based + Persona-Based** approach.

This project has several strongly defined personas, but the clearest implementation and demo flow follows user journeys:

- Requester creates and tracks a supplier request.
- System validates, checks duplicates, scores risk, and generates AI explanation.
- Reviewer approves, rejects, marks duplicate, or requests correction.
- OIC/Fusion integration creates the supplier or fails visibly.
- Support user reviews logs and retries eligible failures.

The story set should therefore be organized by journey, with each story mapped to the personas it serves.

## Story Breakdown Options

### Option 1: User Journey-Based

Stories follow the end-to-end workflow from request creation through Fusion creation or failure.

**Benefits**:
- Aligns well with demo scenarios.
- Makes acceptance testing straightforward.
- Keeps cross-persona handoffs visible.

**Trade-off**:
- Some persona-specific needs may appear across multiple sections.

### Option 2: Feature-Based

Stories are grouped by capabilities such as request form, duplicate detection, risk scoring, dashboard, integration logs, and attachments.

**Benefits**:
- Maps neatly to implementation components.
- Useful for later unit generation.

**Trade-off**:
- Can hide the end-to-end user experience if used alone.

### Option 3: Persona-Based

Stories are grouped by Requester, Reviewer, and Admin in the prototype. Finance, compliance, and governance responsibilities are represented as reviewer concerns; IT/support log and retry responsibilities are represented as Admin concerns.

**Benefits**:
- Makes each stakeholder's needs obvious.
- Helpful for stakeholder review.

**Trade-off**:
- Integration and system workflows may be repeated across personas.

### Option 4: Domain-Based

Stories are grouped by business domains: onboarding, duplicate governance, risk/compliance, ERP integration, and support operations.

**Benefits**:
- Good for business ownership and governance.

**Trade-off**:
- Less direct for screen-by-screen demo design.

### Option 5: Epic-Based

Stories are structured as epics with child stories.

**Benefits**:
- Handles complexity cleanly.
- Supports roadmap and phased delivery.

**Trade-off**:
- Can become too heavy if not kept focused.

## Recommended Output Structure

- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/user-stories/stories.md`

## Mandatory Artifacts

- [x] Generate `personas.md` with user archetypes and characteristics.
- [x] Generate `stories.md` with user stories following INVEST criteria.
- [x] Include acceptance criteria for each story.
- [x] Map personas to relevant user stories.
- [x] Map stories to requirement IDs where practical.
- [x] Include stories for success, duplicate-risk, high-risk, validation-failure, correction, integration-failure, and retry scenarios.
- [x] Confirm AI remains advisory in all stories.
- [x] Include property-based testing implications for duplicate detection, risk scoring, and payload transformation stories.

## Execution Checklist

- [x] Read approved requirements and verification answers.
- [x] Confirm story generation questions are answered and unambiguous.
- [x] Create user personas.
- [x] Create epics organized by user journey.
- [x] Create requester stories.
- [x] Create reviewer stories.
- [x] Create finance/compliance stories as merged Reviewer responsibilities.
- [x] Create support/admin stories.
- [x] Create system/integration stories where the "user" is an internal system actor.
- [x] Add acceptance criteria to every story.
- [x] Check each story against INVEST criteria.
- [x] Add requirement traceability references.
- [x] Save `personas.md` and `stories.md`.
- [x] Update AIDLC state and audit log.

## Story Generation Questions

Please answer each question by filling in the letter choice after the `[Answer]:` tag. If none of the options match, choose `X` and describe your preference after the tag.

### Question 1
Which story breakdown approach should be used?

A) User Journey-Based + Persona-Based hybrid, as recommended

B) Feature-Based, grouped by system capability

C) Persona-Based, grouped primarily by user type

D) Epic-Based, with epics and child stories

X) Other (please describe after [Answer]: tag below)

[Answer]: A - The transcript is driven by end-to-end journeys across several personas, so use the recommended User Journey-Based + Persona-Based hybrid.

### Question 2
What level of story granularity should be generated?

A) Comprehensive stories covering all approved requirements and exception paths

B) Medium-detail stories focused on core demo and implementation flows

C) Minimal stories covering only the primary happy path and major exceptions

X) Other (please describe after [Answer]: tag below)

[Answer]: A - The transcript includes success paths, duplicate risk, high risk, validation failure, correction, integration failure, retry, dashboards, and support flows.

### Question 3
How should acceptance criteria be written?

A) Given/When/Then format for every story

B) Bullet checklist format for every story

C) Hybrid: Given/When/Then for workflow stories, bullet checklist for data/system stories

X) Other (please describe after [Answer]: tag below)

[Answer]: C - Use Given/When/Then for workflow stories and bullet checklist criteria for data, integration, and system behavior stories.

### Question 4
Should system and integration behaviors be written as user stories too?

A) Yes - include internal system actor stories for ATP, ORDS, OIC, Fusion, Gemini, duplicate detection, and risk scoring

B) Partially - include only system stories that directly support visible user workflows

C) No - keep stories only for human personas

X) Other (please describe after [Answer]: tag below)

[Answer]: A - Include internal system actor stories because ATP, ORDS, OIC, Fusion, Gemini, duplicate detection, and risk scoring all produce user-visible outcomes.

### Question 5
How should story priority be represented?

A) Use Must/Should/Could priority labels

B) Use MoSCoW labels: Must, Should, Could, Won't

C) Do not assign priority in User Stories; defer prioritization to Workflow Planning

X) Other (please describe after [Answer]: tag below)

[Answer]: C - Defer prioritization to Workflow Planning so stories stay focused on user value and acceptance criteria.

### Question 6
Should stories include requirement traceability IDs?

A) Yes - map each story to relevant requirement IDs from `requirements.md`

B) Partially - map only high-value or complex stories

C) No - keep stories readable without traceability IDs

X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Approval Gate

After all `[Answer]:` tags are filled and validated, this plan requires explicit approval before story generation begins.
