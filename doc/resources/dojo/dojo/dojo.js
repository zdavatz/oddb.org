// Minimal Dojo shim - full Dojo toolkit not installed
(function() {
  var dojoConfig = window.dojoConfig || {};
  dojoConfig.searchIds = dojoConfig.searchIds || [];
  window.dojoConfig = dojoConfig;
  window.require = function(deps, callback) {
    // no-op: Dojo modules not available
  };
  window.dojo = {
    ready: function(fn) { if (typeof fn === 'function') fn(); },
    byId: function(id) { return document.getElementById(id); },
    connect: function() {},
    keys: { ENTER: 13 }
  };
})();
