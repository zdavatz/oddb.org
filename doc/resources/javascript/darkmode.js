// Dunkelmodus-Umschalter fuer oddb.org
//
// Setzt html[data-theme] und laesst dark.css den Rest machen. Kein Cookie, kein
// Neuladen, keine Anfrage an den Server: die Wahl liegt in localStorage und
// gilt sofort.
//
// Bewusst nicht ueber die bestehende Farbwahl (:styles, oddb-blue.css und
// Geschwister) gebaut. Die ist wirkungslos, seit das Stylesheet eingebettet
// statt verlinkt wird - publictemplate.rb sucht "oddb.css" in einem <style>-
// Block, in dem der Dateiname nicht vorkommt, und ersetzt folglich nichts.
//
// Ohne Javascript bleibt die Seite hell und vollstaendig bedienbar; es faellt
// nur der Knopf weg.

(function () {
  "use strict";

  var KEY = "oddb-theme";
  var root = document.documentElement;

  function stored() {
    try {
      return window.localStorage.getItem(KEY);
    } catch (e) {
      // Privates Fenster, gesperrte Seitendaten: dann eben ohne Gedaechtnis.
      return null;
    }
  }

  function remember(theme) {
    try {
      window.localStorage.setItem(KEY, theme);
    } catch (e) {
      // Nicht schlimm - die Wahl gilt fuer diese Seite trotzdem.
    }
  }

  function preferred() {
    var saved = stored();
    if (saved === "dark" || saved === "light") {
      return saved;
    }
    return window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  function apply(theme) {
    if (theme === "dark") {
      root.setAttribute("data-theme", "dark");
    } else {
      root.removeAttribute("data-theme");
    }
    var button = document.getElementById("dark-mode-toggle");
    if (button) {
      var dark = theme === "dark";
      button.textContent = dark ? "☀" : "☽";
      button.setAttribute("aria-pressed", dark ? "true" : "false");
      button.setAttribute("title", dark ? LABEL_LIGHT : LABEL_DARK);
      button.setAttribute("aria-label", dark ? LABEL_LIGHT : LABEL_DARK);
    }
  }

  // Die Beschriftung kommt aus dem Dokument, damit sie der Sprache der Seite
  // folgt. Fehlt sie, wird deutsch angenommen.
  var LABEL_DARK = root.getAttribute("data-theme-label-dark") || "Dunkler Modus";
  var LABEL_LIGHT = root.getAttribute("data-theme-label-light") || "Heller Modus";

  // Vor dem ersten Zeichnen anwenden, sonst blitzt die helle Seite kurz auf.
  apply(preferred());

  function toggle() {
    var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
    remember(next);
    apply(next);
  }

  function addButton() {
    if (document.getElementById("dark-mode-toggle")) {
      return;
    }
    var button = document.createElement("button");
    button.id = "dark-mode-toggle";
    button.type = "button";
    button.addEventListener("click", toggle);
    document.body.appendChild(button);
    apply(root.getAttribute("data-theme") === "dark" ? "dark" : "light");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", addButton);
  } else {
    addButton();
  }

  // Wer nie selbst gewaehlt hat, folgt weiter der Einstellung des Systems.
  if (window.matchMedia) {
    var query = window.matchMedia("(prefers-color-scheme: dark)");
    var follow = function (event) {
      if (!stored()) {
        apply(event.matches ? "dark" : "light");
      }
    };
    if (query.addEventListener) {
      query.addEventListener("change", follow);
    } else if (query.addListener) {
      query.addListener(follow);
    }
  }
})();
