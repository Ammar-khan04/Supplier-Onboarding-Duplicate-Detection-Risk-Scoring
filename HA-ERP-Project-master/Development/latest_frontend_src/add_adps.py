import json

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(FILE, "r") as f:
    data = json.load(f)

# Add ADPs for logs and history
data["variables"]["integrationLogsADP"] = {
    "type": "vb/ArrayDataProvider2",
    "defaultValue": {
        "data": "{{ $variables.integrationLogs }}",
        "keyAttributes": "job_id"
    }
}

data["variables"]["actionHistoryADP"] = {
    "type": "vb/ArrayDataProvider2",
    "defaultValue": {
        "data": "{{ $variables.actionHistory }}",
        "keyAttributes": "history_id"
    }
}

# Add action chains for pagination and sorting
new_chains = {
    "onDashboardSortChain": {
        "variables": {
            "header": {"type": "string", "input": "fromCaller"},
            "direction": {"type": "string", "input": "fromCaller"}
        },
        "root": "assignSort",
        "actions": {
            "assignSort": {
                "module": "vb/action/builtin/assignVariablesAction",
                "parameters": {
                    "$page.variables.dashboardSortCol": {"source": "{{ $variables.header }}"},
                    "$page.variables.dashboardSortDir": {"source": "{{ $variables.direction === 'ascending' ? 'asc' : 'desc' }}"},
                    "$page.variables.dashboardOffset": {"source": 0}
                },
                "outcomes": {"success": "reload"}
            },
            "reload": {
                "module": "vb/action/builtin/callChainAction",
                "parameters": {"id": "loadDashboardDataChain"}
            }
        }
    },
    "onDashboardPageChain": {
        "variables": {
            "direction": {"type": "string", "input": "fromCaller"}
        },
        "root": "assignOffset",
        "actions": {
            "assignOffset": {
                "module": "vb/action/builtin/assignVariablesAction",
                "parameters": {
                    "$page.variables.dashboardOffset": {"source": "{{ $variables.direction === 'next' ? $page.variables.dashboardOffset + $page.variables.dashboardLimit : Math.max(0, $page.variables.dashboardOffset - $page.variables.dashboardLimit) }}"}
                },
                "outcomes": {"success": "reload"}
            },
            "reload": {
                "module": "vb/action/builtin/callChainAction",
                "parameters": {"id": "loadDashboardDataChain"}
            }
        }
    },
    
    "onLogsSortChain": {
        "variables": {
            "header": {"type": "string", "input": "fromCaller"},
            "direction": {"type": "string", "input": "fromCaller"}
        },
        "root": "assignSort",
        "actions": {
            "assignSort": {
                "module": "vb/action/builtin/assignVariablesAction",
                "parameters": {
                    "$page.variables.logsSortCol": {"source": "{{ $variables.header }}"},
                    "$page.variables.logsSortDir": {"source": "{{ $variables.direction === 'ascending' ? 'asc' : 'desc' }}"},
                    "$page.variables.logsOffset": {"source": 0}
                },
                "outcomes": {"success": "reload"}
            },
            "reload": {
                "module": "vb/action/builtin/callChainAction",
                "parameters": {"id": "loadIntegrationLogsChain"}
            }
        }
    },
    "onLogsPageChain": {
        "variables": {
            "direction": {"type": "string", "input": "fromCaller"}
        },
        "root": "assignOffset",
        "actions": {
            "assignOffset": {
                "module": "vb/action/builtin/assignVariablesAction",
                "parameters": {
                    "$page.variables.logsOffset": {"source": "{{ $variables.direction === 'next' ? $page.variables.logsOffset + $page.variables.logsLimit : Math.max(0, $page.variables.logsOffset - $page.variables.logsLimit) }}"}
                },
                "outcomes": {"success": "reload"}
            },
            "reload": {
                "module": "vb/action/builtin/callChainAction",
                "parameters": {"id": "loadIntegrationLogsChain"}
            }
        }
    },
    
    "onHistorySortChain": {
        "variables": {
            "header": {"type": "string", "input": "fromCaller"},
            "direction": {"type": "string", "input": "fromCaller"}
        },
        "root": "assignSort",
        "actions": {
            "assignSort": {
                "module": "vb/action/builtin/assignVariablesAction",
                "parameters": {
                    "$page.variables.historySortCol": {"source": "{{ $variables.header }}"},
                    "$page.variables.historySortDir": {"source": "{{ $variables.direction === 'ascending' ? 'asc' : 'desc' }}"},
                    "$page.variables.historyOffset": {"source": 0}
                },
                "outcomes": {"success": "reload"}
            },
            "reload": {
                "module": "vb/action/builtin/callChainAction",
                "parameters": {"id": "loadActionHistoryChain"}
            }
        }
    },
    "onHistoryPageChain": {
        "variables": {
            "direction": {"type": "string", "input": "fromCaller"}
        },
        "root": "assignOffset",
        "actions": {
            "assignOffset": {
                "module": "vb/action/builtin/assignVariablesAction",
                "parameters": {
                    "$page.variables.historyOffset": {"source": "{{ $variables.direction === 'next' ? $page.variables.historyOffset + $page.variables.historyLimit : Math.max(0, $page.variables.historyOffset - $page.variables.historyLimit) }}"}
                },
                "outcomes": {"success": "reload"}
            },
            "reload": {
                "module": "vb/action/builtin/callChainAction",
                "parameters": {"id": "loadActionHistoryChain"}
            }
        }
    }
}

data["chains"].update(new_chains)

# Update existing filter chains to reset offset to 0 when filters change.
filter_chains = [
    "onFilterStatusChangeChain", "onFilterBusinessUnitChangeChain", "onFilterRiskLevelChangeChain",
    "onFilterDuplicateLevelChangeChain", "onSearchTermChangeChain"
]
for c in filter_chains:
    if c in data["chains"]:
        # Add offset reset to 0 in the assign action
        for action_name, action in data["chains"][c]["actions"].items():
            if action["module"] == "vb/action/builtin/assignVariablesAction":
                action["parameters"]["$page.variables.dashboardOffset"] = {"source": 0}

log_filter_chains = ["onFilterLogStatusChangeChain", "onFilterLogTypeChangeChain"]
for c in log_filter_chains:
    if c in data["chains"]:
        for action_name, action in data["chains"][c]["actions"].items():
            if action["module"] == "vb/action/builtin/assignVariablesAction":
                action["parameters"]["$page.variables.logsOffset"] = {"source": 0}

hist_filter_chains = ["onFilterHistoryActionTypeChangeChain", "onFilterHistoryRequestIdInputChain"]
for c in hist_filter_chains:
    if c in data["chains"]:
        for action_name, action in data["chains"][c]["actions"].items():
            if action["module"] == "vb/action/builtin/assignVariablesAction":
                action["parameters"]["$page.variables.historyOffset"] = {"source": 0}

with open(FILE, "w") as f:
    json.dump(data, f, indent=2)

