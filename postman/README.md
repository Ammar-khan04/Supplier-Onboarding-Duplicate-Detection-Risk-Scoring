# Postman Setup: Supplier Onboarding Local ORDS

## Files

- `supplier-onboarding-local.postman_collection.json`
- `supplier-onboarding-local.import-safe.postman_collection.json`
- `supplier-onboarding-local.bare.postman_collection.json`
- `supplier-onboarding-local.bare-v2.postman_collection.json`
- `supplier-onboarding-local.import-test.postman_collection.json`
- `supplier-onboarding-local.import-test-v2.postman_collection.json`
- `supplier-onboarding-local.postman_environment.json`

## Import

### Current Postman Cloud Setup

The full collection is already provisioned in the Postman **Default workspace**
through the official Postman MCP server. Do not import another copy.

- Collection: [Supplier Onboarding Local ORDS](https://go.postman.co/collection/56812232-38fbd4d6-f0e5-4be7-b616-739f7416dee2)
- Collection UID: `56812232-38fbd4d6-f0e5-4be7-b616-739f7416dee2`
- Environment: `Supplier Onboarding Local ORDS`

In the Cursor Postman extension, select **Default workspace** and refresh the
sidebar. Select the environment before running requests.

### Cursor

The Postman extension in Cursor 3.12.17 can fail local collection imports with
`TypeError: Only HTTP(S) protocols are supported`. This is a Cursor extension
importer failure, not a collection validation failure.

1. Open [Postman Web](https://web.postman.co/) and select the same Postman workspace used by the Cursor extension.
2. Select Import, then Files.
3. Import `supplier-onboarding-local.postman_collection.json`.
4. Return to the Postman extension in Cursor and refresh the workspace.
5. Select the already-imported `Supplier Onboarding Local ORDS` environment.

The synchronized collection contains all 41 requests, folders, scripts, and tests.

### Postman Desktop or VS Code

1. Open Postman.
2. Select Import.
3. Import `supplier-onboarding-local.import-test.postman_collection.json`.
4. If that imports, import `supplier-onboarding-local.bare.postman_collection.json`.
5. If the v2.1 bare file fails, import `supplier-onboarding-local.bare-v2.postman_collection.json`.
6. In the top-right environment dropdown, select `Supplier Onboarding Local ORDS`.
7. Confirm `baseUrl` is `http://localhost:8080/ords/supplier-onboarding/v1`.

If the environment already imported successfully, do not reimport it. Import only the collection file.

If Postman still shows `Could not import collection. Please try again.` for the tiny import-test file, the failure is in the Postman client importer rather than the collection content. Use the Postman Web synchronization path above or Postman Desktop.

The available collection variants are:

- `supplier-onboarding-local.import-test.postman_collection.json`: two simple requests, used only to prove import works.
- `supplier-onboarding-local.import-test-v2.postman_collection.json`: same two requests using the older v2.0.0 collection schema.
- `supplier-onboarding-local.bare.postman_collection.json`: 24 plain endpoint requests, no folders, no variables, no scripts.
- `supplier-onboarding-local.bare-v2.postman_collection.json`: same 24 plain endpoint requests using the older v2.0.0 collection schema.
- `supplier-onboarding-local.import-safe.postman_collection.json`: all 41 requests, folders and variables, but no scripts.
- `supplier-onboarding-local.postman_collection.json`: full automated 41-request collection with scripts and tests.

## Local Server Check

Before running the collection, confirm the local stack is up:

```bash
cd oracle/local
./scripts/check-local-oracle-ords.sh
```

## Recommended Run Order

Run folders in this order:

1. `00 Health and Reads`
2. `01 Requester Happy Path`
3. `02 Reviewer AI and Decision`
4. `03 OIC Fusion Success`
5. `04 Admin Config and Supplier Reference`
6. `05 Optional Retry Scenario`

The collection stores response IDs into environment variables such as `requestId`, `documentId`, `aiJobId`, `fusionJobId`, and `retryJobId`.

## Local ORDS PUT Note

The local ORDS 26.2 stack has been verified with query parameters for `PUT` handlers. The collection therefore sends draft updates, integration job results, risk-rule updates, and high-risk-country updates as query parameters so readback checks confirm the database state changed.

## Fresh Run

To create a fresh data set, clear the `testToken` environment value before running again. The collection will create a new timestamp token automatically.
