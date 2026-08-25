#!/usr/bin/env ruby

# ODDB::GoogleServiceAccount -- oddb.org -- 2026
#
# Zugriffstoken für ein Google-Dienstkonto: RS256-JWT selbst signieren und
# gegen ein Bearer-Token eintauschen. Bewusst ohne googleauth, signet oder
# google-apis-* - es sind fünfzig Zeilen stdlib, und die Abhängigkeiten wiegen
# schwerer als der Code.
#
# Zwei Nutzer: GoogleSearchConsole (nur Lesen von Property-Daten) und GmailApi
# (Entwürfe im ywesee-Postfach). Der Unterschied liegt allein im scope und
# darin, dass Gmail ein Postfach zu übernehmen verlangt - dafür trägt der
# claim ein "sub" mit der Adresse des Postfachs, was Google
# "domain-weite Delegation" nennt und was in der Workspace-Verwaltung für
# genau diesen scope freigeschaltet sein muss.

require "base64"
require "json"
require "net/http"
require "openssl"
require "uri"

module ODDB
  module GoogleServiceAccount
    class Error < StandardError; end

    TOKEN_URI = "https://oauth2.googleapis.com/token"
    JWT_GRANT = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    TOKEN_LIFETIME = 3600
    TOKEN_REFRESH_MARGIN = 300
    # Googles alte p12-Schlüssel tragen alle diese feste Passphrase.
    P12_PASSPHRASE = "notasecret"

    attr_reader :key_file, :client_email

    # `subject` ist das zu übernehmende Postfach, oder nil.
    def load_credentials(key_file, client_email, subject = nil)
      @key_file = key_file
      @subject = subject
      raise Error, "service account key not found: #{@key_file}" unless File.exist?(@key_file.to_s)
      if /\.p12\z/i.match?(@key_file)
        load_p12(client_email)
      else
        load_json(client_email)
      end
    end

    def access_token
      if @access_token.nil? || Time.now >= @token_expires_at
        @access_token = fetch_access_token
      end
      @access_token
    end

    private

    def load_json(client_email)
      @credentials = JSON.parse(File.read(@key_file))
      @client_email = client_email || @credentials["client_email"]
      raise Error, "#{@key_file} has no client_email" unless @client_email
      key = @credentials["private_key"]
      raise Error, "#{@key_file} has no private_key" unless key
      @private_key = OpenSSL::PKey::RSA.new(key)
      @token_uri = @credentials["token_uri"] || TOKEN_URI
    rescue JSON::ParserError => error
      raise Error, "cannot parse #{@key_file}: #{error.message}"
    end

    def load_p12(client_email)
      @client_email = client_email
      unless @client_email
        raise Error, "#{@key_file} is a p12 key, which does not contain the " \
          "service account address. Configure it, or download the JSON key " \
          "instead, which carries both."
      end
      p12 = OpenSSL::PKCS12.new(File.binread(@key_file), P12_PASSPHRASE)
      @private_key = p12.key
      raise Error, "#{@key_file} contains no private key" unless @private_key
      @credentials = {}
      @token_uri = TOKEN_URI
    rescue OpenSSL::PKCS12::PKCS12Error => error
      raise Error, "cannot read #{@key_file} as a p12 key (#{error.message}). " \
        "Google's p12 keys use the passphrase #{P12_PASSPHRASE.inspect}."
    end

    def fetch_access_token
      issued_at = Time.now.to_i
      claim = {
        "iss" => @client_email,
        "scope" => self.class::SCOPE,
        "aud" => @token_uri,
        "exp" => issued_at + TOKEN_LIFETIME,
        "iat" => issued_at
      }
      claim["sub"] = @subject if @subject
      response = post_form(@token_uri,
        "grant_type" => JWT_GRANT,
        "assertion" => signed_jwt(claim))
      token = response["access_token"]
      raise Error, "no access_token in token response" unless token
      lifetime = (response["expires_in"] || TOKEN_LIFETIME).to_i
      @token_expires_at = Time.now + lifetime - TOKEN_REFRESH_MARGIN
      token
    end

    # RS256, was Googles Dienstkonten verwenden.
    def signed_jwt(claim)
      segments = [{"alg" => "RS256", "typ" => "JWT"}, claim].collect { |part|
        base64url(JSON.generate(part))
      }
      signature = @private_key.sign(OpenSSL::Digest.new("SHA256"), segments.join("."))
      (segments << base64url(signature)).join(".")
    end

    def base64url(str)
      Base64.urlsafe_encode64(str, padding: false)
    end

    def post_form(uri, params)
      request = Net::HTTP::Post.new(URI(uri))
      request.set_form_data(params)
      perform(uri, request)
    end

    def get_json(uri)
      request = Net::HTTP::Get.new(URI(uri))
      request["Authorization"] = "Bearer #{access_token}"
      perform(uri, request)
    end

    def post_json(uri, body, headers = {})
      request = Net::HTTP::Post.new(URI(uri))
      request["Content-Type"] = "application/json"
      request["Authorization"] ||= "Bearer #{access_token}"
      headers.each { |key, value| request[key] = value }
      request.body = JSON.generate(body)
      perform(uri, request)
    end

    def perform(uri, request)
      uri = URI(uri)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
        open_timeout: 20, read_timeout: 60) { |http| http.request(request) }
      parsed = begin
        JSON.parse(response.body.to_s)
      rescue JSON::ParserError
        {}
      end
      unless response.is_a?(Net::HTTPSuccess)
        # Nicht blind digen: Googles Token-Endpunkt antwortet auch mit einem
        # nackten String, und ein TypeError hier verdeckt die eigentliche
        # Meldung - was genau das ist, was man in dem Moment lesen will.
        message = if parsed.is_a?(Hash)
          detail = parsed["error"]
          # Der Token-Endpunkt liefert "error" als String
          # ("unauthorized_client"), die uebrigen Dienste als Objekt mit
          # "message". Blind zu digen wirft dort TypeError und verdeckt genau
          # die Meldung, die man lesen will.
          (detail.is_a?(Hash) && detail["message"]) ||
            parsed["error_description"] ||
            (detail.is_a?(String) && detail) || response.message
        else
          response.body.to_s[0, 300]
        end
        raise Error, "#{response.code} #{message}"
      end
      parsed
    rescue Error
      raise
    rescue => error
      raise Error, "#{error.class}: #{error.message}"
    end
  end
end
