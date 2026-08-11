import json

JSON_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(JSON_FILE, "r") as f:
    data = json.load(f)

# Update event listener
data["eventListeners"]["onRuleWeightChange"]["chains"][0]["parameters"] = {
    "index": "{{ $event.index }}",
    "value": "{{ $event.value }}"
}

with open(JSON_FILE, "w") as f:
    json.dump(data, f, indent=2)

