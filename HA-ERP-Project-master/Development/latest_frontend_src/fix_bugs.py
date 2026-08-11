import re
import json

JS_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.js"
JSON_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"
HTML_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

# --- 1. JS Fixes ---
with open(JS_FILE, "r") as f:
    js = f.read()

new_spend_logic = """
      if (i > 0) {
        var prevMax = sorted[i - 1].max_amount != null && sorted[i - 1].max_amount !== '' ? Number(sorted[i - 1].max_amount) : null;
        if (prevMax == null) return false; 
        var gap = min - prevMax;
        if (gap < 0 || gap > 1.01) return false;
      }
"""

js = re.sub(r'      if \(i > 0\) \{\s+var prevMax = sorted\[i - 1\].max_amount \!= null && sorted\[i - 1\].max_amount \!\=\= \'\' \? Number\(sorted\[i - 1\].max_amount\) : null;\s+if \(prevMax == null\) return false;\s+if \(Math\.abs\(prevMax - min\) > 0\.01\) return false;\s+\}', new_spend_logic, js)

set_rule_inactive = """
  PageModule.prototype.setRuleInactiveIfZero = function(index, value, rules) {
    if (Number(value) !== 0) return rules;
    var updated = (rules || []).slice();
    if (updated[index] && updated[index].active !== 'N') {
      updated[index] = Object.assign({}, updated[index]);
      updated[index].active = 'N';
    }
    return updated;
  };
"""

js = js.replace("return PageModule;", set_rule_inactive + "\n  return PageModule;")

with open(JS_FILE, "w") as f:
    f.write(js)

# --- 2. JSON Fixes ---
with open(JSON_FILE, "r") as f:
    data = json.load(f)

# Update event listener
data["eventListeners"]["onRuleWeightChange"]["chains"][0]["parameters"] = {
    "index": "{{ $event.currentTarget.dataset.index }}",
    "value": "{{ $event.detail.value }}"
}

# Update chain
data["chains"]["onRuleWeightChangeChain"] = {
    "variables": {
        "index": {
            "type": "number",
            "input": "fromCaller"
        },
        "value": {
            "type": "any",
            "input": "fromCaller"
        }
    },
    "root": "checkAndSetInactive",
    "actions": {
        "checkAndSetInactive": {
            "module": "vb/action/builtin/callModuleFunctionAction",
            "parameters": {
                "module": "[[ $functions ]]",
                "functionName": "setRuleInactiveIfZero",
                "params": [
                    "{{ $chain.variables.index }}",
                    "{{ $chain.variables.value }}",
                    "{{ $page.variables.riskRules }}"
                ]
            },
            "outcomes": {
                "success": "assignRules"
            }
        },
        "assignRules": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.riskRules": {
                    "source": "{{ $chain.results.checkAndSetInactive }}"
                }
            },
            "outcomes": {
                "success": "updateTotal"
            }
        },
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

with open(JSON_FILE, "w") as f:
    json.dump(data, f, indent=2)

