import json
import os

OPENAPI_FILE = "services/ORDS-Specification/openapi3.json"

with open(OPENAPI_FILE, "r") as f:
    data = json.load(f)

# The GET /requests/{request_id} returns a RequestDetail schema. Let's find it.
# It might be an inline schema or a ref.
# Let's search components.schemas for something matching the request detail properties.

for schema_name, schema_obj in data.get("components", {}).get("schemas", {}).items():
    if "properties" in schema_obj and "request_id" in schema_obj["properties"] and "status" in schema_obj["properties"]:
        if "latest_correction_reason" not in schema_obj["properties"]:
            schema_obj["properties"]["latest_correction_reason"] = {"type": "string"}
            print(f"Added to schema: {schema_name}")

# Also check GET /requests/{request_id} response if inline
try:
    inline_schema = data["paths"]["/requests/{request_id}"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]
    if "properties" in inline_schema:
        if "latest_correction_reason" not in inline_schema["properties"]:
            inline_schema["properties"]["latest_correction_reason"] = {"type": "string"}
            print("Added to inline GET /requests/{request_id} schema")
except Exception as e:
    pass

with open(OPENAPI_FILE, "w") as f:
    json.dump(data, f, indent=2)

