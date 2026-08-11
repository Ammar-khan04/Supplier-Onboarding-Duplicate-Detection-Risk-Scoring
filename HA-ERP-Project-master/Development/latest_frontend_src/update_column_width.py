import re

FILE = "/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/latest_frontend_src/webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE, "r") as f:
    html = f.read()

# 1. Dashboard
html = html.replace(
    """{"headerText": "Request / Supplier", "field": "supplier_name", "sortable": "enabled", "template": "supplierTemplate"},""",
    """{"headerText": "Request / Supplier", "field": "supplier_name", "sortable": "enabled", "template": "supplierTemplate", "width": "300px"},"""
)

# 2. Integration Logs
html = html.replace(
    """{"headerText": "Request / Supplier", "field": "request_number", "sortable": "enabled", "template": "requestTemplate"},""",
    """{"headerText": "Request / Supplier", "field": "request_number", "sortable": "enabled", "template": "requestTemplate", "width": "300px"},"""
)

# 3. Action History
html = html.replace(
    """{"headerText": "Request / Details", "field": "request_number", "sortable": "enabled", "template": "requestTemplate"},""",
    """{"headerText": "Request / Details", "field": "request_number", "sortable": "enabled", "template": "requestTemplate", "width": "300px"},"""
)

with open(FILE, "w") as f:
    f.write(html)
