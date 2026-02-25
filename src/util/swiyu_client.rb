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
        presentation_definition: {
          id: SecureRandom.uuid,
          input_descriptors: [
            {
              id: "doctor-credential",
              format: {
                "vc+sd-jwt": {
                  "sd-jwt_alg_values": ["ES256"],
                  "kb-jwt_alg_values": ["ES256"]
                }
              },
              constraints: {
                fields: [
                  {
                    path: ["$.vct"],
                    filter: {
                      type: "string",
                      const: "doctor-credential-sdjwt"
                    }
                  },
                  {path: ["$.firstName"]},
                  {path: ["$.lastName"]},
                  {path: ["$.gln"]}
                ]
              }
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
