import re

FILE = "/home/hussainsulaiman/Trainings/ERP Project/Project Files/Development/latest_frontend_src/webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE, "r") as f:
    html = f.read()

# Requests Search
req_search_target = """              <input type="text"
                     :value="[[ $variables.filterSearchTerm ]]"
                     on-input="[[ $listeners.onSearchTermChange ]]"
                     placeholder="Name or Request #..."
                     style="width:100%;border:1px solid #cbd5e1;border-radius:7px;padding:7px 9px;font-size:12px;"/>"""
                     
req_search_new = """              <oj-input-text value="{{ $variables.filterSearchTerm }}"
                             on-value-changed="[[ $listeners.onSearchTermChange ]]"
                             placeholder="Name or Request #..."
                             clear-icon="always"
                             style="width:100%;">
              </oj-input-text>"""
html = html.replace(req_search_target, req_search_new)

# History Search
hist_search_target = """              <input type="text"
                     :value="[[ $variables.filterHistoryRequestId ]]"
                     on-input="[[ $listeners.onFilterHistoryRequestIdInput ]]"
                     placeholder="e.g. REQ-1004 or 42…"/>"""

hist_search_new = """              <oj-input-text value="{{ $variables.filterHistoryRequestId }}"
                             on-value-changed="[[ $listeners.onFilterHistoryRequestIdInput ]]"
                             placeholder="e.g. REQ-1004 or 42…"
                             clear-icon="always"
                             style="width:100%;">
              </oj-input-text>"""
html = html.replace(hist_search_target, hist_search_new)

with open(FILE, "w") as f:
    f.write(html)

