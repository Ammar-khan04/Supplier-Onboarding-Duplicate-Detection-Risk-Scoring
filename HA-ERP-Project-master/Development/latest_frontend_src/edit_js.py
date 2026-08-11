import re

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.js", "r") as f:
    js = f.read()

spend_bands_valid = """
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
        if (Math.abs(prevMax - min) > 0.01) return false;
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
"""

js = js.replace("return PageModule;", spend_bands_valid + "\n  return PageModule;")

with open("webApps/supplierportal/flows/item-1/pages/item-1-start-page.js", "w") as f:
    f.write(js)
