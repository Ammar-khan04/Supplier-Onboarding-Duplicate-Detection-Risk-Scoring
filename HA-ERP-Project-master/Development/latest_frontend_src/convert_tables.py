import re

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE, "r") as f:
    html = f.read()

# 1. Update Logs Table
logs_target = """              <div class="sp-log-header">
                <span>Status</span>
                <span>Request / Supplier</span>
                <span>Type</span>
                <span>OIC Instance</span>
                <span>Updated</span>
                <span>Action</span>
              </div>
              <oj-bind-for-each data="[[ $functions.filterLogs($variables.integrationLogs, $variables.filterLogStatus, $variables.filterLogType) ]]">
                <template data-oj-as="log">
                  <div class="sp-log-row">

                    <!-- Status pill -->
                    <span :class="[[ $functions.getLogStatusClass(log.data.status) ]]">
                      <oj-bind-text value="[[ log.data.status || '—' ]]"></oj-bind-text>
                    </span>

                    <!-- Request / supplier info -->
                    <div>
                      <div class="sp-log-type">
                        <oj-bind-text value="[[ log.data.request_number || ('Request #' + log.data.request_id) ]]"></oj-bind-text>
                        &nbsp;—&nbsp;
                        <oj-bind-text value="[[ log.data.supplier_name || '' ]]"></oj-bind-text>
                      </div>
                      <div class="sp-log-meta">
                        <oj-bind-text value="[[ $functions.formatIntegrationType(log.data.integration_type) ]]"></oj-bind-text>
                        <oj-bind-if test="[[ log.data.fusion_supplier_number ]]">
                          &nbsp;· Fusion: <oj-bind-text value="[[ log.data.fusion_supplier_number ]]"></oj-bind-text>
                        </oj-bind-if>
                      </div>
                      <oj-bind-if test="[[ log.data.error_message ]]">
                        <div class="sp-log-err">⚠ <oj-bind-text value="[[ log.data.error_message ]]"></oj-bind-text></div>
                      </oj-bind-if>
                    </div>

                    <!-- Integration type badge -->
                    <span class="sp-pill neutral" style="font-size:10px;">
                      <oj-bind-text value="[[ (log.data.integration_type || '—').replace(/_/g, ' ') ]]"></oj-bind-text>
                    </span>

                    <!-- OIC instance ID + correlation ID -->
                    <div>
                      <div class="sp-log-ref"><oj-bind-text value="[[ log.data.oic_instance_id || '—' ]]"></oj-bind-text></div>
                      <oj-bind-if test="[[ log.data.correlation_id ]]">
                        <div class="sp-log-meta">Corr: <oj-bind-text value="[[ log.data.correlation_id ]]"></oj-bind-text></div>
                      </oj-bind-if>
                    </div>

                    <!-- Timestamp -->
                    <div class="sp-muted">
                      <oj-bind-text value="[[ $functions.formatDate(log.data.updated_at || log.data.created_at) ]]"></oj-bind-text>
                    </div>

                    <!-- Retry button (only for retryable failures) -->
                    <div>
                      <oj-bind-if test="[[ $functions.isRetryable(log.data) ]]">
                        <button type="button"
                                class="sp-btn retry"
                                :disabled="[[ $variables.retryBusyId === ('' + log.data.request_id) ]]"
                                on-click="[[ $listeners.onRetryRequest ]]"
                                :data-request-id="[[ log.data.request_id ]]">
                          <oj-bind-if test="[[ $variables.retryBusyId !== ('' + log.data.request_id) ]]">↺ Retry</oj-bind-if>
                          <oj-bind-if test="[[ $variables.retryBusyId === ('' + log.data.request_id) ]]">…</oj-bind-if>
                        </button>
                      </oj-bind-if>
                      <oj-bind-if test="[[ !$functions.isRetryable(log.data) && (log.data.status || '').toUpperCase() === 'FAILED' ]]">
                        <span class="sp-muted" style="font-size:10px;">Not retryable</span>
                      </oj-bind-if>
                    </div>

                  </div>
                </template>
              </oj-bind-for-each>"""

logs_new = """              <oj-table id="logs-table"
                        aria-label="Integration Logs Table"
                        data="[[ $variables.integrationLogsADP ]]"
                        display="grid"
                        layout="fixed"
                        on-oj-sort="[[ $listeners.onLogsSort ]]"
                        columns='[
                          {"headerText": "Status", "field": "status", "sortable": "enabled", "template": "statusTemplate"},
                          {"headerText": "Request / Supplier", "field": "request_number", "sortable": "enabled", "template": "requestTemplate"},
                          {"headerText": "Type", "field": "integration_type", "sortable": "enabled", "template": "typeTemplate"},
                          {"headerText": "OIC Instance", "field": "oic_instance_id", "sortable": "enabled", "template": "oicTemplate"},
                          {"headerText": "Updated", "field": "updated_at", "sortable": "enabled", "template": "dateTemplate"},
                          {"headerText": "Action", "field": "action", "sortable": "disabled", "template": "actionTemplate"}
                        ]'
                        style="width: 100%; border-radius: 8px; border: 1px solid #ebf0f4; margin-bottom: 20px;">
                
                <template slot="statusTemplate" data-oj-as="cell">
                  <span :class="[[ $functions.getLogStatusClass(cell.row.status) ]]">
                    <oj-bind-text value="[[ cell.row.status || '—' ]]"></oj-bind-text>
                  </span>
                </template>
                
                <template slot="requestTemplate" data-oj-as="cell">
                  <div>
                    <div class="sp-log-type">
                      <oj-bind-text value="[[ cell.row.request_number || ('Request #' + cell.row.request_id) ]]"></oj-bind-text>
                      &nbsp;—&nbsp;
                      <oj-bind-text value="[[ cell.row.supplier_name || '' ]]"></oj-bind-text>
                    </div>
                    <div class="sp-log-meta">
                      <oj-bind-text value="[[ $functions.formatIntegrationType(cell.row.integration_type) ]]"></oj-bind-text>
                      <oj-bind-if test="[[ cell.row.fusion_supplier_number ]]">
                        &nbsp;· Fusion: <oj-bind-text value="[[ cell.row.fusion_supplier_number ]]"></oj-bind-text>
                      </oj-bind-if>
                    </div>
                    <oj-bind-if test="[[ cell.row.error_message ]]">
                      <div class="sp-log-err">⚠ <oj-bind-text value="[[ cell.row.error_message ]]"></oj-bind-text></div>
                    </oj-bind-if>
                  </div>
                </template>
                
                <template slot="typeTemplate" data-oj-as="cell">
                  <span class="sp-pill neutral" style="font-size:10px;">
                    <oj-bind-text value="[[ (cell.row.integration_type || '—').replace(/_/g, ' ') ]]"></oj-bind-text>
                  </span>
                </template>
                
                <template slot="oicTemplate" data-oj-as="cell">
                  <div>
                    <div class="sp-log-ref"><oj-bind-text value="[[ cell.row.oic_instance_id || '—' ]]"></oj-bind-text></div>
                    <oj-bind-if test="[[ cell.row.correlation_id ]]">
                      <div class="sp-log-meta">Corr: <oj-bind-text value="[[ cell.row.correlation_id ]]"></oj-bind-text></div>
                    </oj-bind-if>
                  </div>
                </template>
                
                <template slot="dateTemplate" data-oj-as="cell">
                  <div class="sp-muted">
                    <oj-bind-text value="[[ $functions.formatDate(cell.row.updated_at || cell.row.created_at) ]]"></oj-bind-text>
                  </div>
                </template>
                
                <template slot="actionTemplate" data-oj-as="cell">
                  <div>
                    <oj-bind-if test="[[ $functions.isRetryable(cell.row) ]]">
                      <button type="button"
                              class="sp-btn retry"
                              :disabled="[[ $variables.retryBusyId === ('' + cell.row.request_id) ]]"
                              on-click="[[ $listeners.onRetryRequest ]]"
                              :data-request-id="[[ cell.row.request_id ]]">
                        <oj-bind-if test="[[ $variables.retryBusyId !== ('' + cell.row.request_id) ]]">↺ Retry</oj-bind-if>
                        <oj-bind-if test="[[ $variables.retryBusyId === ('' + cell.row.request_id) ]]">…</oj-bind-if>
                      </button>
                    </oj-bind-if>
                    <oj-bind-if test="[[ !$functions.isRetryable(cell.row) && (cell.row.status || '').toUpperCase() === 'FAILED' ]]">
                      <span class="sp-muted" style="font-size:10px;">Not retryable</span>
                    </oj-bind-if>
                  </div>
                </template>
              </oj-table>
              
              <!-- Logs Pagination -->
              <div style="display:flex; justify-content: space-between; align-items: center; margin-top: 10px; padding: 0 16px;">
                <span class="sp-muted" style="font-size: 12px;">Showing up to <oj-bind-text value="[[ $variables.logsLimit ]]"></oj-bind-text> records.</span>
                <div>
                  <oj-button on-oj-action="[[ $listeners.onLogsPagePrev ]]" disabled="[[ $variables.logsOffset === 0 ]]"><span slot="startIcon" class="oj-ux-ico-arrow-left"></span>Previous</oj-button>
                  <oj-button on-oj-action="[[ $listeners.onLogsPageNext ]]" disabled="[[ $variables.integrationLogsADP.data.length < $variables.logsLimit ]]">Next<span slot="endIcon" class="oj-ux-ico-arrow-right"></span></oj-button>
                </div>
              </div>"""

if logs_target in html:
    html = html.replace(logs_target, logs_new)
    print("Logs target replaced")
else:
    print("Logs target not found")

with open(FILE, "w") as f:
    f.write(html)
