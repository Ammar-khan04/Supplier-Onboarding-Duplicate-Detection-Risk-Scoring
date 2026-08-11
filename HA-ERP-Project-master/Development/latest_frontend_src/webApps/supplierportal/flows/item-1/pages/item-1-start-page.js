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

  /**
   * Validates if all required fields in the new request form are filled out.
   */
  PageModule.prototype.isFormValid = function(req) {
    if (!req) return false;
    var required = [
      req.supplier_name,
      req.supplier_type,
      req.country_code,
      req.business_unit,
      req.tax_registration_number,
      req.expected_annual_spend,
      req.currency_code,
      req.business_justification,
      req.contact_person,
      req.contact_email,
      req.address_line1,
      req.city,
      req.site_name
    ];
    for (var i = 0; i < required.length; i++) {
      if (!required[i] || String(required[i]).trim() === '') {
        return false;
      }
    }
    return true;
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

  PageModule.prototype.getIntegrationTypeClass = function(type) {
    if (!type) return 'sp-pill neutral';
    var t = type.toUpperCase();
    if (t === 'AI_EXPLANATION') return 'sp-pill medium';
    if (t === 'FUSION_CREATE')  return 'sp-pill low';
    if (t === 'SUPPLIER_SYNC')  return 'sp-pill neutral';
    return 'sp-pill neutral';
  };

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
    if (t === 'APPROVED' || t === 'CREATED_IN_FUSION' || t === 'VALIDATION_PASSED') return 'sp-pill low';
    if (t === 'REJECTED' || t === 'DUPLICATE' || t === 'VALIDATION_FAILED')         return 'sp-pill high';
    if (t === 'SUBMITTED' || t === 'SUBMIT')           return 'sp-pill medium';
    if (t.indexOf('CORRECTION') !== -1)                return 'sp-pill medium';
    if (t.indexOf('REVIEW') !== -1)                    return 'sp-pill medium';
    if (t.indexOf('FAILED') !== -1)                    return 'sp-pill high';
    if (t.indexOf('RISK_ASSESSED') !== -1)             return 'sp-pill medium';
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
      if (t === 'APPROVE' || t === 'APPROVED')                              stats.approved++;
      else if (t === 'REJECT' || t === 'REJECTED' || t === 'DUPLICATE')   stats.rejected++;
      else if (t.indexOf('CORRECTION') !== -1)           stats.corrections++;
      else if (t === 'SUBMITTED' || t === 'SUBMIT' || t === 'SUBMIT_TO_FUSION')      stats.submissions++;
    });
    return stats;
  };

  /**
   * Build unique action type options from the history list.
   */
  PageModule.prototype.buildActionTypeOptions = function(history) {
    var defaultOpts = [
      { value: '', label: 'All Actions' }
    ];
    if (history && history.length > 0) {
      var types = {};
      history.forEach(function(h) {
        if (h.action_type) {
          types[h.action_type] = true;
        }
      });
      Object.keys(types).sort().forEach(function(t) {
        var lbl = t.replace(/_/g, ' ');
        lbl = lbl.toLowerCase().replace(/\b\w/g, function(c) { return c.toUpperCase(); });
        defaultOpts.push({ value: t, label: lbl });
      });
    }
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

  PageModule.prototype.toggleRuleActive = function(index, rules) {
    var updated = (rules || []).slice();
    if (updated[index]) {
      updated[index].active = updated[index].active === 'Y' ? 'N' : 'Y';
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

  PageModule.prototype.computeRiskBandsValid = function(bands) {
    if (!bands || bands.length === 0) return true;
    
    // Check coverage from 0 to 100
    // ...

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

  /* ============================================================
     COUNTRY REFERENCE DATASET & HELPERS
  ============================================================ */

  var ISO_COUNTRIES = [
    { country_code: "AD", country_name: "Andorra" },
    { country_code: "AE", country_name: "United Arab Emirates" },
    { country_code: "AF", country_name: "Afghanistan" },
    { country_code: "AG", country_name: "Antigua and Barbuda" },
    { country_code: "AI", country_name: "Anguilla" },
    { country_code: "AL", country_name: "Albania" },
    { country_code: "AM", country_name: "Armenia" },
    { country_code: "AO", country_name: "Angola" },
    { country_code: "AQ", country_name: "Antarctica" },
    { country_code: "AR", country_name: "Argentina" },
    { country_code: "AS", country_name: "American Samoa" },
    { country_code: "AT", country_name: "Austria" },
    { country_code: "AU", country_name: "Australia" },
    { country_code: "AW", country_name: "Aruba" },
    { country_code: "AX", country_name: "Aland Islands" },
    { country_code: "AZ", country_name: "Azerbaijan" },
    { country_code: "BA", country_name: "Bosnia and Herzegovina" },
    { country_code: "BB", country_name: "Barbados" },
    { country_code: "BD", country_name: "Bangladesh" },
    { country_code: "BE", country_name: "Belgium" },
    { country_code: "BF", country_name: "Burkina Faso" },
    { country_code: "BG", country_name: "Bulgaria" },
    { country_code: "BH", country_name: "Bahrain" },
    { country_code: "BI", country_name: "Burundi" },
    { country_code: "BJ", country_name: "Benin" },
    { country_code: "BL", country_name: "Saint Barthelemy" },
    { country_code: "BM", country_name: "Bermuda" },
    { country_code: "BN", country_name: "Brunei Darussalam" },
    { country_code: "BO", country_name: "Bolivia" },
    { country_code: "BQ", country_name: "Bonaire, Sint Eustatius and Saba" },
    { country_code: "BR", country_name: "Brazil" },
    { country_code: "BS", country_name: "Bahamas" },
    { country_code: "BT", country_name: "Bhutan" },
    { country_code: "BV", country_name: "Bouvet Island" },
    { country_code: "BW", country_name: "Botswana" },
    { country_code: "BY", country_name: "Belarus" },
    { country_code: "BZ", country_name: "Belize" },
    { country_code: "CA", country_name: "Canada" },
    { country_code: "CC", country_name: "Cocos (Keeling) Islands" },
    { country_code: "CD", country_name: "Congo, Democratic Republic of the" },
    { country_code: "CF", country_name: "Central African Republic" },
    { country_code: "CG", country_name: "Congo" },
    { country_code: "CH", country_name: "Switzerland" },
    { country_code: "CI", country_name: "Cote d'Ivoire" },
    { country_code: "CK", country_name: "Cook Islands" },
    { country_code: "CL", country_name: "Chile" },
    { country_code: "CM", country_name: "Cameroon" },
    { country_code: "CN", country_name: "China" },
    { country_code: "CO", country_name: "Colombia" },
    { country_code: "CR", country_name: "Costa Rica" },
    { country_code: "CU", country_name: "Cuba" },
    { country_code: "CV", country_name: "Cabo Verde" },
    { country_code: "CW", country_name: "Curacao" },
    { country_code: "CX", country_name: "Christmas Island" },
    { country_code: "CY", country_name: "Cyprus" },
    { country_code: "CZ", country_name: "Czech Republic" },
    { country_code: "DE", country_name: "Germany" },
    { country_code: "DJ", country_name: "Djibouti" },
    { country_code: "DK", country_name: "Denmark" },
    { country_code: "DM", country_name: "Dominica" },
    { country_code: "DO", country_name: "Dominican Republic" },
    { country_code: "DZ", country_name: "Algeria" },
    { country_code: "EC", country_name: "Ecuador" },
    { country_code: "EE", country_name: "Estonia" },
    { country_code: "EG", country_name: "Egypt" },
    { country_code: "EH", country_name: "Western Sahara" },
    { country_code: "ER", country_name: "Eritrea" },
    { country_code: "ES", country_name: "Spain" },
    { country_code: "ET", country_name: "Ethiopia" },
    { country_code: "FI", country_name: "Finland" },
    { country_code: "FJ", country_name: "Fiji" },
    { country_code: "FK", country_name: "Falkland Islands" },
    { country_code: "FM", country_name: "Micronesia" },
    { country_code: "FO", country_name: "Faroe Islands" },
    { country_code: "FR", country_name: "France" },
    { country_code: "GA", country_name: "Gabon" },
    { country_code: "GB", country_name: "United Kingdom" },
    { country_code: "GD", country_name: "Grenada" },
    { country_code: "GE", country_name: "Georgia" },
    { country_code: "GF", country_name: "French Guiana" },
    { country_code: "GG", country_name: "Guernsey" },
    { country_code: "GH", country_name: "Ghana" },
    { country_code: "GI", country_name: "Gibraltar" },
    { country_code: "GL", country_name: "Greenland" },
    { country_code: "GM", country_name: "Gambia" },
    { country_code: "GN", country_name: "Guinea" },
    { country_code: "GP", country_name: "Guadeloupe" },
    { country_code: "GQ", country_name: "Equatorial Guinea" },
    { country_code: "GR", country_name: "Greece" },
    { country_code: "GS", country_name: "South Georgia and South Sandwich Islands" },
    { country_code: "GT", country_name: "Guatemala" },
    { country_code: "GU", country_name: "Guam" },
    { country_code: "GW", country_name: "Guinea-Bissau" },
    { country_code: "GY", country_name: "Guyana" },
    { country_code: "HK", country_name: "Hong Kong" },
    { country_code: "HM", country_name: "Heard Island and McDonald Islands" },
    { country_code: "HN", country_name: "Honduras" },
    { country_code: "HR", country_name: "Croatia" },
    { country_code: "HT", country_name: "Haiti" },
    { country_code: "HU", country_name: "Hungary" },
    { country_code: "ID", country_name: "Indonesia" },
    { country_code: "IE", country_name: "Ireland" },
    { country_code: "IL", country_name: "Israel" },
    { country_code: "IM", country_name: "Isle of Man" },
    { country_code: "IN", country_name: "India" },
    { country_code: "IO", country_name: "British Indian Ocean Territory" },
    { country_code: "IQ", country_name: "Iraq" },
    { country_code: "IR", country_name: "Iran" },
    { country_code: "IS", country_name: "Iceland" },
    { country_code: "IT", country_name: "Italy" },
    { country_code: "JE", country_name: "Jersey" },
    { country_code: "JM", country_name: "Jamaica" },
    { country_code: "JO", country_name: "Jordan" },
    { country_code: "JP", country_name: "Japan" },
    { country_code: "KE", country_name: "Kenya" },
    { country_code: "KG", country_name: "Kyrgyzstan" },
    { country_code: "KH", country_name: "Cambodia" },
    { country_code: "KI", country_name: "Kiribati" },
    { country_code: "KM", country_name: "Comoros" },
    { country_code: "KN", country_name: "Saint Kitts and Nevis" },
    { country_code: "KP", country_name: "Korea, Democratic People's Republic of" },
    { country_code: "KR", country_name: "Korea, Republic of" },
    { country_code: "KW", country_name: "Kuwait" },
    { country_code: "KY", country_name: "Cayman Islands" },
    { country_code: "KZ", country_name: "Kazakhstan" },
    { country_code: "LA", country_name: "Lao People's Democratic Republic" },
    { country_code: "LB", country_name: "Lebanon" },
    { country_code: "LC", country_name: "Saint Lucia" },
    { country_code: "LI", country_name: "Liechtenstein" },
    { country_code: "LK", country_name: "Sri Lanka" },
    { country_code: "LR", country_name: "Liberia" },
    { country_code: "LS", country_name: "Lesotho" },
    { country_code: "LT", country_name: "Lithuania" },
    { country_code: "LU", country_name: "Luxembourg" },
    { country_code: "LV", country_name: "Latvia" },
    { country_code: "LY", country_name: "Libya" },
    { country_code: "MA", country_name: "Morocco" },
    { country_code: "MC", country_name: "Monaco" },
    { country_code: "MD", country_name: "Moldova" },
    { country_code: "ME", country_name: "Montenegro" },
    { country_code: "MF", country_name: "Saint Martin" },
    { country_code: "MG", country_name: "Madagascar" },
    { country_code: "MH", country_name: "Marshall Islands" },
    { country_code: "MK", country_name: "North Macedonia" },
    { country_code: "ML", country_name: "Mali" },
    { country_code: "MM", country_name: "Myanmar" },
    { country_code: "MN", country_name: "Mongolia" },
    { country_code: "MO", country_name: "Macao" },
    { country_code: "MP", country_name: "Northern Mariana Islands" },
    { country_code: "MQ", country_name: "Martinique" },
    { country_code: "MR", country_name: "Mauritania" },
    { country_code: "MS", country_name: "Montserrat" },
    { country_code: "MT", country_name: "Malta" },
    { country_code: "MU", country_name: "Mauritius" },
    { country_code: "MV", country_name: "Maldives" },
    { country_code: "MW", country_name: "Malawi" },
    { country_code: "MX", country_name: "Mexico" },
    { country_code: "MY", country_name: "Malaysia" },
    { country_code: "MZ", country_name: "Mozambique" },
    { country_code: "NA", country_name: "Namibia" },
    { country_code: "NC", country_name: "New Caledonia" },
    { country_code: "NE", country_name: "Niger" },
    { country_code: "NF", country_name: "Norfolk Island" },
    { country_code: "NG", country_name: "Nigeria" },
    { country_code: "NI", country_name: "Nicaragua" },
    { country_code: "NL", country_name: "Netherlands" },
    { country_code: "NO", country_name: "Norway" },
    { country_code: "NP", country_name: "Nepal" },
    { country_code: "NR", country_name: "Nauru" },
    { country_code: "NU", country_name: "Niue" },
    { country_code: "NZ", country_name: "New Zealand" },
    { country_code: "OM", country_name: "Oman" },
    { country_code: "PA", country_name: "Panama" },
    { country_code: "PE", country_name: "Peru" },
    { country_code: "PF", country_name: "French Polynesia" },
    { country_code: "PG", country_name: "Papua New Guinea" },
    { country_code: "PH", country_name: "Philippines" },
    { country_code: "PK", country_name: "Pakistan" },
    { country_code: "PL", country_name: "Poland" },
    { country_code: "PM", country_name: "Saint Pierre and Miquelon" },
    { country_code: "PN", country_name: "Pitcairn" },
    { country_code: "PR", country_name: "Puerto Rico" },
    { country_code: "PS", country_name: "Palestine, State of" },
    { country_code: "PT", country_name: "Portugal" },
    { country_code: "PW", country_name: "Palau" },
    { country_code: "PY", country_name: "Paraguay" },
    { country_code: "QA", country_name: "Qatar" },
    { country_code: "RE", country_name: "Reunion" },
    { country_code: "RO", country_name: "Romania" },
    { country_code: "RS", country_name: "Serbia" },
    { country_code: "RU", country_name: "Russian Federation" },
    { country_code: "RW", country_name: "Rwanda" },
    { country_code: "SA", country_name: "Saudi Arabia" },
    { country_code: "SB", country_name: "Solomon Islands" },
    { country_code: "SC", country_name: "Seychelles" },
    { country_code: "SD", country_name: "Sudan" },
    { country_code: "SE", country_name: "Sweden" },
    { country_code: "SG", country_name: "Singapore" },
    { country_code: "SH", country_name: "Saint Helena" },
    { country_code: "SI", country_name: "Slovenia" },
    { country_code: "SJ", country_name: "Svalbard and Jan Mayen" },
    { country_code: "SK", country_name: "Slovakia" },
    { country_code: "SL", country_name: "Sierra Leone" },
    { country_code: "SM", country_name: "San Marino" },
    { country_code: "SN", country_name: "Senegal" },
    { country_code: "SO", country_name: "Somalia" },
    { country_code: "SR", country_name: "Suriname" },
    { country_code: "SS", country_name: "South Sudan" },
    { country_code: "ST", country_name: "Sao Tome and Principe" },
    { country_code: "SV", country_name: "El Salvador" },
    { country_code: "SX", country_name: "Sint Maarten" },
    { country_code: "SY", country_name: "Syrian Arab Republic" },
    { country_code: "SZ", country_name: "Eswatini" },
    { country_code: "TC", country_name: "Turks and Caicos Islands" },
    { country_code: "TD", country_name: "Chad" },
    { country_code: "TF", country_name: "French Southern Territories" },
    { country_code: "TG", country_name: "Togo" },
    { country_code: "TH", country_name: "Thailand" },
    { country_code: "TJ", country_name: "Tajikistan" },
    { country_code: "TK", country_name: "Tokelau" },
    { country_code: "TL", country_name: "Timor-Leste" },
    { country_code: "TM", country_name: "Turkmenistan" },
    { country_code: "TN", country_name: "Tunisia" },
    { country_code: "TO", country_name: "Tonga" },
    { country_code: "TR", country_name: "Turkey" },
    { country_code: "TT", country_name: "Trinidad and Tobago" },
    { country_code: "TV", country_name: "Tuvalu" },
    { country_code: "TW", country_name: "Taiwan" },
    { country_code: "TZ", country_name: "Tanzania" },
    { country_code: "UA", country_name: "Ukraine" },
    { country_code: "UG", country_name: "Uganda" },
    { country_code: "UM", country_name: "United States Minor Outlying Islands" },
    { country_code: "US", country_name: "United States" },
    { country_code: "UY", country_name: "Uruguay" },
    { country_code: "UZ", country_name: "Uzbekistan" },
    { country_code: "VA", country_name: "Holy See (Vatican City State)" },
    { country_code: "VC", country_name: "Saint Vincent and the Grenadines" },
    { country_code: "VE", country_name: "Venezuela" },
    { country_code: "VG", country_name: "Virgin Islands, British" },
    { country_code: "VI", country_name: "Virgin Islands, U.S." },
    { country_code: "VN", country_name: "Viet Nam" },
    { country_code: "VU", country_name: "Vanuatu" },
    { country_code: "WF", country_name: "Wallis and Futuna" },
    { country_code: "WS", country_name: "Samoa" },
    { country_code: "YE", country_name: "Yemen" },
    { country_code: "YT", country_name: "Mayotte" },
    { country_code: "ZA", country_name: "South Africa" },
    { country_code: "ZM", country_name: "Zambia" },
    { country_code: "ZW", country_name: "Zimbabwe" }
  ];

  PageModule.prototype.getDefaultCountries = function() {
    return ISO_COUNTRIES;
  };

  PageModule.prototype.buildCountryOptions = function(items) {
    var list = (items && items.length > 0) ? items : ISO_COUNTRIES;
    return list.map(function(c) {
      var code = (c.country_code || '').toUpperCase();
      var name = c.country_name || code;
      return {
        value: code,
        label: name + ' (' + code + ')',
        country_code: code,
        country_name: name
      };
    });
  };

  PageModule.prototype.getCountryDisplayName = function(code) {
    if (!code) return '—';
    var upper = code.toUpperCase();
    for (var i = 0; i < ISO_COUNTRIES.length; i++) {
      if (ISO_COUNTRIES[i].country_code === upper) {
        return ISO_COUNTRIES[i].country_name + ' (' + upper + ')';
      }
    }
    return upper;
  };

  const FUSION_BUS = [
  {
    "value": "0012",
    "label": "0012"
  },
  {
    "value": "01PRC Exam BU",
    "label": "01PRC Exam BU"
  },
  {
    "value": "02PRC Exm",
    "label": "02PRC Exm"
  },
  {
    "value": "04PRC Exam",
    "label": "04PRC Exam"
  },
  {
    "value": "06PRC Exam",
    "label": "06PRC Exam"
  },
  {
    "value": "10PRCBU",
    "label": "10PRCBU"
  },
  {
    "value": "28Business Unit",
    "label": "28Business Unit"
  },
  {
    "value": "ABC Procurement BU",
    "label": "ABC Procurement BU"
  },
  {
    "value": "AKBusiness Unit Corporate",
    "label": "AKBusiness Unit Corporate"
  },
  {
    "value": "AKBusiness Unit Domestic",
    "label": "AKBusiness Unit Domestic"
  },
  {
    "value": "AKBusiness Unit South Asia ",
    "label": "AKBusiness Unit South Asia "
  },
  {
    "value": "AMNA BU",
    "label": "AMNA BU"
  },
  {
    "value": "AW GoSaaS",
    "label": "AW GoSaaS"
  },
  {
    "value": "AmnaNBU",
    "label": "AmnaNBU"
  },
  {
    "value": "AsadsBU",
    "label": "AsadsBU"
  },
  {
    "value": "Ascend Money",
    "label": "Ascend Money"
  },
  {
    "value": "Ascend Money ",
    "label": "Ascend Money "
  },
  {
    "value": "Ash BU",
    "label": "Ash BU"
  },
  {
    "value": "Ash Bash",
    "label": "Ash Bash"
  },
  {
    "value": "Asif-test",
    "label": "Asif-test"
  },
  {
    "value": "Ayaan",
    "label": "Ayaan"
  },
  {
    "value": "AyaanQ BU",
    "label": "AyaanQ BU"
  },
  {
    "value": "BU1",
    "label": "BU1"
  },
  {
    "value": "BU2",
    "label": "BU2"
  },
  {
    "value": "BUU1",
    "label": "BUU1"
  },
  {
    "value": "Canada Business Unit1",
    "label": "Canada Business Unit1"
  },
  {
    "value": "Cedar Hollow BU",
    "label": "Cedar Hollow BU"
  },
  {
    "value": "DS Procurement BU",
    "label": "DS Procurement BU"
  },
  {
    "value": "DSSBusiness Unit Corporate",
    "label": "DSSBusiness Unit Corporate"
  },
  {
    "value": "DSSBusiness Unit Domestic",
    "label": "DSSBusiness Unit Domestic"
  },
  {
    "value": "DSSBusiness Unit South Asia ",
    "label": "DSSBusiness Unit South Asia "
  },
  {
    "value": "Daim OG Bu",
    "label": "Daim OG Bu"
  },
  {
    "value": "Dropship Procurement BU",
    "label": "Dropship Procurement BU"
  },
  {
    "value": "Duck BU",
    "label": "Duck BU"
  },
  {
    "value": "FR_TEST_BU",
    "label": "FR_TEST_BU"
  },
  {
    "value": "GKS Test",
    "label": "GKS Test"
  },
  {
    "value": "Go Saas Labs",
    "label": "Go Saas Labs"
  },
  {
    "value": "GoSaaS",
    "label": "GoSaaS"
  },
  {
    "value": "GoSaaS Inc. BU",
    "label": "GoSaaS Inc. BU"
  },
  {
    "value": "GoSaaS Labs PK",
    "label": "GoSaaS Labs PK"
  },
  {
    "value": "HAHABusiness Unit Corporate",
    "label": "HAHABusiness Unit Corporate"
  },
  {
    "value": "HAHABusiness Unit Domestic",
    "label": "HAHABusiness Unit Domestic"
  },
  {
    "value": "HAHABusiness Unit South Asia ",
    "label": "HAHABusiness Unit South Asia "
  },
  {
    "value": "HASH BU",
    "label": "HASH BU"
  },
  {
    "value": "Harborfield BU",
    "label": "Harborfield BU"
  },
  {
    "value": "Huzaima BU",
    "label": "Huzaima BU"
  },
  {
    "value": "HuzaimaBU",
    "label": "HuzaimaBU"
  },
  {
    "value": "INVSHN Business Unit",
    "label": "INVSHN Business Unit"
  },
  {
    "value": "INVZN",
    "label": "INVZN"
  },
  {
    "value": "Imtenan BU",
    "label": "Imtenan BU"
  },
  {
    "value": "Inv_Test_BU",
    "label": "Inv_Test_BU"
  },
  {
    "value": "KHO BU1",
    "label": "KHO BU1"
  },
  {
    "value": "Khushinv",
    "label": "Khushinv"
  },
  {
    "value": "MA BU",
    "label": "MA BU"
  },
  {
    "value": "MOMI",
    "label": "MOMI"
  },
  {
    "value": "MWBK BU",
    "label": "MWBK BU"
  },
  {
    "value": "MWBK BU 1",
    "label": "MWBK BU 1"
  },
  {
    "value": "MWBK BU 2",
    "label": "MWBK BU 2"
  },
  {
    "value": "Mannan's BU",
    "label": "Mannan's BU"
  },
  {
    "value": "Maple Bend BU",
    "label": "Maple Bend BU"
  },
  {
    "value": "MinahilTemur",
    "label": "MinahilTemur"
  },
  {
    "value": "Momina US West BU",
    "label": "Momina US West BU"
  },
  {
    "value": "N24Business Unit Corporate",
    "label": "N24Business Unit Corporate"
  },
  {
    "value": "N24Business Unit Domestic",
    "label": "N24Business Unit Domestic"
  },
  {
    "value": "N24Business Unit South Asia ",
    "label": "N24Business Unit South Asia "
  },
  {
    "value": "New BU",
    "label": "New BU"
  },
  {
    "value": "OM BU",
    "label": "OM BU"
  },
  {
    "value": "OM_test_BU",
    "label": "OM_test_BU"
  },
  {
    "value": "PPBusiness Unit",
    "label": "PPBusiness Unit"
  },
  {
    "value": "PRC01",
    "label": "PRC01"
  },
  {
    "value": "PRC02 Business Unit",
    "label": "PRC02 Business Unit"
  },
  {
    "value": "PRC100 BU",
    "label": "PRC100 BU"
  },
  {
    "value": "PRCSYEDA_BZNS",
    "label": "PRCSYEDA_BZNS"
  },
  {
    "value": "PRCSYEDA_SERVICE",
    "label": "PRCSYEDA_SERVICE"
  },
  {
    "value": "PRCgilani",
    "label": "PRCgilani"
  },
  {
    "value": "PRCmomina",
    "label": "PRCmomina"
  },
  {
    "value": "PRCmomina services",
    "label": "PRCmomina services"
  },
  {
    "value": "Pinewatch BU",
    "label": "Pinewatch BU"
  },
  {
    "value": "Shahbano's BU",
    "label": "Shahbano's BU"
  },
  {
    "value": "Silver Creek BU",
    "label": "Silver Creek BU"
  },
  {
    "value": "Snober BU",
    "label": "Snober BU"
  },
  {
    "value": "Sohaib's BU",
    "label": "Sohaib's BU"
  },
  {
    "value": "Spark BU 02",
    "label": "Spark BU 02"
  },
  {
    "value": "Splendid BU",
    "label": "Splendid BU"
  },
  {
    "value": "T22 BU",
    "label": "T22 BU"
  },
  {
    "value": "T25",
    "label": "T25"
  },
  {
    "value": "TEST-AI",
    "label": "TEST-AI"
  },
  {
    "value": "Taimour's BU",
    "label": "Taimour's BU"
  },
  {
    "value": "Test BU",
    "label": "Test BU"
  },
  {
    "value": "Thermacell Repellents",
    "label": "Thermacell Repellents"
  },
  {
    "value": "UK1 CS",
    "label": "UK1 CS"
  },
  {
    "value": "US1",
    "label": "US1"
  },
  {
    "value": "USA Business Unit1",
    "label": "USA Business Unit1"
  },
  {
    "value": "USA Business Unit2",
    "label": "USA Business Unit2"
  },
  {
    "value": "USAMA BU ",
    "label": "USAMA BU "
  },
  {
    "value": "UserTestUnit",
    "label": "UserTestUnit"
  },
  {
    "value": "Vision BU",
    "label": "Vision BU"
  },
  {
    "value": "Z Procurement BU",
    "label": "Z Procurement BU"
  },
  {
    "value": "ZS BU",
    "label": "ZS BU"
  },
  {
    "value": "ZS Business Unit",
    "label": "ZS Business Unit"
  },
  {
    "value": "Zaid BU",
    "label": "Zaid BU"
  },
  {
    "value": "Zaid Building",
    "label": "Zaid Building"
  },
  {
    "value": "Zaid Building Services",
    "label": "Zaid Building Services"
  },
  {
    "value": "Zaid Case Study BU",
    "label": "Zaid Case Study BU"
  },
  {
    "value": "Zaid Practice Client BU",
    "label": "Zaid Practice Client BU"
  },
  {
    "value": "Zaid Practice Hub BU",
    "label": "Zaid Practice Hub BU"
  },
  {
    "value": "Zaid Services BU",
    "label": "Zaid Services BU"
  },
  {
    "value": "Zaynab Manufacturing",
    "label": "Zaynab Manufacturing"
  },
  {
    "value": "Zaynab Services",
    "label": "Zaynab Services"
  },
  {
    "value": "blenwiq",
    "label": "blenwiq"
  },
  {
    "value": "daim",
    "label": "daim"
  },
  {
    "value": "newBU",
    "label": "newBU"
  }
];

  PageModule.prototype.getDefaultBusinessUnits = function() {
    return FUSION_BUS;
  };

  
  PageModule.prototype.computeSpendBandsValid = function(bands) {
    if (!bands || bands.length === 0) return true;

    // Sort by min_amount
    var sorted = bands.slice().sort(function(a, b) {
      return Number(a.min_amount || 0) - Number(b.min_amount || 0);
    });

    for (var i = 0; i < sorted.length; i++) {
      var min = Number(sorted[i].min_amount || 0);
      var max = sorted[i].max_amount != null && sorted[i].max_amount !== '' ? Number(sorted[i].max_amount) : null;
      if (max != null && min > max) return false;


      if (i > 0) {
        var prevMax = sorted[i - 1].max_amount != null && sorted[i - 1].max_amount !== '' ? Number(sorted[i - 1].max_amount) : null;
        if (prevMax == null) return false; 
        var gap = min - prevMax;
        if (gap < 0 || gap > 1.01) return false;
      }

    }
    return true;
  };

  PageModule.prototype.formatCurrencyWithUSD = function(amount, code, rates) {
    var val = this.formatCurrency(amount, code);
    if (!code || code === 'USD' || !rates || rates.length === 0) {
      return val;
    }
    var rateObj = rates.find(function(r) { return r.currency_code === code; });
    if (rateObj && rateObj.to_usd_rate) {
       var usdAmount = Number(amount) * Number(rateObj.to_usd_rate);
       return val + " (" + this.formatCurrency(usdAmount, 'USD') + ")";
    }
    return val;
  };

  
  PageModule.prototype.setRuleInactiveIfZero = function(index, value, rules) {
    if (Number(value) !== 0) return rules;
    var updated = (rules || []).slice();
    if (updated[index] && updated[index].active !== 'N') {
      updated[index] = Object.assign({}, updated[index]);
      updated[index].active = 'N';
    }
    return updated;
  };

  return PageModule;
});

