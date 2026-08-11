import re

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.js"

with open(FILE, "r") as f:
    js = f.read()

# Add getRequestStatusClass
new_fn = """
  PageModule.prototype.getRequestStatusClass = function(status) {
    if (!status) return 'sp-pill neutral';
    switch (status.toUpperCase()) {
      case 'DRAFT': return 'sp-pill neutral';
      case 'SUBMITTED': return 'sp-pill neutral';
      case 'UNDER_REVIEW': return 'sp-pill medium';
      case 'APPROVED': return 'sp-pill low';
      case 'REJECTED': return 'sp-pill high';
      case 'CORRECTION_REQUIRED': return 'sp-pill high';
      case 'SUBMITTED_TO_FUSION': return 'sp-pill neutral';
      case 'CREATED_IN_FUSION': return 'sp-pill low';
      case 'INTEGRATION_FAILED': return 'sp-pill high';
      case 'VALIDATION_FAILED': return 'sp-pill high';
      case 'DUPLICATE': return 'sp-pill high';
      default: return 'sp-pill neutral';
    }
  };
"""

if "getRequestStatusClass" not in js:
    js = js.replace("  PageModule.prototype.getLogStatusClass = function(status) {", new_fn + "\n  PageModule.prototype.getLogStatusClass = function(status) {")

with open(FILE, "w") as f:
    f.write(js)
