#!/usr/bin/env ruby
# State::Drugs::TestIncompleteRegs -- oddb -- 25.08.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/incompleteregistrations'
require 'sbsm/state'

module Net
	class HTTP
		alias :_old_head :head
		def head(*args)
			if(/file\.xls/.match args.first)
				HTTPOK.new(nil, nil, nil)
			else
				_old_head(*args)
			end
		end
	end
end
module ODDB
	class BsvPlugin
		def update_from_url(source, filename, target)
			if(target =~ /file.xls/)
				true
			else
				false
			end
		end
	end
	module State
		module Drugs
class IncompleteRegs < State::Drugs::Global
	public :url_parts
end
class StubIncompleteRegsSession
	attr_writer :user_input
	def user_input(key)
		@user_input[key] 
	end
	def app
		@app ||= State::Drugs::StubIncompleteRegsApp.new
	end
end
class StubIncompleteRegsApp
	attr_accessor :registrations, :updates, :packages, :deletions
	def initialize
		@deletions = []
		@updates = {}
	end
	def delete(pointer)
		@deletions.push(pointer)
	end
	def each_package(&block)
		@packages.each(&block)
	end
	def registration(iksnr)
		(@registrations ||={})[iksnr]
	end
	def update(pointer, values)
		@updates.store(pointer, values)
	end
	def async(&block)
		true
	end
end

class TestIncompleteRegs < Test::Unit::TestCase
	def setup
		@session = State::Drugs::StubIncompleteRegsSession.new
		@state = State::Drugs::IncompleteRegs.new(@session, nil)
	end
	def test_update_bsv
		file = @session.user_input = { :bsv_url => 'http://www.oddb.org/file.xls' }
		@state.update_bsv
		assert_equal([:i_bsv_in_progress], @state.infos)
	end
	def test_update_bsv2
		file = @session.user_input = { :bsv_url => 'http://www.oddb.org/nofilethere.xls' }
		@state.update_bsv
		result = @state.errors[:bsv_url].message
		assert_equal('e_file_not_found', result)
	end
	def test_update_bsv3
		file = @session.user_input = { :bsv_url => 'http://www.oddb.org/nofilethere.doc' }
		@state.update_bsv
		result = @state.errors[:bsv_url].message
		assert_equal('e_invalid_url', result)
	end
	def test_url_parts
		assert_nil(@state.url_parts('fdesafdas'))
		expected = [
			'www.foo.bar',
			'/files/baz.xls',
			'baz.xls',
		]
		assert_equal(expected, @state.url_parts('http://www.foo.bar/files/baz.xls'))
	end
end
		end
	end
end
