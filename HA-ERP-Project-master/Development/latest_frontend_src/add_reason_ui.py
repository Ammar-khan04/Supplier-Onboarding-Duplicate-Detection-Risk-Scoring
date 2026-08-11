import re

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "r") as f:
    html = f.read()

# Add the warning banner below the Read-only notice banner in New / Correction Request view
target = """          <!-- Read-only notice banner -->
          <oj-bind-if test="[[ $variables.currentRequestReadOnly ]]">
            <div style="margin:0 0 16px 0; padding:12px 16px; background:#fff3cd; border-left:4px solid #f59e0b; border-radius:6px; color:#92400e;">
              🔒 <strong>Read-only view</strong> — This request (<oj-bind-text value="[[ $variables.currentRequestStatus ]]"></oj-bind-text>) cannot be edited. To create a new request, click <strong>New Supplier Request</strong>.
            </div>
          </oj-bind-if>"""

insertion = """
          <!-- Correction Required / Rejected Reviewer Comment -->
          <oj-bind-if test="[[ ($variables.currentRequestStatus === 'CORRECTION_REQUIRED' || $variables.currentRequestStatus === 'REJECTED') && $variables.newRequest.latest_correction_reason ]]">
            <div style="margin:0 0 16px 0; padding:12px 16px; background:#fee2e2; border-left:4px solid #ef4444; border-radius:6px; color:#991b1b;">
              ⚠️ <strong>Reviewer Comment:</strong> <oj-bind-text value="[[ $variables.newRequest.latest_correction_reason ]]"></oj-bind-text>
            </div>
          </oj-bind-if>"""

html = html.replace(target, target + insertion)

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.html", "w") as f:
    f.write(html)

