#!/usr/bin/env ruby
# TestUpdater -- oddb -- 23.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/updater'
require 'stub/odba'

module ODDB
	class StubUpdaterPlugin
		attr_reader :month
		def initialize(app)
			@app = app
		end
		def log_info
			{
				:report =>	@last_date,
			}
		end
		def update(date)
			@last_date = @month = @app.last_date = date
			date < Date.new(2002,12)
		end
		def report
			@last_date
		end
		def incomplete_pointers
			[]
		end
		alias :recipients :incomplete_pointers
	end
	class TestUpdater < Test::Unit::TestCase
		class StubLog
			include ODDB::Persistence
			attr_accessor :report, :pointers, :recipients, :hash
			def notify(arg=nil)
			end
		end
		class StubApp
			attr_writer :log_group
			attr_reader :pointer, :values, :model
			attr_accessor :last_date
			def initialize
				@model = StubLog.new
			end
			def update(pointer, values)
				@pointer = pointer
				@values = values
				@model
			end
			def log_group(key)
				@log_group
			end
			def create(pointer)
				@log_group
			end
		end
		class StubLogGroup
			attr_accessor :newest_date
			def pointer
				ODDB::Persistence::Pointer.new([:log_group, :foo])
			end
		end

		def setup
			@app = StubApp.new
			@updater = ODDB::Updater.new(@app)
			@group = @app.log_group = StubLogGroup.new
		end
		def test_update_bsv_no_repeats
			today = Date.today()
			this_month = Date.new(today.year, today.month)
			@group.newest_date = this_month >> 1
			@updater.update_bsv
			assert_nil(@app.last_date)
		end
	end
end
