#!/usr/bin/env ruby
# FiPDF -- oddb -- 05.02.2004 -- hwyss@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'drb/drb'
require 'util/oddbconfig'
require 'model/fachinfo'
require 'fachinfo_writer'
require 'text/hyphen'
require 'delegate'

module ODDB
	module FiPDF
		include DRb::DRbUndumped
		DATA_DIR = File.expand_path('../data', File.dirname(__FILE__))
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
		def dictionary(language)
			file = case language
			when :fr
				'hyph_fr_FR.dic'
			else
				'hyph_de_CH.dic'
			end
			path = File.expand_path(file, DATA_DIR)
			::Text::Hyphen::Dictionary.new(path)
		end
		def document(filename, language, &block)
			begin
				writer = FachinfoWriter.new
				writer.hyphenator = dictionary(language)
				pdf = FachinfoWriterProxy.new(writer)
				block.call(pdf)
				File.open(filename, 'w') { |fh| 
					fh << writer.ez_output
				}
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
		module_function :document
		module_function :dictionary
	end
end

DRb.start_service(ODDB::FIPDF_URI, ODDB::FiPDF)

$0 = "Oddb (FiPDF)"

DRb.thread.join
