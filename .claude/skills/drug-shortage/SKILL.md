---
name: drug-shortage
description: "Lieferengpass-Import von drugshortage.ch: jobs/update_drugshortage, src/plugin/shortage.rb, JSON-API mit HMAC-Signatur, Feld-Mapping auf Package#shortage_*. Laden bei shortage.rb, HTTP 403 vom API oder den shortage_-Feldern."
---

# Lieferengpass-Import

Vorfall-Historie und Regeln aus `CLAUDE.md` (ausgelagert am 02.09.2026). Neue Notizen zu diesem Teilsystem gehoeren hierher, nicht in `CLAUDE.md`.

### Drug Shortage Import (`jobs/update_drugshortage`)

- Imports current Swiss drug shortages from drugshortage.ch into the `shortage_*` fields on `Package` objects (`shortage_state`, `shortage_last_update`, `shortage_delivery_date`, `shortage_link`)
- Core implementation in `src/plugin/shortage.rb` (`ShortagePlugin`)
- **May 2026 migration**: drugshortage.ch retired its ASP.NET `UebersichtaktuelleLieferengpaesse2.aspx` page (now returns HTTP 500) and switched to a WordPress site with JSON APIs. The plugin fetches `https://www.drugshortage.ch/api/api_engpaesse.php` — the official "show all current shortages" endpoint backing the `uebersicht-nach-firmen` page. Returns ~705 active shortages as JSON in a single call, under the top-level `engpaesse` key.
- **June 2026 endpoint move**: the endpoint moved from `/api_engpaesse.php` to `/api/api_engpaesse.php`. At the same time `status` values gained a leading category-number prefix (e.g. `"1 aktuell keine Lieferungen"` instead of `"aktuell keine Lieferungen"`). The plugin strips the leading `\d+\s+` from `status` before assigning `shortage_state`, so existing DB values stay stable and the migration email stays quiet on field churn. The leading digit duplicates `bewertung` and is not needed.
- **June 2026 HMAC request signing**: later in June 2026 the API began rejecting unsigned requests with **HTTP 403** (`{"fehler":"Zugriff verweigert – fehlende Header"}`). Every call must now carry an HMAC-SHA256 signature plus the headers the server's CORS policy advertises (`X-Timestamp`, `X-Nonce`, `X-Signature`, `X-Requested-With`). The signature is `HMAC_SHA256(secret, "<timestamp>|<nonce>|<api_name>")` as lowercase hex, where `api_name` is `api_engpaesse` and the shared secret + scheme are taken verbatim from the site's inline signing JS (visible in the page source of `uebersicht-nach-firmen`; the same scheme also backs the newer `ds.php?a=…` endpoints). `ShortagePlugin#shortage_source_headers` generates a fresh timestamp+nonce per call (the server rejects stale/replayed requests) and these headers are passed through `Latest.get_latest_file` → `Latest.fetch_with_http` (`URI.open`). The URL, the `engpaesse` payload, and the field mapping are unchanged — only the headers were added. If this breaks again, re-read `HMAC_SECRET` and the `hmacSign()` message format from the page source.
- JSON field mapping: `gtin` → `gtin`, `mutation` (DD.MM.YYYY) → `shortage_last_update`, `status` (stripped of `"<digit> "` prefix) → `shortage_state`, `lieferdatum` → `shortage_delivery_date`, `id` → used to construct `shortage_link`.
- **`shortage_link`** is constructed as `https://www.drugshortage.ch/index.php/detail-lieferengpass/?ID=<id>` where `<id>` is the stable upstream record id from `engpaesse[].id`. This is the new per-shortage detail page (replaces the old `detail_lieferengpass.aspx?ID=...`).
- Change-detection still uses `Latest.get_latest_file`'s byte-size comparison (`src/util/latest.rb`); fresh fetch is skipped if today's downloaded size matches the cached `data/json/drugshortage-latest.json`.
