#!/usr/bin/env ruby

# ODDB::TestOdbaIdPatch -- oddb.org -- 31.08.2026

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "odba"
require "util/odba_id_patch"

module ODDB
  class TestOdbaIdSequence < Minitest::Test
    def setup
      # Singleton: allocate ist privat, wir wollen aber eine nackte Instanz.
      @storage = ODBA::Storage.send(:allocate)
      @storage.instance_variable_set(:@id_mutex, Mutex.new)
      @dbi = flexmock("dbi")
      flexmock(@storage).should_receive(:dbi).and_return(@dbi)
    end

    # Der Kern: die id kommt aus der Datenbank, nicht aus einem Zaehler im
    # Prozess. Zwei Prozesse bekamen sonst dieselbe - nachgemessen.
    def test_next_id_asks_the_sequence
      @dbi.should_receive(:do).once
      @dbi.should_receive(:select_one)
        .with("SELECT nextval('odba_id_seq')").once.and_return([4711])
      assert_equal(4711, @storage.next_id)
    end

    # Die Sequenz wird einmal angelegt und danach nicht mehr angefasst.
    def test_the_sequence_is_created_only_once
      @dbi.should_receive(:do).once
      @dbi.should_receive(:select_one).and_return([1], [2], [3])
      3.times { @storage.next_id }
    end

    # max_id und reserve_next_id lesen @next_id, der muss mitwachsen.
    def test_next_id_keeps_the_local_counter_in_step
      @dbi.should_receive(:do)
      @dbi.should_receive(:select_one).and_return([90])
      @storage.instance_variable_set(:@next_id, 10)
      @storage.next_id
      assert_equal(90, @storage.instance_variable_get(:@next_id))
    end

    # Rueckwaerts nie: eine kleinere id aus der Sequenz darf einen hoeheren
    # Stand nicht zuruecksetzen.
    def test_next_id_never_moves_the_counter_backwards
      @dbi.should_receive(:do)
      @dbi.should_receive(:select_one).and_return([5])
      @storage.instance_variable_set(:@next_id, 900)
      @storage.next_id
      assert_equal(900, @storage.instance_variable_get(:@next_id))
    end
  end

  class TestOdbaCacheNextId < Minitest::Test
    def setup
      @cache = ODBA::Cache.send(:allocate)
      @cache.instance_variable_set(:@file_lock, false)
    end

    def with_peer(peer, ids)
      @cache.instance_variable_set(:@peers, [peer])
      storage = flexmock("storage")
      storage.should_receive(:next_id).and_return(*ids)
      flexmock(ODBA).should_receive(:storage).and_return(storage)
    end

    # Das war der Fehler: `peer.reserve_next_id id rescue DRb::DRbError` hat
    # jeden StandardError geschluckt, also auch OdbaDuplicateIdError, und das
    # `retry` darunter konnte nie greifen. Der Peer meldete den Konflikt, und
    # niemand hoerte zu.
    def test_a_peer_conflict_leads_to_a_new_id
      peer = flexmock("peer")
      seen = []
      peer.should_receive(:reserve_next_id).and_return { |id|
        seen << id
        raise ODBA::OdbaDuplicateIdError, "belegt" if seen.size == 1
        true
      }
      with_peer(peer, [100, 101])
      assert_equal(101, @cache.next_id)
      assert_equal([100, 101], seen)
    end

    # Ein Peer, den wir nicht erreichen, darf die Vergabe nicht aufhalten -
    # das war die Absicht der Originalzeile und bleibt so.
    def test_an_unreachable_peer_does_not_stop_the_allocation
      peer = flexmock("peer")
      peer.should_receive(:reserve_next_id).and_raise(DRb::DRbError, "weg")
      with_peer(peer, [100])
      assert_equal(100, @cache.next_id)
    end

    def test_without_a_conflict_the_first_id_stands
      peer = flexmock("peer")
      peer.should_receive(:reserve_next_id).once
      with_peer(peer, [100])
      assert_equal(100, @cache.next_id)
    end
  end
end
