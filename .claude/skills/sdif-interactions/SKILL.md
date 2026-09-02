---
name: sdif-interactions
description: "Interaktionscheck ueber die SDIF-SQLite-Datenbank (data/sqlite/interactions.db): Tabellen, vier Lookup-Strategien, Severity-Scoring, Route- und Kombi-Badges, Gegenrichtung, Autocomplete. Laden bei src/model/sdif_interaction.rb, src/view/interactions/*, src/view/searchbar.rb, src/plugin/epha_interactions.rb."
---

# SDIF-Interaktionen

Vorfall-Historie und Regeln aus `CLAUDE.md` (ausgelagert am 02.09.2026). Neue Notizen zu diesem Teilsystem gehoeren hierher, nicht in `CLAUDE.md`.

### SDIF Drug Interactions

- Drug interaction checking uses the **SDIF** (Swiss Drug Interactions Finder) SQLite database at `data/sqlite/interactions.db`
- Core model: `src/model/sdif_interaction.rb` (module `ODDB::EphaInteractions` — name kept for backward compatibility)
- **DB tables**: `epha_interactions` (curated ATC-to-ATC, 15k+ pairs), `interactions` (substance-level from FachInfo), `drugs` (brand/ATC/substances/interactions_text), `class_keywords` (ATC prefix keywords), `cyp_rules` (CYP enzyme rules)
- **Four lookup strategies** (in priority order):
  1. **EPha curated** (label: "Quelle: EPha.ch"): Direct ATC-to-ATC lookup in `epha_interactions` table — risk_class (A/B/C/D/X), effect, mechanism, measures. Table only present if SDIF was built with `--epha` flag; gracefully skipped otherwise.
  2. **Substance-level** (label: "Quelle: Swissmedic FI"): Look up SDIF substance names via ATC code (`sdif_substances_for_atc`), query `interactions` table for direct matches
  3. **ATC class-level** (label: "Quelle: Swissmedic FI"): Load drug's `interactions_text` from `drugs` table, search for keywords from `class_keywords` table matching other drug's ATC prefix, extract sentence context, score severity
  4. **CYP enzyme-mediated** (label: "Quelle: Swissmedic FI"): Load `cyp_rules` table, check if one drug's FI text mentions a CYP enzyme and the other drug is a known inhibitor/inducer by ATC prefix or substance name. Covers CYP3A4, CYP2D6, CYP2C9, CYP2C19, CYP1A2, CYP2C8, CYP2B6.
- **Route indicators**: Purple badges showing administration route (topisch, i.v., p.o., s.c., inhalativ, nasal, ophthalm., etc.) next to drug names in interaction headers, read from the `route` column in the `drugs` table
- **Combo hints**: Green badges showing approved combination therapy hints (e.g. "Zugelassene Kombitherapie mit ASS") from the `combo_hint` column in the `drugs` table
- **Gegenrichtung hints**: Compares each interaction's severity against the maximum severity across all interaction types for the same drug pair (both directions). FI results (class-level, substance, CYP) show "Gegenrichtung hat höhere Einstufung" when their severity is lower than the pair maximum. EPha results show the hint only when the EPha severity itself differs between directions (asymmetric EPha rating). The pair-max includes EPha, class-level, CYP, and reverse-direction severities.
- **Severity scoring**: Keyword-based, synced with SDIF: 3=Kontraindiziert, 2=Schwerwiegend (toxizität, hyperkaliämie, etc.), 1=Vorsicht (erhöh-stem, plasmakonzentration, etc.), 0=Keine Einstufung. Tiermodell/Tierstudie/Tierversuch mentions are deprioritized in context extraction to avoid false snippet attribution.
- **Autocomplete**: Vanilla JS with fetch() to `/ajax_matches` endpoint, 200ms debounce, custom dropdown. Uses inline `onkeydown` attribute for keyboard handling (Enter key must be caught before browser form submission). Dojo toolkit replaced with minimal shim at `doc/resources/dojo/dojo/dojo.js`.
- Key files: `src/view/searchbar.rb` (autocomplete), `src/view/interactions/interaction_chooser.rb` (form), `src/plugin/epha_interactions.rb` (DB update plugin)
