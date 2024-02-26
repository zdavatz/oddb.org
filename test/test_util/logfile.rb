#!/usr/bin/env ruby
# encoding: utf-8
# TestLogFile -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'util/logfile'
require 'util/workdir'

module ODDB
	module LogFile
		LOG_ROOT = File.join(ODDB::WORK_DIR, 'log')
	end
end

class TestLogFile <Minitest::Test
	def test_filename
		expected = File.join(ODDB::WORK_DIR, 'log/foo/2003/08.log')
		res = ODDB::LogFile.filename(:foo, Date.new(2003,8,21))
		assert_equal(expected, res)
		res = ODDB::LogFile.filename(:foo, Time.utc(2003,8,21))
		assert_equal(expected, res)
	end
	def test_create_dir
		file = File.join(ODDB::WORK_DIR, 'log/foo/2003/08.log')
		begin
			ODDB::LogFile.append(:foo, ';foobar', Time.utc(2003,8,21,19,32,10))
			assert(File.exist?(file), "Missing Logfile: #{file}")
			expected = "2003-08-21 19:32:10 UTC;foobar\n"
			assert_equal(expected, File.read(file))
		ensure
			if(File.exist?(file))
				File.delete(file) 
				Dir.rmdir(File.dirname(file))
			end
		end
	end
	def test_append
		file = File.join(ODDB::WORK_DIR, 'log/foo/2003/08.log')
		begin
			ODDB::LogFile.append(:foo, ';foobar', Time.utc(2003,8,21,19,32,10))
			assert(File.exist?(file), "Missing Logfile: #{file}")
			expected = "2003-08-21 19:32:10 UTC;foobar\n"
			assert_equal(expected, File.read(file))
			ODDB::LogFile.append(:foo, ';barbaz', Time.utc(2003,8,21,10,02,25))
			expected << "2003-08-21 10:02:25 UTC;barbaz\n"
			assert_equal(expected, File.read(file))
		ensure
			if(File.exist?(file))
				File.delete(file) 
				Dir.rmdir(File.dirname(file))
			end
		end
	end
	def test_read
		file = File.join(ODDB::WORK_DIR, 'log/foo/2003/08.log')
		begin
			ODDB::LogFile.append(:foo, ';foobar', Time.utc(2003,8,21,19,32,10))
			assert(File.exist?(file), "Missing Logfile: #{file}")
			expected = "2003-08-21 19:32:10 UTC;foobar\n"
			assert_equal(expected, ODDB::LogFile.read(:foo, Date.new(2003,8)))
		ensure
			if(File.exist?(file))
				File.delete(file) 
				Dir.rmdir(File.dirname(file))
			end
		end
	end
end
