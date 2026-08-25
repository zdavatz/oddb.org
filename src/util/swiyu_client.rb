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

    # Format, in dem der Issuer die Arztausweise ausstellt. Der Verifier
    # akzeptiert waehrend der Migrationsphase weiterhin "vc+sd-jwt";
    # "dc+sd-jwt" ist der kanonische Typ nach draft-ietf-oauth-sd-jwt-vc-09.
    CREDENTIAL_FORMAT = "vc+sd-jwt"

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
        response_mode: "direct_post",
        # OID4VP 1.0: der swiyu-Verifier ab 4.x akzeptiert nur noch DCQL,
        # presentation_definition wird mit "dcqlQuery: must not be null" abgelehnt.
        dcql_query: {
          credentials: [
            {
              id: "doctor_credential",
              format: CREDENTIAL_FORMAT,
              meta: {vct_values: ["doctor-credential-sdjwt"]},
              claims: [
                {path: ["firstName"]},
                {path: ["lastName"]},
                {path: ["gln"]}
              ]
            }
          ]
        }
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
