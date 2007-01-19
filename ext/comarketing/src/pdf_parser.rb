#!/usr/bin/env ruby
# CoMarketing::PdfParser -- oddb.org -- 08.05.2006 -- hwyss@ywesee.com

require 'rpdf2txt/parser'
require 'open-uri'

module ODDB
	module CoMarketing
		class PdfParser
			class CallbackHandler < Rpdf2txt::SimpleHandler
				attr_reader :pairs
				def initialize
					@pairs = []
					reset
				end
				def firstword(str)
					str.strip.split(/\s+/, 2).first
				end
				def reset
					@current_column = 0
					@raw_original = ''
					@raw_comarketing = ''
				end
				def send_column
					if(@current_column == 1 && firstword(@raw_original))
						@original = @raw_original.strip
					end
					@current_column += 1
				end
				def send_flowing_data(data)
					if(/tierarzneimittel/i.match(data))
						throw :vet_products
					end
					case @current_column
					when 1
						@raw_original << data
					when 3,4
						@raw_comarketing << data
					end
				end
				def send_line_break
					if(@original && (iksnr = @raw_comarketing[/\d{5}/]))
						@pairs.push([@original, iksnr])
					end
					reset
				end
				def send_page
					reset
				end
			end
			def initialize(path)
				open(path) { |fh|
					@rpdf2txt = Rpdf2txt::Parser.new(fh.read)
				}
			end
			def extract_pairs
				handler = CallbackHandler.new
				catch(:vet_products) {
					@rpdf2txt.extract_text(handler)
				}
				handler.pairs
			end
		end
	end
end
