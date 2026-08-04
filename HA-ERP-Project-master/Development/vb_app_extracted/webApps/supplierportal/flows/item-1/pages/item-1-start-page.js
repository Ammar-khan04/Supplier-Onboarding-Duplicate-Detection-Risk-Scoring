define([], function() {
  'use strict';

  var PageModule = function PageModule(context) {
    this.eventHelper = context.getEventHelper();
  };

  /* ============================================================
     ACTOR IDENTITY HELPERS
     The ORDS WHERE clause is:
       WHERE requester_subject_id = :actor_subject_id
          OR has_role(:actor_roles, 'REVIEWER') = 'Y'
          OR has_role(:actor_roles, 'ADMIN') = 'Y'
     So the fix is: when role is REVIEWER or ADMIN we must send a
     subject_id that is NOT a real requester's ID, so the first OR
     branch (has_role) fires instead of the subject filter.
  ============================================================ */

  /**
   * Returns the subject ID to send for a given role.
   * REVIEWER and ADMIN use their own non-requester IDs so ORDS
   * bypasses the requester_subject_id filter and returns all rows.
   */
  PageModule.prototype.actorSubjectId = function(role) {
    switch ((role || '').toUpperCase()) {
      case 'REVIEWER': return 'REV_SUBJECT_ID';
      case 'ADMIN':    return 'ADM_SUBJECT_ID';
      default:         return 'REQ_AMINA_SUB';   // default demo requester
    }
  };

  /* ============================================================
     BADGE / PILL HELPERS
  ============================================================ */

  PageModule.prototype.getRiskBadgeClass = function(riskLevel) {
    if (!riskLevel) return 'sp-pill neutral';
    switch (riskLevel.toUpperCase()) {
      case 'LOW':      return 'sp-pill low';
      case 'MEDIUM':   return 'sp-pill medium';
      case 'HIGH':
      case 'CRITICAL': return 'sp-pill high';
      default:         return 'sp-pill neutral';
    }
  };

  // Bug 2 fix: DB duplicate_level values are NONE/POSSIBLE/STRONG/EXACT
  PageModule.prototype.getDuplicateBadgeClass = function(duplicateLevel) {
    if (!duplicateLevel) return 'sp-pill neutral';
    switch (duplicateLevel.toUpperCase()) {
      case 'NONE':     return 'sp-pill low';
      case 'POSSIBLE': return 'sp-pill medium';
      case 'STRONG':
      case 'EXACT':    return 'sp-pill high';
      default:         return 'sp-pill neutral';
    }
  };

  /* ============================================================
     DASHBOARD STATS
  ============================================================ */

  PageModule.prototype.computeDashboardStats = function(requests) {
    var list = requests || [];
    var CLOSED_STATUSES = ['CREATED_IN_FUSION', 'REJECTED', 'DUPLICATE'];
    var stats = {
      openRequests: 0,
      highRiskCount: 0,
      createdInFusionCount: 0,
      correctionRequiredCount: 0
    };
    list.forEach(function(r) {
      var status = (r.status || '').toUpperCase();
      var risk   = (r.risk_level || '').toUpperCase();
      if (CLOSED_STATUSES.indexOf(status) === -1) stats.openRequests++;
      if (risk === 'HIGH' || risk === 'CRITICAL')  stats.highRiskCount++;
      if (status === 'CREATED_IN_FUSION')           stats.createdInFusionCount++;
      if (status === 'CORRECTION_REQUIRED')         stats.correctionRequiredCount++;
    });
    return stats;
  };

  PageModule.prototype.buildBusinessUnitOptions = function(requests) {
    var list = requests || [];
    var seen = {};
    var options = [{ value: 'ALL', label: 'All Business Units' }];
    list.forEach(function(r) {
      var bu = r.business_unit;
      if (bu && !seen[bu]) {
        seen[bu] = true;
        options.push({ value: bu, label: bu });
      }
    });
    return options;
  };

  PageModule.prototype.filterRequests = function(requests, businessUnit, status, riskLevel, duplicateLevel) {
    var list = requests || [];
    function normalize(v) { return (v == null) ? '' : String(v).toUpperCase(); }
    var wantStatus    = normalize(status);
    var wantRisk      = normalize(riskLevel);
    var wantDuplicate = normalize(duplicateLevel);
    return list.filter(function(r) {
      if (businessUnit && businessUnit !== 'ALL' && r.business_unit !== businessUnit) return false;
      if (wantStatus    && wantStatus    !== 'ALL' && normalize(r.status)          !== wantStatus)    return false;
      if (wantRisk      && wantRisk      !== 'ALL' && normalize(r.risk_level)      !== wantRisk)      return false;
      if (wantDuplicate && wantDuplicate !== 'ALL' && normalize(r.duplicate_level) !== wantDuplicate) return false;
      return true;
    });
  };

  /* ============================================================
     DOCUMENT HELPERS
  ============================================================ */

  PageModule.prototype.buildDocumentMetadata = function(file, documentType) {
    var f = file || {};
    return {
      document_type: documentType || 'OTHER',
      file_name:     f.name || 'unnamed-file',
      mime_type:     f.type || 'application/octet-stream'
    };
  };

  PageModule.prototype.extractFileFromPicker = function(event) {
    if (!event) return null;
    if (event.detail && event.detail.files && event.detail.files.length > 0) {
      return event.detail.files[0];
    }
    if (event.target && event.target.files && event.target.files.length > 0) {
      return event.target.files[0];
    }
    return null;
  };

  PageModule.prototype.getDocumentTypeLabel = function(docType) {
    if (!docType) return 'Supporting Document';
    switch (docType.toUpperCase()) {
      case 'TAX_CERTIFICATE':       return 'Tax Registration / Certificate';
      case 'BANK_CONFIRMATION':     return 'Bank Confirmation Letter / Void Cheque';
      case 'BUSINESS_REGISTRATION': return 'Business Registration / License';
      case 'W9_W8_BEN':             return 'W-9 / W-8BEN Form';
      case 'COMPANY_PROFILE':       return 'Company Profile / Presentation';
      case 'OTHER':                 return 'Other Supporting Document';
      default:                      return docType.replace(/_/g, ' ');
    }
  };

  PageModule.prototype.getDocumentTypeIcon = function(docType) {
    if (!docType) return '📄';
    switch (docType.toUpperCase()) {
      case 'TAX_CERTIFICATE':       return '📑';
      case 'BANK_CONFIRMATION':     return '🏦';
      case 'BUSINESS_REGISTRATION': return '🏢';
      case 'W9_W8_BEN':             return '📋';
      case 'COMPANY_PROFILE':       return '📊';
      default:                      return '📄';
    }
  };

  PageModule.prototype.hasDocumentOfType = function(docList, docType) {
    if (!docList || !docList.length) return false;
    for (var i = 0; i < docList.length; i++) {
      if ((docList[i].document_type || '').toUpperCase() === (docType || '').toUpperCase()) {
        return true;
      }
    }
    return false;
  };

  PageModule.prototype.appendSessionDocument = function(existingDocuments, metadata) {
    var updated = (existingDocuments || []).slice();
    updated.push(Object.assign({}, metadata, { uploaded_at: new Date().toISOString() }));
    return updated;
  };

  PageModule.prototype.formatFileSize = function(bytes) {
    if (!bytes) return '';
    if (bytes < 1024)          return bytes + ' B';
    if (bytes < 1024 * 1024)   return Math.round(bytes / 1024) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  };

  PageModule.prototype.readFileDetails = function(event) {
    if (!event) {
      return Promise.resolve({ fileName: '', mimeType: 'application/pdf', fileSize: 0, base64: '' });
    }
    var files = null;
    if (typeof File !== 'undefined' && event instanceof File) {
      files = [event];
    } else if ((typeof FileList !== 'undefined' && event instanceof FileList) || Array.isArray(event)) {
      files = event;
    } else if (event.detail && event.detail.files) {
      files = event.detail.files;
    } else if (event.target && event.target.files) {
      files = event.target.files;
    } else if (event.detail && event.detail.originalEvent && event.detail.originalEvent.target && event.detail.originalEvent.target.files) {
      files = event.detail.originalEvent.target.files;
    }

    if (!files || files.length === 0) {
      return Promise.resolve({ fileName: '', mimeType: 'application/pdf', fileSize: 0, base64: '' });
    }
    var file = files[0];
    return new Promise(function(resolve) {
      var reader = new FileReader();
      reader.onload = function(e) {
        resolve({
          fileName: file.name,
          mimeType: file.type || 'application/pdf',
          fileSize: file.size,
          base64: e.target.result || ''
        });
      };
      reader.onerror = function() {
        resolve({
          fileName: file.name,
          mimeType: file.type || 'application/pdf',
          fileSize: file.size,
          base64: ''
        });
      };
      reader.readAsDataURL(file);
    });
  };

  PageModule.prototype.getDocumentDownloadUrl = function(requestId, documentId) {
    if (!requestId || !documentId) return '#';
    return 'http://172.105.152.7:8181/ords/ha_erp_api/ha_v1/requests/' + encodeURIComponent(requestId) + '/documents/' + encodeURIComponent(documentId) + '/content';
  };

  PageModule.prototype.openDocument = function(requestId, documentId, fileName) {
    var url = this.getDocumentDownloadUrl(requestId, documentId);
    if (!url || url === '#') return;
    var win = window.open(url, '_blank');
    if (!win) {
      window.location.href = url;
    }
  };

  /* ============================================================
     REVIEWER DETAIL HELPERS
  ============================================================ */

  PageModule.prototype.parseJsonSafe = function(value) {
    if (!value) return [];
    if (Array.isArray(value)) return value;
    if (typeof value === 'object') return [value];
    try {
      var parsed = JSON.parse(value);
      if (Array.isArray(parsed)) return parsed;
      if (parsed && typeof parsed === 'object') {
        if (Array.isArray(parsed.items)) return parsed.items;
        return [parsed];
      }
      return [];
    } catch (e) {
      return [];
    }
  };

  // Bug 1 fix: risk_score is already 0-100 in the DB schema, not 0-30
  PageModule.prototype.riskScoreToPercent = function(score) {
    if (score == null || isNaN(score)) return 0;
    return Math.min(Math.max(Math.round(Number(score)), 0), 100);
  };

  PageModule.prototype.factorSeverityClass = function(factor) {
    if (!factor) return '';
    // DB field is applied_weight (not points/risk_points)
    var pts = Number(factor.applied_weight || factor.points || factor.risk_points || 0);
    if (pts >= 10) return 'factor-high';
    if (pts >= 5)  return 'factor-medium';
    return 'factor-low';
  };

  PageModule.prototype.factorIcon = function(factor) {
    if (!factor) return '📌';
    // DB field is rule_code (not factor_code/code)
    var code = (factor.rule_code || factor.factor_code || factor.code || '').toUpperCase();
    if (code.indexOf('COUNTRY') !== -1)    return '🌍';
    if (code.indexOf('BANK') !== -1)       return '🏦';
    if (code.indexOf('TAX') !== -1)        return '🧳';
    if (code.indexOf('DUPLICATE') !== -1)  return '🔁';
    if (code.indexOf('JUSTIF') !== -1)     return '📝';
    if (code.indexOf('SPEND') !== -1)      return '💰';
    if (code.indexOf('CONTACT') !== -1)    return '📧';
    return '⚠';
  };

  PageModule.prototype.validationResultClass = function(vr) {
    if (!vr) return 'sp-val-result';
    var sev = (vr.severity || vr.level || vr.status || '').toUpperCase();
    if (sev === 'ERROR'   || sev === 'FAIL'    || sev === 'FAILED')  return 'sp-val-result val-fail';
    if (sev === 'WARNING' || sev === 'WARN')                          return 'sp-val-result val-warn';
    if (sev === 'OK'      || sev === 'PASS'    || sev === 'PASSED')   return 'sp-val-result val-ok';
    return 'sp-val-result';
  };

  PageModule.prototype.formatValidationResult = function(vr) {
    if (!vr) return '';
    var icon = '';
    var sev  = (vr.severity || vr.level || vr.status || '').toUpperCase();
    if (sev === 'ERROR' || sev === 'FAIL' || sev === 'FAILED')       icon = '❌ ';
    else if (sev === 'WARNING' || sev === 'WARN')                     icon = '⚠ ';
    else if (sev === 'OK' || sev === 'PASS' || sev === 'PASSED')      icon = '✅ ';
    var label = vr.field_name || vr.check || vr.rule || vr.code || '';
    var msg   = vr.message || vr.description || vr.reason || '';
    if (label && msg) return icon + label + ': ' + msg;
    return icon + (label || msg || JSON.stringify(vr));
  };

  PageModule.prototype.formatDate = function(ts) {
    if (!ts) return '—';
    try {
      var d = new Date(ts);
      if (isNaN(d.getTime())) return ts;
      return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }) +
             ' ' + d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    } catch (e) {
      return ts;
    }
  };

  PageModule.prototype.formatCurrency = function(amount, currencyCode) {
    if (amount == null) return '—';
    var code = currencyCode || 'USD';
    try {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: code,
        maximumFractionDigits: 0
      }).format(Number(amount));
    } catch (e) {
      return code + ' ' + Number(amount).toLocaleString();
    }
  };

  PageModule.prototype.canDecide = function(status) {
    if (!status) return false;
    var decidable = ['SUBMITTED', 'UNDER_REVIEW', 'CORRECTION_REQUIRED', 'VALIDATION_FAILED'];
    return decidable.indexOf(status.toUpperCase()) !== -1;
  };

  PageModule.prototype.validateDecision = function(decision) {
    var d = decision || {};
    if (!d.decision) {
      return { valid: false, error: 'Please select a decision before submitting.' };
    }
    var requiresReason = ['REJECT', 'DUPLICATE', 'REQUEST_CORRECTION'];
    if (requiresReason.indexOf(d.decision) !== -1 && !(d.reason || '').trim()) {
      return { valid: false, error: 'A reason is required for ' + d.decision + ' decisions.' };
    }
    return { valid: true, error: '' };
  };

  PageModule.prototype.patchReviewDecision = function(current, field, value) {
    var updated = Object.assign({}, current || {});
    updated[field] = value;
    return updated;
  };

  /* ============================================================
     ADMIN / INTEGRATION LOG HELPERS
  ============================================================ */

  /**
   * Returns a CSS class for the integration log status pill.
   */
  // Bug 3 fix: DB integration_job.status values are READY/CLAIMED/IN_PROGRESS/SUCCEEDED/FAILED/CANCELLED
  PageModule.prototype.getLogStatusClass = function(status) {
    if (!status) return 'sp-pill neutral';
    switch (status.toUpperCase()) {
      case 'SUCCEEDED':   return 'sp-pill low';
      case 'READY':
      case 'CLAIMED':
      case 'IN_PROGRESS': return 'sp-pill medium';
      case 'FAILED':      return 'sp-pill high';
      case 'CANCELLED':   return 'sp-pill neutral';
      default:            return 'sp-pill neutral';
    }
  };

  /**
   * Returns a human-readable label for an integration type.
   */
  // Bug 4 fix: real integration_type values are AI_EXPLANATION, FUSION_CREATE, SUPPLIER_SYNC
  PageModule.prototype.formatIntegrationType = function(type) {
    if (!type) return '—';
    var map = {
      'FUSION_CREATE':  '🏭 Fusion Supplier Create',
      'AI_EXPLANATION': '🤖 AI Risk Explanation',
      'SUPPLIER_SYNC':  '🔄 Supplier Reference Sync'
    };
    return map[type.toUpperCase()] || type;
  };

  /**
   * Returns true if a log entry is retryable (FAILED + retryable flag).
   */
  PageModule.prototype.isRetryable = function(log) {
    if (!log) return false;
    return (log.status || '').toUpperCase() === 'FAILED' && log.retryable === 'Y';
  };

  /**
   * Compute admin dashboard stats from integration logs.
   */
  // Bug 3 fix: use real DB status values for admin stats
  PageModule.prototype.computeAdminStats = function(logs) {
    var list = logs || [];
    var stats = { total: 0, pending: 0, failed: 0, completed: 0, retryable: 0 };
    list.forEach(function(l) {
      stats.total++;
      var s = (l.status || '').toUpperCase();
      if (s === 'READY' || s === 'CLAIMED' || s === 'IN_PROGRESS') stats.pending++;
      if (s === 'FAILED') {
        stats.failed++;
        if (l.retryable === 'Y') stats.retryable++;
      }
      if (s === 'SUCCEEDED') stats.completed++;
    });
    return stats;
  };

  /**
   * Filter integration logs for the admin table.
   */
  PageModule.prototype.filterLogs = function(logs, statusFilter, typeFilter) {
    var list = logs || [];
    return list.filter(function(l) {
      if (statusFilter && statusFilter !== 'ALL' && (l.status || '').toUpperCase() !== statusFilter) return false;
      if (typeFilter   && typeFilter   !== 'ALL' && (l.integration_type || '').toUpperCase() !== typeFilter) return false;
      return true;
    });
  };

/* ============================================================
     ACTION HISTORY HELPERS
  ============================================================ */

  /**
   * Returns a CSS class for an action type badge.
   */
  PageModule.prototype.getActionTypeBadgeClass = function(actionType) {
    if (!actionType) return 'sp-pill neutral';
    var t = actionType.toUpperCase();
    if (t === 'APPROVED' || t === 'CREATED_IN_FUSION') return 'sp-pill low';
    if (t === 'REJECTED' || t === 'DUPLICATE')         return 'sp-pill high';
    if (t === 'SUBMITTED' || t === 'SUBMIT')           return 'sp-pill medium';
    if (t.indexOf('CORRECTION') !== -1)                return 'sp-pill medium';
    if (t.indexOf('REVIEW') !== -1)                    return 'sp-pill medium';
    return 'sp-pill neutral';
  };

  /**
   * Returns an icon for an action type.
   */
  PageModule.prototype.getActionTypeIcon = function(actionType) {
    if (!actionType) return '📋';
    var t = actionType.toUpperCase();
    var map = {
      'CREATED':             '🆕',
      'SUBMITTED':           '📤',
      'SUBMIT':              '📤',
      'APPROVED':            '✅',
      'REJECTED':            '❌',
      'DUPLICATE':           '🔁',
      'CORRECTION_REQUIRED': '✏️',
      'REQUEST_CORRECTION':  '✏️',
      'UPDATED':             '📝',
      'DOCUMENT_ADDED':      '📄',
      'VALIDATION_PASSED':   '✅',
      'VALIDATION_FAILED':   '❌',
      'RISK_ASSESSED':       '⚠',
      'DUPLICATE_CHECKED':   '🔍',
      'AI_SUMMARY_GENERATED':'🤖',
      'SUBMITTED_TO_FUSION': '🏭',
      'CREATED_IN_FUSION':   '🏭',
      'INTEGRATION_FAILED':  '🔴',
      'RETRIED':             '↺',
      'AI_REGENERATED':      '🔄',
      'RISK_ADJUSTED':       '⚖'
    };
    return map[t] || '📋';
  };

  /**
   * Filter action history list by action type and request ID search.
   */
  PageModule.prototype.filterHistory = function(history, actionTypeFilter, requestIdSearch) {
    var list = history || [];
    var wantType  = (actionTypeFilter  || 'ALL').toUpperCase();
    var wantReqId = (requestIdSearch   || '').toLowerCase().trim();
    return list.filter(function(h) {
      if (wantType !== 'ALL' && (h.action_type || '').toUpperCase() !== wantType) return false;
      if (wantReqId) {
        var reqNum = (h.request_number || '').toLowerCase();
        var reqId  = String(h.request_id || '').toLowerCase();
        if (reqNum.indexOf(wantReqId) === -1 && reqId.indexOf(wantReqId) === -1) return false;
      }
      return true;
    });
  };

  /**
   * Compute summary stats for action history.
   */
  PageModule.prototype.computeHistoryStats = function(history) {
    var list = history || [];
    var stats = { total: 0, approved: 0, rejected: 0, corrections: 0, submissions: 0 };
    list.forEach(function(h) {
      stats.total++;
      var t = (h.action_type || '').toUpperCase();
      if (t === 'APPROVED')                              stats.approved++;
      else if (t === 'REJECTED' || t === 'DUPLICATE')   stats.rejected++;
      else if (t.indexOf('CORRECTION') !== -1)           stats.corrections++;
      else if (t === 'SUBMITTED' || t === 'SUBMIT')      stats.submissions++;
    });
    return stats;
  };

  /**
   * Build unique action type options from the history list.
   */
  PageModule.prototype.buildActionTypeOptions = function(history) {
    const defaultOpts = [
      { value: '', label: 'All Actions' },
      { value: 'CREATE_SUBMIT', label: 'Submissions' },
      { value: 'CORRECTION_REQUIRED', label: 'Corrections Sent' },
      { value: 'RESUBMIT', label: 'Resubmissions' },
      { value: 'REJECTED', label: 'Rejections' },
      { value: 'DUPLICATE', label: 'Duplicate Marked' },
      { value: 'APPROVED', label: 'Approvals' },
      { value: 'CREATED_IN_FUSION', label: 'Fusion Creates' },
      { value: 'INTEGRATION_FAILED', label: 'Integration Fails' }
    ];
    return defaultOpts;
  };

  PageModule.prototype.updateRuleWeight = function(rules, code, newWeight) {
    let updated = [...(rules || [])];
    for(let i = 0; i < updated.length; i++) {
      if(updated[i].rule_code === code) {
        updated[i].weight = Number(newWeight);
        break;
      }
    }
    return updated;
  };

  PageModule.prototype.computeBaseRulesTotal = function(rules) {
    let total = 0;
    for(let i = 0; i < (rules || []).length; i++) {
      if(rules[i].component === 'BASE' && rules[i].active === 'Y') {
        total += Number(rules[i].weight || 0);
      }
    }
    return total;
  };

  /**
   * Computes if risk bands are contiguous and cover 0 to 100 perfectly.
   */
  PageModule.prototype.computeRiskBandsValid = function(bands) {
    if (!bands || bands.length === 0) return true;
    
    // Sort by min_score
    var sorted = bands.slice().sort(function(a, b) {
      return Number(a.min_score || 0) - Number(b.min_score || 0);
    });

    if (Number(sorted[0].min_score || 0) !== 0) return false;
    if (Number(sorted[sorted.length - 1].max_score || 0) !== 100) return false;

    for (var i = 0; i < sorted.length; i++) {
      var min = Number(sorted[i].min_score || 0);
      var max = Number(sorted[i].max_score || 0);
      if (min > max) return false;
      
      if (i > 0) {
        var prevMax = Number(sorted[i - 1].max_score || 0);
        if (min !== prevMax + 1) return false;
      }
    }
    return true;
  };

  /**
   * Patch a field on the justification adjustment object.
   */
  PageModule.prototype.patchJustAdj = function(current, field, value) {
    var updated = Object.assign({}, current || {});
    updated[field] = value;
    return updated;
  };

  return PageModule;
});
