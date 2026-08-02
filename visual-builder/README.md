# Supplier Portal Visual Builder Frontend

## Contents

- `item-1-start-page.html`: the Visual Builder page source for the Supplier Onboarding prototype.
- `*.png`: screenshots captured during the Visual Builder preview/update work.

## How To Share Or Use

1. Open Oracle Visual Builder.
2. Create or open the web application page.
3. Paste the contents of `item-1-start-page.html` into the page source/custom HTML area used for the prototype.
4. Preview the page and use the role buttons at the top: Requester, Reviewer, and Admin.

## Current Frontend Scope

- Requester can view dashboard state, create a new request, see correction-required behavior, and track status.
- Reviewer can view request detail, risk/duplicate/Gemini evidence, apply `+3`, `+5`, or `+10` justification-risk points, and approve/reject/request correction.
- Admin can inspect integration and audit logs, manage risk weights that must total 100, and maintain high-risk countries.

## Backend Contract Notes

The UI labels align to the current local ORDS contract:

- `/requests`
- `/requests/{requestId}/submit`
- `/requests/{requestId}/justification-risk-adjustment`
- `/requests/{requestId}/review`
- `/requests/{requestId}/retry`
- `/risk-rules`
- `/high-risk-countries`
- `/integration-logs`

This package is the Visual Builder frontend/prototype export only. The Oracle ATP/ORDS backend files are not included in this zip.
