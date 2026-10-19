#!/usr/bin/env ruby

# Turns anonymous requests away with a quick 503 once the process is busy,
# instead of letting them queue.
#
# Why: on 30.09.2026 and again on 19.10.2026 a scraper spread over hundreds of
# residential addresses (855 addresses in 50 minutes, 742 of them with one
# request each, none in Switzerland) passed Anubis and sent ~25 requests a
# minute at Patinfo, Fachinfo, comparison and price-history pages. Each is
# cheap alone (median 0.2 s), but WEBrick starts a thread per request, all of
# them share one interpreter lock, and with 30-40 in flight single requests
# took up to 270 s. Then the healthcheck saw a silent port and restarted the
# process, which dropped everybody - the registered users with them.
#
# A 503 is answered in microseconds, so the port never goes silent, the
# healthcheck leaves the process alone, and the requests already inside get
# the interpreter to themselves.
#
# Registered users always pass: a session that is logged in (SBSM, via Yus)
# or carries a Swiyu authorisation is never counted against the limit and
# never turned away. Their requests are counted in flight all the same, so an
# anonymous request cannot slip in behind them.
#
# The limit is ODDB.config.max_anonymous_in_flight when set, else
# DEFAULT_LIMIT. Requests for the healthcheck (HEAD from localhost) always
# pass, though a 503 would count as alive for it anyway.

require "rack"

module ODDB
  class LoadShedder
    DEFAULT_LIMIT = 20
    RETRY_AFTER = 30
    SESSION_ID = "_session_id"
    BODY = <<~HTML
      <!DOCTYPE html>
      <html><head><meta charset="utf-8"><title>ODDB.org</title></head>
      <body style="font-family:sans-serif;max-width:40em;margin:3em auto;padding:0 1em">
      <h1>ODDB.org ist im Moment ausgelastet</h1>
      <p>Bitte versuchen Sie es in einer halben Minute noch einmal.
      Angemeldete Benutzer werden immer bedient.</p>
      <p>ODDB.org is busy at the moment. Please try again in half a minute.
      Registered users are always served.</p>
      </body></html>
    HTML

    attr_reader :in_flight, :shed

    def initialize(app, limit: nil, privileged: nil, logger: nil)
      @app = app
      @limit = limit || configured_limit
      @privileged = privileged || method(:privileged?)
      @logger = logger
      @mutex = Mutex.new
      @in_flight = 0
      @shed = 0
    end

    def call(env)
      request = Rack::Request.new(env)
      priority = always_pass?(request) || @privileged.call(request)
      admitted = @mutex.synchronize {
        if priority || @in_flight < @limit
          @in_flight += 1
          true
        else
          @shed += 1
          false
        end
      }
      return busy(request) unless admitted
      begin
        @app.call(env)
      ensure
        @mutex.synchronize { @in_flight -= 1 }
      end
    end

    # A logged-in SBSM session, or a Swiyu authorisation on the session id.
    def privileged?(request)
      session_id = request.cookies[SESSION_ID]
      return false if session_id.nil? || session_id.empty?
      if defined?(SwiyuMiddleware) && (auth = SwiyuMiddleware.get_auth(session_id))
        return true if auth["swiyu_auth"] == "true"
      end
      session = SBSM::SessionStore.sessions[session_id] if defined?(SBSM::SessionStore)
      !!(session.respond_to?(:logged_in?) && session.logged_in?)
    rescue NoMethodError, TypeError
      false
    end

    private

    def always_pass?(request)
      request.head? && %w[127.0.0.1 ::1].include?(request.ip)
    end

    def busy(request)
      @logger&.call("load_shedder: 503 #{request.ip} #{request.path} (#{@in_flight} in flight, #{@shed} shed)")
      [503,
        {"content-type" => "text/html; charset=utf-8",
         "retry-after" => RETRY_AFTER.to_s,
         "cache-control" => "no-store"},
        [BODY]]
    end

    def configured_limit
      value = ODDB.config.max_anonymous_in_flight if defined?(ODDB.config) && ODDB.config.respond_to?(:max_anonymous_in_flight)
      Integer(value || DEFAULT_LIMIT)
    rescue ArgumentError, TypeError
      DEFAULT_LIMIT
    end
  end
end
