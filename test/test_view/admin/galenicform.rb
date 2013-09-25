#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestGalenicGroup -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::TestGalenicGroupSelect -- oddb.org -- 31.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
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
		end
	end
end

module ODDB
  module View
    module Admin

class TestGalenicGroupSelect <Minitest::Test
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

  include FlexMock::TestCase
	def setup
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:next_id).and_return(123)
    end
		session = StubSession.new
		model = StubModel.new
		model.galenic_group = session.galenic_groups[1]
		@select = ODDB::View::Admin::GalenicGroupSelect.new(:galenic_group, model, session) 
	end
	def test_to_html
		expected = '<SELECT name="galenic_group"><OPTION value=":!galenic_group,123.">Salben</OPTION></SELECT>'
		assert_equal(expected, @select.to_html(CGI.new))
	end
end	

class TestGalenicFormForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :languages  => ['language'],
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :error => 'error',
                        :lookandfeel => @lnf,
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model', :synonyms => ['synonym'])
    @form    = ODDB::View::Admin::GalenicFormForm.new(@model, @session)
  end
  def test_languages
    expected = ["language", "lt", "synonym_list"]
    assert_equal(expected, @form.languages)
  end
end

class TestGalenicFormComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :languages  => ['language'],
                        :attributes => {},
                        :base_url   => 'base_url',
                        :event_url  => 'event_url'
                       )
    state    = flexmock('state')
    @session = flexmock('session', 
                        :error => 'error',
                        :lookandfeel => @lnf,
                        :warning?    => nil,
                        :error?      => nil,
                        :event       => 'event',
                        :allowed?    => nil,
                        :state       => state,
                        :language    => 'language'
                       )
    galenic_form = flexmock('galenic_form', :language => 'language')
    substance    = flexmock('substance', :language => 'language')
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose => 'dose'
                           )
    composition  = flexmock('composition', 
                            :galenic_form  => galenic_form,
                            :active_agents => [active_agent]
                           )
    atc_class    = flexmock('atc_class', :code => 'code')
    sequence = flexmock('sequence', 
                        :pointer => 'pointer',
                        :seqnr   => 'seqnr',
                        :compositions => [composition],
                        :atc_class    => atc_class,
                        :has_patinfo? => nil
                       )
    @model   = flexmock('model', 
                        :synonyms  => ['synonym'],
                        :sequences => [sequence]
                       )
    @composite = ODDB::View::Admin::GalenicFormComposite.new(@model, @session)
  end
  def test_sequences
    assert_kind_of(ODDB::View::Admin::RegistrationSequences, @composite.sequences(@model, @session))
  end
end
    end # Admin
  end # View
end # ODDB
