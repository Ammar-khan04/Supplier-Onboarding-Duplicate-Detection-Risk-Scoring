import json

FILE = "/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/latest_frontend_src/webApps/supplierportal/flows/item-1/pages/item-1-start-page.json"

with open(FILE, "r") as f:
    data = json.load(f)

# Update Dashboard sort logic
dash_sort = data["chains"]["onDashboardSortChain"]["actions"]["assignSort"]["parameters"]
dash_sort["$page.variables.dashboardSortDir"] = {
    "source": "{{ $page.variables.dashboardSortCol === $variables.header && $page.variables.dashboardSortDir === 'asc' ? 'desc' : 'asc' }}"
}

# Update Logs sort logic
logs_sort = data["chains"]["onLogsSortChain"]["actions"]["assignSort"]["parameters"]
logs_sort["$page.variables.logsSortDir"] = {
    "source": "{{ $page.variables.logsSortCol === $variables.header && $page.variables.logsSortDir === 'asc' ? 'desc' : 'asc' }}"
}

# Update History sort logic
hist_sort = data["chains"]["onHistorySortChain"]["actions"]["assignSort"]["parameters"]
hist_sort["$page.variables.historySortDir"] = {
    "source": "{{ $page.variables.historySortCol === $variables.header && $page.variables.historySortDir === 'asc' ? 'desc' : 'asc' }}"
}

with open(FILE, "w") as f:
    json.dump(data, f, indent=2)

