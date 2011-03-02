#!/usr/bin/env ruby
# View::Admin::GalenicGroup -- oddb -- 01.03.2011 -- mhatakeyama@ywesee.com
# View::Drugs::GalenicGroupSelect -- oddb -- 31.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/galenicform'
require 'stub/cgi'
require 'util/persistence'

module ODDB
	class GalenicGroup
		def GalenicGroup.reset_oid
			@oid = 0
		end
	end
	module View
		module Admin

class TestGalenicGroupSelect < Test::Unit::TestCase
	class StubGalenicGroup
		include Persistence
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
				group.pointer = Persistence::Pointer.new([:galenic_group, group.oid])
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

  include FlexMock::TestCase
	def setup
		GalenicGroup.reset_oid
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:next_id).and_return(123)
    end
		session = StubSession.new
		model = StubModel.new
		model.galenic_group = session.galenic_groups[1]
		@select = View::Admin::GalenicGroupSelect.new(:galenic_group, model, session) 
	end
	def test_to_html
		expected = '<SELECT name="galenic_group"><OPTION value=":!galenic_group,123.">Salben</OPTION></SELECT>'
		assert_equal(expected, @select.to_html(CGI.new))
	end
end	
		end
	end
end
