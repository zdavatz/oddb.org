// compactdetail.js -- oddb.org -- 26.08.2026
//
// Blendet auf schmalen Bildschirmen die Feldpaare der Detailansicht aus, deren
// Wert leer ist.
//
// Die Detailansicht ist eine Tabelle aus Label/Wert-Paaren, und ein Feld ohne
// Inhalt kommt als <TD class="list">&nbsp;</TD>. Gestapelt wird daraus eine
// leere Zeile unter einer Beschriftung - "Revisionsdatum", "Gueltig bis",
// "Beschreibung" standen so untereinander mit nichts dazwischen.
//
// Warum nicht in CSS: ein Kasten, der nur ein &nbsp; enthaelt, ist fuer
// :empty nicht leer, und CSS kann Textinhalt nicht pruefen. Warum nicht im
// View: dort haenge es an der Breite des Bildschirms, die der Server nicht
// kennt - am Desktop stehen die Paare nebeneinander und ein leerer Wert
// kostet nichts.
(function () {
  "use strict";

  var QUERY = "(max-width: 640px)";
  var HIDDEN = "oddb-empty-pair";

  function blank(cell) {
    //   ist das &nbsp;.
    return !cell || cell.textContent.replace(/[\s ]+/g, "") === "";
  }

  function apply(narrow) {
    var labels = document.querySelectorAll("td.list > label");
    for (var i = 0; i < labels.length; i++) {
      var cell = labels[i].parentNode;
      var value = cell.nextElementSibling;
      // Nur echte Paare: die naechste Zelle muss der Wert sein, nicht schon
      // die naechste Beschriftung.
      if (!value || value.querySelector("label")) { continue; }
      var hide = narrow && blank(value);
      cell.classList.toggle(HIDDEN, hide);
      value.classList.toggle(HIDDEN, hide);
    }
  }

  function start() {
    if (!window.matchMedia) { return; }
    var mq = window.matchMedia(QUERY);
    apply(mq.matches);
    var onChange = function () { apply(mq.matches); };
    if (mq.addEventListener) {
      mq.addEventListener("change", onChange);
    } else if (mq.addListener) {
      mq.addListener(onChange);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
