#!/usr/bin/env ruby

# GoogleSearchConsole -- oddb.org -- 2026 -- zdavatz@ywesee.com
#
# Thin client for the Search Console URL Inspection API.
#
# Note what this API can and cannot do: there is NO endpoint that lists the
# urls behind a Page Indexing ("Serverfehler (5xx)") report - the old
# urlcrawlerrorssamples api was shut down in 2019 and never replaced. Only
# four resources exist: Search Analytics, Sitemaps, Sites and URL Inspection.
# So the url list has to come from our side (jobs/check_indexing reads it out
# of the app log) and this class looks each one up individually.
#
# Auth is a service account: sign a JWT with the account's private key, trade
# it for an access token. Implemented on stdlib (openssl/net/http) rather than
# pulling in googleauth + signet + google-apis-* for a single job.
#
# Setup:
#   1. create a service account in Google Cloud, download its JSON key
#   2. add that account's client_email as a user of BOTH Search Console
#      properties (ch.oddb.org and generika.cc) - "Full" or "Owner", "Restricted"
#      is not enough for URL Inspection
#   3. point gsc_service_account_json in etc/oddb.yml at the key file

require "json"
require "net/http"
require "openssl"
require "base64"
require "uri"
require "util/logfile"

module ODDB
  class GoogleSearchConsole
    class Error < StandardError; end

    TOKEN_URI = "https://oauth2.googleapis.com/token"
    INSPECT_URI = "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect"
    SCOPE = "https://www.googleapis.com/auth/webmasters.readonly"
    JWT_GRANT = "urn:ietf:params:oauth:grant-type:jwt-bearer"

    # Google's published limits: 2000 inspections per property per day and 600
    # per minute. We stay under the per-minute one with a small delay and let
    # the caller cap the daily volume.
    DAILY_QUOTA = 2000
    MIN_SECONDS_BETWEEN_CALLS = 0.12

    # A token is good for an hour; refresh a little early.
    TOKEN_LIFETIME = 3600
    TOKEN_REFRESH_MARGIN = 300

    # Google's legacy p12 keys are all encrypted with this fixed passphrase.
    P12_PASSPHRASE = "notasecret"

    attr_reader :key_file, :client_email

    def initialize(key_file = nil, client_email = nil)
      @key_file = key_file || ODDB.config.gsc_service_account_json
      raise Error, "gsc_service_account_json is not configured" unless @key_file
      raise Error, "service account key not found: #{@key_file}" unless File.exist?(@key_file)
      if /\.p12\z/i.match?(@key_file)
        load_p12(client_email)
      else
        load_json(client_email)
      end
      @last_call_at = nil
    end

    # Look one url up. Returns the indexStatusResult hash, or raises Error.
    def inspect_url(url, site_url, language_code = "de")
      body = {
        "inspectionUrl" => url,
        "siteUrl" => site_url,
        "languageCode" => language_code
      }
      result = post_json(INSPECT_URI, body, "Authorization" => "Bearer #{access_token}")
      result.dig("inspectionResult", "indexStatusResult") || {}
    end

    # Look several urls up, yielding (url, status_hash_or_nil, error_or_nil) as
    # we go so a long run can report progress and survive single failures.
    def inspect_urls(urls, site_url, language_code = "de")
      results = {}
      urls.each do |url|
        throttle
        begin
          results[url] = inspect_url(url, site_url, language_code)
          yield(url, results[url], nil) if block_given?
        rescue Error => error
          results[url] = nil
          yield(url, nil, error) if block_given?
        end
      end
      results
    end

    private

    def load_json(client_email)
      @credentials = JSON.parse(File.read(@key_file))
      # Easy to grab the wrong file in the Cloud Console: an OAuth client for a
      # desktop app looks like {"installed": {"client_id", "client_secret"}} and
      # needs an interactive browser consent, which is a different flow
      # entirely. Say so rather than failing later on a missing private_key.
      %w[installed web].each do |kind|
        next unless @credentials[kind]
        raise Error, "#{@key_file} is an OAuth client (#{kind}), not a service " \
          "account key. Create a service account under " \
          "console.cloud.google.com/iam-admin/serviceaccounts and download its " \
          "JSON key - it has \"type\": \"service_account\" and a private_key."
      end
      %w[client_email private_key].each do |field|
        raise Error, "service account key has no #{field}" unless @credentials[field]
      end
      @client_email = client_email || @credentials["client_email"]
      @private_key = OpenSSL::PKey::RSA.new(@credentials["private_key"])
      @token_uri = @credentials["token_uri"] || TOKEN_URI
    rescue JSON::ParserError
      raise Error, "#{@key_file} is not valid JSON. A .p12 key must be named .p12."
    end

    # Legacy p12 keys carry the private key but no metadata - the certificate
    # CN is the service account's numeric unique id, not its email - so the
    # address has to come from gsc_service_account_email.
    def load_p12(client_email)
      @client_email = client_email || ODDB.config.gsc_service_account_email
      unless @client_email
        raise Error, "#{@key_file} is a p12 key, which does not contain the " \
          "service account address. Set gsc_service_account_email in " \
          "etc/oddb.yml to the account's ...iam.gserviceaccount.com address, " \
          "or download the JSON key instead, which carries both."
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

    def throttle
      return unless @last_call_at
      elapsed = Time.now - @last_call_at
      sleep(MIN_SECONDS_BETWEEN_CALLS - elapsed) if elapsed < MIN_SECONDS_BETWEEN_CALLS
    ensure
      @last_call_at = Time.now
    end

    def access_token
      if @access_token.nil? || Time.now >= @token_expires_at
        @access_token = fetch_access_token
      end
      @access_token
    end

    def fetch_access_token
      issued_at = Time.now.to_i
      claim = {
        "iss" => @client_email,
        "scope" => SCOPE,
        "aud" => @token_uri,
        "exp" => issued_at + TOKEN_LIFETIME,
        "iat" => issued_at
      }
      response = post_form(@token_uri,
        "grant_type" => JWT_GRANT,
        "assertion" => signed_jwt(claim))
      token = response["access_token"]
      raise Error, "no access_token in token response" unless token
      lifetime = (response["expires_in"] || TOKEN_LIFETIME).to_i
      @token_expires_at = Time.now + lifetime - TOKEN_REFRESH_MARGIN
      token
    end

    # RS256, which is what Google's service accounts use.
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

    def post_json(uri, body, headers = {})
      request = Net::HTTP::Post.new(URI(uri))
      request["Content-Type"] = "application/json"
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
        # The api reports quota exhaustion and missing permissions as 403 with
        # different messages; pass the message through so the job can say which.
        message = parsed.dig("error", "message") || response.message
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
