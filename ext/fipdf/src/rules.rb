#!/usr/bin/env ruby
#PdfWriterRules -- oddb -- 10.02.2004 -- mwalder@ywesee.com

require 'pdf/ezwriter'
require 'model/text'

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

module ODDB
	module FiPDF
		class Rule
			attr_reader :name
			def initialize(name)
				@name = name
				@pagebreak = 0
				@lines = 0
			end
			def notify(event)
			end
			def fulfilled?
				false
			end
		end
		class OrphanRule < Rule
			attr_reader :pagebreak, :lines
			def fulfilled?
				(@pagebreak == 0) || (@lines < 2) || (@pagebreak > 1)
			end
			def notify(event)
				case event
				when :add_text_wrap
					@lines += 1
				when :ez_new_page
					@pagebreak = @lines unless @pagebreak > 0
				end
			end
		end
		class WidowRule < Rule 
			attr_reader :pagebreak, :lines
			def fulfilled?
				!((@lines - @pagebreak) == 1 && @pagebreak != 0)
			end
			def notify(event)
				case event
				when :add_text_wrap
					@lines += 1
				when :ez_new_page
					@pagebreak = @lines
				end
			end
		end
		class FachinfoRule < Rule
			attr_reader :pagebreak, :paragraphs
			def initialize(*args)
				super
				@paragraphs = 0
				@pagebreak = -1
			end
			def fulfilled?
				@pagebreak != 0
			end
			def notify(event)
				case event
				when :write_paragraph
					@paragraphs += 1
				when :ez_new_page
					@pagebreak = @paragraphs if @pagebreak < 0
				end
			end
		end
	end
end
