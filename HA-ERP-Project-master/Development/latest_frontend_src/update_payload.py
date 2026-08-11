import json

JSON_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(JSON_FILE, "r") as f:
    data = json.load(f)

# Update payload in callPUT inside saveAllRulesChain
# "active": "{{ $current.data.active }}" -> "{{ $current.data.weight == 0 ? 'N' : $current.data.active }}"

if "callPUT" in data["chains"]["saveAllRulesChain"]["actions"]:
    data["chains"]["saveAllRulesChain"]["actions"]["callPUT"]["parameters"]["body"]["active"] = "{{ $current.data.weight == 0 || $current.data.weight === '0' ? 'N' : $current.data.active }}"

with open(JSON_FILE, "w") as f:
    json.dump(data, f, indent=2)

