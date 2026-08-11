import re

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE, "r") as f:
    html = f.read()

# 1. Update columns
columns_target = """                      columns='[
                        {"headerText": "Request / Supplier", "template": "supplierTemplate"},
                        {"headerText": "Status", "template": "statusTemplate"},
                        {"headerText": "Risk", "template": "riskTemplate"},
                        {"headerText": "Duplicate", "template": "duplicateTemplate"},
                        {"headerText": "Fusion Result", "field": "fusion_supplier_number"},
                        {"headerText": "Actions", "template": "actionTemplate"}
                      ]'"""
columns_new = """                      columns='[
                        {"headerText": "Request / Supplier", "field": "supplier_name", "sortable": "enabled", "template": "supplierTemplate"},
                        {"headerText": "Status", "field": "status", "sortable": "enabled", "template": "statusTemplate"},
                        {"headerText": "Risk", "field": "risk_level", "sortable": "enabled", "template": "riskTemplate"},
                        {"headerText": "Duplicate", "field": "duplicate_level", "sortable": "enabled", "template": "duplicateTemplate"},
                        {"headerText": "Fusion Result", "field": "fusion_supplier_number", "sortable": "enabled"},
                        {"headerText": "Actions", "sortable": "disabled", "template": "actionTemplate"}
                      ]'"""
html = html.replace(columns_target, columns_new)

# 2. Update statusTemplate
status_target = """              <template slot="statusTemplate" data-oj-as="cell">
                <span class="sp-pill neutral"><oj-bind-text value="[[ cell.row.status ]]"></oj-bind-text></span>
              </template>"""
status_new = """              <template slot="statusTemplate" data-oj-as="cell">
                <span :class="[[ $functions.getRequestStatusClass(cell.row.status) ]]"><oj-bind-text value="[[ cell.row.status ]]"></oj-bind-text></span>
              </template>"""
html = html.replace(status_target, status_new)

# 3. Add search bar to sp-filters
filters_target = """          <div class="sp-filters">
            <div>
              <label class="field-label">Business Unit</label>"""
filters_new = """          <div class="sp-filters">
            <div style="flex: 0 0 200px;">
              <label class="field-label">Search</label>
              <input type="text"
                     :value="[[ $variables.filterSearchTerm ]]"
                     on-input="[[ $listeners.onSearchTermChange ]]"
                     placeholder="Name or Request #..."
                     style="width:100%;border:1px solid #cbd5e1;border-radius:7px;padding:7px 9px;font-size:12px;"/>
            </div>
            <div>
              <label class="field-label">Business Unit</label>"""
html = html.replace(filters_target, filters_new)

with open(FILE, "w") as f:
    f.write(html)
