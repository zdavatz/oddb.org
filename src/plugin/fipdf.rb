#!/usr/bin/env ruby
# FiPDFExporter -- ODDB -- 13.02.2004 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'util/oddbconfig'
require 'drb'
require 'model/fachinfo'
require 'delegate'

module ODDB
	class FiPDFExporter < Plugin
		WRITER = DRbObject.new(nil, FIPDF_URI)
		PDF_PATH = File.expand_path('pdf/fachinfo', ARCHIVE_PATH)
		class FachinfoProxy < DelegateClass(FachinfoDocument)
			include DRb::DRbUndumped
			attr_reader :fachinfo
			def initialize(fachinfo, language=:de)
				@fachinfo = fachinfo
				@fachinfo_document = fachinfo.send(language)
				super(@fachinfo_document)
			end
			def company_name
				@fachinfo.company_name
			end
			def generic_type
				@fachinfo.generic_type
			end
			def substance_names
				@fachinfo.substance_names
			end
		end
		def run
			write_pdf
		end
		def write_pdf(fachinfos = nil, language = :de, path = nil)
			path ||= File.expand_path('fachinfos.pdf', PDF_PATH)
			fachinfos ||= @app.fachinfos.values
			fachinfos = fachinfos.sort_by { |fachinfo|
				fachinfo.send(language).name
			}
			total = fachinfos.size
			puts "Total: #{total} fachinfos to write"
			WRITER.document(path, language) { |document|
				start_time = Time.new
				fachinfos.each_with_index { |fachinfo, idx|
					puts "checking Fachinfo: (#{idx}/#{total})"
					unless(fachinfo.registrations.empty?)
						puts "writing Fachinfo: (#{idx}/#{total})"
						proxy = FachinfoProxy.new(fachinfo, language)
						document.write_fachinfo(proxy)
						puts "done"
					end
				}
				end_time = Time.new
				document.write_substance_index
				puts "Fachinfos took #{end_time - start_time} seconds or #{(end_time - start_time) / 60} minutes"
				puts "closing writer"
			}	
			puts "written all pdfs"
		end
	end
end
