# Swiyu OID4VP Login — Architecture Summary

## Protocol

The system implements **OID4VP** (OpenID for Verifiable Presentations) using the Swiss government's **Swiyu** identity wallet infrastructure. Users authenticate by presenting a verifiable credential (SD-JWT) from their Swiyu wallet app, containing `firstName`, `lastName`, and `gln` (GLN = Global Location Number for healthcare professionals).

## Components

### 1. `SwiyuClient` (`src/util/swiyu_client.rb`)

- HTTP client that talks to the Swiyu verifier API at `https://swiyu.ywesee.com/verifier-mgmt/api`
- `create_verification` — POSTs a presentation request asking for a `doctor-credential-sdjwt` with fields `firstName`, `lastName`, `gln`, issuer-locked to a specific DID
- `get_verification(id)` — GETs the verification status (PENDING → SUCCESS/FAILED/EXPIRED)

### 2. `SwiyuMiddleware` (`src/util/swiyu_middleware.rb`)

- Rack middleware mounted in `config.ru` via `use ODDB::SwiyuMiddleware`
- Handles 5 routes before requests reach the SBSM app:
  - `GET /swiyu` — serves the static login HTML page
  - `GET /swiyu/login` — creates a new verification, returns JSON with `id` + `verification_deeplink`
  - `GET /swiyu/status/:id` — polls verification state, returns claims on SUCCESS
  - `POST /swiyu/session` — re-validates the verification server-side, validates GLN format (`760XXXXXXXXXX`), credential type, and names, then stores auth data in a thread-safe in-memory hash keyed by the Rack session cookie `_session_id`
  - `GET /swiyu/logout` — clears the auth store entry, redirects to `/`

### 3. `SwiyuRoles` (`src/util/swiyu_roles.rb`)

- Singleton that loads `etc/swiyu_roles.yml`
- Maps GLN → roles/permissions config. Unknown GLNs get a default `PowerUser` role
- Provides the `accepted_issuer_did` for the verification request

### 4. `SwiyuUser` (`src/model/user.rb`)

- Extends `SBSM::KnownUser` — the authenticated user object for the session
- Created in `Session#login` when Swiyu auth data exists in the middleware store
- Implements `allowed?(action, key)` with a permission system: RootUser gets everything, others check explicit permissions from `swiyu_roles.yml`
- Provides `model` (fetches an associated ODBA object by `odba_id` if configured), `creditable?`, preference accessors, etc.

### 5. Session integration (`src/util/session.rb`)

- `Session#login` checks `SwiyuMiddleware.get_auth(session_id)` — if `swiyu_auth == "true"`, it creates a `SwiyuUser` from the claims + role config
- `Session#active_state` detects stale auth (middleware cleared it via logout) and resets the session user
- `Session#logout` calls `SwiyuMiddleware.clear_auth`

### 6. Login page (`doc/resources/swiyu/login.html`)

- Static HTML+JS page with QR code generation (via `qrcode.js`)
- Flow: calls `/swiyu/login` → renders QR code of the `verification_deeplink` → polls `/swiyu/status/:id` every 2 seconds → on SUCCESS, POSTs to `/swiyu/session` → redirects to `/`
- 5-minute timeout, retry button on failure/expiry

## Auth Flow

```
Browser → GET /swiyu (login page)
       → GET /swiyu/login (create verification)
       ← {id, verification_deeplink}
       → QR code displayed, user scans with Swiyu wallet
       → Poll GET /swiyu/status/:id every 2s
       ← state: SUCCESS + claims
       → POST /swiyu/session {verification_id}
         (server re-validates, stores auth in memory store)
       ← redirect to /
       → Normal SBSM request flow picks up SwiyuUser via Session#login
```

## Navigation

In `state/global.rb`, the user navigation shows `:swiyu_logout` for authenticated `SwiyuUser` instances and `:swiyu_login` for unauthenticated visitors. The old Yus authentication system was replaced entirely.
