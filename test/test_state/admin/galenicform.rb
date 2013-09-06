#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestGalenicFormState -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestGalenicFormState -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/galenicform'
require 'util/language'

module ODDB
	module State
		module Admin

class TestGalenicForm2 < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf
                       )
    @parent = flexmock('parent', :pointer => 'pointer')
    @model   = flexmock("model_#{__LINE__}", :empty? => nil, :parent => @parent)
    @form    = ODDB::State::Admin::GalenicForm.new(@session, @model)
  end
  def test_delete
    assert_kind_of(ODDB::State::Admin::MergeGalenicForm, @form.delete)
  end
  def test_delete__model_empty
    flexmock(@app, :delete => 'delete')
    parent = flexmock('parent')
    flexmock(@model, 
             :empty?  => true,
             :parent  => parent,
             :pointer => 'pointer'
            )
    assert_kind_of(ODDB::State::Admin::MergeGalenicForm, @form.delete)
  end
  def test_update
    galenic_form = flexmock('galenic_form')
    flexmock(@app, :galenic_form => galenic_form)
    flexmock(@lnf, :languages => ['language'])
    flexmock(@session, :user_input => 'user_input')
    assert_kind_of(ODDB::State::Admin::GalenicForm, @form.update)
  end

end

class	TestGalenicForm < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		attr_accessor :user_input
		def app
			@app ||= StubApp.new
		end
		def lookandfeel
			StubLookandfeel.new
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
	class StubApp
    include FlexMock::TestCase
    attr_accessor :galenic_forms
    attr_accessor :model
		attr_reader :update_called
		def initialize
			@update_called = false
		end
		def galenic_form(name)
			@galenic_forms[name]
		end
		def update(pointer,values, unique_email=nil)	
			@update_called = true
		end
	end
	class StubPointer; end
	class StubGalenicForm
    def initialize
      @odba_id = 123
    end
		include Language
	end
	class StubLookandfeel
		def languages
			['de', 'fr']
		end
	end

	def setup
		@session = StubSession.new
		@galform = StubGalenicForm.new
    @parent = flexmock('parent', :pointer => 'pointer')
    @galform   = flexmock("model_#{__LINE__}",
                          :empty? => nil,
                          :parent => @parent,
                          :pointer => 'pointer',
                          )
    # @galform.update_values({'de'=>'Tabletten', 'fr'=>'comprim?s'})
		@state = State::Admin::GalenicForm.new(@session, @galform)

	end
	def test_update1
		@session.app.galenic_forms = { 
			'Tabletten'	=>	@galform, 
			'comprim?s'	=>	@galform,
		}
		@session.user_input = { :de => 'Tabletten',  :fr => 'comprim?s'}
    flexstub(@state) do |sta|
      sta.should_receive(:unique_email).once
    end
		@state.update
		assert_equal(false, @state.error?)
	end
	def test_update2
		@session.app.galenic_forms = { 
			'Tabletten'	=>	@galform, 
			'comprim?s'	=>	@galform,
		}
		@session.user_input = { :de => 'Filmtabletten', :fr => 'filmcomprim?s'}
    flexstub(@state) do |sta|
      sta.should_receive(:unique_email)
    end
		@state.update
		assert_equal(false, @state.error?)
	end
	def test_update3
		galform = StubGalenicForm.new
		galform.update_values({'de'=>'Tabletten', 'fr'=>'comprim?s'})
		@session.app.galenic_forms = { 
			'Tabletten'	=>	galform, 
			'comprim?s'	=>	galform,
		}
		@session.user_input = { :de => 'Filmtabletten', :fr => 'filmcomprim?s'}
    flexstub(@state) do |sta|
      sta.should_receive(:unique_email)
    end
		@state.update
		assert_equal(false, @state.error?)
	end
	def test_update4
		galform = StubGalenicForm.new
		galform.update_values({'de'=>'Tabletten', 'fr'=>'comprim?s'})
		@session.app.galenic_forms = { 
			'Tabletten'	=>	galform, 
			'comprim?s'	=>	galform,
		}
		@session.user_input = { :de =>'Tabletten', :fr => 'comprim?s'}
		@state.update
		assert_equal(true, @state.error?)
	end
end
		end
	end
end
