#!/usr/bin/env ruby

# ODDB -- oddb -- 05.04.2006 -- hwyss@ywesee.com

module ODDB
  TERM_PAIRS = {
    "Æ" => "Ae", "Ä" => "Ae",
    "æ" => "ae", "ä" => "ae",
    "Œ" => "Oe", "Ö" => "Oe", "Ø" => "Oe",
    "œ" => "oe", "ö" => "oe",
    "Ü" => "Ue", "ü" => "ue",
    "Å" => "A", "Á" => "A", "Â" => "A", "À" => "A", "Ã" => "A", "Ą" => "A",
    "Ǎ" => "A", "Ă" => "A", "Ā" => "A", "Ȧ" => "A",
    "Ḃ" => "B",
    "Ç" => "C", "Ĉ" => "C", "Č" => "C", "Ć" => "C", "Ċ" => "C",
    "Ḑ" => "D", "Đ" => "D", "Ð" => "D", "Ď" => "D", "Ḋ" => "D",
    "Ë" => "E", "É" => "E", "Ê" => "E", "È" => "E", "Ȩ" => "E", "Ę" => "E",
    "Ě" => "E", "Ĕ" => "E", "Ẽ" => "E", "Ē" => "E", "Ė" => "E",
    "Þ" => "F", "Ḟ" => "F",
    "Ģ" => "G", "Ǧ" => "G", "Ğ" => "G", "Ǵ" => "G", "Ĝ" => "G", "Ḡ" => "G",
    "Ġ" => "G",
    "Ȟ" => "H", "Ĥ" => "H", "Ḧ" => "H", "Ḩ" => "H", "Ḣ" => "H",
    "Ï" => "I", "Í" => "I", "Î" => "I", "Ì" => "I", "Į" => "I", "Ǐ" => "I",
    "Ĭ" => "I", "Ĩ" => "I", "İ" => "I",
    "Ĵ" => "J",
    "Ǩ" => "K", "Ḱ" => "K", "Ķ" => "K",
    "Ł" => "L", "Ĺ" => "L", "Ľ" => "L", "Ļ" => "L",
    "Ḿ" => "M", "Ṁ" => "M",
    "Ň" => "N", "Ń" => "N", "Ñ" => "N", "Ǹ" => "N", "Ņ" => "N", "Ṅ" => "N",
    "Ó" => "O", "Ô" => "O", "Ò" => "O", "Õ" => "O", "Ō" => "O", "Ŏ" => "O",
    "Ǫ" => "O", "Ǒ" => "O", "Ȯ" => "O",
    "Ṕ" => "P", "Ṗ" => "P",
    "Ř" => "R", "Ŕ" => "R", "Ŗ" => "R", "Ṙ" => "R",
    "Ś" => "S", "Ŝ" => "S", "Š" => "S", "Ş" => "S", "Ṡ" => "S", "ß" => "ss",
    "Ť" => "T", "Ţ" => "T", "Ṫ" => "T",
    "Ú" => "U", "Û" => "U", "Ù" => "U", "Ų" => "U", "Ǘ" => "U", "Ǔ" => "U",
    "Ǚ" => "U", "Ǜ" => "U", "Ũ" => "U", "Ŭ" => "U", "Ů" => "U", "Ǖ" => "U",
    "Ṽ" => "V",
    "Ẃ" => "W", "Ŵ" => "W", "Ẁ" => "W", "Ẅ" => "W", "Ẇ" => "W",
    "Ẍ" => "X", "Ẋ" => "X",
    "Ÿ" => "Y", "Ẏ" => "Y", "Ỹ" => "Y", "Ỳ" => "Y", "Ŷ" => "Y", "Ý" => "Y",
    "Ȳ" => "Y",
    "Ž" => "Z", "Ź" => "Z", "Ẑ" => "Z", "Ż" => "Z",
    "å" => "a", "á" => "a", "â" => "a", "à" => "a", "ã" => "a", "ą" => "a",
    "ǎ" => "a", "ă" => "a", "ā" => "a", "ȧ" => "a",
    "ḃ" => "b",
    "ç" => "c", "ĉ" => "c", "č" => "c", "ć" => "c", "ċ" => "c",
    "ḑ" => "d", "đ" => "d", "ð" => "d", "ď" => "d", "ḋ" => "d",
    "ë" => "e", "é" => "e", "ê" => "e", "è" => "e", "ȩ" => "e", "ę" => "e",
    "ě" => "e", "ĕ" => "e", "ẽ" => "e", "ē" => "e", "ė" => "e",
    "þ" => "f", "ḟ" => "f",
    "ģ" => "g", "ǧ" => "g", "ğ" => "g", "ǵ" => "g", "ĝ" => "g", "ḡ" => "g",
    "ġ" => "g",
    "ȟ" => "h", "ĥ" => "h", "ḧ" => "h", "ḩ" => "h", "ḣ" => "h",
    "ï" => "i", "í" => "i", "î" => "i", "ì" => "i", "į" => "i", "ǐ" => "i",
    "ĭ" => "i", "ĩ" => "i", "ı" => "i",
    "ĵ" => "j",
    "ǩ" => "k", "ḱ" => "k", "ķ" => "k",
    "ł" => "l", "ĺ" => "l", "ľ" => "l", "ļ" => "l",
    "ḿ" => "m", "ṁ" => "m",
    "ň" => "n", "ń" => "n", "ñ" => "n", "ǹ" => "n", "ņ" => "n", "ṅ" => "n",
    "ó" => "o", "ô" => "o", "ò" => "o", "õ" => "o", "ō" => "o", "ŏ" => "o",
    "ø" => "o", "ǫ" => "o", "ǒ" => "o", "ȯ" => "o",
    "ṕ" => "p", "ṗ" => "p",
    "ř" => "r", "ŕ" => "r", "ŗ" => "r", "ṙ" => "r",
    "ś" => "s", "ŝ" => "s", "š" => "s", "ş" => "s", "ṡ" => "s",
    "ť" => "t", "ţ" => "t", "ṫ" => "t",
    "ú" => "u", "û" => "u", "ù" => "u", "ų" => "u", "ǘ" => "u", "ǔ" => "u",
    "ǚ" => "u", "ǜ" => "u", "ũ" => "u", "ŭ" => "u", "ů" => "u", "ǖ" => "u",
    "ṽ" => "v",
    "ẃ" => "w", "ŵ" => "w", "ẁ" => "w", "ẅ" => "w", "ẇ" => "w",
    "ẍ" => "x", "ẋ" => "x",
    "ÿ" => "y", "ẏ" => "y", "ỹ" => "y", "ỳ" => "y", "ŷ" => "y", "ý" => "y",
    "ȳ" => "y",
    "ž" => "z", "ź" => "z", "ẑ" => "z", "ż" => "z"
  }
  TERM_PTRN = /[#{TERM_PAIRS.keys.join}]/u
  def self.search_term(term)
    begin
    term = term.encode("UTF-8") unless term.frozen?
    rescue Encoding::UndefinedConversionError => error
      # work around some problems. See https://github.com/zdavatz/oddb.org/issues/386
      puts "#{error} #{term} #{term.encoding} #{error.backtrace[0..3].join("\n")}"
      term.force_encoding('ISO-8859-1')
      term = term.encode('UTF-8')
    end
    term = term.to_s.gsub(/[[:punct:]]/u, "")
    term.gsub!(/[\/\s\-]+/u, " ")
    term.gsub! TERM_PTRN do |match| TERM_PAIRS.fetch match, match end
    term
  end

  def self.search_terms(words, opts = {})
    terms = []
    words.flatten.compact.uniq.each_with_object(terms) do |term, terms|
      if opts[:downcase]
        term = term.downcase
      end
      begin
      term = term.encode("UTF-8") unless term.frozen?
      rescue => error
        ODDB::LogFile.debug("#{term} #{error} #{error.backtrace[0..10].join("\n")}")
        term.force_encoding("ISO-8859-1")
        term = term.encode("UTF-8")
      end
      parts = term.split(/[\/-]/u)
      if parts.size > 1
        terms.push(ODDB.search_term(parts.first))
        terms.push(ODDB.search_term(parts.join))
        terms.push(ODDB.search_term(parts.join(" ")))
      else
        terms.push(ODDB.search_term(term))
      end
    end.select { |term|
      term.length > 2 # && !/^[0-9]+$/u.match(term)
    }
  end
end
