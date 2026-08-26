// externallinks.js -- oddb.org -- 26.08.2026
//
// Setzt target="_blank" auf jeden Verweis, der auf einen fremden Host zeigt -
// ywesee.com, swissmedic.ch, drugbank.ca, google.com und was in den Fach- und
// Patienteninformationen sonst noch verlinkt ist.
//
// Warum hier und nicht in den Views: die Verweise entstehen an ueber
// zweihundert Stellen im Baum, und ein Teil davon steckt im Text der
// Fachinformationen, den ein Parser liefert. Eine Regel an einer Stelle deckt
// alle ab, auch die, die morgen dazukommen.
//
// rel="noopener noreferrer" gehoert zwingend dazu: ohne noopener kann die
// geoeffnete Seite ueber window.opener auf die oeffnende zugreifen.
(function () {
  "use strict";

  function isExternal(link) {
    // href="" oder ein reiner Anker ist nichts Fremdes.
    var href = link.getAttribute("href");
    if (!href || href.charAt(0) === "#") { return false; }
    // mailto:, tel:, javascript: - kein Host, also nichts zu oeffnen.
    if (!/^https?:/i.test(link.protocol)) { return false; }
    // link.hostname ist der aufgeloeste Host, auch bei relativen Adressen.
    // Die Anwendung schreibt ihre eigenen Verweise absolut, mit eigenem Host -
    // die duerfen nicht im neuen Reiter landen.
    return link.hostname !== window.location.hostname;
  }

  function mark(root) {
    var links = (root || document).querySelectorAll("a[href]");
    for (var i = 0; i < links.length; i++) {
      var link = links[i];
      if (link.target || !isExternal(link)) { continue; }
      link.target = "_blank";
      var rel = link.rel ? link.rel.split(/\s+/) : [];
      if (rel.indexOf("noopener") === -1) { rel.push("noopener"); }
      if (rel.indexOf("noreferrer") === -1) { rel.push("noreferrer"); }
      link.rel = rel.join(" ");
    }
  }

  function start() {
    mark(document);
    // Die Vervollstaendigung der Suche und der Interaktionsrechner bauen
    // Verweise nachtraeglich ein.
    if (!window.MutationObserver) { return; }
    new MutationObserver(function (records) {
      for (var i = 0; i < records.length; i++) {
        var added = records[i].addedNodes;
        for (var j = 0; j < added.length; j++) {
          if (added[j].nodeType === 1) { mark(added[j]); }
        }
      }
    }).observe(document.documentElement, {childList: true, subtree: true});
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
