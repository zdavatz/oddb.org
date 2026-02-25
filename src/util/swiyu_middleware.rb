require "rack"
require "json"
require "util/swiyu_client"
require "util/swiyu_roles"

module ODDB
  class SwiyuMiddleware
    SESSION_ID = "_session_id"
    GLN_PATTERN = /\A760\d{10}\z/

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

      SwiyuMiddleware.store_auth(session_id, {
        "swiyu_auth" => "true",
        "swiyu_gln" => gln,
        "swiyu_firstName" => first_name,
        "swiyu_lastName" => last_name
      })

      json_response({
        "status" => "ok",
        "redirect" => "/",
        "name" => "#{first_name} #{last_name}",
        "gln" => gln
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

    def extract_claims(result)
      result.dig("wallet_response", "credential_subject_data") || {}
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

      def clear_expired(max_age_seconds = 1800)
        @auth_mutex.synchronize do
          @auth_store.delete_if { |_, data| data["_created_at"] && (Time.now - data["_created_at"]) > max_age_seconds }
        end
      end
    end
  end
end
