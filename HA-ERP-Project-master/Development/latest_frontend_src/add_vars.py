import json

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(FILE, "r") as f:
    data = json.load(f)

new_vars = {
    "dashboardOffset": {"type": "number", "defaultValue": 0},
    "dashboardSortCol": {"type": "string", "defaultValue": "updated_at"},
    "dashboardSortDir": {"type": "string", "defaultValue": "desc"},
    "dashboardLimit": {"type": "number", "defaultValue": 25},
    
    "logsOffset": {"type": "number", "defaultValue": 0},
    "logsSortCol": {"type": "string", "defaultValue": "updated_at"},
    "logsSortDir": {"type": "string", "defaultValue": "desc"},
    "logsLimit": {"type": "number", "defaultValue": 25},
    
    "historyOffset": {"type": "number", "defaultValue": 0},
    "historySortCol": {"type": "string", "defaultValue": "action_at"},
    "historySortDir": {"type": "string", "defaultValue": "desc"},
    "historyLimit": {"type": "number", "defaultValue": 200},
}

data["variables"].update(new_vars)

# Also update the fetch actions to use these new variables.
# 1. loadDashboardDataChain -> fetchRequests
try:
    fetchRequestsParams = data["chains"]["loadDashboardDataChain"]["actions"]["fetchRequests"]["parameters"]["uriParams"]
    fetchRequestsParams["limit"] = "{{ $page.variables.dashboardLimit }}"
    fetchRequestsParams["offset"] = "{{ $page.variables.dashboardOffset }}"
    fetchRequestsParams["sort_col"] = "{{ $page.variables.dashboardSortCol }}"
    fetchRequestsParams["sort_dir"] = "{{ $page.variables.dashboardSortDir }}"
    fetchRequestsParams["status"] = "{{ $page.variables.filterStatus === 'ALL' ? '' : $page.variables.filterStatus }}"
    fetchRequestsParams["search"] = "{{ $page.variables.filterSearchTerm }}"
    print("Updated fetchRequests params")
except Exception as e:
    print(f"Error updating fetchRequests: {e}")

# 2. loadIntegrationLogsChain -> fetchLogs
try:
    fetchLogsParams = data["chains"]["loadIntegrationLogsChain"]["actions"]["fetchLogs"]["parameters"]["uriParams"]
    fetchLogsParams["limit"] = "{{ $page.variables.logsLimit }}"
    fetchLogsParams["offset"] = "{{ $page.variables.logsOffset }}"
    fetchLogsParams["sort_col"] = "{{ $page.variables.logsSortCol }}"
    fetchLogsParams["sort_dir"] = "{{ $page.variables.logsSortDir }}"
    # type and status were probably already there, let's verify
    fetchLogsParams["type"] = "{{ $page.variables.filterLogType === 'ALL' ? '' : $page.variables.filterLogType }}"
    fetchLogsParams["status"] = "{{ $page.variables.filterLogStatus === 'ALL' ? '' : $page.variables.filterLogStatus }}"
    print("Updated fetchLogs params")
except Exception as e:
    print(f"Error updating fetchLogs: {e}")

# 3. loadActionHistoryChain -> fetchHistory
try:
    fetchHistoryParams = data["chains"]["loadActionHistoryChain"]["actions"]["fetchHistory"]["parameters"]["uriParams"]
    fetchHistoryParams["limit"] = "{{ $page.variables.historyLimit }}"
    fetchHistoryParams["offset"] = "{{ $page.variables.historyOffset }}"
    fetchHistoryParams["sort_col"] = "{{ $page.variables.historySortCol }}"
    fetchHistoryParams["sort_dir"] = "{{ $page.variables.historySortDir }}"
    fetchHistoryParams["action_type"] = "{{ $page.variables.filterHistoryActionType === 'ALL' ? '' : $page.variables.filterHistoryActionType }}"
    print("Updated fetchHistory params")
except Exception as e:
    print(f"Error updating fetchHistory: {e}")


with open(FILE, "w") as f:
    json.dump(data, f, indent=2)

