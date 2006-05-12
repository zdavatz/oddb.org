#!/usr/bin/env ruby
# ComarketingPlugin -- oddb.org -- 09.05.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'drb'

module ODDB
	class CoMarketingPlugin < Plugin
		COMARKETING_PARSER = DRb::DRbObject.new(nil, COMARKETING_URI)
		SOURCE_URI = "http://www.swissmedic.ch/files/pdf/Co-Marketing-Praeparate_nach_Basis.pdf"
		def find(name)
			while(!name.empty?)
				registrations = @app.search_sequences(name).collect { |seq|
					seq.registration }.uniq
				if(registrations.size == 1)
					return registrations.first
				end
				name = name.gsub(/(\s+|^)\S+$/, '')
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
		def update
			@updated = 0
			@found = 0
			@not_found = []
			@pairs = COMARKETING_PARSER.get_pairs(SOURCE_URI)
			@pairs.each { |pair|
				update_pair(*pair)
			}
		end
		def update_pair(original_name, comarketing_name)
			if((original = find(original_name)) \
				 && (comarketing = find(comarketing_name)))
				@found += 1
				update_registration(original, comarketing)
			else
				@not_found.push([original_name, comarketing_name])
			end
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
