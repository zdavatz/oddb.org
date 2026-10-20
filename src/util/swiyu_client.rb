require "net/http"
require "json"
require "uri"
require "securerandom"
require "util/swiyu_roles"

module ODDB
  class SwiyuClient
    BASE_URL = "https://swiyu.ywesee.com/verifier-mgmt/api"
    API_HEADERS = {
      "SWIYU-API-Version" => "1",
      "Content-Type" => "application/json"
    }.freeze

    # Format, in dem der Issuer die Arztausweise ausstellt. Ab swiyu-issuer
    # 5.0 gibt es nur noch "dc+sd-jwt" (draft-ietf-oauth-sd-jwt-vc-09);
    # das alte "vc+sd-jwt" wurde entfernt.
    CREDENTIAL_FORMAT = "dc+sd-jwt"

    # ID der DCQL-Abfrage. Der Verifier gruppiert die zurueckgelieferten Claims
    # unter diesem Schluessel, siehe SwiyuMiddleware#extract_claims.
    DCQL_CREDENTIAL_ID = "doctor_credential"

    VERIFICATION_PURPOSE = {
      scope: "org.oddb.doctor_login",
      purpose_name: {
        default: "ODDB Arzt-Login",
        en: "ODDB doctor login",
        "de-CH": "ODDB Arzt-Login",
        "fr-CH": "Connexion médecin ODDB"
      },
      purpose_description: {
        default: "ywesee GmbH prüft Name und GLN Ihres Arztausweises für die Anmeldung bei ch.oddb.org.",
        en: "ywesee GmbH checks the name and GLN on your doctor credential to log you in to ch.oddb.org.",
        "de-CH": "ywesee GmbH prüft Name und GLN Ihres Arztausweises für die Anmeldung bei ch.oddb.org.",
        "fr-CH": "ywesee GmbH vérifie le nom et le GLN de votre carte de médecin pour la connexion à ch.oddb.org."
      }
    }.freeze

    def create_verification
      uri = URI("#{BASE_URL}/verifications")
      req = Net::HTTP::Post.new(uri)
      API_HEADERS.each { |k, v| req[k] = v }
      req.body = verification_request_body.to_json
      response = do_request(uri, req)
      JSON.parse(response.body)
    end

    def get_verification(id)
      uri = URI("#{BASE_URL}/verifications/#{id}")
      req = Net::HTTP::Get.new(uri)
      API_HEADERS.each { |k, v| req[k] = v }
      response = do_request(uri, req)
      JSON.parse(response.body)
    end

    private

    def verification_request_body
      {
        accepted_issuer_dids: [
          SwiyuRoles.instance.accepted_issuer_did
        ],
        response_mode: "direct_post.jwt",
        # Wallet ab 1.17 erzwingt verschluesselte Antworten (direct_post.jwt),
        # direct_post wird mit invalid_request abgelehnt.
        # OID4VP 1.0: der swiyu-Verifier ab 4.x akzeptiert nur noch DCQL,
        # presentation_definition wird mit "dcqlQuery: must not be null" abgelehnt.
        dcql_query: {
          credentials: [
            {
              id: DCQL_CREDENTIAL_ID,
              format: CREDENTIAL_FORMAT,
              meta: {vct_values: ["doctor-credential-sdjwt"]},
              claims: [
                {path: ["firstName"]},
                {path: ["lastName"]},
                {path: ["gln"]}
              ]
            }
          ]
        },
        # Trust Protocol 2.0: der Verifier registriert damit ein Verification
        # Query Public Statement (vqPS) beim Trust Registry. Ohne vqPS zeigt
        # die Wallet "This request is not registered in the Confederation's
        # system". Wirkt nur, wenn im Verifier SWIYU_TMS_* gesetzt ist.
        verification_purpose: VERIFICATION_PURPOSE
      }
    end

    def do_request(uri, req)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10
      http.request(req)
    end
  end
end
