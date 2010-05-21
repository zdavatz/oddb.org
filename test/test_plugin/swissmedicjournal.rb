#!/usr/bin/env ruby
# TestSmjPlugin -- oddb -- 30.04.2003 -- benfay@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/swissmedicjournal'

class Object
  @@today = Date.today
end
module ODDB
	class TestSmjPlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@app.should_receive :registration
			@plugin = ODDB::SwissmedicJournalPlugin.new(@app)
		end
		def test_update
			assert_respond_to(@plugin, :update)
		end
		def test_log_info
			@app.should_receive(:atcless_sequences).and_return { [] }
			info = @plugin.log_info
			[:report, :change_flags, :recipients].each { |key|
				assert(info.include?(key))
			}
		end
	end
end
