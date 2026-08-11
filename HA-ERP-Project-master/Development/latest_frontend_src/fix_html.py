import re
import os

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "r") as f:
    html = f.read()

# Replace RISK SCORE BANDS table
risk_table_pattern = r'<table style="width:100%; border-collapse:collapse; margin-bottom:16px; background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 1px 3px rgba\(0,0,0,0\.05\);">\s*<thead>.*?<tbody>(.*?)</tbody>\s*</table>'

def risk_table_replacer(match):
    tbody_content = match.group(1)
    
    # Replace tr, th, td
    # But for tbody_content, we need to convert tr to div and td to div
    tbody_content = tbody_content.replace('<tr style="border-bottom:1px solid #f1f5f9;">', '<div style="display:table-row; border-bottom:1px solid #f1f5f9;">')
    tbody_content = tbody_content.replace('</tr>', '</div>')
    
    tbody_content = re.sub(r'<td style="([^"]*)">', r'<div style="display:table-cell; \1">', tbody_content)
    tbody_content = tbody_content.replace('</td>', '</div>')
    
    res = f"""<div style="display:table; width:100%; border-collapse:collapse; margin-bottom:16px; background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.05);">
                  <div style="display:table-header-group;">
                    <div style="display:table-row; background:#f1f5f9; border-bottom:2px solid #e2e8f0;">
                      <div style="display:table-cell; padding:10px 12px;text-align:left;font-weight:600;color:#475569;font-size:12px;">RISK LEVEL</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:center;font-weight:600;color:#475569;font-size:12px;">MIN SCORE</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:center;font-weight:600;color:#475569;font-size:12px;">MAX SCORE</div>
                    </div>
                  </div>
                  <div style="display:table-row-group;">{tbody_content}</div>
                </div>"""
    return res

html = re.sub(risk_table_pattern, risk_table_replacer, html, count=1, flags=re.DOTALL)

# Delete duplicate Spend Bands section and replace the remaining one
parts = html.split('<!-- ── PANEL 1C: High Expected Spend Bands ── -->')
# There are 3 parts (so 2 instances).
# We want parts[0] + NEW_SPEND_BANDS + the rest after the second instance.
# Let's find where PANEL 1D starts.
idx_1d = html.find('<!-- ── PANEL 1D: Currency Exchange Rates ── -->')
if idx_1d == -1:
    idx_1d = html.find('<!-- ── PANEL 1E') or html.find('</section>') # fallback

# Find the hr just before PANEL 1D
hr_idx = html.rfind('<hr class="sp-divider"/>', 0, idx_1d)

rest_of_html = html[hr_idx:]

new_spend_bands = """<!-- ── PANEL 1C: High Expected Spend Bands ── -->
            <div class="sp-section-inner">
              <h3 style="text-transform:uppercase;color:#475569;font-size:13px;letter-spacing:1px;margin-bottom:12px;">High Expected Spend Bands</h3>
              <p class="sp-muted" style="margin-bottom:16px;">
                Define spend tiers and the percentage of the High Expected Spend rule's maximum weight to apply. Base currency is USD.
              </p>

              <oj-bind-if test="[[ $variables.spendRiskBands.length > 0 ]]">
                <div style="display:table; width:100%; border-collapse:collapse; margin-bottom:16px; background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.05);">
                  <div style="display:table-header-group;">
                    <div style="display:table-row; background:#f1f5f9; border-bottom:2px solid #e2e8f0;">
                      <div style="display:table-cell; padding:10px 12px;text-align:left;font-weight:600;color:#475569;font-size:12px;">BAND NAME</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:right;font-weight:600;color:#475569;font-size:12px;">MIN AMOUNT (USD)</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:right;font-weight:600;color:#475569;font-size:12px;">MAX AMOUNT (USD)</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:center;font-weight:600;color:#475569;font-size:12px;">RISK WEIGHT %</div>
                      <div style="display:table-cell; padding:10px 12px;text-align:center;font-weight:600;color:#475569;font-size:12px;">STATUS</div>
                    </div>
                  </div>
                  <div style="display:table-row-group;">
                    <oj-bind-for-each data="[[ $variables.spendRiskBands ]]">
                      <template data-oj-as="band">
                        <div style="display:table-row; border-bottom:1px solid #f1f5f9;">
                          <div style="display:table-cell; padding:8px 12px;font-weight:500;">
                            <oj-bind-text value="[[ band.data.band_name ]]"></oj-bind-text>
                          </div>
                          <div style="display:table-cell; padding:8px 12px;text-align:right;">
                            <oj-input-number min="0" 
                                   value="{{ $variables.spendRiskBands[band.index].min_amount }}"
                                   on-value-changed="[[ $listeners.onSpendBandChange ]]"
                                   style="width:120px;text-align:right;"></oj-input-number>
                          </div>
                          <div style="display:table-cell; padding:8px 12px;text-align:right;">
                            <oj-input-number min="0" 
                                   value="{{ $variables.spendRiskBands[band.index].max_amount }}"
                                   on-value-changed="[[ $listeners.onSpendBandChange ]]"
                                   style="width:120px;text-align:right;"
                                   placeholder="No Limit"></oj-input-number>
                          </div>
                          <div style="display:table-cell; padding:8px 12px;text-align:center;">
                            <oj-input-number min="0" max="100"
                                   value="{{ $variables.spendRiskBands[band.index].risk_weight_percentage }}"
                                   on-value-changed="[[ $listeners.onSpendBandChange ]]"
                                   style="width:80px;text-align:center;"></oj-input-number>
                          </div>
                          <div style="display:table-cell; padding:8px 12px;text-align:center;">
                            <oj-switch value="[[ $variables.spendRiskBands[band.index].active === 'Y' ]]"
                                       data-index="[[ band.index ]]"
                                       on-value-changed="[[ $listeners.onSpendBandActiveToggle ]]"></oj-switch>
                          </div>
                        </div>
                      </template>
                    </oj-bind-for-each>
                  </div>
                </div>
                
                <div style="margin-top:16px; display:flex; justify-content:flex-end; align-items:center; background:#f8fafc; padding:12px 16px; border-radius:8px; border:1px solid #e2e8f0;">
                  <button type="button" class="sp-btn success"
                          :disabled="[[ $variables.spendBandUpdateBusy ]]"
                          on-click="[[ $listeners.onSaveAllSpendBands ]]">
                    <oj-bind-if test="[[ !$variables.spendBandUpdateBusy ]]">Save Spend Bands</oj-bind-if>
                    <oj-bind-if test="[[ $variables.spendBandUpdateBusy ]]">Saving…</oj-bind-if>
                  </button>
                </div>
              </oj-bind-if>

              <oj-bind-if test="[[ $variables.spendBandUpdateMessage ]]">
                <div :class="[[ $variables.spendBandUpdateMessage.indexOf('Error') === -1 ? 'sp-val-result val-ok' : 'sp-val-result val-fail' ]]" style="margin-top:12px;">
                  <oj-bind-text value="[[ $variables.spendBandUpdateMessage ]]"></oj-bind-text>
                </div>
              </oj-bind-if>
            </div>

            """

html = parts[0] + new_spend_bands + rest_of_html

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "w") as f:
    f.write(html)
