#!/usr/bin/env ruby
# GalenicGroupSelect -- oddb -- 31.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/galenicform'
require 'stub/cgi'
require 'util/persistence'

module ODDB
	class GalenicGroup
		def GalenicGroup.reset_oid
			@oid = 0
		end
	end
end

class TestGalenicGroupSelect < Test::Unit::TestCase
	class StubGalenicGroup
		include ODDB::Persistence
		def initialize(description)
			super()
			@description = description
		end
		def description(language)
			@description
		end
	end
	class StubLookandfeel
		def languages
			%w{de fr}
		end
		def lookup(key)
			{
				'de'		=>	'Deutsch',
			'fr'		=>	'Franz&ouml;sisch',
			:update	=>	'Speichern',	
		}[key]
	end
	def attributes(key)
		{}
	end
	def method_missing(*args)
		''
	end
end
	class StubSession
		attr_reader :galenic_groups
		def initialize()
			@galenic_groups = [
			StubGalenicGroup.new("Tabletten"),	
			StubGalenicGroup.new("Salben"),	
			].inject({}) { |inj,group| 
				group.pointer = ODDB::Persistence::Pointer.new([:galenic_group, group.oid])
				inj.store(group.oid, group)
				inj
			}
		end
		def app	
			self
		end
		def lookandfeel
			StubLookandfeel.new
		end
	end
	class StubModel
		attr_accessor :galenic_group
	end

	def setup
		ODDB::GalenicGroup.reset_oid
		session = StubSession.new
		model = StubModel.new
		model.galenic_group = session.galenic_groups[1]
		@select = ODDB::GalenicGroupSelect.new(:galenic_group, model, session) 
	end
	def test_to_html
		expected = '<SELECT name="galenic_group"><OPTION value=":!galenic_group,2.">Salben</OPTION><OPTION selected value=":!galenic_group,1.">Tabletten</OPTION></SELECT>'
		assert_equal(expected, @select.to_html(CGI.new))
	end
end	
