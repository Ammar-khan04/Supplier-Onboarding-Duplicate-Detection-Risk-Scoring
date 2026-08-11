import json

file_path = '/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/vb_app_extracted/webApps/supplierportal/flows/item-1/pages/item-1-start-page.json'

with open(file_path, 'r') as f:
    data = json.load(f)

# 1. Add variable
data['variables']['riskBands'] = {
    "type": "any[]",
    "defaultValue": []
}
data['variables']['totalBandsValid'] = {
    "type": "boolean",
    "defaultValue": True
}
data['variables']['bandUpdateBusy'] = {
    "type": "boolean",
    "defaultValue": False
}
data['variables']['bandUpdateMessage'] = {
    "type": "string",
    "defaultValue": ""
}

# 2. Add to loadAdminConfigChain
# Insert fetchBands after fetchCountries
actions = data['chains']['loadAdminConfigChain']['actions']

# Change fetchCountries outcome to point to fetchBands instead of assignData
actions['fetchCountries']['outcomes']['success'] = 'fetchBands'

actions['fetchBands'] = {
    "module": "vb/action/builtin/restAction",
    "parameters": {
        "endpoint": "ORDS-Specification/getRiskBands",
        "uriParams": {
            "actor_subject_id": "{{ $functions.actorSubjectId($page.variables.currentRole) }}",
            "actor_roles": "{{ $page.variables.currentRole }}"
        }
    },
    "outcomes": {
        "success": "assignData",
        "failure": "loadError"
    }
}

# Update assignData to include riskBands
actions['assignData']['parameters']['$page.variables.riskBands'] = {
    "source": "{{ $chain.results.fetchBands.body.items || [] }}"
}
actions['assignData']['parameters']['$page.variables.totalBandsValid'] = {
    "source": "{{ $functions.computeRiskBandsValid($chain.results.fetchBands.body.items || []) }}"
}

# 3. Add Event Listeners
data['eventListeners']['onBandScoreChange'] = {
    "chains": [{ "chainId": "onBandScoreChangeChain" }]
}
data['eventListeners']['onSaveAllBands'] = {
    "chains": [{ "chainId": "saveAllBandsChain" }]
}

# 4. Add Action Chains
data['chains']['onBandScoreChangeChain'] = {
    "root": "updateValid",
    "actions": {
        "updateValid": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.totalBandsValid": {
                    "source": "{{ $functions.computeRiskBandsValid($page.variables.riskBands) }}"
                }
            }
        }
    }
}

data['chains']['saveAllBandsChain'] = {
    "root": "setBusy",
    "actions": {
        "setBusy": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.bandUpdateBusy": { "source": "{{ true }}" },
                "$page.variables.bandUpdateMessage": { "source": "" }
            },
            "outcomes": { "success": "loopBands" }
        },
        "loopBands": {
            "module": "vb/action/builtin/forEachAction",
            "parameters": {
                "items": "{{ $page.variables.riskBands }}",
                "actionId": "callPUT"
            },
            "outcomes": { "success": "saveSuccess" }
        },
        "callPUT": {
            "module": "vb/action/builtin/restAction",
            "parameters": {
                "endpoint": "ORDS-Specification/updateRiskScoreBand",
                "uriParams": {
                    "risk_level": "{{ $current.data.risk_level }}",
                    "actor_subject_id": "{{ $functions.actorSubjectId($page.variables.currentRole) }}",
                    "actor_roles": "{{ $page.variables.currentRole }}"
                },
                "body": {
                    "min_score": "{{ $current.data.min_score }}",
                    "max_score": "{{ $current.data.max_score }}"
                }
            }
        },
        "saveSuccess": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.bandUpdateBusy": { "source": "{{ false }}" },
                "$page.variables.bandUpdateMessage": { "source": "Risk bands updated successfully." }
            },
            "outcomes": { "success": "reload" }
        },
        "reload": {
            "module": "vb/action/builtin/callChainAction",
            "parameters": { "id": "loadAdminConfigChain" }
        }
    }
}

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2)

print("JSON updated")
