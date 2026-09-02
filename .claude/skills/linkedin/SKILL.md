---
name: linkedin
description: "LinkedIn-Posts ueber bin/oddb_linkedin und src/util/linkedin_api.rb: Escaping (Little Text Format), Bilder, Scopes und Tokens, API-Version, Author-URN. Laden bei bin/oddb_linkedin, src/util/linkedin_api.rb oder Posts auf LinkedIn."
---

# LinkedIn

Vorfall-Historie und Regeln aus `CLAUDE.md` (ausgelagert am 02.09.2026). Neue Notizen zu diesem Teilsystem gehoeren hierher, nicht in `CLAUDE.md`.

### LinkedIn (`bin/oddb_linkedin`, `src/util/linkedin_api.rb`)

- **An unescaped underscore eats the link.** `commentary` is read as "Little Text Format", where `\|{}@[]()<>*_~` are markup and are dropped from the published text — so `.../rss_html/channel/price_cut.rss` was shown as `.../rsshtml/channel/pricecut.rss`, a link into nowhere, while the post looked fine. `LinkedInApi.escape` handles it. **`#` is left alone on purpose**: escaped it is an ordinary hash sign and the hashtags stop being hashtags. The backslash is escaped first, or it escapes its own escapes. This cannot be verified by reading the post back — `GET /rest/posts/<urn>` answers **403**, `w_member_social` is write-only — so publish both forms side by side to connections and look. Tests: `test/test_util/linkedin_api.rb`.
- `authorize` → `post --body=text.txt [--image=path::alttext]` → `delete --id=urn`. Credentials in `etc/oddb.yml` (gitignored, mode 600): `linkedin_client_id`, `linkedin_client_secret`, `linkedin_access_token`, `linkedin_author_urn`.
- **An image uploaded as `application/octet-stream` vanishes silently.** LinkedIn answers 201, hands back a valid urn, and creates the post without complaint — the image is simply not there. `GET /rest/images/<urn>` is what tells the two apart: with `image/png` it has a `downloadUrl`. `mime_for` derives the type from the extension.
- **Scopes are stamped into a token when it is issued.** Enabling a product (*Share on LinkedIn*, *Sign In with LinkedIn using OpenID Connect*) or verifying the app changes nothing for existing tokens — they keep answering **403 with an empty message**. Re-run `authorize`. That empty 403 looks identical whether a product is missing, the app is unverified, or the author urn is nonsense: posting with a deliberately absurd author returns exactly the same, which is how the author was ruled out as the cause.
- **The `profileId` in a profile's page source is not the OpenID subject.** `ACoAAABS404B…` and `B7IDuzOVBE` are the same person; only the second works as `author`. Scraping for it is pointless anyway — LinkedIn answers **HTTP 999** to automated fetches of a profile.
- **`202601` is the only active `LinkedIn-Version`**; everything older answers `NONEXISTENT_VERSION`. Probe with an empty body (`{}` → 422 "author is required" means the version is live) so nothing gets published while testing.
- `w_member_social` is **write-only** — a published post cannot be read back, so verify in the browser. Posting is immediate: this API has **no drafts**, unlike `bin/oddb_mail`. Images cannot be added afterwards, hence `delete_post`. One image goes to `content.media`, several to `content.multiImage`.
- The redirect uri must match the registered one character for character (`https://localhost` here); a mismatch is the only thing LinkedIn says out loud.
