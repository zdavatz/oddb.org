#!/usr/bin/env ruby

# Monkey-patch ODBA::ConnectionPool to reconnect on stale PG connections.
# The upstream method_missing only retries when the error message is exactly
# "no connection to the server", but PostgreSQL can also drop connections
# with "PQsocket() can't get socket descriptor" or similar messages.

require "odba/connection_pool"

module ODBA
  class ConnectionPool
    RETRIABLE_MESSAGES = [
      "no connection to the server",
      /PQsocket/i,
      /socket descriptor/i,
      /server closed the connection unexpectedly/i,
      /could not connect to server/i,
      /connection not open/i
    ].freeze

    # Waiting for a free connection instead of being handed nil.
    #
    # Upstream next_connection does `@connections.shift` and yields whatever
    # comes out - nil when all five connections are in use. The caller then
    # raises NoMethodError ("undefined method 'select_one' for nil"), which
    # method_missing treats as a lost connection: it sleeps, calls reconnect,
    # and reconnect disconnects every idle connection and opens five new ones
    # while other threads are mid-query on theirs. And the ensure pushed the
    # nil back, so the pool kept handing it out. With more than five threads
    # wanting the database at once this never settles: on 19.10.2026 a
    # scraper kept 50-100 requests in flight and oddb finished none of them
    # for half an hour, until it exited at 100 threads and started over.
    #
    # Now a thread waits (up to CHECKOUT_TIMEOUT) for a connection to come
    # back, nil is never pushed, and running out is not mistaken for a dead
    # connection.
    CHECKOUT_TIMEOUT = 30

    class CheckoutTimeout < StandardError; end

    def next_connection # :nodoc:
      conn = nil
      @mutex.synchronize {
        @available ||= ConditionVariable.new
        deadline = Time.now + CHECKOUT_TIMEOUT
        while (conn = @connections.shift).nil?
          remaining = deadline - Time.now
          raise CheckoutTimeout, "no database connection free after #{CHECKOUT_TIMEOUT}s" if remaining <= 0
          @available.wait(@mutex, remaining)
        end
      }
      yield(conn)
    ensure
      if conn
        @mutex.synchronize {
          @connections.push(conn)
          @available&.signal
        }
      end
    end

    # connect pushes the new connections; wake anyone waiting for them.
    def connect # :nodoc:
      @mutex.synchronize {
        _connect
        @available ||= ConditionVariable.new
        @available.broadcast
      }
    end

    def reconnect # :nodoc:
      @mutex.synchronize {
        _disconnect
        _connect
        @available ||= ConditionVariable.new
        @available.broadcast
      }
    end

    alias_method :_original_method_missing, :method_missing

    def method_missing(method, *args, &block)
      tries = SETUP_RETRIES
      begin
        next_connection { |conn|
          conn.send(method, *args, &block)
        }
      rescue NoMethodError, DBI::Error => e
        warn e
        if tries > 0 && retriable_error?(e)
          sleep(SETUP_RETRIES - tries)
          tries -= 1
          reconnect
          retry
        else
          raise
        end
      end
    end

    private

    def retriable_error?(error)
      return true unless error.is_a?(DBI::ProgrammingError)
      msg = error.message
      RETRIABLE_MESSAGES.any? { |pattern|
        pattern.is_a?(Regexp) ? msg.match?(pattern) : msg == pattern
      }
    end
  end
end
