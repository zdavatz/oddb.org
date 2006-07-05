#!/usr/bin/env ruby
# TestCoMarketingPlugin -- oddb.org -- 09.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'flexmock'
require 'plugin/comarketing'

module ODDB
	class TestCoMarketingPlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = CoMarketingPlugin.new(@app)
		end
		def test_find
      flap_flag = false
			name = "Alpina Arnica-Gel mit Spilanthes, Gel"
			expected = [
				"Alpina Arnica Gel mit Spilanthes Gel",
				"Alpina Arnica Gel mit Spilanthes",
				"Alpina Arnica Gel mit",
				"Alpina Arnica Gel",
				"Alpina",
			]
			@app.mock_handle(:search_sequences, 10) { |query, fuzzflag|
				assert_equal(flap_flag, fuzzflag)
        flap_flag = !flap_flag
        exp = expected.shift
				assert_equal(exp, query)
        if(flap_flag)
          expected.unshift(exp)
        end
				[]
			}
			result = @plugin.find(name)
			assert_nil(result)
      @app.mock_verify
		end
		def test_find__lacteol
      flap_flag = false
			name = "Lactéol 5, capsules"
			expected = [
				"Lacteol 5 capsules",
				"Lacteol 5",
				"Lacteol",
			]
			@app.mock_handle(:search_sequences, 6) { |query, fuzzflag|
				assert_equal(flap_flag, fuzzflag)
        flap_flag = !flap_flag
        exp = expected.shift
				assert_equal(exp, query)
        if(flap_flag)
          expected.unshift(exp)
        end
				[]
			}
			result = @plugin.find(name)
			assert_nil(result)
      @app.mock_verify
		end
		def test_find__lactoferment
      flap_flag = false
			name = "Lactoferment 5, Kapseln"
			expected = [
				"Lactoferment 5 Kapseln",
				"Lactoferment 5",
				"Lactoferment",
			]
			@app.mock_handle(:search_sequences, 6) { |query, fuzzflag|
				assert_equal(flap_flag, fuzzflag)
        flap_flag = !flap_flag
        exp = expected.shift
				assert_equal(exp, query)
        if(flap_flag)
          expected.unshift(exp)
        end
				[]
			}
			result = @plugin.find(name)
			assert_nil(result)
		end
	end
end
