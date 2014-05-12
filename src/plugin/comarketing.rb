#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::ComarketingPlugin -- oddb.org -- 29.12.2011 -- mhatakeyama@ywesee.com
# ODDB::ComarketingPlugin -- oddb.org -- 09.05.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/searchterms'
require 'mechanize'
require 'drb'
require 'rubyXL'
require 'open-uri'
require 'tempfile'

module ODDB
	class CoMarketingPlugin < Plugin
		SOURCE_URI = 'https://www.swissmedic.ch/arzneimittel/00156/00221/00222/00239/index.html?lang=de'
		def find(iksnr)
      @app.registration(iksnr)
		end
		def _find(name, fuzz=false)
			search_term = ODDB.search_term(name)
			sequences = @app.search_sequences(search_term, fuzz)
			registrations = sequence_registrations(sequences)
			if(registrations.size > 1)
				if(registrations.size > 1 && (match = /,\s*([^,]+)$/u.match(name)) \
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
    def prune_comarketing except_pairs
      table = {}
      except_pairs.each do |original, comarketing|
        table.store comarketing, original
      end
      @app.registrations.each do |iksnr, reg|
        if (com_reg = reg.comarketing_with) && table[iksnr] != com_reg.iksnr
          @app.update reg.pointer, :comarketing_with => nil
          @deleted += 1
        end
      end
    end
		def report
			fmt =  "Found                %3i Co-Marketing-Pairs\n"
			fmt << "of which             %3i were found in the Database\n"
			fmt << "New Connections:     %3i\n"
			fmt << "Deleted Connections: %3i\n\n"
			fmt << "The following        %3i Original/Comarketing-Pairs were not found in the Database:\n"
			txt = sprintf(fmt, @pairs.size, @found, @updated, @deleted, @not_found.size)
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
    def get_pairs(url)
      tempfile = Tempfile.new('comarketing.xlsx')
      open(url) do |input|
          tempfile.print input.read
      end
      pairs = []
      workbook = RubyXL::Parser.parse(tempfile.path)
      workbook[0].each do |row|
        if row[0] and row[0].value.to_i > 0
          original_iksnr = "%05d" % row[0].value.to_i.to_s
          comarket_iksnr = "%05d" % row[3].value.to_i.to_s
					pairs <<  [original_iksnr, comarket_iksnr]
        end
      end
      tempfile.close
      pairs.uniq
    end
		def update(agent=Mechanize.new)
      @deleted = 0
			@updated = 0
			@found = 0
			@not_found = []
      page = agent.get SOURCE_URI
      link = page.links.find do |node|
        /Excel-Version/iu.match node.attributes['title']
      end or raise "unable to identify url for Co-Marketing-data"
      url = link.attributes['href']
      url = "https://www.swissmedic.ch/#{link.attributes['href']}" unless File.exists?(url) # for unit testing
			@pairs = get_pairs(url)
			@pairs.each { |pair|
				update_pair(*pair)
			}
      prune_comarketing @pairs
		end
		def update_pair(original_iksnr, comarketing_iksnr)
			if((original = find(original_iksnr)) \
				 && (comarketing = find(comarketing_iksnr)))
				@found += 1
				update_registration(original, comarketing)
			else
				@not_found.push([original_iksnr, comarketing_iksnr])
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
