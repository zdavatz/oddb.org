// compactdetail.js -- oddb.org -- 26.08.2026
//
// Blendet auf schmalen Bildschirmen aus, was nur Platz kostet: die Feldpaare
// der Detailansicht ohne Wert, und in den Karten der Trefferliste die Zellen,
// die nur ein &nbsp; enthalten.
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
    cards(narrow);
  }

  // Dasselbe in den Karten der Trefferliste. Eine Packung ohne Preis hat dort
  // Zellen, die nur ein &nbsp; enthalten - und weil der Selbstbehalt eine
  // ganze Zeile breit ist, klaffte zwischen Name und Marken eine leere
  // Flaeche. :empty greift auch hier nicht.
  function cards(narrow) {
    var names = document.querySelectorAll("td.col-name_base");
    for (var i = 0; i < names.length; i++) {
      var row = names[i].parentNode;
      var cells = row.children;
      for (var j = 0; j < cells.length; j++) {
        var cell = cells[j];
        if (cell === names[i]) { continue; }
        cell.classList.toggle(HIDDEN, narrow && blank(cell));
      }
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
