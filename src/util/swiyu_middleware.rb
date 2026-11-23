require "rack"
require "json"
require "util/swiyu_client"
require "util/swiyu_roles"
require "util/swiyu_passkeys"
require "webauthn"

module ODDB
  class SwiyuMiddleware
    SESSION_ID = "_session_id"
    GLN_PATTERN = /\A760\d{10}\z/
    # Wie lange eine Passkey-Challenge gueltig ist.
    CHALLENGE_TTL = 300

    def initialize(app)
      @app = app
      @client = SwiyuClient.new
    end

    def call(env)
      request = Rack::Request.new(env)
      path = request.path_info

      case path
      when "/swiyu"
        serve_login_page(request)
      when "/swiyu/login"
        handle_create_verification(request)
      when %r{\A/swiyu/status/([a-zA-Z0-9\-]+)\z}
        handle_poll_status(request, $1)
      when "/swiyu/session"
        handle_create_session(request)
      when "/swiyu/logout"
        handle_logout(request)
      when "/swiyu/passkey/register/options"
        handle_passkey_register_options(request)
      when "/swiyu/passkey/register"
        handle_passkey_register(request)
      when "/swiyu/passkey/login/options"
        handle_passkey_login_options(request)
      when "/swiyu/passkey/login"
        handle_passkey_login(request)
      else
        @app.call(env)
      end
    end

    private

    def serve_login_page(request)
      html_path = File.expand_path("../../../doc/resources/swiyu/login.html", __FILE__)
      if File.exist?(html_path)
        [200, {"Content-Type" => "text/html; charset=utf-8"}, [File.read(html_path)]]
      else
        [500, {"Content-Type" => "text/plain"}, ["Login page not found"]]
      end
    end

    def handle_create_verification(request)
      result = @client.create_verification
      json_response(result)
    rescue => e
      SBSM.logger.error("Swiyu create_verification error: #{e.message}")
      json_response({"error" => "Failed to create verification"}, 502)
    end

    def handle_poll_status(request, verification_id)
      result = @client.get_verification(verification_id)
      state = result["state"]
      response_data = {"state" => state}

      if state == "SUCCESS"
        claims = extract_claims(result)
        response_data["authenticated"] = true
        response_data["claims"] = {
          "firstName" => claims["firstName"],
          "lastName" => claims["lastName"],
          "gln" => claims["gln"]
        }
      end

      json_response(response_data)
    rescue => e
      SBSM.logger.error("Swiyu poll_status error: #{e.message}")
      json_response({"error" => "Failed to check status"}, 502)
    end

    def handle_create_session(request)
      return method_not_allowed unless request.post?

      body = JSON.parse(request.body.read)
      verification_id = body["verification_id"]

      unless verification_id
        return json_response({"status" => "error", "message" => "Missing verification_id"}, 400)
      end

      # Re-validate server-side
      result = @client.get_verification(verification_id)

      unless result["state"] == "SUCCESS"
        return json_response({"status" => "error", "state" => result["state"]}, 401)
      end

      claims = extract_claims(result)
      gln = claims["gln"]
      first_name = claims["firstName"]
      last_name = claims["lastName"]
      vct = claims["vct"]

      # Validate credential type
      unless vct == "doctor-credential-sdjwt"
        return json_response({"status" => "error", "message" => "Invalid credential type"}, 401)
      end

      # Validate GLN format
      unless gln && GLN_PATTERN.match?(gln)
        return json_response({"status" => "error", "message" => "Invalid GLN"}, 401)
      end

      # Validate names
      if first_name.nil? || first_name.strip.empty? || last_name.nil? || last_name.strip.empty?
        return json_response({"status" => "error", "message" => "Missing name"}, 401)
      end

      session_id = request.cookies[SESSION_ID]
      unless session_id && !session_id.empty?
        return json_response({"status" => "error", "message" => "No session"}, 400)
      end

      # Passkeys gelten so lange wie der zuletzt vorgelegte Nachweis.
      valid_until = credential_valid_until(claims)
      SwiyuPasskeys.instance.renew(gln, valid_until) if valid_until

      SwiyuMiddleware.store_auth(session_id, {
        "swiyu_auth" => "true",
        "swiyu_gln" => gln,
        "swiyu_firstName" => first_name,
        "swiyu_lastName" => last_name,
        "swiyu_valid_until" => valid_until&.utc&.iso8601
      })

      json_response({
        "status" => "ok",
        "redirect" => "/",
        "name" => "#{first_name} #{last_name}",
        "gln" => gln,
        # Ohne exp im Nachweis keine Passkeys - sie haetten kein Ablaufdatum.
        "passkey_offer" => !valid_until.nil?,
        "valid_until" => valid_until&.utc&.iso8601
      })
    rescue JSON::ParserError
      json_response({"status" => "error", "message" => "Invalid JSON"}, 400)
    rescue => e
      SBSM.logger.error("Swiyu create_session error: #{e.message}")
      json_response({"status" => "error", "message" => "Server error"}, 500)
    end

    def handle_logout(request)
      session_id = request.cookies[SESSION_ID]
      SwiyuMiddleware.clear_auth(session_id) if session_id
      [302, {"Location" => "/"}, []]
    end

    # exp des SD-JWT, also credential_valid_until beim Ausstellen.
    def credential_valid_until(claims)
      exp = Integer(claims["exp"], exception: false)
      exp && Time.at(exp)
    end

    # ── Passkeys (WebAuthn) ──────────────────────────────────────────────
    # Einrichten nur mit bestehender swiyu-Anmeldung in derselben Session.
    # Ein Passkey-Login legt dieselben Auth-Daten an wie der swiyu-Login,
    # Session#login merkt keinen Unterschied.

    def handle_passkey_register_options(request)
      return method_not_allowed unless request.post?
      session_id, auth = swiyu_session(request)
      return json_response({"status" => "error", "message" => "Not logged in"}, 401) unless auth
      unless auth["swiyu_valid_until"]
        return json_response({"status" => "error", "message" => "No credential expiry"}, 409)
      end

      gln = auth["swiyu_gln"]
      store = SwiyuPasskeys.instance
      options = relying_party(request).options_for_registration(
        user: {
          id: store.user_handle(gln),
          name: gln,
          display_name: "#{auth["swiyu_firstName"]} #{auth["swiyu_lastName"]}"
        },
        exclude: store.for_gln(gln).keys,
        authenticator_selection: {resident_key: "required", user_verification: "required"}
      )
      SwiyuMiddleware.store_challenge(session_id, :register, options.challenge)
      json_response(options.as_json)
    rescue => e
      SBSM.logger.error("Swiyu passkey register_options error: #{e.message}")
      json_response({"status" => "error", "message" => "Server error"}, 500)
    end

    def handle_passkey_register(request)
      return method_not_allowed unless request.post?
      session_id, auth = swiyu_session(request)
      return json_response({"status" => "error", "message" => "Not logged in"}, 401) unless auth
      challenge = SwiyuMiddleware.take_challenge(session_id, :register)
      return json_response({"status" => "error", "message" => "No challenge"}, 400) unless challenge

      credential = relying_party(request).verify_registration(
        JSON.parse(request.body.read), challenge, user_verification: true
      )
      SwiyuPasskeys.instance.purge_expired
      SwiyuPasskeys.instance.add(
        credential_id: credential.id,
        public_key: credential.public_key,
        sign_count: credential.sign_count,
        gln: auth["swiyu_gln"],
        first_name: auth["swiyu_firstName"],
        last_name: auth["swiyu_lastName"],
        valid_until: Time.parse(auth["swiyu_valid_until"]),
        label: request.user_agent.to_s[0, 120]
      )
      json_response({"status" => "ok", "valid_until" => auth["swiyu_valid_until"]})
    rescue WebAuthn::Error, JSON::ParserError => e
      SBSM.logger.warn("Swiyu passkey register rejected: #{e.class}: #{e.message}")
      json_response({"status" => "error", "message" => "Passkey rejected"}, 400)
    rescue => e
      SBSM.logger.error("Swiyu passkey register error: #{e.message}")
      json_response({"status" => "error", "message" => "Server error"}, 500)
    end

    def handle_passkey_login_options(request)
      return method_not_allowed unless request.post?
      session_id = request.cookies[SESSION_ID]
      return json_response({"status" => "error", "message" => "No session"}, 400) if session_id.to_s.empty?

      # Ohne allowCredentials: der Browser bietet alle Passkeys fuer diese
      # Domain an (discoverable credentials).
      options = relying_party(request).options_for_authentication(user_verification: "required")
      SwiyuMiddleware.store_challenge(session_id, :login, options.challenge)
      json_response(options.as_json)
    rescue => e
      SBSM.logger.error("Swiyu passkey login_options error: #{e.message}")
      json_response({"status" => "error", "message" => "Server error"}, 500)
    end

    def handle_passkey_login(request)
      return method_not_allowed unless request.post?
      session_id = request.cookies[SESSION_ID]
      return json_response({"status" => "error", "message" => "No session"}, 400) if session_id.to_s.empty?
      challenge = SwiyuMiddleware.take_challenge(session_id, :login)
      return json_response({"status" => "error", "message" => "No challenge"}, 400) unless challenge

      store = SwiyuPasskeys.instance
      record = nil
      credential, = relying_party(request).verify_authentication(
        JSON.parse(request.body.read), challenge, user_verification: true
      ) do |webauthn_credential|
        record = store.find(webauthn_credential.id)
        raise WebAuthn::Error, "unknown passkey" unless record
        Struct.new(:public_key, :sign_count).new(record["public_key"], record["sign_count"])
      end

      unless store.valid?(record)
        return json_response({"status" => "error", "message" => "Passkey expired",
                              "expired" => true}, 401)
      end
      store.touch(credential.id, credential.sign_count)

      SwiyuMiddleware.store_auth(session_id, {
        "swiyu_auth" => "true",
        "swiyu_gln" => record["gln"],
        "swiyu_firstName" => record["first_name"],
        "swiyu_lastName" => record["last_name"],
        "swiyu_valid_until" => record["valid_until"],
        "swiyu_passkey" => "true"
      })
      json_response({"status" => "ok", "name" => "#{record["first_name"]} #{record["last_name"]}"})
    rescue WebAuthn::Error, JSON::ParserError => e
      SBSM.logger.warn("Swiyu passkey login rejected: #{e.class}: #{e.message}")
      json_response({"status" => "error", "message" => "Passkey rejected"}, 401)
    rescue => e
      SBSM.logger.error("Swiyu passkey login error: #{e.message}")
      json_response({"status" => "error", "message" => "Server error"}, 500)
    end

    def swiyu_session(request)
      session_id = request.cookies[SESSION_ID]
      return [nil, nil] if session_id.to_s.empty?
      auth = SwiyuMiddleware.get_auth(session_id)
      auth && auth["swiyu_auth"] == "true" ? [session_id, auth] : [session_id, nil]
    end

    # Passkeys sind an den Hostnamen gebunden (rp_id). Hinter dem Apache
    # kommt die Anfrage per http an, die Seite laeuft aber unter https.
    def relying_party(request)
      host = request.host
      origin = if %w[localhost 127.0.0.1].include?(host)
        request.base_url
      else
        "https://#{host}"
      end
      WebAuthn::RelyingParty.new(
        id: host,
        name: "ODDB.org",
        allowed_origins: [origin],
        algorithms: %w[ES256 RS256]
      )
    end

    def extract_claims(result)
      data = result.dig("wallet_response", "credential_subject_data")
      return {} unless data.is_a?(Hash)
      # Alte Struktur (presentation_definition): Claims lagen flach.
      return data if data.key?("vct")
      # DCQL (swiyu-verifier 4.x): nach der Query-ID gruppiert, und der Wert
      # ist ein Array, weil eine Abfrage mehrere passende Nachweise liefern kann.
      entry = data[SwiyuClient::DCQL_CREDENTIAL_ID] || data.values.first
      entry = entry.first if entry.is_a?(Array)
      entry.is_a?(Hash) ? entry : {}
    end

    def json_response(data, status = 200)
      [status, {"Content-Type" => "application/json"}, [data.to_json]]
    end

    def method_not_allowed
      [405, {"Content-Type" => "text/plain"}, ["Method not allowed"]]
    end

    # Thread-safe auth store
    @auth_store = {}
    @auth_mutex = Mutex.new
    @challenges = {}
    @challenge_mutex = Mutex.new

    class << self
      def store_auth(session_id, data)
        @auth_mutex.synchronize { @auth_store[session_id] = data }
      end

      def get_auth(session_id)
        @auth_mutex.synchronize { @auth_store[session_id] }
      end

      def clear_auth(session_id)
        @auth_mutex.synchronize { @auth_store.delete(session_id) }
      end

      def store_challenge(session_id, purpose, challenge)
        @challenge_mutex.synchronize do
          now = Time.now
          @challenges.delete_if { |_, c| now - c[:at] > CHALLENGE_TTL }
          @challenges[[session_id, purpose]] = {challenge: challenge, at: now}
        end
      end

      # Einmal verwendbar: holt die Challenge und loescht sie.
      def take_challenge(session_id, purpose)
        @challenge_mutex.synchronize do
          entry = @challenges.delete([session_id, purpose])
          entry[:challenge] if entry && Time.now - entry[:at] <= CHALLENGE_TTL
        end
      end

      def clear_expired(max_age_seconds = 1800)
        @auth_mutex.synchronize do
          @auth_store.delete_if { |_, data| data["_created_at"] && (Time.now - data["_created_at"]) > max_age_seconds }
        end
      end
    end
  end
end
