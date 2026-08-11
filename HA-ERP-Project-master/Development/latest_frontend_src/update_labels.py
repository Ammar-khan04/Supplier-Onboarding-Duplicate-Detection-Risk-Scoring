import re

FILE_JS = "/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/latest_frontend_src/webApps/supplierportal/flows/item-1/pages/item-1-start-page.js"

with open(FILE_JS, "r") as f:
    js = f.read()

# 1. Enhance getActionTypeBadgeClass
action_old = """  PageModule.prototype.getActionTypeBadgeClass = function(actionType) {
    if (!actionType) return 'sp-pill neutral';
    var t = actionType.toUpperCase();
    if (t === 'APPROVED' || t === 'CREATED_IN_FUSION') return 'sp-pill low';
    if (t === 'REJECTED' || t === 'DUPLICATE')         return 'sp-pill high';
    if (t === 'SUBMITTED' || t === 'SUBMIT')           return 'sp-pill medium';
    if (t.indexOf('CORRECTION') !== -1)                return 'sp-pill medium';
    if (t.indexOf('REVIEW') !== -1)                    return 'sp-pill medium';
    return 'sp-pill neutral';
  };"""

action_new = """  PageModule.prototype.getActionTypeBadgeClass = function(actionType) {
    if (!actionType) return 'sp-pill neutral';
    var t = actionType.toUpperCase();
    if (t === 'APPROVED' || t === 'CREATED_IN_FUSION' || t === 'VALIDATION_PASSED') return 'sp-pill low';
    if (t === 'REJECTED' || t === 'DUPLICATE' || t === 'VALIDATION_FAILED')         return 'sp-pill high';
    if (t === 'SUBMITTED' || t === 'SUBMIT')           return 'sp-pill medium';
    if (t.indexOf('CORRECTION') !== -1)                return 'sp-pill medium';
    if (t.indexOf('REVIEW') !== -1)                    return 'sp-pill medium';
    if (t.indexOf('FAILED') !== -1)                    return 'sp-pill high';
    if (t.indexOf('RISK_ASSESSED') !== -1)             return 'sp-pill medium';
    return 'sp-pill neutral';
  };"""
js = js.replace(action_old, action_new)

# 2. Add getIntegrationTypeClass
integ_fn = """
  PageModule.prototype.getIntegrationTypeClass = function(type) {
    if (!type) return 'sp-pill neutral';
    var t = type.toUpperCase();
    if (t === 'AI_EXPLANATION') return 'sp-pill medium';
    if (t === 'FUSION_CREATE')  return 'sp-pill low';
    if (t === 'SUPPLIER_SYNC')  return 'sp-pill neutral';
    return 'sp-pill neutral';
  };
"""
if "getIntegrationTypeClass" not in js:
    js = js.replace("  PageModule.prototype.formatIntegrationType = function(type) {", integ_fn + "\n  PageModule.prototype.formatIntegrationType = function(type) {")

with open(FILE_JS, "w") as f:
    f.write(js)

FILE_HTML = "/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/latest_frontend_src/webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE_HTML, "r") as f:
    html = f.read()

type_old = """                <template slot="typeTemplate" data-oj-as="cell">
                  <span class="sp-pill neutral" style="font-size:10px;">
                    <oj-bind-text value="[[ (cell.row.integration_type || '—').replace(/_/g, ' ') ]]"></oj-bind-text>
                  </span>
                </template>"""

type_new = """                <template slot="typeTemplate" data-oj-as="cell">
                  <span :class="[[ $functions.getIntegrationTypeClass(cell.row.integration_type) ]]" style="font-size:10px;">
                    <oj-bind-text value="[[ (cell.row.integration_type || '—').replace(/_/g, ' ') ]]"></oj-bind-text>
                  </span>
                </template>"""
html = html.replace(type_old, type_new)

with open(FILE_HTML, "w") as f:
    f.write(html)
