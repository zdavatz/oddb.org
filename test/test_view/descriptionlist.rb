#!/usr/bin/env ruby
# encoding: utf-8
# View::TestDescriptionList -- oddb -- 28.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'view/descriptionlist'

module ODDB
	module View
		class TestDescriptionList <Minitest::Test
			class StubModel
				attr_reader :args
				def description(*args)
					@args = args
				end
			end
			class StubDescriptionList < View::DescriptionList
				public :sort_model
				def init
				end
			end
			class StubLookandfeel
				def language 
					'de'
				end
				def lookandfeel
					self
				end
			end

			def setup
				@model = StubModel.new
				lnf = StubLookandfeel.new
				@list = StubDescriptionList.new([@model], lnf)
			end
			def test_sort_model
				@list.sort_model
				assert_equal(['de'], @model.args)
			end
		end
	end
end
