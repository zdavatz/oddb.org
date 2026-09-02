---
name: swiyu-login
description: "Swiyu-Login und Anfragelimit: SwiyuMiddleware, SwiyuClient (DCQL, direct_post.jwt), Verifier auf swiyu.ywesee.com, DID nur auf swiyu-int, iOS-Deeplink-Problem, Debugging ueber die Verifier-Logs. Laden bei src/util/swiyu_*.rb, etc/swiyu_roles.yml, doc/resources/swiyu/, QUERY_LIMIT in src/util/session.rb."
---

# Swiyu-Login und Anfragelimit

Vorfall-Historie und Regeln aus `CLAUDE.md` (ausgelagert am 02.09.2026). Neue Notizen zu diesem Teilsystem gehoeren hierher, nicht in `CLAUDE.md`.

### Swiyu Login & Query Limit

- Anonymous users are limited to 5 searches per 24h (`QUERY_LIMIT` in `src/util/session.rb`). After exceeding the limit, the user sees a login prompt.
- Swiyu login is handled by `SwiyuMiddleware` (`src/util/swiyu_middleware.rb`) which serves `doc/resources/swiyu/login.html` and manages auth via an in-memory store keyed by `_session_id` cookie.
- After login, the user is redirected back to their last search via a `return_url` query parameter passed through the Swiyu flow. Key files: `src/view/limit.rb`, `src/view/navigation.rb`, `doc/resources/swiyu/login.html`.
- The IP's query limit counter is reset on Swiyu login (`active_state` in `src/util/session.rb`).
- `SwiyuClient` (`src/util/swiyu_client.rb`) talks to the verifier at `https://swiyu.ywesee.com/verifier-mgmt/api`. That server lives in a separate repo (`swiyu4health`, host 212.51.146.241); ch.oddb.org is authorised there by IP whitelist, not by API key.
- **The verifier (4.x) accepts only DCQL.** Sending `presentation_definition` fails with `{"error_description":"dcqlQuery: must not be null"}`. The request body therefore uses `dcql_query` with `response_mode: "direct_post.jwt"` — swiyu wallet 1.17 enforces payload encryption during presentations, so a plain `direct_post` is refused with `invalid_request` before the wallet ever posts. The `CREDENTIAL_FORMAT` constant selects the media type (`vc+sd-jwt`, matching what the issuer emits — `dc+sd-jwt` is the newer canonical name and also accepted).
- `accepted_issuer_did` in `etc/swiyu_roles.yml` must match the issuer DID actually running on swiyu.ywesee.com. A mismatch surfaces only as a failed verification, never as a config error.
- The verifier returns the presented claims grouped by DCQL query id and wrapped in an array: `wallet_response.credential_subject_data` is `{"doctor_credential": [{...}]}`, not the flat claims hash the `presentation_definition` flow used to produce. `SwiyuMiddleware#extract_claims` unwraps both shapes; the key is `SwiyuClient::DCQL_CREDENTIAL_ID`.
- **Two swiyu apps on one phone: iOS picks the wrong one.** The deeplink is a custom URL scheme, `swiyu-verify://?client_id=...&request_uri=...`, and both the public app and the ABN (Abnahme) app register it. Apple leaves the choice undefined when several apps claim one scheme, and the sender cannot influence it — no parameter, no header, nothing in the QR payload. Only a Universal Link (https + `apple-app-site-association`) binds to one app, and only the apps' publisher can set that up. **The QR code is the unambiguous path**: opening the intended app and scanning from inside it always reaches that app; only tapping the button is a coin toss. `doc/resources/swiyu/login.html` says so on the page.
- **Our DID lives on the integration network only.** `identifier-reg.trust-infra.swiyu-int.admin.ch` answers 200 for `.../did/5b1672d3-.../did.jsonl`, the production registry `identifier-reg.trust-infra.swiyu.admin.ch` answers 404. So only a wallet wired to swiyu-int can complete a login here at all — which app the link opens is a second question on top of that one.
- Debugging: the wallet reports every rejected authorization request as a bare `invalid_request` and then stops contacting the server. The evidence lives on the verifier host — `/var/log/apache2/swiyu-access.log` and the `management` table of `swiyu-verifier-db`. A `GET …/request-object/<id>` with no following `POST …/response-data` means the wallet rejected the request object itself, so the fault is on the verifier side, not in the credential.
