#!/usr/bin/env ruby

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "rack/mock"
require "tmpdir"
require "logger"
require "webauthn"
require "webauthn/fake_client"

module SBSM
  def self.logger
    @logger ||= Logger.new(File::NULL)
  end
end unless defined?(SBSM) && SBSM.respond_to?(:logger)

require "util/swiyu_middleware"

class TestSwiyuPasskeys < Minitest::Test
  GLN = "7601000000000"
  ORIGIN = "https://ch.oddb.org"

  # Liefert eine erfolgreiche Verifikation mit dem gewuenschten exp.
  class FakeSwiyuClient
    attr_accessor :exp

    def get_verification(_id)
      {
        "state" => "SUCCESS",
        "wallet_response" => {
          "credential_subject_data" => {
            "doctor_credential" => [{
              "vct" => "doctor-credential-sdjwt", "gln" => GLN,
              "firstName" => "Zeno", "lastName" => "Davatz", "exp" => exp
            }]
          }
        }
      }
    end
  end

  def setup
    @dir = Dir.mktmpdir
    ODDB::SwiyuPasskeys.instance_variable_set(:@instance, ODDB::SwiyuPasskeys.new(File.join(@dir, "passkeys.json")))
    @client = FakeSwiyuClient.new
    @client.exp = (Time.now + 365 * 86400).to_i
    @app = ODDB::SwiyuMiddleware.new(->(_env) { [404, {}, ["app"]] })
    @app.instance_variable_set(:@client, @client)
    @device = WebAuthn::FakeAuthenticator.new
    @authenticator = WebAuthn::FakeClient.new(ORIGIN, authenticator: @device)
  end

  def teardown
    ODDB::SwiyuPasskeys.instance_variable_set(:@instance, nil)
    FileUtils.remove_entry(@dir)
  end

  def store
    ODDB::SwiyuPasskeys.instance
  end

  def post(path, session, body = nil)
    env = Rack::MockRequest.env_for("https://ch.oddb.org#{path}", method: "POST",
      input: body ? body.to_json : "", "CONTENT_TYPE" => "application/json")
    env["HTTP_COOKIE"] = "_session_id=#{session}" if session
    status, _, resp = @app.call(env)
    [status, JSON.parse(resp.join)]
  end

  def swiyu_login(session)
    post("/swiyu/session", session, {"verification_id" => "v1"})
  end

  def register(session)
    _, options = post("/swiyu/passkey/register/options", session)
    credential = @authenticator.create(challenge: options["challenge"], rp_id: "ch.oddb.org", user_verified: true)
    post("/swiyu/passkey/register", session, credential)
  end

  def passkey_login(session)
    _, options = post("/swiyu/passkey/login/options", session)
    assertion = @authenticator.get(challenge: options["challenge"], rp_id: "ch.oddb.org", user_verified: true)
    post("/swiyu/passkey/login", session, assertion)
  end

  def test_swiyu_login_offers_passkey
    status, body = swiyu_login("s1")
    assert_equal 200, status
    assert body["passkey_offer"]
    assert_equal Time.at(@client.exp).utc.iso8601, ODDB::SwiyuMiddleware.get_auth("s1")["swiyu_valid_until"]
  end

  def test_no_passkey_without_exp
    @client.exp = nil
    _, body = swiyu_login("s1")
    refute body["passkey_offer"]
    status, _ = post("/swiyu/passkey/register/options", "s1")
    assert_equal 409, status
  end

  def test_register_requires_swiyu_login
    status, _ = post("/swiyu/passkey/register/options", "anonymous")
    assert_equal 401, status
  end

  def test_register_and_login_with_passkey
    swiyu_login("s1")
    status, body = register("s1")
    assert_equal 200, status, body.inspect
    record = store.for_gln(GLN).values.first
    assert_equal Time.at(@client.exp).utc.iso8601, record["valid_until"]

    status, body = passkey_login("s2")
    assert_equal 200, status, body.inspect
    auth = ODDB::SwiyuMiddleware.get_auth("s2")
    assert_equal GLN, auth["swiyu_gln"]
    assert_equal "Zeno", auth["swiyu_firstName"]
    assert_equal "true", auth["swiyu_passkey"]
  end

  def test_expired_passkey_is_rejected
    swiyu_login("s1")
    register("s1")
    id = store.for_gln(GLN).keys.first
    store.renew(GLN, Time.now - 1)

    status, body = passkey_login("s3")
    assert_equal 401, status
    assert body["expired"]
    assert_nil ODDB::SwiyuMiddleware.get_auth("s3")
    refute_nil store.find(id)
  end

  def test_new_swiyu_login_renews_passkeys
    swiyu_login("s1")
    register("s1")
    @client.exp = (Time.now + 2 * 365 * 86400).to_i
    swiyu_login("s4")
    assert_equal Time.at(@client.exp).utc.iso8601, store.for_gln(GLN).values.first["valid_until"]
  end

  def test_challenge_is_single_use
    swiyu_login("s1")
    register("s1")
    _, options = post("/swiyu/passkey/login/options", "s5")
    assertion = @authenticator.get(challenge: options["challenge"], rp_id: "ch.oddb.org", user_verified: true)
    assert_equal 200, post("/swiyu/passkey/login", "s5", assertion).first
    assert_equal 400, post("/swiyu/passkey/login", "s5", assertion).first
  end

  def test_wrong_origin_is_rejected
    swiyu_login("s1")
    register("s1")
    @authenticator = WebAuthn::FakeClient.new("https://evil.example", authenticator: @device)
    status, _ = passkey_login("s6")
    assert_equal 401, status
  end

  def test_store_file_is_private
    swiyu_login("s1")
    register("s1")
    mode = File.stat(File.join(@dir, "passkeys.json")).mode & 0o777
    assert_equal 0o600, mode
  end

  def test_delete_gln
    swiyu_login("s1")
    register("s1")
    assert_equal 1, store.delete_gln(GLN)
    assert_empty store.for_gln(GLN)
  end
end
