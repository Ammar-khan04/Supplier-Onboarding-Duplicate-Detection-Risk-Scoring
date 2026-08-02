# Requirement Follow-Up Questions

The first verification pass found one missing answer and several choices that need confirmation because they affect scope, security, and production readiness.

Please answer each question by filling in the letter choice after the `[Answer]:` tag. If none of the options match, choose `X` and describe your preference after the tag.

## Question 1
Question 5 in the original file is still unanswered. How strict should duplicate detection be?

A) Explainable rules plus lightweight fuzzy matching for name/address/domain, exact matching for tax ID and bank account

B) Rules only, with no fuzzy matching

C) Advanced fuzzy matching with weighted scoring, threshold configuration, and match reason breakdowns

X) Other (please describe after [Answer]: tag below)

[Answer]: 

## Question 2
You selected production-ready delivery, but also selected application-level role simulation and skipped security rules. Which scope should the requirements follow?

A) Keep production-ready delivery, and upgrade security/auth expectations to production-grade Oracle identity integration and security controls

B) Change delivery target to prototype/MVP, keeping application-level role simulation and skipped security extension enforcement

C) Keep production-ready as a long-term target, but define the current phase as a prototype with production gaps documented as limitations

X) Other (please describe after [Answer]: tag below)

[Answer]: 

## Question 3
You selected production-ready delivery, but skipped the resiliency baseline. How should reliability requirements be handled?

A) Apply resiliency guidance because production-ready scope requires availability, recovery, monitoring, retry, and rollback expectations

B) Skip resiliency because this phase is not intended to be production-ready

C) Keep only transcript-specific reliability requirements: integration logs, retry count, technical/business failure separation, and visible status tracking

X) Other (please describe after [Answer]: tag below)

[Answer]: 

## Question 4
For the AI provider answer, you wrote "Gemini". Please confirm how it should be recorded.

A) Use Gemini as the AI provider for risk explanations and recommended actions

B) Use Gemini if available, with mocked AI responses as fallback for demo/testing

C) Treat AI provider as undecided and document provider selection as an implementation decision

X) Other (please describe after [Answer]: tag below)

[Answer]: 
