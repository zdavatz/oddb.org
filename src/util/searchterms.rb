#!/usr/bin/env ruby
# ODDB -- oddb -- 05.04.2006 -- hwyss@ywesee.com

module ODDB
  TERM_PAIRS = [
    [/[\/\s\-]+/u, ' '], [/[[:punct:]]/u, ''],
    [/[ÆÄ]/u, 'Ae'], [/[æä]/u, 'ae'],
    [/[ŒÖØ]/u, 'Oe'], [/[œö]/u, 'oe'],
    [/Ü/u, 'Ue'], [/ü/u, 'ue'],
    [/ÅÁÂÀÃĄǍĂĀȦ/u, 'A'], [/Ḃ/u, 'B'], [/ÇĈČĆĊ/u, 'C'], [/ḐĐÐĎḊ/u, 'D'],
    [/ËÉÊÈȨĘĚĔẼĒĖ/u, 'E'], [/ÞḞ/u, 'F'], [/ĢǦĞǴĜḠĠ/u, 'G'], [/ȞĤḦḨḢ/u, 'H'],
    [/ÏÍÎÌĮǏĬĨİ/u, 'I'], [/Ĵ/u, 'J'], [/ǨḰĶ/u, 'K'], [/ŁĹĽĻ/u, 'L'],
    [/ḾṀ/u, 'M'], [/ŇŃÑǸŅṄ/u, 'N'], [/ÓÔÒÕŌŎǪǑȮ/u, 'O'], [/ṔṖ/u, 'P'],
    [/ŘŔŖṘ/u, 'R'], [/ŚŜŠŞṠ/u, 'S'], [/ŤŢṪ/u, 'T'], [/ÚÛÙŲǗǓǙǛŨŬŮǕ/u, 'U'],
    [/Ṽ/u, 'V'], [/ẂŴẀẄẆ/u, 'W'], [/ẌẊ/u, 'X'], [/ŸẎỸỲŶÝȲ/u, 'Y'],
    [/ŽŹẐŻ/u, 'Z'],
    [/åáâàãąǎăāȧ/u, 'a'], [/ḃ/u, 'b'], [/çĉčćċ/u, 'c'], [/ḑđðďḋ/u, 'd'],
    [/ëéêèȩęěĕẽēė/u, 'e'], [/þḟ/u, 'f'], [/ģǧğǵĝḡġ/u, 'g'], [/ȟĥḧḩḣ/u, 'h'],
    [/ïíîìįǐĭĩı/u, 'i'], [/ĵ/u, 'j'], [/ǩḱķ/u, 'k'], [/łĺľļ/u, 'l'],
    [/ḿṁ/u, 'm'], [/ňńñǹņṅ/u, 'n'], [/óôòõōŏøǫǒȯ/u, 'o'], [/ṕṗ/u, 'p'],
    [/řŕŗṙ/u, 'r'], [/śŝšşṡ/u, 's'], [/ťţṫ/u, 't'], [/úûùųǘǔǚǜũŭůǖ/u, 'u'],
    [/ṽ/u, 'v'], [/ẃŵẁẅẇ/u, 'w'], [/ẍẋ/u, 'x'], [/ÿẏỹỳŷýȳ/u, 'y'],
    [/žźẑż/u, 'z']
  ]
  def ODDB.search_term(term)
    term = term.to_s.dup
    TERM_PAIRS.each do |search, replace|
      term.gsub! search, replace
    end
    term
  end
	def ODDB.search_terms(words, opts={})
		terms = []
		words.flatten.compact.uniq.inject(terms) { |terms, term| 
      if(opts[:downcase])
        term = term.downcase
      end
			parts = term.split(/[\/-]/u)
			if(parts.size > 1)
        terms.push(ODDB.search_term(parts.first))
				terms.push(ODDB.search_term(parts.join))
				terms.push(ODDB.search_term(parts.join(' ')))
			else
				terms.push(ODDB.search_term(term))
			end
			terms
		}.select { |term| 
			                # don't exclude analysis-codes
			term.length > 2 # && !/^[0-9]+$/u.match(term)
		}
	end
end
