#!/usr/bin/env ruby

# ODBA::ConnectionPool hands a thread a connection or makes it wait; it never
# hands out nil. Until 19.10.2026 the sixth concurrent thread got nil, the
# pool took that for a dead connection and rebuilt itself under the others.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "dbi"
require "util/odba_connection_patch"

class TestOdbaConnectionPatch < Minitest::Test
  class FakeConn
    @@made = 0
    def self.made = @@made
    def self.reset = (@@made = 0)
    def initialize = (@@made += 1)
    def select_one(sql)
      sleep 0.05
      [sql]
    end
    def disconnect; end
  end

  def setup
    FakeConn.reset
    @pool = ODBA::ConnectionPool.allocate
    @pool.instance_variable_set(:@dbi_args, [])
    @pool.instance_variable_set(:@opts, {})
    @pool.instance_variable_set(:@connections, [])
    @pool.instance_variable_set(:@mutex, Mutex.new)
    @pool.define_singleton_method(:_connect) { 5.times { @connections.push(FakeConn.new) } }
    @pool.connect
  end

  def test_twenty_threads_share_five_connections_without_reconnecting
    results = 20.times.map { |i| Thread.new { @pool.select_one("q#{i}") } }.map(&:value)
    assert_equal(20.times.map { |i| ["q#{i}"] }, results)
    assert_equal(5, FakeConn.made, "no reconnect")
    assert_equal(5, @pool.size)
    refute_includes(@pool.connections, nil)
  end

  def test_a_waiting_thread_gives_up_after_the_timeout
    stub_const_timeout(0.1) {
      5.times { @pool.connections.shift } # all checked out elsewhere
      assert_raises(ODBA::ConnectionPool::CheckoutTimeout) { @pool.next_connection { |c| c } }
      assert_empty(@pool.connections, "nothing pushed on timeout")
    }
  end

  def test_a_returned_connection_wakes_a_waiter
    held = @pool.connections.dup
    5.times { @pool.connections.shift }
    waiter = Thread.new { @pool.next_connection { |c| c } }
    sleep 0.05
    assert(waiter.alive?, "waits while the pool is empty")
    @pool.instance_variable_get(:@mutex).synchronize {
      @pool.connections.push(held.first)
      @pool.instance_variable_get(:@available).signal
    }
    assert_same(held.first, waiter.value)
  end

  def test_reconnect_wakes_waiters
    5.times { @pool.connections.shift }
    waiter = Thread.new { @pool.next_connection { |c| c } }
    sleep 0.05
    @pool.reconnect
    assert_kind_of(FakeConn, waiter.value)
  end

  private

  def stub_const_timeout(value)
    old = ODBA::ConnectionPool::CHECKOUT_TIMEOUT
    ODBA::ConnectionPool.send(:remove_const, :CHECKOUT_TIMEOUT)
    ODBA::ConnectionPool.const_set(:CHECKOUT_TIMEOUT, value)
    yield
  ensure
    ODBA::ConnectionPool.send(:remove_const, :CHECKOUT_TIMEOUT)
    ODBA::ConnectionPool.const_set(:CHECKOUT_TIMEOUT, old)
  end
end
