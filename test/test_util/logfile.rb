#!/usr/bin/env ruby
# TestLogFile -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/logfile'

module ODDB
	module LogFile
		LOG_ROOT = File.expand_path('../data/log', File.dirname(__FILE__))
	end
end

class TestLogFile < Test::Unit::TestCase
	def test_filename
		expected = '/var/www/oddb.org/test/data/log/foo/2003/08.log'
		res = ODDB::LogFile.filename(:foo, Date.new(2003,8,21))
		assert_equal(expected, res)
		res = ODDB::LogFile.filename(:foo, Time.local(2003,8,21))
		assert_equal(expected, res)
	end
	def test_create_dir
		file = '/var/www/oddb.org/test/data/log/foo/2003/08.log'
		begin
			ODDB::LogFile.append(:foo, ';foobar', Time.local(2003,8,21,19,32,10))
			assert(File.exist?(file), "Missing Logfile: #{file}")
			expected = "2003-08-21 19:32:10 CEST;foobar\n"
			assert_equal(expected, File.read(file))
		ensure
			if(File.exist?(file))
				File.delete(file) 
				Dir.rmdir(File.dirname(file))
			end
		end
	end
	def test_append
		file = '/var/www/oddb.org/test/data/log/foo/2003/08.log'
		begin
			ODDB::LogFile.append(:foo, ';foobar', Time.local(2003,8,21,19,32,10))
			assert(File.exist?(file), "Missing Logfile: #{file}")
			expected = "2003-08-21 19:32:10 CEST;foobar\n"
			assert_equal(expected, File.read(file))
			ODDB::LogFile.append(:foo, ';barbaz', Time.utc(2003,8,21,10,02,25))
			expected << "2003-08-21 10:02:25 GMT;barbaz\n"
			assert_equal(expected, File.read(file))
		ensure
			if(File.exist?(file))
				File.delete(file) 
				Dir.rmdir(File.dirname(file))
			end
		end
	end
	def test_read
		file = '/var/www/oddb.org/test/data/log/foo/2003/08.log'
		begin
			ODDB::LogFile.append(:foo, ';foobar', Time.local(2003,8,21,19,32,10))
			assert(File.exist?(file), "Missing Logfile: #{file}")
			expected = "2003-08-21 19:32:10 CEST;foobar\n"
			assert_equal(expected, ODDB::LogFile.read(:foo, Date.new(2003,8)))
		ensure
			if(File.exist?(file))
				File.delete(file) 
				Dir.rmdir(File.dirname(file))
			end
		end
	end
end
