import json

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(FILE, "r") as f:
    data = json.load(f)

# Fix fetchRequestsParams
try:
    fetchRequestsParams = data["chains"]["loadDashboardDataChain"]["actions"]["fetchRequests"]["parameters"]["uriParams"]
    
    # If the expression doesn't have an empty string fallback, it might send the literal 'undefined' if it's evaluated as such by VB.
    # Actually, the SQL fix handles 'undefined' now, but it's cleaner to fix it here too.
    if "search" in fetchRequestsParams:
        fetchRequestsParams["search"] = "{{ $page.variables.filterSearchTerm || '' }}"
        
    print("Fixed fetchRequests search parameter")
except Exception as e:
    print(f"Error updating fetchRequests: {e}")

with open(FILE, "w") as f:
    json.dump(data, f, indent=2)
