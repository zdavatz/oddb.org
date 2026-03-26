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
