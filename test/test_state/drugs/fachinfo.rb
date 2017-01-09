#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'sbsm/state'
module ODDB
  module State
    class Global < SBSM::State; end
    module Drugs
      class Global < State::Global; end
      class Fachinfo < State::Drugs::Global; end
      class RootFachinfo < Fachinfo; end
    end
    module Drugs
      class FachinfoChangelogs < State::Drugs::Global
        attr_reader :default_view
      end
    end
  end
end


require 'minitest/autorun'
require 'flexmock/minitest'
require 'state/drugs/fachinfo'

module ODDB
	module State
		module Drugs

class TestFachinfoChangelogs <Minitest::Test
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state = ODDB::State::Drugs::FachinfoChangelogs.new(@session, @model)
  end
  def teardown
    super
  end
  def test_init
    flexmock(@state, :allowed? => true)
    assert_equal(nil, @state.init)
    assert_equal(nil, @state.default_view)
  end
end

class TestFachinfo <Minitest::Test
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    @model   = flexmock('model', :localized_name => 'localized_name')
    @state   = ODDB::State::Drugs::Fachinfo.new(@session, @model)
  end
  def test_init
    assert_equal('lookup', @state.init)
  end
  def test_allowed
    flexmock(@session, :allowed? => true)
    flexmock(@model, :registrations => ['registration'])
    @state.init
    assert(@state.allowed?)
  end
end

class TestFachinfoPrint <Minitest::Test
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')

    @state = ODDB::State::Drugs::FachinfoPrint.new(@session, @model)
  end
  def test_init
    flexmock(@state, :allowed? => true)
    assert_equal(nil, @state.init)
  end
end

class TestRootFachinfo <Minitest::Test
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @user    = flexmock('user', :allowed? => true)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => {:html_chapter => 'html_chapter', :chapter => 'chapter'},
                        :user        => @user,
                        :language    => 'language',
                        :app         => @app
                       )
    pointer  = flexmock('pointer')
    flexmock(pointer, :+ => pointer)
    registration = flexmock('registration', :pointer => pointer)
    @model   = flexmock('model', 
                        :pointer        => pointer,
                        :localized_name => 'localized_name',
                        :language       => 'language',
                        :registrations  => [registration],
                       )
    flexmock(@app, :update => @model)

    @state = ODDB::State::Drugs::RootFachinfo.new(@session, @model)
  end
  def test_update
    @state.init
    description = flexmock('description', :chapter => 'chapter')
    flexmock(@model, 
             :is_a? => true,
             :descriptions => {'language' => description}
            )
    flexmock(@state, :unique_email => 'unique_email')
    assert_equal(@state, @state.update)
  end
  def test_update__fetch_block
    @state.init
    doc = flexmock('doc', 
                   :name=    => 'name',
                   :chapter  => nil,
                   :chapter= => nil
                  )
    language = flexmock('language', :"class.new" => doc)
    chapter  = flexmock('chapter', :fetch => 'fetch', :chapter => 'chapter')
    descriptions = flexmock('descriptions', :name= => nil, :chapter => 'chapter', :fetch => chapter)
    flexmock(@model, 
             :is_a?        => true,
             :descriptions => descriptions,
             :language     => 'language',
             :name_base    => 'name_base'
            )
    flexmock(@state, :unique_email => 'unique_email')
    assert_equal(@state, @state.update)
  end
end

class TestCompanyFachinfo <Minitest::Test
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @user    = flexmock('user', :allowed? => true)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => {:html_chapter => 'html_chapter', :chapter => 'chapter'},
                        :user        => @user,
                        :language    => 'language',
                        :allowed?    => nil,
                        :app         => @app
                       )
    description = flexmock('description', :chapter => 'chapter')
    pointer  = flexmock('pointer')
    flexmock(pointer, :+ => pointer)
    registration = flexmock('registration', :pointer => pointer)
    @model   = flexmock('model', 
                        :descriptions   => {'language' => description},
                        :pointer        => pointer,
                        :localized_name => 'localized_name',
                        :registrations  => [registration],
                        :language       => 'language',
                       )
    flexmock(@app, :update => @model)
    @state = ODDB::State::Drugs::CompanyFachinfo.new(@session, @model)
  end
  def test_init
    assert_equal(ODDB::View::Drugs::Fachinfo, @state.init)
  end
  def test_update
    @state.init
    flexmock(@state, :unique_email => 'unique_email')
    flexmock(@state, :allowed? => true)
    assert_equal(@state, @state.update)
  end
end

		end # Drugs
	end # State
end # ODDB
