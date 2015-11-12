#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestEntity -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/entity'

module ODDB
  module State
    module Admin

class TestEntity <Minitest::Test
  include FlexMock::TestCase
  def setup
    @yus_user = flexmock('yus_user', :yus_name => 'yus_name')
    yus_model = flexmock('yus_model', 
                         :users       => [@yus_user],
                         :odba_store  => 'odba_store',
                         :remove_user => 'remove_user',
                         :"pointer.to_yus_privilege"     => 'pointer'
                        )
    @app      = flexmock('app', :yus_model => yus_model)
    @lnf      = flexmock('lookandfeel', :lookup => 'lookup')
    @user     = flexmock('user', 
                         :rename       => 'rename',
                         :revoke       => 'revoke',
                         :disaffiliate => 'disaffiliate',
                         :set_password => 'set_password',
                         :set_entity_preference => 'set_entity_preference'
                        )
    @session  = flexmock('session', 
                         :app          => @app,
                         :user         => @user,
                         :lookandfeel  => @lnf,
                         :allowed?     => nil,
                         :valid_values => ['action', 'key']
                        )
    @group    = flexmock('group', :name => 'name')
    @model    = flexmock('model', 
                         :name => 'name',
                         :affiliations => [@group]
                        )
    flexmock(@user, :find_entity => @model)
    @entity   = ODDB::State::Admin::Entity.new(@session, @model)
  end
  def test_update
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@entity, @entity.update)
  end
  def test_update__yus_name
    flexmock(@model, :name => 'yus_name')
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@entity, @entity.update)
  end
  def test_update__pass1
    flexmock(@session, :user_input => {:set_pass_1 => 'set_pass', :set_pass_2 => 'set_pass', :name => 'name'})
    assert_equal(@entity, @entity.update)
  end
  def test_update__model_create_item
    flexmock(@user, :create_entity => @model)
    flexmock(@model, 
             :is_a? => true,
             :carry => 'carry'
            )
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@entity, @entity.update)
  end
  def test_update__from_yus_privilege
    flexmock(@session, 
             :user_input => {:yus_association => 'yus_association', :name => 'name'},
             :grant      => 'grant'
            )
    flexmock(@user, :grant => 'grant')
    ass     = flexmock('ass', :add_user => 'add_user')
    ass_ptr = flexmock('ass_ptr', :resolve => ass)
    flexmock(Persistence::Pointer, :from_yus_privilege => ass_ptr)
    assert_equal(@entity, @entity.update)
  end
  def test_update__session_allowed
    flexmock(@session, 
             :user_input => 'user_input',
             :allowed?   => true
            )
    assert_equal(@entity, @entity.update)
  end
  def test_update__power_user
    flexmock(@group, :name => 'PowerUser')
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@entity, @entity.update)
  end
  def test_update__groups
    flexmock(@session, :user_input => {:yus_groups => {'PowerUser' => 'value'}, :valid_until => Date.new(2011,2,3), :name => 'name'})
    flexmock(@user, 
             :affiliate => 'affiliate',
             :grant     => 'grant'
            )
    assert_equal(@entity, @entity.update)
  end
  def test_update__error
    flexmock(@session, :user_input   => {:set_pass_1 => 'set_pass_1', :set_pass_2 => 'set_pass_2'})
    assert_equal(@entity, @entity.update)
  end
  def stdout_null
    require 'tempfile'
    $stdout = Tempfile.open('stdout')
    yield
    $stdout.close
    $stdout = STDERR
  end
  def test_update__exception
    flexmock(@session, :user_input => 'user_input')
    flexmock(YusStub) do |m|
      m.should_receive(:new).and_raise(::Exception)
    end
    stdout_null do 
      assert_equal(@entity, @entity.update)
    end
  end
  def test_uopdate__yus_error
    flexmock(@yus_user) do |y|
      y.should_receive(:yus_name).and_raise(Yus::YusError)
    end
    flexmock(@session, :user_input => 'user_input')
    stdout_null do 
      assert_equal(@entity, @entity.set_pass)
    end
  end
  def test_update__yus_duplicate_name_error
    flexmock(@yus_user) do |y|
      y.should_receive(:yus_name).and_raise(Yus::DuplicateNameError)
    end
    flexmock(@session, :user_input => 'user_input')
    stdout_null do 
      assert_equal(@entity, @entity.set_pass)
    end
  end
  def test_set_pass
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@entity, @entity.update)
  end
end

    end # Admin
  end # State
end # ODDB
