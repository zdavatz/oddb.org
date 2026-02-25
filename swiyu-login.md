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

---

# Test Infrastructure Summary

## Overview

The project uses two testing frameworks side by side: **Minitest + FlexMock** for unit tests and **RSpec + Watir** for browser integration tests.

## 1. Minitest + FlexMock (Unit Tests — `test/`)

### Runner: `OddbTestRunner` (`test/helpers.rb`)

The custom `OddbTestRunner` class handles a key problem: some test files pollute global state (ODBA persistence, module constants) and fail when loaded in the same process as other tests.

- Each sub-suite (`test/test_model/suite.rb`, `test/test_state/suite.rb`, etc.) declares a `must_be_run_separately` list of files that need process isolation
- `run_isolated_tests` — runs those files as separate `bundle exec ruby` subprocesses, collecting pass/fail per file
- `run_normal_tests` — `require`s all remaining `.rb` test files into the current process (standard Minitest in-process execution)
- `show_results_and_exit` — prints a summary with timing, exits non-zero if any subprocess failed

### Top-level orchestration (`test/suite.rb`)

Delegates to 9 sub-suites, each run as its own subprocess:

| Suite | Isolated files |
|---|---|
| `test_state/` | `admin/password_lost.rb`, `drugs/fachinfo.rb`, `global.rb`, `page_facade.rb` |
| `test_view/` | `searchbar.rb`, `personal.rb`, `navigationfoot.rb`, + 4 more |
| `test_model/` | `package.rb` |
| `test_util/`, `test_command/`, `test_custom/`, `test_plugin/`, `test_remote/` | varies |
| `ext/` | `meddata/test/test_drbsession.rb` |

### ODBA Stub (`test/stub/odba.rb`)

Replaces the real ODBA persistence layer with in-memory stubs (`CacheStub`, `StorageStub`) so tests don't need a PostgreSQL database. Most model/state/view unit tests load this stub.

### VCR + WebMock (`test/test_helpers.rb`)

Records and replays HTTP interactions for external services (Swissmedic, Refdata, BAG). VCR cassettes are stored in `fixtures/vcr_cassettes/`. The `before_record` hooks trim large responses (Excel files, XML feeds) to only include test-relevant GTINs, keeping cassettes small.

### Environment

- `ENV["TZ"] = "UTC"` is forced globally
- The `$LOAD_PATH` is set to `src/` so requires match production paths

## 2. RSpec + Watir (Browser Integration Tests — `spec/`)

- 20 spec files for GUI-level integration testing
- Uses **Watir** (browser automation) with **Headless** (Xvfb) for headless Chrome
- Uses **page-object** gem for page object pattern
- Configurable target: tests run against `http://127.0.0.1:8012` by default, or against `https://ch.oddb.org` via `ODDB_URL` env var
- `spec/parslet_spec.rb` is the exception — it's a pure unit spec for the Parslet composition parser, no browser needed

## 3. StandardRB (Linting)

`bundle exec standardrb` enforces Ruby style. Not part of the test suite but available for CI.

## How to Run

```bash
# Full unit test suite (CI)
bundle exec ruby test/suite.rb

# Single test file
bundle exec ruby test/test_model/test_package.rb

# Parslet composition specs only
bundle exec rspec spec/parslet_spec.rb

# Full browser integration specs
bundle exec rspec spec

# Linting
bundle exec standardrb
```
