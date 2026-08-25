#!/usr/bin/env ruby

# ODDB::GoogleOAuth -- oddb.org -- 2026
#
# Zugriffstoken über einen OAuth-Client, nicht über ein Dienstkonto.
#
# Der Unterschied ist der Punkt: ein Dienstkonto muesste das Postfach
# uebernehmen, was domainweite Delegation in der Workspace-Verwaltung
# voraussetzt. Ein OAuth-Client fragt stattdessen den Postfachinhaber einmal
# um Zustimmung; danach genuegt ein Refresh-Token, und niemand muss
# Administrator sein.
#
# Einrichtung, einmalig:
#
#   1. In der Cloud Console (Projekt oddb-506507) unter "APIs & Dienste ->
#      Anmeldedaten" einen OAuth-Client vom Typ "Desktop-App" anlegen und
#      client_id und client_secret nach etc/oddb.yml eintragen:
#        gmail_oauth_client_id:     ...apps.googleusercontent.com
#        gmail_oauth_client_secret: ...
#   2. bin/oddb_mail authorize   und der Anleitung folgen
#
# Das Refresh-Token landet in gmail_oauth_refresh_token in etc/oddb.yml, das
# gitignored ist - wie smtp_pass und der Schluessel der Search Console.

require "base64"
require "json"
require "net/http"
require "uri"

module ODDB
  class GoogleOAuth
    class Error < StandardError; end

    AUTH_URI = "https://accounts.google.com/o/oauth2/v2/auth"
    TOKEN_URI = "https://oauth2.googleapis.com/token"
    # Google hat "urn:ietf:wg:oauth:2.0:oob" abgeschaltet; erlaubt ist nur noch
    # eine Weiterleitung auf localhost. Auf einem Server ohne Browser laeuft
    # dort nichts - der Code steht aber in der Adresszeile, aus der er sich
    # abschreiben laesst, auch wenn die Seite nicht laedt.
    # Muss zu einer der redirect_uris des Clients passen; die Desktop-Clients
    # von Google sind auf "http://localhost" eingetragen.
    REDIRECT_URI = "http://localhost"
    TOKEN_REFRESH_MARGIN = 300

    # RCLConf wirft NoMethodError fuer Schluessel, die nicht gesetzt sind,
    # statt nil zu liefern - was das uebliche "|| default" unbrauchbar macht.
    def self.config(key)
      ODDB.config.send(key)
    rescue NoMethodError
      nil
    end

    def initialize(client_id = nil, client_secret = nil, refresh_token = nil)
      @client_id = client_id || self.class.config(:gmail_oauth_client_id)
      @client_secret = client_secret || self.class.config(:gmail_oauth_client_secret)
      @refresh_token = refresh_token || self.class.config(:gmail_oauth_refresh_token)
      raise Error, "gmail_oauth_client_id is not configured" unless @client_id
      raise Error, "gmail_oauth_client_secret is not configured" unless @client_secret
    end

    # Die Adresse, die der Postfachinhaber im Browser oeffnet.
    def authorization_url(scope)
      params = {
        "client_id" => @client_id,
        "redirect_uri" => REDIRECT_URI,
        "response_type" => "code",
        "scope" => scope,
        # offline, damit ueberhaupt ein Refresh-Token kommt; consent, damit
        # auch dann eines kommt, wenn schon einmal zugestimmt wurde.
        "access_type" => "offline",
        "prompt" => "consent"
      }
      "#{AUTH_URI}?" + URI.encode_www_form(params)
    end

    # Tauscht den Code aus der Adresszeile gegen ein Refresh-Token.
    def exchange(code)
      response = post_form(
        "code" => code,
        "client_id" => @client_id,
        "client_secret" => @client_secret,
        "redirect_uri" => REDIRECT_URI,
        "grant_type" => "authorization_code"
      )
      token = response["refresh_token"]
      unless token
        raise Error, "no refresh_token in response - was access_type=offline " \
          "and prompt=consent used? #{response.inspect}"
      end
      @refresh_token = token
    end

    def access_token
      raise Error, "gmail_oauth_refresh_token is not configured - run bin/oddb_mail authorize" unless @refresh_token
      if @access_token.nil? || Time.now >= @token_expires_at
        response = post_form(
          "client_id" => @client_id,
          "client_secret" => @client_secret,
          "refresh_token" => @refresh_token,
          "grant_type" => "refresh_token"
        )
        @access_token = response["access_token"]
        raise Error, "no access_token in response: #{response.inspect}" unless @access_token
        @token_expires_at = Time.now + (response["expires_in"] || 3600).to_i - TOKEN_REFRESH_MARGIN
      end
      @access_token
    end

    private

    def post_form(params)
      uri = URI(TOKEN_URI)
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(params)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
        open_timeout: 20, read_timeout: 60) { |http| http.request(request) }
      parsed = begin
        JSON.parse(response.body.to_s)
      rescue JSON::ParserError
        {}
      end
      unless response.is_a?(Net::HTTPSuccess)
        detail = parsed.is_a?(Hash) ? (parsed["error_description"] || parsed["error"]) : nil
        raise Error, "#{response.code} #{detail || response.message}"
      end
      parsed
    end
  end
end
