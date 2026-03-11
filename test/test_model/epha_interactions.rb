#!/usr/bin/env ruby

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "model/sdif_interaction"
require "stub/odba"

module ODDB
  class TestEphaInteraction < Minitest::Test
    def test_ratings
      assert_equal "Keine Einstufung", ODDB::EphaInteractions::Ratings["0"]
      assert_equal "Vorsichtsmassnahmen", ODDB::EphaInteractions::Ratings["1"]
      assert_equal "Kombination vermeiden", ODDB::EphaInteractions::Ratings["2"]
      assert_equal "Kontraindiziert", ODDB::EphaInteractions::Ratings["3"]
    end

    def test_colors
      assert_equal "#caff70", ODDB::EphaInteractions::Colors["0"]
      assert_equal "#ffec8b", ODDB::EphaInteractions::Colors["1"]
      assert_equal "#ff82ab", ODDB::EphaInteractions::Colors["2"]
      assert_equal "#ff6a6a", ODDB::EphaInteractions::Colors["3"]
    end

    def test_db_file_path
      assert ODDB::EphaInteractions::DB_FILE.end_with?("sqlite/interactions.db")
    end

    def test_get_returns_empty_hash
      assert_equal({}, ODDB::EphaInteractions.get)
    end

    def test_get_epha_interaction_returns_nil
      assert_nil ODDB::EphaInteractions.get_epha_interaction("A01", "B02")
    end
  end
end
