#!/usr/bin/env ruby

# ODDB::TestOdbaIdPatch -- oddb.org -- 31.08.2026
#
# Die odba_id muss aus einer gemeinsamen Quelle kommen und nicht aus einem
# Zaehler je Prozess - sonst vergeben zwei Prozesse dieselbe und der eine
# ueberschreibt die Zeile des anderen in `object`. Seit odba 1.2.2 steckt
# das im Gem; src/util/odba_id_patch.rb schaltet sich dann ab und bleibt
# nur fuer den Fall liegen, dass jemand auf 1.1.9 zurueckgeht.
#
# Geprueft wird deshalb die *Zusicherung*, nicht die Umsetzung: dass es die
# Sequenzquelle ueberhaupt gibt, und dass ein Peer-Konflikt zu einer neuen
# id fuehrt statt verschluckt zu werden. Die Umsetzung selbst hat odba in
# test/test_storage.rb und test/test_cache.rb.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "odba"
require "util/odba_id_patch"

module ODDB
  class TestOdbaIdSource < Minitest::Test
    # Entweder das Gem (>= 1.2.2) oder der Patch stellt sie bereit. Faellt
    # beides weg, vergeben die Prozesse wieder jeder fuer sich.
    def test_the_id_comes_from_a_shared_source
      assert(ODBA::Storage.method_defined?(:id_sequence?) ||
             ODBA::Storage.method_defined?(:ensure_id_sequence),
        "weder odba >= 1.2.2 noch der Patch ist geladen - die odba_id kaeme " \
        "wieder aus einem Zaehler je Prozess")
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

    # Der Peer meldet den Konflikt, und bis odba 1.2.2 hat ein `rescue` ohne
    # Klasse ihn mitverschluckt - das `retry` konnte nie greifen, und beide
    # Prozesse behielten dieselbe id.
    def test_a_peer_conflict_leads_to_a_new_id
      seen = []
      peer = flexmock("peer")
      peer.should_receive(:reserve_next_id).and_return { |id|
        seen << id
        raise ODBA::OdbaDuplicateIdError, "belegt" if seen.size == 1
        true
      }
      with_peer(peer, [100, 101])
      assert_equal(101, @cache.next_id)
      assert_equal([100, 101], seen)
    end

    # Ein Peer, den wir nicht erreichen, darf die Vergabe nicht aufhalten.
    def test_an_unreachable_peer_does_not_stop_the_allocation
      peer = flexmock("peer")
      peer.should_receive(:reserve_next_id).and_raise(DRb::DRbError, "weg")
      with_peer(peer, [100])
      assert_equal(100, @cache.next_id)
    end
  end
end
