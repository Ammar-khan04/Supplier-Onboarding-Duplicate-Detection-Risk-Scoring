import json

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(FILE, "r") as f:
    data = json.load(f)

# Add variable
data["variables"]["filterSearchTerm"] = {
    "type": "string",
    "defaultValue": ""
}

# Add chain
data["chains"]["onSearchTermChangeChain"] = {
    "variables": {
        "value": {
            "type": "string",
            "input": "fromCaller"
        }
    },
    "root": "assignSearch",
    "actions": {
        "assignSearch": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.dashboardOffset": {"source": 0}
            },
            "outcomes": {"success": "reload"}
        },
        "reload": {
            "module": "vb/action/builtin/callChainAction",
            "parameters": {"id": "loadDashboardDataChain"}
        }
    }
}

# Also need to add listener
data["eventListeners"]["onSearchTermChange"] = {
    "chains": [{"chainId": "onSearchTermChangeChain", "parameters": {"value": "{{ $event.detail.value }}"}}]
}

with open(FILE, "w") as f:
    json.dump(data, f, indent=2)
