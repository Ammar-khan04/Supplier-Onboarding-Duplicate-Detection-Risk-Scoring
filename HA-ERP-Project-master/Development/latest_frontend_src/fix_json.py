import json
import sys

file_path = '/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/vb_app_extracted/webApps/supplierportal/flows/item-1/pages/item-1-start-page.json'

with open(file_path, 'r') as f:
    data = json.load(f)

# Add totalBaseWeight variable
data['variables']['totalBaseWeight'] = {
    "type": "number",
    "defaultValue": 0
}

# Update assignData in loadAdminConfigChain to set totalBaseWeight
assignData = data['chains']['loadAdminConfigChain']['actions']['assignData']
assignData['parameters']['$page.variables.totalBaseWeight'] = {
    "source": "{{ $functions.computeBaseRulesTotal($chain.results.fetchRules.body.items || []) }}"
}

# Update onRuleWeightChange event listener - no parameters needed for recompute
data['eventListeners']['onRuleWeightChange'] = {
    "chains": [{
        "chainId": "onRuleWeightChangeChain"
    }]
}

# Update onRuleWeightChangeChain to just recompute totalBaseWeight
data['chains']['onRuleWeightChangeChain'] = {
    "root": "updateTotal",
    "actions": {
        "updateTotal": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.totalBaseWeight": {
                    "source": "{{ $functions.computeBaseRulesTotal($page.variables.riskRules) }}"
                }
            }
        }
    }
}

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2)

print("JSON updated")
