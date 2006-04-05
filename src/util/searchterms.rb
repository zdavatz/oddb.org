#!/usr/bin/env ruby
# ODDB -- oddb -- 05.04.2006 -- hwyss@ywesee.com

module ODDB
	def ODDB.search_term(term)
		term = term.to_s.gsub(/\s+/, ' ')
		term.gsub!(/[,'\-]/, '')
		term.gsub!(/[ÁÂÀ]/, 'A')
		term.gsub!(/[áâà]/, 'a')
		term.gsub!(/Ä/, 'Ae')
		term.gsub!(/ä/, 'ae')
		term.gsub!(/ç/, 'c')
		term.gsub!(/[ÉÊÈË]/, 'E')
		term.gsub!(/[éêèë]/, 'e')
		term.gsub!(/[ÍÎÌÏ]/, 'I')
		term.gsub!(/[íîìï]/, 'i')
		term.gsub!(/ÓÔÒ/, 'O')
		term.gsub!(/óôò/, 'o')
		term.gsub!(/Ö/, 'Oe')
		term.gsub!(/ö/, 'oe')
		term.gsub!(/ÚÛÙ/, 'U')
		term.gsub!(/úûù/, 'u')
		term.gsub!(/Ü/, 'Ue')
		term.gsub!(/ü/, 'ue')
		term
	end
	def ODDB.search_terms(words)
		terms = []
		words.flatten.compact.uniq.inject(terms) { |terms, term| 
			parts = term.split('-')
			if(parts.size > 1)
				terms.push(ODDB.search_term(parts.join))
				terms.push(ODDB.search_term(parts.join(' ')))
			else
				terms.push(ODDB.search_term(term))
			end
			terms
		}.select { |term| 
			term.length > 2 && !/^[0-9]+$/.match(term)
		}
	end
end
