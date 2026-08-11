import json

OPENAPI_FILE = "services/ORDS-Specification/openapi3.json"

with open(OPENAPI_FILE, "r") as f:
    data = json.load(f)

# Define the new parameters
params_to_add = [
    {"name": "sort_col", "in": "query", "required": False, "schema": {"type": "string"}},
    {"name": "sort_dir", "in": "query", "required": False, "schema": {"type": "string"}}
]
requests_params = params_to_add + [
    {"name": "status", "in": "query", "required": False, "schema": {"type": "string"}},
    {"name": "search", "in": "query", "required": False, "schema": {"type": "string"}}
]

# Update paths
if "/requests" in data["paths"]:
    existing = data["paths"]["/requests"]["get"].get("parameters", [])
    names = [p["name"] for p in existing]
    for p in requests_params:
        if p["name"] not in names:
            existing.append(p)
    data["paths"]["/requests"]["get"]["parameters"] = existing

if "/integration-logs" in data["paths"]:
    existing = data["paths"]["/integration-logs"]["get"].get("parameters", [])
    names = [p["name"] for p in existing]
    for p in params_to_add:
        if p["name"] not in names:
            existing.append(p)
    data["paths"]["/integration-logs"]["get"]["parameters"] = existing

if "/action-history" in data["paths"]:
    existing = data["paths"]["/action-history"]["get"].get("parameters", [])
    names = [p["name"] for p in existing]
    for p in params_to_add:
        if p["name"] not in names:
            existing.append(p)
    data["paths"]["/action-history"]["get"]["parameters"] = existing

with open(OPENAPI_FILE, "w") as f:
    json.dump(data, f, indent=2)

