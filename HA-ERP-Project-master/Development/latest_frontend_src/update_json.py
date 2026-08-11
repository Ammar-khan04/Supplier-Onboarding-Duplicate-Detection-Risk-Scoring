import json

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.json", "r") as f:
    data = json.load(f)

# 1. Variables
data["variables"]["spendBandUpdateBusy"] = {
    "type": "boolean",
    "defaultValue": False
}
data["variables"]["spendBandUpdateMessage"] = {
    "type": "string"
}

# 2. Event Listeners
if "eventListeners" not in data:
    data["eventListeners"] = {}

data["eventListeners"]["onSpendBandChange"] = {
    "chains": [
        {
            "chainId": "onSpendBandChangeChain"
        }
    ]
}
data["eventListeners"]["onSpendBandActiveToggle"] = {
    "chains": [
        {
            "chainId": "onSpendBandActiveToggleChain",
            "parameters": {
                "index": "{{ $event.currentTarget.dataset.index }}",
                "value": "{{ $event.detail.value }}"
            }
        }
    ]
}
data["eventListeners"]["onSaveAllSpendBands"] = {
    "chains": [
        {
            "chainId": "saveAllSpendBandsChain"
        }
    ]
}

# 3. Chains
data["chains"]["onSpendBandChangeChain"] = {
    "root": "clearMessage",
    "actions": {
        "clearMessage": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendBandUpdateMessage": {
                    "source": ""
                }
            }
        }
    }
}

data["chains"]["onSpendBandActiveToggleChain"] = {
    "variables": {
        "index": {
            "type": "number",
            "input": "fromCaller"
        },
        "value": {
            "type": "boolean",
            "input": "fromCaller"
        }
    },
    "root": "updateActive",
    "actions": {
        "updateActive": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendRiskBands[$chain.variables.index].active": {
                    "source": "{{ $chain.variables.value ? 'Y' : 'N' }}"
                }
            },
            "outcomes": {
                "success": "clearMessage"
            }
        },
        "clearMessage": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendBandUpdateMessage": {
                    "source": ""
                }
            }
        }
    }
}

data["chains"]["saveAllSpendBandsChain"] = {
    "root": "setBusy",
    "actions": {
        "setBusy": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendBandUpdateBusy": {
                    "source": True
                },
                "$page.variables.spendBandUpdateMessage": {
                    "source": ""
                }
            },
            "outcomes": {
                "success": "loopBands"
            }
        },
        "loopBands": {
            "module": "vb/action/builtin/forEachAction",
            "parameters": {
                "items": "{{ $page.variables.spendRiskBands }}",
                "actionId": "callUpdateSpendBandREST"
            },
            "outcomes": {
                "success": "setSuccessMessage"
            }
        },
        "callUpdateSpendBandREST": {
            "module": "vb/action/builtin/callChainAction",
            "parameters": {
                "id": "callUpdateSpendBandREST",
                "params": {
                    "band": "{{ $current.data }}"
                }
            },
            "outcomes": {
                "success": "nextOrNot"
            }
        },
        "nextOrNot": {
            "module": "vb/action/builtin/ifAction",
            "parameters": {
                "condition": "{{ $chain.results.callUpdateSpendBandREST === true }}"
            },
            "outcomes": {
                "true": "continueLoop",
                "false": "setFailureMessage"
            }
        },
        "continueLoop": {
            "module": "vb/action/builtin/returnAction"
        },
        "setSuccessMessage": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendBandUpdateMessage": {
                    "source": "Spend risk bands updated successfully!"
                }
            },
            "outcomes": {
                "success": "setNotBusy"
            }
        },
        "setFailureMessage": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendBandUpdateMessage": {
                    "source": "Error updating spend bands. Please try again."
                }
            },
            "outcomes": {
                "success": "setNotBusy"
            }
        },
        "setNotBusy": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.spendBandUpdateBusy": {
                    "source": False
                }
            }
        }
    }
}

data["chains"]["callUpdateSpendBandREST"] = {
    "variables": {
        "band": {
            "type": "any",
            "input": "fromCaller"
        }
    },
    "root": "callRest",
    "actions": {
        "callRest": {
            "module": "vb/action/builtin/restAction",
            "parameters": {
                "endpoint": "ORDS-Specification/updateSpendRiskBand",
                "uriParams": {
                    "band_name": "{{ $chain.variables.band.band_name }}"
                },
                "body": {
                    "min_amount": "{{ $chain.variables.band.min_amount }}",
                    "max_amount": "{{ $chain.variables.band.max_amount }}",
                    "risk_weight_percentage": "{{ $chain.variables.band.risk_weight_percentage }}",
                    "active": "{{ $chain.variables.band.active }}"
                }
            },
            "outcomes": {
                "success": "returnSuccess",
                "failure": "returnFailure"
            }
        },
        "returnSuccess": {
            "module": "vb/action/builtin/returnAction",
            "parameters": {
                "outcome": "success",
                "payload": "{{ true }}"
            }
        },
        "returnFailure": {
            "module": "vb/action/builtin/returnAction",
            "parameters": {
                "outcome": "success",
                "payload": "{{ false }}"
            }
        }
    }
}

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.json", "w") as f:
    json.dump(data, f, indent=2)

