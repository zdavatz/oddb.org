#!/usr/bin/env ruby
# MedData::DRbSession -- oddb.org -- 08.05.2006 -- hwyss@ywesee.com

require 'session'
require 'drb'

module ODDB
	module MedData
		class DRbSession
			include DRb::DRbUndumped
			attr_reader :search_type
			def initialize(search_type)
				@search_type = search_type
				@session = Session.new(search_type)
			end
			def detail(result, template)
				html = @session.detail_html(result.ctl)
				writer = DetailWriter.new
				formatter = Formatter.new(writer)
				parser = HtmlParser.new(formatter)
				parser.feed(html)
				results = writer.extract_data(template)
				remove_whitespace(results)
			end
			def remove_whitespace(data)
				data.each { |key, value|
					value.gsub!(/\240/, "") unless(value.nil?)
				}
			end
			def search(criteria, &block)
				html = @session.get_result_list(criteria)
				if(html.include?('lblcountPreciseSearch'))
					raise OverflowError, 'not all valid entries in result!'
				end
				writer = ResultWriter.new(@search_type)
				formatter = Formatter.new(writer)
				parser = HtmlParser.new(formatter)
				parser.feed(html)
				results = writer.extract_data
				_dispatch(results, &block)
			end
			def _dispatch(results, &block)
				if(block_given?)
					results.each { |ctl, values|
						block.call(Result.new(values, ctl))
					}
					nil
				else
					results.collect { |ctl, values|
						Result.new(values, ctl)
					}
				end
			end
		end
	end
end
