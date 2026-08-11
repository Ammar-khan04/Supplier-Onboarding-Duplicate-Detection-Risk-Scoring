import re
import json

HTML_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"
JSON_FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

# Update HTML
with open(HTML_FILE, "r") as f:
    html = f.read()

# 1. formatCurrencyWithUSD
html = html.replace(
    "$functions.formatCurrency($variables.reviewDetail.expected_annual_spend, $variables.reviewDetail.currency_code)",
    "$functions.formatCurrencyWithUSD($variables.reviewDetail.expected_annual_spend, $variables.reviewDetail.currency_code, $variables.currencyRates)"
)

# 2. Add data-index to onRuleWeightChange
html = html.replace(
    'on-value-changed="[[ $listeners.onRuleWeightChange ]]"',
    'data-index="[[ rule.index ]]"\n                                   on-value-changed="[[ $listeners.onRuleWeightChange ]]"'
)

# 3. Spend Bands Validation UI
old_spend_save = """                <div style="margin-top:16px; display:flex; justify-content:flex-end; align-items:center; background:#f8fafc; padding:12px 16px; border-radius:8px; border:1px solid #e2e8f0;">
                  <button type="button" class="sp-btn success"
                          :disabled="[[ $variables.spendBandUpdateBusy ]]"
                          on-click="[[ $listeners.onSaveAllSpendBands ]]">"""

new_spend_save = """                <div style="margin-top:16px; display:flex; justify-content:space-between; align-items:center; background:#f8fafc; padding:12px 16px; border-radius:8px; border:1px solid #e2e8f0;">
                  <div style="font-size:14px;">
                    <oj-bind-if test="[[ $variables.totalSpendBandsValid ]]">
                      <span style="color:#15803d;font-weight:bold;">✔ Spend bands are continuous</span>
                    </oj-bind-if>
                    <oj-bind-if test="[[ !$variables.totalSpendBandsValid ]]">
                      <span style="color:#b91c1c;font-weight:bold;">⚠ Bands must be continuous with no gaps or overlaps</span>
                    </oj-bind-if>
                  </div>
                  <button type="button" class="sp-btn success"
                          :disabled="[[ $variables.spendBandUpdateBusy || !$variables.totalSpendBandsValid ]]"
                          on-click="[[ $listeners.onSaveAllSpendBands ]]">"""

html = html.replace(old_spend_save, new_spend_save)

with open(HTML_FILE, "w") as f:
    f.write(html)

# Update JSON
with open(JSON_FILE, "r") as f:
    data = json.load(f)

# 1. variable totalSpendBandsValid
data["variables"]["totalSpendBandsValid"] = {
    "type": "boolean",
    "defaultValue": True
}

# 2. Modify onRuleWeightChange listener
if "chains" in data["eventListeners"]["onRuleWeightChange"]:
    data["eventListeners"]["onRuleWeightChange"]["chains"][0]["parameters"] = {
        "index": "{{ $event.currentTarget.dataset.index }}"
    }

# 3. Modify onRuleWeightChangeChain
data["chains"]["onRuleWeightChangeChain"] = {
    "variables": {
        "index": {
            "type": "number",
            "input": "fromCaller"
        }
    },
    "root": "checkWeight",
    "actions": {
        "checkWeight": {
            "module": "vb/action/builtin/ifAction",
            "parameters": {
                "condition": "{{ $chain.variables.index !== undefined && $page.variables.riskRules[$chain.variables.index].weight === 0 }}"
            },
            "outcomes": {
                "true": "setInactive",
                "false": "updateTotal"
            }
        },
        "setInactive": {
            "module": "vb/action/builtin/assignVariablesAction",
            "parameters": {
                "$page.variables.riskRules[$chain.variables.index].active": {
                    "source": "N"
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

# 4. Modify onSpendBandChangeChain
data["chains"]["onSpendBandChangeChain"]["actions"]["clearMessage"]["outcomes"] = {
    "success": "updateValid"
}
data["chains"]["onSpendBandChangeChain"]["actions"]["updateValid"] = {
    "module": "vb/action/builtin/assignVariablesAction",
    "parameters": {
        "$page.variables.totalSpendBandsValid": {
            "source": "{{ $functions.computeSpendBandsValid($page.variables.spendRiskBands) }}"
        }
    }
}

with open(JSON_FILE, "w") as f:
    json.dump(data, f, indent=2)

