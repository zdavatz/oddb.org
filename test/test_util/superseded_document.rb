#!/usr/bin/env ruby

# ODDB::TestSupersededDocument -- oddb.org -- 27.08.2026

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require "minitest/autorun"
require "util/superseded_document"

module ODDB
  # Persistence einzubinden zoege den halben ODBA-Unterbau nach. Was die
  # Pruefung braucht, sind drei Eigenschaften: odba_id, chapters und
  # odba_delete.
  class FakePersistence
    def self.===(other)
      other.is_a?(FakePersistence)
    end
  end

  class TestSupersededDocument < Minitest::Test
    class Chapter
      attr_reader :odba_id
      attr_accessor :deleted
      def initialize(id)
        @odba_id = id
        @deleted = false
      end

      def odba_delete
        @deleted = true
      end
    end

    class Document
      CHAPTERS = [:composition, :effects, :usage]
      attr_reader :odba_id, :composition, :effects, :usage
      attr_accessor :deleted, :change_log
      def initialize(id, chapters)
        @odba_id = id
        @composition, @effects, @usage = chapters
        @change_log = []
        @deleted = false
      end

      def chapters
        CHAPTERS
      end

      def odba_delete
        @deleted = true
      end
    end

    def setup
      # Persistence?-Pruefung fuer die Attrappen umbiegen.
      @original = ODDB::SupersededDocument.method(:persistable?)
      ODDB::SupersededDocument.define_singleton_method(:persistable?) { |object|
        object.is_a?(TestSupersededDocument::Document)
      }
      super
    end

    def teardown
      ODDB::SupersededDocument.define_singleton_method(:persistable?, @original)
      super
    end

    def document(id, chapter_ids)
      Document.new(id, chapter_ids.collect { |c| Chapter.new(c) })
    end

    # Der Kern: das abgeloeste Dokument und seine Kapitel fallen.
    def test_the_old_document_and_its_chapters_are_deleted
      old = document(1, [11, 12, 13])
      new = document(2, [21, 22, 23])
      assert_equal(4, SupersededDocument.discard(old, new))
      assert(old.deleted)
      assert(old.chapters.collect { |c| old.send(c).deleted }.all?)
      refute(new.deleted)
    end

    # Ein Kapitel, das das neue Dokument ebenfalls benutzt, bleibt. Der Parser
    # baut jedes Kapitel neu - aber das ist eine Annahme ueber fremden Code,
    # und eine falsche kostete hier den Text eines lebenden Praeparats.
    def test_a_chapter_the_successor_uses_survives
      shared = Chapter.new(11)
      old = Document.new(1, [shared, Chapter.new(12), Chapter.new(13)])
      new = Document.new(2, [shared, Chapter.new(22), Chapter.new(23)])
      assert_equal(3, SupersededDocument.discard(old, new))
      refute(shared.deleted, "geteiltes Kapitel wurde geloescht")
      assert(old.deleted)
    end

    # Die Historie wird nie angefasst. Sie wird ins neue Dokument geklont, die
    # Eintraege haengen also an beiden; aus dem alten wird sie genommen, bevor
    # es faellt.
    def test_the_change_log_is_taken_out_first
      old = document(1, [11])
      items = [:diff1, :diff2]
      old.change_log = items
      SupersededDocument.discard(old, document(2, [21]))
      assert_nil(old.instance_variable_get(:@change_log))
      assert_equal([:diff1, :diff2], items, "die Liste selbst bleibt unversehrt")
    end

    # Dasselbe Objekt ist keine Ablösung.
    def test_nothing_happens_when_the_successor_is_the_same_object
      doc = document(1, [11])
      assert_equal(0, SupersededDocument.discard(doc, doc))
      refute(doc.deleted)
    end

    # In @descriptions stehen bei den meisten Modellen Zeichenketten -
    # Substanznamen, galenische Formen. Die haben weder odba_id noch Kapitel.
    def test_strings_and_nil_are_left_alone
      ODDB::SupersededDocument.define_singleton_method(:persistable?, @original)
      assert_equal(0, SupersededDocument.discard("Paracetamolum", "Paracetamol"))
      assert_equal(0, SupersededDocument.discard(nil, "x"))
      assert_equal(0, SupersededDocument.discard(42, 43))
    end

    # Ohne Nachfolger - etwa wenn eine Sprache wegfaellt - wird trotzdem
    # aufgeraeumt.
    def test_works_without_a_successor
      old = document(1, [11, 12])
      assert_equal(3, SupersededDocument.discard(old))
      assert(old.deleted)
    end

    # Ein Kapitel, das sich nicht loeschen laesst, darf den Rest nicht
    # mitnehmen.
    def test_a_failing_chapter_does_not_stop_the_rest
      old = document(1, [11, 12])
      def (old.composition).odba_delete
        raise "kaputt"
      end
      assert_equal(2, SupersededDocument.discard(old))
      assert(old.deleted)
      assert(old.effects.deleted)
    end
  end
end
