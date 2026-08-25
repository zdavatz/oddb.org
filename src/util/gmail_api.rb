#!/usr/bin/env ruby

# ODDB::GmailApi -- oddb.org -- 2026
#
# Legt Entwürfe im ywesee-Postfach an. Nur Entwürfe, kein Versand: was
# rausgeht, entscheidet ein Mensch.
#
# Zwei Wege zum Token, in dieser Reihenfolge:
#
#   1. OAuth-Client (util/google_oauth.rb). Der Postfachinhaber stimmt einmal
#      zu, danach genügt ein Refresh-Token. Niemand muss Administrator sein.
#   2. Dienstkonto mit Postfachübernahme (util/google_service_account.rb).
#      Setzt domainweite Delegation in der Workspace-Verwaltung voraus, sonst
#      antwortet Google mit "Client is unauthorized to retrieve access tokens".
#
# Weg 1 ist der übliche; Weg 2 bleibt, weil das Dienstkonto für die Search
# Console ohnehin da ist und sich anbietet, wenn die Delegation einmal steht.
#
# Konfiguration in etc/oddb.yml (gitignored):
#   gmail_draft_mailbox         Postfach, in dem der Entwurf liegen soll
#   gmail_oauth_client_id       Weg 1
#   gmail_oauth_client_secret   Weg 1
#   gmail_oauth_refresh_token   Weg 1, von bin/oddb_mail authorize gesetzt
#   gsc_service_account_json    Weg 2
#   gsc_service_account_email   Weg 2

require "util/google_oauth"
require "util/google_service_account"

module ODDB
  class GmailApi
    include GoogleServiceAccount

    Error = GoogleServiceAccount::Error

    # gmail.compose reicht zum Anlegen von Entwürfen und erlaubt kein Lesen
    # des Postfachs - die kleinste Berechtigung, die den Zweck erfüllt.
    SCOPE = "https://www.googleapis.com/auth/gmail.compose"
    DRAFTS_URI = "https://gmail.googleapis.com/gmail/v1/users/me/drafts"

    attr_reader :mailbox

    def initialize(mailbox = nil, key_file = nil, client_email = nil)
      @mailbox = mailbox || GoogleOAuth.config(:gmail_draft_mailbox)
      raise Error, "no mailbox given and gmail_draft_mailbox is not configured" unless @mailbox
      @oauth = begin
        GoogleOAuth.new
      rescue GoogleOAuth::Error
        nil
      end
      return if @oauth
      key_file ||= GoogleOAuth.config(:gsc_service_account_json)
      unless key_file
        raise Error, "neither gmail_oauth_client_id nor gsc_service_account_json " \
          "is configured - see src/util/gmail_api.rb"
      end
      load_credentials(key_file, client_email || GoogleOAuth.config(:gsc_service_account_email), @mailbox)
    end

    # Bei OAuth kommt das Token vom Client, sonst vom Dienstkonto. Beide Wege
    # liefern dasselbe Bearer-Token, der Rest der Klasse merkt den Unterschied
    # nicht.
    def access_token
      @oauth ? @oauth.access_token : super
    end

    # Legt einen Entwurf an und liefert dessen id.
    def create_draft(to:, subject:, body:, cc: nil)
      response = post_json(DRAFTS_URI,
        {"message" => {"raw" => base64url(rfc822(to, subject, body, cc))}})
      response.dig("id") or raise Error, "no draft id in response: #{response.inspect}"
    end

    # Ersetzt den Inhalt eines Entwurfs, statt einen zweiten anzulegen.
    def update_draft(id, to:, subject:, body:, cc: nil)
      uri = URI("#{DRAFTS_URI}/#{id}")
      request = Net::HTTP::Put.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{access_token}"
      request.body = JSON.generate(
        {"message" => {"raw" => base64url(rfc822(to, subject, body, cc))}}
      )
      response = perform(uri, request)
      response["id"] or raise Error, "no draft id in response: #{response.inspect}"
    end

    private

    # Betreff und Absendername werden nach RFC 2047 kodiert, sonst zerlegt
    # Gmail Umlaute. Der Rumpf geht als UTF-8 mit base64, was Zeilenlängen und
    # Sonderzeichen gleichermassen erledigt.
    def rfc822(to, subject, body, cc)
      headers = [
        "From: #{@mailbox}",
        "To: #{Array(to).join(", ")}"
      ]
      headers << "Cc: #{Array(cc).join(", ")}" if cc && !Array(cc).empty?
      headers += [
        "Subject: #{encode_header(subject)}",
        "MIME-Version: 1.0",
        "Content-Type: text/plain; charset=UTF-8",
        "Content-Transfer-Encoding: base64"
      ]
      headers.join("\r\n") + "\r\n\r\n" +
        [body.to_s].pack("m").gsub("\n", "\r\n")
    end

    def encode_header(text)
      text = text.to_s
      return text if text.ascii_only?
      "=?UTF-8?B?" + [text].pack("m0") + "?="
    end
  end
end
