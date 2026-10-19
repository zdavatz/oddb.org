#!/usr/bin/env ruby

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "rack/mock"
require "util/load_shedder"

class TestLoadShedder < Minitest::Test
  # An app that holds every request until released, so requests overlap.
  class Gate
    def initialize
      @queue = Queue.new
    end

    def call(env)
      @queue.pop
      [200, {"content-type" => "text/plain"}, ["ok"]]
    end

    def release(n)
      n.times { @queue << :go }
    end
  end

  def shedder(limit: 2)
    @gate = Gate.new
    privileged = ->(req) { req.cookies["_session_id"] == "member" }
    ODDB::LoadShedder.new(@gate, limit: limit, privileged: privileged)
  end

  def get(app, cookie: nil, method: "GET", ip: "203.0.113.9")
    env = Rack::MockRequest.env_for("/de/gcc/home/", method: method, "REMOTE_ADDR" => ip)
    env["HTTP_COOKIE"] = "_session_id=#{cookie}" if cookie
    app.call(env)
  end

  def in_background(app, **opts)
    Thread.new { get(app, **opts) }.tap { sleep 0.05 }
  end

  def test_below_the_limit_everyone_is_served
    app = shedder(limit: 2)
    t = in_background(app)
    @gate.release(2)
    assert_equal(200, get(app).first)
    assert_equal(200, t.value.first)
    assert_equal(0, app.in_flight)
  end

  def test_over_the_limit_anonymous_gets_503_at_once
    app = shedder(limit: 2)
    threads = 2.times.map { in_background(app) }
    status, headers, body = get(app)
    assert_equal(503, status)
    assert_equal("30", headers["retry-after"])
    assert_match(/Registered users are always served/, body.join)
    assert_equal(1, app.shed)
    @gate.release(2)
    threads.each(&:join)
    assert_equal(0, app.in_flight)
  end

  def test_registered_users_pass_when_full
    app = shedder(limit: 2)
    threads = 2.times.map { in_background(app) }
    member = in_background(app, cookie: "member")
    assert_equal(3, app.in_flight)
    @gate.release(3)
    assert_equal(200, member.value.first)
    threads.each(&:join)
  end

  def test_registered_requests_count_so_anonymous_cannot_slip_in
    app = shedder(limit: 2)
    members = 2.times.map { in_background(app, cookie: "member") }
    assert_equal(503, get(app).first)
    @gate.release(2)
    members.each(&:join)
  end

  def test_an_unknown_session_cookie_is_anonymous
    app = shedder(limit: 1)
    t = in_background(app)
    assert_equal(503, get(app, cookie: "stranger").first)
    @gate.release(1)
    t.join
  end

  def test_the_healthcheck_from_localhost_always_passes
    app = shedder(limit: 1)
    t = in_background(app)
    h = in_background(app, method: "HEAD", ip: "::1")
    @gate.release(2)
    assert_equal(200, h.value.first)
    t.join
  end

  def test_a_failing_app_releases_its_slot
    app = ODDB::LoadShedder.new(->(env) { raise ArgumentError, "boom" }, limit: 1, privileged: ->(_) { false })
    assert_raises(ArgumentError) { get(app) }
    assert_equal(0, app.in_flight)
  end

  def test_privileged_reads_the_session_store_and_swiyu
    app = ODDB::LoadShedder.new(->(env) {}, limit: 1)
    req = ->(id) { Rack::Request.new(Rack::MockRequest.env_for("/", "HTTP_COOKIE" => "_session_id=#{id}")) }
    sessions = {"in" => Struct.new(:logged_in?).new(true), "out" => Struct.new(:logged_in?).new(false)}
    store = Module.new
    store.define_singleton_method(:sessions) { sessions }
    swiyu = Module.new
    swiyu.define_singleton_method(:get_auth) { |id| (id == "sw") ? {"swiyu_auth" => "true"} : nil }
    Object.const_set(:SBSM, Module.new) unless defined?(::SBSM)
    SBSM.const_set(:SessionStore, store) unless defined?(SBSM::SessionStore)
    ODDB.const_set(:SwiyuMiddleware, swiyu) unless defined?(ODDB::SwiyuMiddleware)
    skip "real SBSM loaded" unless SBSM::SessionStore.equal?(store)
    assert(app.privileged?(req.call("in")))
    refute(app.privileged?(req.call("out")))
    assert(app.privileged?(req.call("sw")))
    refute(app.privileged?(req.call("none")))
    refute(app.privileged?(Rack::Request.new(Rack::MockRequest.env_for("/"))))
  end
end
