#!/usr/bin/env ruby
# FiPDF -- oddb -- 05.02.2004 -- hwyss@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'drb/drb'
require 'util/oddbconfig'
require 'model/fachinfo'
require 'fachinfo_writer'
#require 'text/hyphen'
require 'delegate'

module ODDB
	module FiPDF
		include DRb::DRbUndumped
		DATA_DIR = File.expand_path('../data', File.dirname(__FILE__))
		PDF_PATH = File.expand_path('downloads', DATA_DIR)
		class FachinfoWriterProxy < DelegateClass(FachinfoWriter)
			include DRb::DRbUndumped
			def initialize(writer)
				@writer = writer
				super
			end
			def write_fachinfo(fachinfo)
				@writer.write_fachinfo(fachinfo)
=begin
				ObjectSpace.each_object(PDF::Writer::Pages){ |font| 
					puts "#"*100
					puts "#{font.id}:#{font.__id__}" 
					if(path = obj_path(font.__id__))
						puts "Direct Path: #{path.join('-')}"
					else
						puts "Paths:"
						paths = []
						ObjectSpace.each_object { |object|
							if(path = object.obj_path(font.__id__))
								puts "#{object.class.to_s}:#{path.join('-')}"
							end
						}
					end
				}
				ObjectSpace.each_object() { |item|
					item.instance_variables.each { |name|
						if((var = item.instance_variable_get(name)) \
							&& var.is_a?(Array) \
							&& var.any? { |cont| 
								cont.is_a?(PDF::Writer::Contents)
							})
							puts "#"*100
							puts "#{item.class}:#{name}"
							if(path = obj_path(var.__id__))
								puts "Direct Path: #{path.join('-')}"
							end
						end
					}
				}
=end
				''
			end
		end
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
      ## Work around a bug in ruby's Delegate Lib.
      def respond_to?(method, *args)
        super method
      end
      def substance_names
        @fachinfo.substance_names
      end
    end
		def dictionary(language)
      require 'text/hyphen'
      ::Text::Hyphen.new(:language => language.to_s)
		end
		def document(filename, language, &block)
			begin
				writer = FachinfoWriter.new :language => language
				writer.hyphenator = dictionary(language)
				pdf = FachinfoWriterProxy.new(writer)
				block.call(pdf)
        writer.save_as filename
        $stdout.flush
			rescue Exception => e
				puts e
				puts e.backtrace
			ensure
				# Cache-Files are only being deleted when their corresponding 
				# instance is Garbage-Collected:
				GC.start
			end
			''
		end
    def write_pdf(fachinfo_ids, language, path)
      fachinfos = fachinfo_ids.collect do |id| ODBA.cache.fetch id end
      fachinfos = fachinfos.sort_by { |fachinfo|
        ODDB.search_term(fachinfo.send(language).name).downcase
      }
      total = fachinfos.size
      puts "Total: #{total} fachinfos to write"
      document(path, language) { |document|
        start_time = Time.new
        fachinfos.each_with_index { |fachinfo, idx|
          puts "checking Fachinfo: (#{idx}/#{total})"
          if(fachinfo.registrations.any? { |reg| reg.public_package_count > 0 })
            puts "writing Fachinfo: (#{idx}/#{total})"
            proxy = FachinfoProxy.new(fachinfo, language)
            document.write_fachinfo(proxy) if(proxy.first_chapter)
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
		module_function :document
		module_function :dictionary
    module_function :write_pdf
	end
end
