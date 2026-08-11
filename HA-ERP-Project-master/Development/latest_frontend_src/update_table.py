import re

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "r") as f:
    html = f.read()

# Define the new grid-based table
new_table = """<div style="display:table; width:100%; border-collapse:collapse; font-size:13px; margin-bottom:16px; background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.05);">
                  <div style="display:table-header-group;">
                    <div style="display:table-row; background:#f1f5f9; border-bottom:2px solid #e2e8f0;">
                      <div style="display:table-cell; padding:10px 12px;text-align:left;font-weight:600;color:#475569;font-size:12px;">RULE CODE</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:left;font-weight:600;color:#475569;font-size:12px;">NAME</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:left;font-weight:600;color:#475569;font-size:12px;">COMPONENT</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:center;font-weight:600;color:#475569;font-size:12px;">WEIGHT</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:center;font-weight:600;color:#475569;font-size:12px;">ACTIVE</div>
                    </div>
                  </div>
                  <div style="display:table-row-group;">
                    <oj-bind-for-each data="[[ $variables.riskRules ]]">
                      <template data-oj-as="rule">
                        <div style="display:table-row; border-bottom:1px solid #e2e8f0;">
                          <div style="display:table-cell; padding:8px 12px;"><code><oj-bind-text value="[[ rule.data.rule_code ]]"></oj-bind-text></code></div>
                          <div style="display:table-cell; padding:8px 12px;"><oj-bind-text value="[[ rule.data.rule_name || rule.data.rule_code ]]"></oj-bind-text></div>
                          <div style="display:table-cell; padding:8px 12px;">
                            <span :class="[[ rule.data.component === 'BASE' ? 'sp-pill medium' : 'sp-pill neutral' ]]">
                              <oj-bind-text value="[[ rule.data.component ]]"></oj-bind-text>
                            </span>
                          </div>
                          <div style="display:table-cell; padding:8px 12px;text-align:center;">
                            <oj-input-number min="0" max="100"
                                   value="{{ $variables.riskRules[rule.index].weight }}"
                                   on-value-changed="[[ function(event){ $listeners.onRuleWeightChange({index: rule.index, value: event.detail.value}) } ]]"
                                   style="width:80px;text-align:center;"></oj-input-number>
                          </div>
                          <div style="display:table-cell; padding:8px 12px;text-align:center;">
                            <button type="button" 
                                    :disabled="[[ rule.data.weight === 0 || rule.data.weight === '0' ]]"
                                    :style="[[ 'border:none; cursor:' + (rule.data.weight === 0 || rule.data.weight === '0' ? 'not-allowed; opacity: 0.7;' : 'pointer;') + ' font-family:inherit; font-weight:600; font-size:12px; padding:6px 12px; border-radius:4px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); transition:all 0.2s; display:inline-flex; align-items:center; gap:6px; margin: 0 auto; width:85px; justify-content:center;' ]]"
                                    :class="[[ rule.data.active === 'Y' && rule.data.weight !== 0 && rule.data.weight !== '0' ? 'sp-btn success' : 'sp-btn neutral' ]]"
                                    on-click="[[ function(event){ $listeners.onRuleActiveClick({index: rule.index}) } ]]">
                              <span :style="[[ 'display:inline-block; width:8px; height:8px; border-radius:50%; background-color: ' + (rule.data.active === 'Y' && rule.data.weight !== 0 && rule.data.weight !== '0' ? '#fff' : '#64748b') ]]"></span>
                              <oj-bind-text value="[[ rule.data.active === 'Y' && rule.data.weight !== 0 && rule.data.weight !== '0' ? 'Active' : 'Inactive' ]]"></oj-bind-text>
                            </button>
                          </div>
                        </div>
                      </template>
                    </oj-bind-for-each>
                  </div>
                </div>"""

# Find the old table. We'll use regex.
old_table_pattern = r'<table style="width:100%;border-collapse:collapse;font-size:13px;">.*?</table>'
html = re.sub(old_table_pattern, new_table, html, flags=re.DOTALL)

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "w") as f:
    f.write(html)

