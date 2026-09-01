#!/usr/bin/env ruby

# ODDB::TestDanglingReferenceRepair -- oddb.org -- 01.09.2026
#
# Die tragende Zusicherung ist die Schreibreihenfolge. Ein Stub auf ein
# geloeschtes Array wird durch [] ersetzt - und dieses [] ist ein eigenes
# ODBA-Objekt mit eigener odba_id, das im Dump des Halters nur als Stub
# steht. Wird es nicht zuerst fuer sich geschrieben, tauscht
# odba_isolated_store den toten Verweis gegen einen neuen toten aus.
#
# Am 01.09.2026 an Package 212202 (31862/035, Maliasin 100 mg) passiert:
# @parts zeigte auf 61866868, nach dem Lauf auf 62051253, und beide fehlen
# in object. Sichtbar wurde es erst beim Nachlesen in einem frischen
# Prozess - der Job selbst hat "1 bereinigt" gemeldet.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "odba"
require "model/slentry"
require "util/dangling_reference_repair"

module ODDB
  class DanglingHolder
    def initialize(stub)
      @parts = stub
    end
  end

  class TestDanglingReferenceRepair < Minitest::Test
    def setup
      @stub = ODBA::Stub.new(4711, nil, nil)
      @stub.instance_variable_set(:@odba_class, Array)
      @holder = DanglingHolder.new(@stub)
      flexmock(ODBA).should_receive(:cache).and_return(
        flexmock("cache", fetch: @holder)
      )
      flexmock(ODBA).should_receive(:storage).and_return(
        flexmock("storage", restore: nil)
      )
      @repair = ODDB::DanglingReferenceRepair.new(nil, apply: true)
    end

    def parts
      @holder.instance_variable_get(:@parts)
    end

    # Gegen den Stand vor dem 01.09.2026: dort wurde nur der Halter
    # geschrieben, die frische Liste blieb ungespeichert. Array selbst laesst
    # sich nicht mocken - flexmock baut seine Doubles mit Array.new und
    # verschwindet in der eigenen Rekursion -, also wird beobachtet, was
    # repair an store weiterreicht, und die Reihenfolge an store selbst
    # geprueft.
    def test_the_fresh_list_is_handed_to_store
      seen = nil
      flexmock(@repair).should_receive(:store).once
        .and_return { |object, fresh| seen = [object, fresh] }
      @repair.repair(1, [4711])
      assert_equal(@holder, seen.first)
      assert_equal([[]], seen.last,
        "die frische Liste muss mitgegeben werden - sie ist ein eigenes " \
        "ODBA-Objekt und steht im Dump des Halters nur als Stub")
    end

    def test_store_writes_the_list_before_the_holder
      order = []
      list = flexmock("liste")
      list.should_receive(:odba_isolated_store).once.and_return { order.push(:liste) }
      holder = flexmock("halter")
      holder.should_receive(:odba_isolated_store).once.and_return { order.push(:halter) }
      @repair.store(holder, [list])
      assert_equal([:liste, :halter], order,
        "sonst tauscht odba_isolated_store den toten Verweis gegen einen neuen toten")
    end

    def test_the_dead_stub_is_replaced_by_an_empty_list
      flexmock(@repair).should_receive(:store)
      @repair.repair(1, [4711])
      assert_equal([], parts)
      refute_kind_of(ODBA::Stub, parts)
    end

    # nil ist kein eigenes Objekt und braucht deshalb keinen eigenen
    # Schreibvorgang - der Grund, warum die 3950 @sl_entry im August heil
    # geblieben sind und nur die Array- und Hash-Faelle betroffen waren.
    def test_a_nil_replacement_is_not_handed_to_store
      seen = nil
      flexmock(@repair).should_receive(:store).once
        .and_return { |_object, fresh| seen = fresh }
      @stub.instance_variable_set(:@odba_class, ODDB::SlEntry)
      @repair.repair(1, [4711])
      assert_equal([], seen)
      assert_nil(parts)
    end

    def test_a_dry_run_writes_nothing
      dry = ODDB::DanglingReferenceRepair.new(nil, apply: false)
      flexmock(dry).should_receive(:store).never
      dry.repair(1, [4711])
      assert_equal(1, dry.counts[:objekte_bereinigt])
    end
  end
end
