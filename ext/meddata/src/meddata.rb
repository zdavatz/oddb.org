#!/usr/bin/env ruby
# MedData -- oddb -- 26.11.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'session'
require 'parser'
require 'result'

module ODDB
	module MedData
class OverflowError < RuntimeError; end
MEDDATA_SERVER = 'www.medwin.ch'
def MedData.detail(result, template)
	html = result.session.detail_html(result.ctl)
	writer = DetailWriter.new
	formatter = Formatter.new(writer)
	parser = HtmlParser.new(formatter)
	parser.feed(html)
	results = writer.extract_data(template)
	remove_whitespace(results)
end
def MedData.remove_whitespace(data)
	data.each { |key, value|
		value.gsub!(/\240/, "") unless(value.nil?)
	}
end
def MedData.search(criteria, search_type=:partner, &block)
	session = Session.new(MEDDATA_SERVER, search_type)
	html = session.get_result_list(criteria)
	if(html.include?('lblcountPreciseSearch'))
		raise OverflowError, 'not all valid entries in result!'
	end
	writer = ResultWriter.new(search_type)
	formatter = Formatter.new(writer)
	parser = HtmlParser.new(formatter)
	parser.feed(html)
	results = writer.extract_data
	_dispatch(session, results, &block)
end
def MedData._dispatch(session, results, &block)
	if(block_given?)
		results.each { |resultline|
			ctl, values = resultline
      result = Result.new(session, values, ctl)
			block.call(result)
		}
		nil
	else
		results.collect { |resultline|  
			ctl, values = resultline
      result = Result.new(session, values, ctl)
		}
	end
end
	end
end
