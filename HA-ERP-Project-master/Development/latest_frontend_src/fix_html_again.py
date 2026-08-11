import re

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "r") as f:
    html = f.read()

# Replace the data-index and on-value-changed
# Current:
# data-index="[[ rule.index ]]"
# on-value-changed="[[ $listeners.onRuleWeightChange ]]"

# To:
# on-value-changed="[[ function(event){ $listeners.onRuleWeightChange({index: rule.index, value: event.detail.value}) } ]]"

html = html.replace('data-index="[[ rule.index ]]"\n                                   on-value-changed="[[ $listeners.onRuleWeightChange ]]"', 
                    'on-value-changed="[[ function(event){ $listeners.onRuleWeightChange({index: rule.index, value: event.detail.value}) } ]]"')

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "w") as f:
    f.write(html)
