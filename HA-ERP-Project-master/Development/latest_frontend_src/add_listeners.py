import json

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(FILE, "r") as f:
    data = json.load(f)

new_listeners = {
    "onDashboardSort": {
        "chains": [{"chainId": "onDashboardSortChain", "parameters": {"header": "{{ $event.detail.header }}", "direction": "{{ $event.detail.direction }}"}}]
    },
    "onDashboardPagePrev": {
        "chains": [{"chainId": "onDashboardPageChain", "parameters": {"direction": "prev"}}]
    },
    "onDashboardPageNext": {
        "chains": [{"chainId": "onDashboardPageChain", "parameters": {"direction": "next"}}]
    },
    
    "onLogsSort": {
        "chains": [{"chainId": "onLogsSortChain", "parameters": {"header": "{{ $event.detail.header }}", "direction": "{{ $event.detail.direction }}"}}]
    },
    "onLogsPagePrev": {
        "chains": [{"chainId": "onLogsPageChain", "parameters": {"direction": "prev"}}]
    },
    "onLogsPageNext": {
        "chains": [{"chainId": "onLogsPageChain", "parameters": {"direction": "next"}}]
    },
    
    "onHistorySort": {
        "chains": [{"chainId": "onHistorySortChain", "parameters": {"header": "{{ $event.detail.header }}", "direction": "{{ $event.detail.direction }}"}}]
    },
    "onHistoryPagePrev": {
        "chains": [{"chainId": "onHistoryPageChain", "parameters": {"direction": "prev"}}]
    },
    "onHistoryPageNext": {
        "chains": [{"chainId": "onHistoryPageChain", "parameters": {"direction": "next"}}]
    }
}

if "eventListeners" not in data:
    data["eventListeners"] = {}

data["eventListeners"].update(new_listeners)

with open(FILE, "w") as f:
    json.dump(data, f, indent=2)

