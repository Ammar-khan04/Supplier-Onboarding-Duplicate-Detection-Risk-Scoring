import re

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "r") as f:
    html = f.read()

# Define the section block
section_2 = """            <!-- ── SECTION 2: Business Justification ── -->
            <div class="sp-section-inner">
              <h3>Business Justification</h3>
              <div style="font-size:13px; color:#334155; line-height:1.6; background:#f8fafc; border:1px solid #e2e8f0; border-radius:7px; padding:10px 12px;">
                <oj-bind-text value="[[ $variables.reviewDetail.business_justification || '(none provided)' ]]"></oj-bind-text>
              </div>
            </div>

            <hr class="sp-divider"/>

"""

# Remove section 2 from its original place
html = html.replace(section_2, "")

# Find section 8 and insert section 2 right before it
section_8 = "            <!-- ── SECTION 8: Justification Risk Adjustment ── -->"
html = html.replace(section_8, section_2 + section_8)

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "w") as f:
    f.write(html)

