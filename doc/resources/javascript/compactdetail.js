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
  var BREAK = "oddb-line-break";

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
    emptyRows(narrow);
    spacers(narrow);
    toggleUnderLogo(narrow);
  }

  // darkmode.js haengt den Umschalter ans Ende von document.body, weil er
  // dort als position:fixed oben rechts steht. Auf dem Telefon gehoert er
  // unter das Logo - dafuer muss er auch im Baum dorthin, sonst landet er
  // beim Wechsel auf position:static am Fuss der Seite.
  function toggleUnderLogo(narrow) {
    var button = document.getElementById("dark-mode-toggle");
    if (!button) { return; }
    var logo = document.querySelector("img.welcomeleft, img.logo, img.welcomecenter");
    var cell = logo && logo.closest("td");
    if (narrow && cell) {
      if (button.parentNode !== cell) { cell.appendChild(button); }
    } else if (button.parentNode !== document.body) {
      document.body.appendChild(button);
    }
  }

  // Zellen, die nur ein &nbsp; enthalten und trotzdem eine Zeile kosten:
  // die erste Zelle der Fusszeile (bei angemeldeten Nutzern steht dort die
  // Begruessung, die bleiben muss - deshalb wird der Inhalt geprueft und
  // nicht die Klasse) und die zweite Zelle des ATC-Bandes.
  function spacers(narrow) {
    var cells = document.querySelectorAll("td.navigation, td.atc, td.explain");
    for (var i = 0; i < cells.length; i++) {
      cells[i].classList.toggle(HIDDEN, narrow && blank(cells[i]));
    }
  }

  // Ganze Zeilen, deren Zellen alle nur ein &nbsp; tragen. Auf der
  // Startseite steht zwischen Logo und Sprachwahl ein
  // <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>: auf dem grossen
  // Bildschirm eine Zeile von 19px, auf dem Telefon drei uebereinander, weil
  // die Zellen dort Bloecke sind. Zusammen mit der leeren td.right neben dem
  // Logo waren das rund 76px Leere.
  //
  // Nur Zeilen ohne jeden Inhalt, und nur solche mit mehr als einer Zelle -
  // eine einzelne leere Zelle kann eine Spalte offenhalten, die daneben
  // gebraucht wird.
  function emptyRows(narrow) {
    // Nur Gerueste, nie Datentabellen: eine Datentabelle hat eine Kopfzeile
    // aus th, und dort wuerde display:none eine Spalte verschieben statt
    // eine Leere zu schliessen.
    var tables = document.querySelectorAll("table.composite");
    for (var t = 0; t < tables.length; t++) {
      if (tables[t].querySelector(":scope > tbody > tr > th")) { continue; }
      var rows = tables[t].querySelectorAll(":scope > tbody > tr");
      for (var i = 0; i < rows.length; i++) {
        // Die Packungszeilen werden Karten; um deren leere Zellen kuemmert
        // sich cards(), samt der Umbruchzelle, die leer sein muss.
        if (rows[i].querySelector(":scope > td.col-name_base")) { continue; }
        var cells = rows[i].children;
        var blanks = 0;
        for (var j = 0; j < cells.length; j++) {
          var cell = cells[j];
          // children.length ist hier das Entscheidende und nicht bloss
          // Vorsicht: blank() sieht nur Text, und eine Zelle mit dem Logo
          // oder dem Suchfeld darin hat keinen. Ohne diese Bedingung
          // verschwanden Logo, Umschalter und die ganze Suchmaske.
          var empty = cell.tagName === "TD" &&
            !cell.classList.contains(BREAK) &&
            cell.children.length === 0 && blank(cell);
          if (empty) { blanks++; }
          cell.classList.toggle(HIDDEN, narrow && empty);
        }
        rows[i].classList.toggle(HIDDEN, narrow && cells.length > 0 && blanks === cells.length);
      }
    }
  }

  // Dasselbe in den Karten der Trefferliste. Eine Packung ohne Preis hat dort
  // Zellen, die nur ein &nbsp; enthalten - und weil der Selbstbehalt eine
  // ganze Zeile breit ist, klaffte zwischen Name und Marken eine leere
  // Flaeche. :empty greift auch hier nicht.
  var BADGES = ["col-limitation_text", "col-minifi", "col-fachinfo",
    "col-patinfo", "col-narcotic", "col-complementary_type",
    "col-comarketing", "col-feedback", "col-google_search", "col-notify"];

  function isBadge(cell) {
    for (var i = 0; i < BADGES.length; i++) {
      if (cell.classList.contains(BADGES[i])) { return true; }
    }
    return false;
  }

  function cards(narrow) {
    var names = document.querySelectorAll("td.col-name_base");
    for (var i = 0; i < names.length; i++) {
      var row = names[i].parentNode;
      var cells = row.children;
      var first = null;
      for (var j = 0; j < cells.length; j++) {
        var cell = cells[j];
        if (cell.classList.contains(BREAK)) { continue; }
        if (cell !== names[i]) {
          cell.classList.toggle(HIDDEN, narrow && blank(cell));
        }
        if (!first && isBadge(cell) && !cell.classList.contains(HIDDEN)) {
          first = cell;
        }
      }
      lineBreak(row, first, narrow);
    }
  }

  // Die Marken gehoeren unter den Namen, immer - auch wenn Name, Groesse und
  // Preis die erste Zeile nicht fuellen. flex-grow kann das nicht: eine
  // Flexbox belegt die Zeile erst und verteilt den Rest danach, ein Umbruch
  // laesst sich damit nicht erzwingen. Ein leeres Element mit flex-basis 100%
  // davor kann es - und das gibt es in der Tabelle nicht, also wird es hier
  // eingesetzt.
  function lineBreak(row, before, narrow) {
    var existing = row.querySelector("." + BREAK);
    if (!narrow || !before) {
      if (existing) { existing.parentNode.removeChild(existing); }
      return;
    }
    if (existing) {
      if (existing.nextElementSibling === before) { return; }
      existing.parentNode.removeChild(existing);
    }
    var br = document.createElement("td");
    br.className = BREAK;
    row.insertBefore(br, before);
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
