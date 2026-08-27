#!/usr/bin/env ruby

# ODDB::LinkedInApi -- oddb.org -- Beitraege auf LinkedIn
#
# LinkedIn kennt keinen Weg, mit Anwendungsdaten allein zu veroeffentlichen:
# grant_type=client_credentials antwortet "Client authentication failed". Ein
# Beitrag wird immer im Namen eines Mitglieds geschrieben, also braucht es den
# dreibeinigen Ablauf - Freigabe im Browser, Code, Token.
#
# Zugangsdaten stehen in etc/oddb.yml (gitignored, Rechte 600), nie im Code.

require "json"
require "net/http"
require "uri"
require "cgi"
require "securerandom"

module ODDB
  class LinkedInApi
    class Error < RuntimeError; end

    AUTH_URI = "https://www.linkedin.com/oauth/v2/authorization"
    TOKEN_URI = "https://www.linkedin.com/oauth/v2/accessToken"
    POSTS_URI = "https://api.linkedin.com/rest/posts"
    IMAGES_URI = "https://api.linkedin.com/rest/images"
    USERINFO_URI = "https://api.linkedin.com/v2/userinfo"

    # Die Version wandert; LinkedIn verlangt sie bei jedem Aufruf als Kopfzeile.
    API_VERSION = "202601"

    # w_member_social erlaubt das Veroeffentlichen, openid und profile liefern
    # die Mitglieds-URN, die als Autor im Beitrag stehen muss.
    SCOPES = "openid profile w_member_social"

    # Muss Zeichen fuer Zeichen mit dem uebereinstimmen, was in der LinkedIn-
    # Anwendung unter Auth > Authorized redirect URLs steht - sonst kommt
    # "The redirect_uri does not match the registered value" und sonst nichts.
    # Ein Server muss dahinter nicht laufen: der Code steht in der Adresszeile.
    REDIRECT_URI = "https://localhost"

    def self.config(key)
      ODDB.config.send(key)
    rescue NoMethodError
      nil
    end

    def initialize(token = nil)
      @client_id = self.class.config(:linkedin_client_id)
      @client_secret = self.class.config(:linkedin_client_secret)
      raise Error, "linkedin_client_id fehlt in etc/oddb.yml" unless @client_id
      @token = token || self.class.config(:linkedin_access_token)
    end

    def authorization_url(state = SecureRandom.hex(8))
      params = {
        "response_type" => "code",
        "client_id" => @client_id,
        "redirect_uri" => REDIRECT_URI,
        "state" => state,
        "scope" => SCOPES
      }
      "#{AUTH_URI}?" + params.collect { |k, v| "#{k}=#{CGI.escape(v)}" }.join("&")
    end

    def exchange(code)
      response = post_form(URI(TOKEN_URI),
        "grant_type" => "authorization_code",
        "code" => code,
        "client_id" => @client_id,
        "client_secret" => @client_secret,
        "redirect_uri" => REDIRECT_URI)
      @token = response["access_token"]
      raise Error, "kein access_token: #{response.inspect}" unless @token
      response
    end

    # Die Mitglieds-URN, die als Autor im Beitrag steht.
    #
    # Ohne die Freigabe openid/profile (Produkt "Sign In with LinkedIn using
    # OpenID Connect") antwortet userinfo mit 403, und es gibt keinen anderen
    # Weg, sie zu erfragen - w_member_social erlaubt schreiben, nicht lesen.
    # Deshalb darf sie auch aus etc/oddb.yml kommen; abzulesen ist sie im
    # Quelltext des eigenen Profils als profileId=ACoAAA...
    def author_urn
      configured = self.class.config(:linkedin_author_urn)
      return configured if configured
      info = get_json(URI(USERINFO_URI))
      sub = info["sub"]
      raise Error, "keine sub im userinfo: #{info.inspect}" unless sub
      "urn:li:person:#{sub}"
    end

    # Ein Bild hochladen und die URN zurueckgeben, mit der es im Beitrag
    # referenziert wird. Drei Schritte, weil LinkedIn den Upload trennt:
    # Platz anfordern, Bytes hinschieben, URN verwenden.
    def upload_image(path, author: nil)
      owner = author || author_urn
      init = post_json(URI(IMAGES_URI + "?action=initializeUpload"),
        {"initializeUploadRequest" => {"owner" => owner}})
      value = init["value"] || {}
      url = value["uploadUrl"]
      urn = value["image"]
      raise Error, "kein uploadUrl: #{init.inspect}" unless url && urn

      uri = URI(url)
      request = Net::HTTP::Put.new(uri)
      request["Authorization"] = "Bearer #{@token}"
      request.body = File.binread(path)
      # image/png, nicht octet-stream: LinkedIn nimmt den Upload zwar an,
      # das Bild taucht im Beitrag aber nicht auf.
      request["Content-Type"] = mime_for(path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 120
      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "Bild-Upload HTTP #{response.code}: #{response.body.to_s[0, 200]}"
      end
      urn
    end

    # LinkedIn liest commentary als "Little Text Format" und behandelt eine
    # Reihe von Zeichen als Auszeichnung. Unmaskiert verschwinden sie aus dem
    # veroeffentlichten Text - und das trifft ausgerechnet Adressen: aus
    # https://ch.oddb.org/de/gcc/rss_html/channel/price_cut.rss wurde
    # .../rsshtml/channel/pricecut.rss, also ein Verweis ins Leere. Der Fehler
    # ist im Beitrag nicht zu sehen, solange man den Link nicht anklickt, und
    # zurueckgelesen werden kann er nicht: GET /rest/posts/<urn> antwortet mit
    # 403, w_member_social ist schreibend.
    #
    # '#' steht bewusst nicht in der Liste. Maskiert waere es ein gewoehnliches
    # Doppelkreuz, und die Schlagworte am Ende eines Beitrags waeren keine
    # mehr. Der Backslash zuerst, sonst maskiert er die eigenen Maskierungen.
    RESERVED = /([\\|{}@\[\]()<>*_~])/

    def self.escape(text)
      text.to_s.gsub(RESERVED) { "\\#{$1}" }
    end

    # visibility: "PUBLIC" oder "CONNECTIONS"
    #
    # images: Liste von [pfad, alternativtext]. Ein Bild wandert nach
    # content.media, mehrere nach content.multiImage - LinkedIn kennt dafuer
    # zwei verschiedene Formen.
    def create_post(text, visibility: "PUBLIC", author: nil, images: [])
      owner = author || author_urn
      uploaded = Array(images).collect { |path, alt|
        [upload_image(path, author: owner), alt.to_s]
      }
      body = {
        "author" => owner,
        "commentary" => self.class.escape(text),
        "visibility" => visibility,
        "distribution" => {
          "feedDistribution" => "MAIN_FEED",
          "targetEntities" => [],
          "thirdPartyDistributionChannels" => []
        },
        "lifecycleState" => "PUBLISHED",
        "isReshareDisabledByAuthor" => false
      }
      if uploaded.size == 1
        urn, alt = uploaded.first
        body["content"] = {"media" => {"id" => urn, "altText" => alt}}
      elsif uploaded.size > 1
        body["content"] = {"multiImage" => {"images" => uploaded.collect { |urn, alt|
          {"id" => urn, "altText" => alt}
        }}}
      end
      post_json(URI(POSTS_URI), body)
    end

    # LinkedIn kennt kein Nachtraegliches Anhaengen von Bildern an einen
    # bestehenden Beitrag - wer Bilder vergessen hat, loescht und stellt neu ein.
    def delete_post(urn)
      uri = URI("#{POSTS_URI}/#{CGI.escape(urn)}")
      request = Net::HTTP::Delete.new(uri)
      headers.each { |k, v| request[k] = v }
      perform(uri, request)
      true
    end

    MIME_TYPES = {
      ".png" => "image/png", ".jpg" => "image/jpeg", ".jpeg" => "image/jpeg",
      ".gif" => "image/gif", ".webp" => "image/webp"
    }.freeze

    def mime_for(path)
      MIME_TYPES.fetch(File.extname(path.to_s).downcase, "image/png")
    end

    private

    def headers
      {
        "Authorization" => "Bearer #{@token}",
        "LinkedIn-Version" => API_VERSION,
        "X-Restli-Protocol-Version" => "2.0.0"
      }
    end

    def post_form(uri, params)
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(params)
      perform(uri, request)
    end

    def get_json(uri)
      raise Error, "kein Token - erst bin/oddb_linkedin authorize" unless @token
      request = Net::HTTP::Get.new(uri)
      headers.each { |k, v| request[k] = v }
      perform(uri, request)
    end

    def post_json(uri, body)
      raise Error, "kein Token - erst bin/oddb_linkedin authorize" unless @token
      request = Net::HTTP::Post.new(uri)
      headers.each { |k, v| request[k] = v }
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(body)
      perform(uri, request)
    end

    def perform(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      response = http.request(request)
      parsed = begin
        response.body.to_s.empty? ? {} : JSON.parse(response.body)
      rescue JSON::ParserError
        {"raw" => response.body.to_s[0, 300]}
      end
      unless response.is_a?(Net::HTTPSuccess)
        message = parsed["message"] || parsed["error_description"] || parsed["error"] || response.body.to_s[0, 300]
        raise Error, "HTTP #{response.code}: #{message}"
      end
      # Die id des neuen Beitrags steht nur in der Kopfzeile.
      parsed["id"] ||= response["x-restli-id"] if response["x-restli-id"]
      parsed
    end
  end
end
