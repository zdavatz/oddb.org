#!/usr/bin/env ruby
# TestResultList -- oddb -- 05.03.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/resultlist'
require 'view/rootresultlist'
require 'util/language'

module ODDB
	class ResultList < HtmlGrid::List
		public :init
		attr_reader :model
	end
	class RootResultList < ResultList
		public :hash_insert
	end
end
class StubResultListCompany
	attr_accessor :name, :cl_status 
	def initialize(name, cl_status)
		@name = name
		@cl_status = cl_status
	end
end
class StubResultListPackage
	def barcode
		'7680123450124'
	end
	def company
		StubResultListCompany.new("ywesee","true")
	end
	def company_name
		company.name
	end
	def method_missing(*args)
		nil
	end
	def price_public
		67890
	end
	def price_exfactory
		12345
	end
	def active_agents
		[]
	end
	def substances
		[]
	end
	def registration
		self
	end
	def iksnr
		'1234567'
	end
end
class StubResultListModel
	attr_accessor :package_count
	def initialize
		@package_count = 12
	end
	def code
		'A01AA01'
	end
	def packages
		[StubResultListPackage.new]
	end
	def description(foo)
		'foo'
	end
	def has_ddd?
		false
	end
end
class StubResultListLookandfeel
	def method_missing(*args)
		nil
	end
	def lookup(key, *args)
		key
	end
	def attributes(key)
		{}
	end
	def format_price(*args)
		'678.90'
	end
end
class StubResultListSession
	attr_accessor :event
	def state
		StubResultListState.new
	end
	def user
		RootUser.new
	end
	def lookandfeel
		StubResultListLookandfeel.new
	end
end
class StubResultListState
	def pages
		nil
	end
end
class RootUser
end

class TestResultList < Test::Unit::TestCase
	class StubSession
		attr_accessor :pages
		attr_accessor :dictionary
		def attributes(key)
			{}
		end
		def event_url(url, name)
		end
		def language()
		end
		def lookup(key, *args)
			(@dictionary ||= {})[key]
		end
		def lookandfeel
			self
		end
		def state()
			self
		end
		def user
			RootUser.new
		end
		def format_price(num)
			'678.90'
		end
	end
	class StubAtc
		attr_accessor :packages, :package_count
		def code
		end
		def description(key)
		end
		def has_ddd?
			false
		end
	end
	class StubPackage
		attr_accessor :pointer, :name_base, :generic_type
		attr_accessor :barcode, :price_exfactory, :price_public
		attr_accessor :active_agents, :company, :ikscat
		attr_accessor :fachinfo, :limitation_text
		def sl_entry
			self
		end
		def substances
			active_agents
		end
		def method_missing(*args)
		end
	end
	class StubCompany
		attr_accessor :fi_status
		def method_missing(*args)
		end
	end
	class StubFachinfo
		attr_accessor :pointer
	end
	class StubLimitationText
		attr_accessor :pointer
		include ODDB::SimpleLanguage
	end
	def setup
		@package = StubPackage.new
		@package.name_base = 'foo'
		@package.active_agents = []
		@model = StubAtc.new
		@model.packages = [@package]
		@session = StubSession.new
		@list = ODDB::ResultList.new([@model], @session)
	end
	def test_price_format
		assert_equal('678.90', @list.price_public(@package, nil).value)
	end
=begin
	def test_fachinfo
		# 2 Voraussetzungen:
		# - Fachinfo vorhanden?
		# - Company erlaubt display?
		fi = StubFachinfo.new
		@session.dictionary = { :fachinfo_short=> 'FI'}
		company = StubCompany.new
		@package.company = company
		assert_nil(@list.fachinfo(@package, @session))
		@package.fachinfo = fi
		assert_nil(@list.fachinfo(@package, @session))
		company.fi_status = true
		link = @list.fachinfo(@package, @session)
		assert_instance_of(HtmlGrid::PopupLink, link)
		assert_equal('FI', link.value)
		@package.fachinfo = nil
		assert_nil(@list.fachinfo(@package, @session))
	end
=end
	def test_limitation_text
		li = StubLimitationText.new
		@session.dictionary = { :limitation_text_short=> '!'}
		assert_nil(@list.limitation_text(@package, @session))
		@package.sl_entry.limitation_text = li
		link = @list.limitation_text(@package, @session)
		assert_instance_of(HtmlGrid::PopupLink, link)
		assert_equal('!', link.value)
		@package.sl_entry.limitation_text = nil
		assert_nil(@list.limitation_text(@package, @session))
	end
end
class TestRootResultList < Test::Unit::TestCase
	def setup
		@list = ODDB::RootResultList.new([StubResultListModel.new], StubResultListSession.new)
	end
	def test_hash_insert1
		foo = {
			[0,0]	=> 0,
			[1,0]	=> 1,
			[2,0]	=> 2,
		}
		expected = {
			[0,0]	=> 0,
			[1,0]	=> 1,
			[2,0]	=> "a",
			[3,0]	=> 2,
		}
		@list.hash_insert(foo, [2,0], "a")
		assert_equal(expected, foo)
	end
	def test_hash_insert2
		foo = {
			[0,0,0]	=> "0a",
			[0,0,1]	=> "0b",
			[0,0,2]	=> "0c",
			[1,0]	=> 1,
			[2,0]	=> 2,
		}
		expected = {
			[0,0]	=> "a",
			[1,0,0]	=> "0a",
			[1,0,1]	=> "0b",
			[1,0,2]	=> "0c",
			[2,0]	=> 1,
			[3,0]	=> 2,
		}
		@list.hash_insert(foo, [0,0], "a")
		assert_equal(expected, foo)
	end
end
