#!/usr/bin/env ruby
# ComarketingPlugin -- oddb.org -- 09.05.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/searchterms'
require 'drb'

module ODDB
	class CoMarketingPlugin < Plugin
		COMARKETING_PARSER = DRb::DRbObject.new(nil, COMARKETING_URI)
		SOURCE_URI = "http://www.swissmedic.ch/files/pdf/Co-Marketing-Praeparate_nach_Basis.pdf"
		def find(iksnr)
      @app.registration(iksnr)
=begin
			while(!name.empty?)
				if(registration = (_find(name) || _find(name, true)))
					return registration
				end
				name = name.gsub(/(\s+|^)\S+$/, '')
			end
=end
		end
		def _find(name, fuzz=false)
			search_term = ODDB.search_term(name)
			sequences = @app.search_sequences(search_term, fuzz)
			registrations = sequence_registrations(sequences)
			if(registrations.size > 1)
				if(registrations.size > 1 && (match = /,\s*([^,]+)$/.match(name)) \
					 && (galform = @app.galenic_form(match[1])))
					registrations = sequence_registrations(sequences) { |seq|
						galform.equivalent_to?(seq.galenic_form)
					}
					if(registrations.size > 1)
						registrations = sequence_registrations(sequences) { |seq|
							galform == seq.galenic_form
						}
					end
				end
			end
			if(registrations.size == 1)
				return registrations.first
			end
		end
		def report
			fmt =  "Found            %3i Co-Marketing-Pairs\n"
			fmt << "of which         %3i were found in the Database\n"
			fmt << "New Connections: %3i\n\n"
			fmt << "The following    %3i Original/Comarketing-Pairs were not found in the Database:\n"
			txt = sprintf(fmt, @pairs.size, @found, @updated, @not_found.size)
			@not_found.each { |original, comarketing|	
				txt << sprintf("%s\n -> %s\n\n", original, comarketing)
			}
			txt
		end
		def sequence_registrations(sequences, &block)
			if(block)
				sequences = sequences.select(&block)
			end
			regs = _sequence_registrations(sequences)
			if(regs.size > 1)
				regs = _sequence_registrations(sequences.select { |seq| seq.active? })
			end
			regs
		end
		def _sequence_registrations(sequences)
			sequences.collect { |seq| 
				seq.registration }.uniq.reject { |reg| reg.parallel_import }
		end
		def update
			@updated = 0
			@found = 0
			@not_found = []
			@pairs = COMARKETING_PARSER.get_pairs(SOURCE_URI)
			@pairs.each { |pair|
				update_pair(*pair)
			}
		end
		def update_pair(original_iksnr, comarketing_iksnr)
			if((original = find(original_iksnr)) \
				 && (comarketing = find(comarketing_iksnr)))
				@found += 1
				update_registration(original, comarketing)
			else
				@not_found.push([original_iksnr, comarketing_iksnr])
			end
=end
		end
		def update_registration(original, comarketing)
			unless((old = comarketing.comarketing_with) \
						 && old.pointer == original.pointer)
				@updated += 1
				@app.update(comarketing.pointer, 
										{:comarketing_with => original.pointer}, :swissmedic)
			end
		end
	end
end
