#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestActiveAgent -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestActiveAgent -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
require 'test/unit'
require 'flexmock'
require 'htmlgrid/select'
require 'define_empty_class'
require 'state/admin/activeagent'


module ODDB
	module State
		module Admin

class TestActiveAgentState < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		attr_accessor :user_input
		def app
			@app ||= StubApp.new
		end
		def user_input(*keys)
			if(keys.size > 1)
				res = {}
				keys.each { |key|
					res.store(key, user_input(key))
				}
				res
			else
				key = keys.first
				(@user_input ||= {
					:pointer	=>	StubPointer.new
				})[key]
			end
		end
	end
	class StubPointer
	end
	class StubApp
		attr_accessor :sequence
		attr_reader	:update_called
		attr_writer :substances, :soundex_substances
		def initialize
			@update_called = false
		end
		def soundex_substances(name)
			@soundex_substances ||= []
		end
		def substance(substance_name)
			(@substances ||= {})[substance_name]	
		end
		def substances
			(@substances ||= {}).values
		end
		def update(pointer,values,unique_email)	
			@update_called = true
		end
	end
	class StubActiveAgent
		attr_accessor :active_agents
		attr_reader :sequence
		include Persistence
		def initialize
			@sequence = self
		end
		def active_agent(substance)
			(@active_agents ||= {})[substance]
		end
		def substance
		end
	end
	class StubSequence
		attr_accessor :substances
		def initialize
			@substances = []
		end
	end
	class StubSubstance
		attr_accessor :pointer
		def initialize(name, similar)
			@name = name
			@similar = similar
		end
	end

	def setup
		@session = StubSession.new
		@activeagent = StubActiveAgent.new
		@activeagent.pointer = Persistence::Pointer.new(:sequence, :active_agent)
		@sequence = StubSequence.new
		#@state = State::Drugs::ActiveAgent.new(@session, @activeagent)
		@state = State::Admin::ActiveAgent.new(@session, @activeagent)
		@session.app.sequence = @sequence
	end
	def test_update1
		@session.user_input = { :substance => '',  :dose => ''}
		newstate = @state.update
		assert_equal(true, @state.error?)
		assert_equal(@state, newstate)
		assert_equal(1, @state.errors.size)
		assert_equal(true, @state.errors.has_key?(:substance))
		assert_equal(false, @state.errors.has_key?(:dose))
		assert_equal(false, @session.app.update_called)
	end
	def test_update2
		@session.user_input = { 
			:substance => 'Acidum Mefenamicum',  
			:dose => '10 mg'
		}
    flexmock(@activeagent) do |age|
      age.should_receive(:parent).and_return(@sequence)
    end
    flexstub(@session) do |ses|
      ses.should_receive(:substance)
    end
		newstate = @state.update
		assert_equal(false, @state.error?)
		assert_equal(State::Admin::SelectSubstance, newstate.class)
		assert_equal(false, @session.app.update_called)
	end
	def test_update3
		substances = {'Acidum Mefenamicum' => 'Acidum Mefenamicum'}
		@session.app.substances = substances
		@activeagent.active_agents = substances
		@session.user_input = { 
			:substance => 'Acidum Mefenamicum',  
			:dose => '10 mg'
		}
    flexmock(@activeagent) do |age|
      age.should_receive(:parent).and_return(@sequence)
    end
    flexmock(@session) do |ses|
      ses.should_receive(:substance).and_return('Acidum Mefenamicum')
    end
		newstate = @state.update
		assert_equal(true, @state.error?)
		assert_equal(@state, newstate)
		assert_equal(1, @state.errors.size)
		assert_equal(true, @state.errors.has_key?(:substance))
		assert_equal(false, @session.app.update_called)
	end
	def test_update4
		subst1 = StubSubstance.new('Acidum Mefenamicum', false)
		subst1.pointer = 'substance_pointer_1'
		subst2 = StubSubstance.new('Acidum Acetylsalicylicum', false)
		subst2.pointer = 'substance_pointer_2'
		substances = {'Acidum Mefenamicum' => subst1}
		@activeagent.active_agents = substances.dup
		substances.store('Acidum Acetylsalicylicum', subst2)
		@session.app.substances = substances
		@session.user_input = { 
			:substance => 'Acidum Acetylsalicylicum',  
			:dose => '10 mg'
		}
    chemical = flexmock('chemical') do |chem|
      chem.should_receive(:pointer)
    end
    flexmock(@session) do |ses|
      ses.should_receive(:substance).and_return(chemical)
    end
    flexmock(@activeagent) do |age|
      age.should_receive(:substance).and_return('Acidum Mefenamicum')
    end
    flexmock(@state) do |sta|
      sta.should_receive(:unique_email).and_return('unique_email')
    end
		newstate = @state.update
		assert_equal(false, @state.error?)
		assert_equal(@state, newstate)
		assert_equal(true, @session.app.update_called)
	end		
	def test_substance_selection
		sub2 = StubSubstance.new("Acidum Mefenanicum", true)
		sub4 = StubSubstance.new("Acidum Mefenanikum", true)
		sub5 = StubSubstance.new("Acidum Mephenanikum", true)
		@sequence.substances = [sub4]
		@session.app.soundex_substances = [ sub2, sub4, sub5 ]
    flexmock(@activeagent) do |age|
      age.should_receive(:parent).and_return(@sequence)
    end
		assert_equal([sub2, sub5], @state.substance_selection)
	end
end

class TestActiveAgent  < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @session = flexmock('session', :app => @app)
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::ActiveAgent.new(@session, @model)
  end
  class StubDummy
    def initialize(session, sequence)
    end
  end
  def test_delete
    flexmock(@app, :delete => 'delete')
    parent  = flexmock('parent', :pointer => 'pointer')
    flexmock(@model, 
             :parent  => parent,
             :pointer => 'pointer'
            )
    flexmock(@state, :resolve_state => StubDummy)
    assert_kind_of(ODDB::State::Admin::TestActiveAgent::StubDummy, @state.delete)
  end
  def test_new_active_agent
    pointer  = flexmock('pointer')
    flexmock(pointer, :+ => pointer)
    sequence = flexmock('sequence', 
                        :pointer   => pointer,
                        :iksnr     => 'iksnr',
                        :name_base => 'name_base'
                       )
    flexmock(@model, :sequence => sequence)
    flexmock(@state, :resolve_state => StubDummy)
    assert_kind_of(ODDB::State::Admin::TestActiveAgent::StubDummy, @state.new_active_agent)
  end
  def test_new_active_agent__resolve_state_nil
    pointer  = flexmock('pointer')
    flexmock(pointer, :+ => pointer)
    sequence = flexmock('sequence', 
                        :pointer   => pointer,
                        :iksnr     => 'iksnr',
                        :name_base => 'name_base'
                       )
    flexmock(@model, :sequence => sequence)
    flexmock(@state, :resolve_state => nil)
    assert_equal(@state, @state.new_active_agent)
  end
  def test_new_active_agent__no_sequence
    flexmock(@model, 
             :sequence  => nil,
             :substance => 'substance'
            )
    assert_equal(@state, @state.new_active_agent)
  end
  def test_update__substance_nil
    flexmock(@session, 
             :user_input => {:name => 'name', :substance => 'substance'},
             :substance  => nil
            )
    flexmock(@app, :soundex_substances => [])
    sequence = flexmock('sequence', :substances => [])
    flexmock(@model, :parent => sequence)
    assert_kind_of(ODDB::State::Admin::SelectSubstance, @state.update)
  end
  def test_update__else
    substance = flexmock('substance', :pointer => 'pointer')
    flexmock(@session, 
             :user_input => {:name => 'name', :substance => 'substance'},
             :substance  => substance,
             :user       => 'user'
            )
    flexmock(@model, 
             :substance => substance,
             :pointer   => 'pointer'
            )
    flexmock(@app, :update => 'update')
    assert_equal(@state, @state.update)
  end
  def test_update__chemical_substance_empty
    substance = flexmock('substance', :pointer => 'pointer')
    flexmock(@session, 
             :user_input => {:name => 'name', :substance => 'substance', :chemical_substance => []},
             :user       => 'user'
            )
    flexmock(@session) do |s|
      s.should_receive(:substance).with('substance').and_return(substance)
      s.should_receive(:substance).with([]).and_return(nil)
    end
    flexmock(@model, 
             :substance => substance,
             :pointer   => 'pointer'
            )
    flexmock(@app, :update => 'update')
    assert_equal(@state, @state.update)
  end
  def test_update__e_unknown_substance
    substance = flexmock('substance', :pointer => 'pointer')
    flexmock(@session, 
             :user_input => {:name => 'name', :substance => 'substance', :chemical_substance => 'chemical_substance'},
             :user       => 'user'
            )
    flexmock(@session) do |s|
      s.should_receive(:substance).with('substance').and_return(substance)
      s.should_receive(:substance).with('chemical_substance').and_return(nil)
    end
    flexmock(@model, 
             :substance => substance,
             :pointer   => 'pointer'
            )
    flexmock(@app, :update => 'update')
    assert_equal(@state, @state.update)
  end
  def test_update__model_persistence_createitem
    substance = flexmock('substance', :pointer => 'pointer')
    flexmock(@session, 
             :user_input => {:name => 'name', :substance => 'substance'},
             :substance  => substance,
             :user       => 'user'
            )
    flexmock(@model, 
             :substance => substance,
             :pointer   => 'pointer',
             :is_a?     => true,
             :carry     => 'carry',
             :append    => 'append'
            )
    flexmock(@app, :update => 'update')
    assert_equal(@state, @state.update)

  end
=begin
  def test_update__else
    substance = flexmock('substance')
    flexmock(@session, 
             :user_input => {:name => 'name', :substance => 'substance'},
             :substance  => {'substance' => substance}
            )
    flexmock(@model, 
             :substance => substance,
             :"sequence.active_agent" => nil
            )
    assert_equal('', @state.update)
  end
=end
end

class TestCompanyActiveAgent < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @session = flexmock('session', 
                        :allowed? => nil,
                        :app      => @app
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::CompanyActiveAgent.new(@session, @model)
  end
  def test_init
    assert_equal(ODDB::View::Admin::ActiveAgent, @state.init)
  end
  def test_delete
    flexmock(@session, :allowed? => true)
    pointer = flexmock('pointer', :skeleton => 'skeleton')
    parent = flexmock('parent', :pointer => pointer)
    flexmock(@model, :parent => parent)
    assert_equal(nil, @state.delete)
  end
  def test_update
    flexmock(@session, 
             :allowed?   => true,
             :user_input => {:name => 'name', :substance => 'substance'},
             :substance  => nil
            )
    flexmock(@app, :soundex_substances => [])
    sequence = flexmock('sequence', :substances => [])
    flexmock(@model, :parent => sequence)
    skip("Don't know how to check here")
    assert_kind_of(ODDB::State::Admin::SelectSubstance, @state.update)
  end
end

		end	
	end
end
