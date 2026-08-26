#!/usr/bin/env ruby
# TestSearchterms -- oddb.org -- Encoding-Schutz fuer die Suchbegriffe

$LOAD_PATH.unshift File.expand_path("../..", __dir__)
$LOAD_PATH.unshift File.expand_path("../../src", __dir__)

require "minitest/autorun"
require "util/searchterms"

module ODDB
  # Ein String, der nicht UTF-8 ist, darf die Suchbegriffe nicht sprengen.
  #
  # Der Schutz, der hier bis August 2026 stand, prueft auf ASCII_8BIT und auf
  # valid_encoding?. Bei ISO-8859-1 sagen beide "in Ordnung" - es ist nicht
  # ASCII_8BIT, und in Latin-1 ist jede Bytefolge gueltig. Der String rutschte
  # ungeprueft durch bis zu /[[:punct:]]/u und warf dort
  # "incompatible encoding regexp match (UTF-8 regexp with ISO-8859-1 string)".
  # Das kostete jede Nacht vier Indizes: substance_index, substance_soundex_index,
  # doctor_index und hospital_index. Seit mindestens 01.01.2026, unbemerkt, weil
  # die Cron-Ausgabe bis zum 24.08.2026 nach /dev/null ging.
  class TestSearchTermEncoding < Minitest::Test
    def test_latin1_does_not_raise
      assert_equal("Befuellung", ODDB.search_term("Bef\xFCllung".dup.force_encoding("ISO-8859-1")))
    end

    def test_latin1_frozen_does_not_raise
      # Der alte Schutz sprang bei eingefrorenen Strings gar nicht erst an,
      # weil force_encoding in place mutiert haette.
      assert_equal("Acetyl", ODDB.search_term("Ac\xE9tyl".dup.force_encoding("ISO-8859-1").freeze))
    end

    def test_ascii_8bit_holding_utf8_bytes
      assert_equal("Acetyl", ODDB.search_term("Ac\xC3\xA9tyl".dup.force_encoding("ASCII-8BIT")))
    end

    def test_lone_continuation_byte
      # Das war der indication_index: "\xC3" from ASCII-8BIT to UTF-8
      assert_equal("", ODDB.search_term("\xC3".dup.force_encoding("ASCII-8BIT")))
    end

    def test_invalid_utf8_is_scrubbed
      assert_equal("Badbyte", ODDB.search_term("Bad\xFF\xFEbyte".dup.force_encoding("UTF-8")))
    end

    def test_plain_utf8_is_untouched
      assert_equal("Acetylsalicylsaeure", ODDB.search_term("Acetylsalicylsäure"))
    end

    def test_frozen_utf8_is_untouched
      assert_equal("Paracetamol", ODDB.search_term("Paracetamol".freeze))
    end

    def test_search_terms_survives_latin1
      terms = ODDB.search_terms(["Bef\xFCllung".dup.force_encoding("ISO-8859-1")])
      assert_equal(["Befuellung"], terms)
    end

    def test_search_terms_mixed_encodings
      words = [
        "Acetylsalicylsäure",
        "Bef\xFCllung".dup.force_encoding("ISO-8859-1"),
        "Ac\xC3\xA9tyl".dup.force_encoding("ASCII-8BIT")
      ]
      assert_equal(%w[Acetylsalicylsaeure Befuellung Acetyl], ODDB.search_terms(words))
    end
  end
end
