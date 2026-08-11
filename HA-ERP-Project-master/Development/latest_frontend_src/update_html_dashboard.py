import re

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE, "r") as f:
    html = f.read()

# 1. Update dashboard-table
if 'id="dashboard-table"' in html:
    html = html.replace('id="dashboard-table"', 'id="dashboard-table" on-oj-sort="[[ $listeners.onDashboardSort ]]"')
    
    # Add pagination controls below the table
    pagination_html = """
            </oj-table>
            
            <!-- Dashboard Pagination -->
            <div style="display:flex; justify-content: space-between; align-items: center; margin-top: 10px; padding: 0 16px;">
              <span class="sp-muted" style="font-size: 12px;">Showing up to <oj-bind-text value="[[ $variables.dashboardLimit ]]"></oj-bind-text> records. Use filters to narrow down.</span>
              <div>
                <oj-button on-oj-action="[[ $listeners.onDashboardPagePrev ]]" disabled="[[ $variables.dashboardOffset === 0 ]]"><span slot="startIcon" class="oj-ux-ico-arrow-left"></span>Previous</oj-button>
                <oj-button on-oj-action="[[ $listeners.onDashboardPageNext ]]" disabled="[[ $functions.filterRequests($variables.allRequests, $variables.filterBusinessUnit, $variables.filterStatus, $variables.filterRiskLevel, $variables.filterDuplicateLevel).length < $variables.dashboardLimit ]]">Next<span slot="endIcon" class="oj-ux-ico-arrow-right"></span></oj-button>
              </div>
            </div>
"""
    html = html.replace("            </oj-table>", pagination_html)

# Now I need to also ensure the listeners are mapped in item-1-start-page.json
# Wait, I didn't create the event listeners in item-1-start-page.json for onDashboardSort etc.
# I will create a separate script to add event listeners in JSON.

with open(FILE, "w") as f:
    f.write(html)

