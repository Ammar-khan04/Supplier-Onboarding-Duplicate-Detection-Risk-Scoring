import re

FILE = "webApps/supplierportal/flows/item-1/pages/item-1-start-page.html"

with open(FILE, "r") as f:
    html = f.read()

hist_target = """              <div class="sp-hist-header">
                <span></span>
                <span>Action</span>
                <span>Request / Details</span>
                <span>Actor</span>
                <span>Role</span>
                <span>Timestamp</span>
              </div>

              <oj-bind-for-each data="[[ $functions.filterHistory($variables.actionHistory, $variables.filterHistoryActionType, $variables.filterHistoryRequestId) ]]">
                <template data-oj-as="entry">
                  <div class="sp-hist-row">

                    <!-- Icon -->
                    <div class="sp-hist-icon">
                      <oj-bind-text value="[[ $functions.getActionTypeIcon(entry.data.action_type) ]]"></oj-bind-text>
                    </div>

                    <!-- Action type badge -->
                    <div>
                      <span :class="[[ $functions.getActionTypeBadgeClass(entry.data.action_type) ]]" style="font-size:10px;">
                        <oj-bind-text value="[[ (entry.data.action_type || '—').replace(/_/g,' ') ]]"></oj-bind-text>
                      </span>
                    </div>

                    <!-- Request + detail -->
                    <div>
                      <div class="sp-hist-request">
                        <oj-bind-text value="[[ entry.data.request_number || ('Request #' + entry.data.request_id) ]]"></oj-bind-text>
                      </div>
                      <div class="sp-hist-supplier">
                        <oj-bind-text value="[[ entry.data.supplier_name || '' ]]"></oj-bind-text>
                        <oj-bind-if test="[[ entry.data.business_unit ]]">
                          &nbsp;·&nbsp;<oj-bind-text value="[[ entry.data.business_unit ]]"></oj-bind-text>
                        </oj-bind-if>
                      </div>
                      <oj-bind-if test="[[ entry.data.action_note || entry.data.reason || entry.data.decision_reason ]]">
                        <div class="sp-hist-detail">
                          <span class="detail-note">
                            "<oj-bind-text value="[[ entry.data.action_note || entry.data.reason || entry.data.decision_reason ]]"></oj-bind-text>"
                          </span>
                        </div>
                      </oj-bind-if>
                      <oj-bind-if test="[[ entry.data.new_status ]]">
                        <div class="sp-hist-detail">
                          <span class="sp-muted">→ </span>
                          <span class="sp-pill neutral" style="font-size:10px;">
                            <oj-bind-text value="[[ entry.data.new_status ]]"></oj-bind-text>
                          </span>
                          <oj-bind-if test="[[ entry.data.previous_status ]]">
                            <span class="sp-muted" style="font-size:10px;">
                              &nbsp;(was&nbsp;<oj-bind-text value="[[ entry.data.previous_status ]]"></oj-bind-text>)
                            </span>
                          </oj-bind-if>
                        </div>
                      </oj-bind-if>
                    </div>

                    <!-- Actor display name -->
                    <div class="sp-hist-actor">
                      <oj-bind-text value="[[ entry.data.actor_display_name || entry.data.actor_subject_id || '—' ]]"></oj-bind-text>
                    </div>

                    <!-- Actor role -->
                    <div>
                      <oj-bind-if test="[[ entry.data.actor_role ]]">
                        <span class="actor-role"><oj-bind-text value="[[ entry.data.actor_role ]]"></oj-bind-text></span>
                      </oj-bind-if>
                    </div>

                    <!-- Timestamp -->
                    <div class="sp-hist-time">
                      <oj-bind-text value="[[ $functions.formatDate(entry.data.action_at || entry.data.created_at) ]]"></oj-bind-text>
                    </div>

                  </div>
                </template>
              </oj-bind-for-each>"""

hist_new = """              <oj-table id="history-table"
                        aria-label="Action History Table"
                        data="[[ $variables.actionHistoryADP ]]"
                        display="grid"
                        layout="fixed"
                        on-oj-sort="[[ $listeners.onHistorySort ]]"
                        columns='[
                          {"headerText": "", "field": "icon", "sortable": "disabled", "template": "iconTemplate", "width": "50px"},
                          {"headerText": "Action", "field": "action_type", "sortable": "enabled", "template": "actionTypeTemplate"},
                          {"headerText": "Request / Details", "field": "request_number", "sortable": "enabled", "template": "requestTemplate"},
                          {"headerText": "Actor", "field": "actor_subject_id", "sortable": "enabled", "template": "actorTemplate"},
                          {"headerText": "Role", "field": "actor_role", "sortable": "disabled", "template": "roleTemplate"},
                          {"headerText": "Timestamp", "field": "action_at", "sortable": "enabled", "template": "timeTemplate"}
                        ]'
                        style="width: 100%; border-radius: 8px; border: 1px solid #ebf0f4; margin-bottom: 20px;">
                
                <template slot="iconTemplate" data-oj-as="cell">
                  <div class="sp-hist-icon">
                    <oj-bind-text value="[[ $functions.getActionTypeIcon(cell.row.action_type) ]]"></oj-bind-text>
                  </div>
                </template>
                
                <template slot="actionTypeTemplate" data-oj-as="cell">
                  <div>
                    <span :class="[[ $functions.getActionTypeBadgeClass(cell.row.action_type) ]]" style="font-size:10px;">
                      <oj-bind-text value="[[ (cell.row.action_type || '—').replace(/_/g,' ') ]]"></oj-bind-text>
                    </span>
                  </div>
                </template>
                
                <template slot="requestTemplate" data-oj-as="cell">
                  <div>
                    <div class="sp-hist-request">
                      <oj-bind-text value="[[ cell.row.request_number || ('Request #' + cell.row.request_id) ]]"></oj-bind-text>
                    </div>
                    <div class="sp-hist-supplier">
                      <oj-bind-text value="[[ cell.row.supplier_name || '' ]]"></oj-bind-text>
                      <oj-bind-if test="[[ cell.row.business_unit ]]">
                        &nbsp;·&nbsp;<oj-bind-text value="[[ cell.row.business_unit ]]"></oj-bind-text>
                      </oj-bind-if>
                    </div>
                    <oj-bind-if test="[[ cell.row.action_note || cell.row.reason || cell.row.decision_reason ]]">
                      <div class="sp-hist-detail">
                        <span class="detail-note">
                          "<oj-bind-text value="[[ cell.row.action_note || cell.row.reason || cell.row.decision_reason ]]"></oj-bind-text>"
                        </span>
                      </div>
                    </oj-bind-if>
                    <oj-bind-if test="[[ cell.row.new_status ]]">
                      <div class="sp-hist-detail">
                        <span class="sp-muted">→ </span>
                        <span class="sp-pill neutral" style="font-size:10px;">
                          <oj-bind-text value="[[ cell.row.new_status ]]"></oj-bind-text>
                        </span>
                        <oj-bind-if test="[[ cell.row.previous_status ]]">
                          <span class="sp-muted" style="font-size:10px;">
                            &nbsp;(was&nbsp;<oj-bind-text value="[[ cell.row.previous_status ]]"></oj-bind-text>)
                          </span>
                        </oj-bind-if>
                      </div>
                    </oj-bind-if>
                  </div>
                </template>
                
                <template slot="actorTemplate" data-oj-as="cell">
                  <div class="sp-hist-actor">
                    <oj-bind-text value="[[ cell.row.actor_display_name || cell.row.actor_subject_id || '—' ]]"></oj-bind-text>
                  </div>
                </template>
                
                <template slot="roleTemplate" data-oj-as="cell">
                  <div>
                    <oj-bind-if test="[[ cell.row.actor_role ]]">
                      <span class="actor-role"><oj-bind-text value="[[ cell.row.actor_role ]]"></oj-bind-text></span>
                    </oj-bind-if>
                  </div>
                </template>
                
                <template slot="timeTemplate" data-oj-as="cell">
                  <div class="sp-hist-time">
                    <oj-bind-text value="[[ $functions.formatDate(cell.row.action_at || cell.row.created_at) ]]"></oj-bind-text>
                  </div>
                </template>
              </oj-table>
              
              <!-- History Pagination -->
              <div style="display:flex; justify-content: space-between; align-items: center; margin-top: 10px; padding: 0 16px;">
                <span class="sp-muted" style="font-size: 12px;">Showing up to <oj-bind-text value="[[ $variables.historyLimit ]]"></oj-bind-text> records.</span>
                <div>
                  <oj-button on-oj-action="[[ $listeners.onHistoryPagePrev ]]" disabled="[[ $variables.historyOffset === 0 ]]"><span slot="startIcon" class="oj-ux-ico-arrow-left"></span>Previous</oj-button>
                  <oj-button on-oj-action="[[ $listeners.onHistoryPageNext ]]" disabled="[[ $variables.actionHistoryADP.data.length < $variables.historyLimit ]]">Next<span slot="endIcon" class="oj-ux-ico-arrow-right"></span></oj-button>
                </div>
              </div>"""

if hist_target in html:
    html = html.replace(hist_target, hist_new)
    print("History target replaced")
else:
    print("History target not found")

with open(FILE, "w") as f:
    f.write(html)
