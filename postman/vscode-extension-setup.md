# Cursor or VS Code Postman Extension Setup

## Installed Extension

The Postman extension installed locally is:

```text
postman.postman-for-vscode
```

It has been installed in both Cursor and VS Code.

## Open The Project

For Cursor:

```bash
cursor "/home/ammarkhan/Desktop/Work/Projects/Supplier Onboarding, Duplicate Detection & Risk Scoring"
```

For VS Code:

```bash
code "/home/ammarkhan/Desktop/Work/Projects/Supplier Onboarding, Duplicate Detection & Risk Scoring"
```

## Sign In

1. Open Cursor or VS Code.
2. Select the Postman icon in the Activity Bar.
3. Click `Sign In`.
4. Complete the browser sign-in and select your Postman workspace/team.

## Import Local API Setup

Import these files from the `postman/` folder:

```text
postman/supplier-onboarding-local.postman_collection.json
postman/supplier-onboarding-local.postman_environment.json
```

After importing, select this environment:

```text
Supplier Onboarding Local ORDS
```

## Run The API Flow

Run the collection folders in this order:

1. `00 Health and Reads`
2. `01 Requester Happy Path`
3. `02 Reviewer AI and Decision`
4. `03 OIC Fusion Success`
5. `04 Admin Config and Supplier Reference`
6. `05 Optional Retry Scenario`

## Local ORDS Check

If requests fail, first confirm the local backend is running:

```bash
cd oracle/local
./scripts/check-local-oracle-ords.sh
```

The expected base URL is:

```text
http://localhost:8080/ords/supplier-onboarding/v1
```
