#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestEntity -- oddb.org -- 06.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/entity'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/pass'

class TestYusPrivileges <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {}
                       )
    @session = flexmock('session', 
                        :valid_values => ['action|key'],
                        :allowed?     => nil,
                        :lookandfeel  => @lnf
                       )
    @model   = flexmock('model')
    @list    = ODDB::View::Admin::YusPrivileges.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
  def test_checkbox
    flexmock(@model, 
             :privileged? => nil,
             :allowed?    => nil
            )
    result = @list.checkbox('model1|model2')
    assert_equal(2, result.length)
    assert_kind_of(HtmlGrid::InputCheckbox, result[0])
    assert_equal('model1 model2', result[1])
  end
  def test_checkbox__privileged
    flexmock(@model, :privileged? => true)
    result = @list.checkbox('model1|model2')
    assert_equal(2, result.length)
    assert_kind_of(HtmlGrid::InputCheckbox, result[0])
    assert_equal('model1 model2', result[1])
  end
  def test_checkbox__allowed
    flexmock(@model, 
             :privileged? => nil,
             :allowed?    => true
            )
    result = @list.checkbox('model1|model2')
    assert_equal(2, result.length)
    assert_kind_of(HtmlGrid::InputCheckbox, result[0])
    assert_equal('model1 model2', result[1])
  end
  def test_row_css
    flexmock(@model, 
             :privileged? => false,
             :allowed?    => true
            )
    assert_equal('disabled', @list.row_css('model1|model2'))
  end
end

class TestYusGroups <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    user       = flexmock('user', :groups => [])
    @session   = flexmock('session', 
                          :user          => user,
                          :event         => 'event',
                          :lookandfeel   => @lnf
                         )
    @model     = flexmock('model', 
                           :name         => 'name',
                           :affiliations => []
                          ).by_default
    @container = flexmock('container', :model => @model)
    @list      = ODDB::View::Admin::YusGroups.new(@model, @session, @container)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
  def test_checkbox
    affiliation = flexmock('affiliation', :name => 'name')
    flexmock(@model, :affiliations => [affiliation])
    result = @list.checkbox(@model)
    assert_equal(2, result.length)
    assert_kind_of(HtmlGrid::InputCheckbox, result[0])
    assert_equal('name', result[1])
  end
  def test_privileged_until
    flexmock(@model, :name => 'PowerUser')
    assert_kind_of(HtmlGrid::Input, @list.privileged_until(@model))
  end
end

class TestEntityForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :attributes => {},
                         :lookup     => 'lookup',
                         :base_url   => 'base_url'
                        )
    group     = flexmock('group', :name => 'name')
    user      = flexmock('user', :groups => [group])
    yus_model = flexmock('yus_model', :"pointer.to_yus_privilege" => 'privilege')
    @app      = flexmock('app', :yus_model => yus_model)
    @session  = flexmock('session', 
                         :lookandfeel  => @lnf,
                         :error        => 'error',
                         :yus_get_preference => 'yus_get_preference',
                         :user         => user,
                         :event        => 'event',
                         :app          => @app,
                         :allowed?     => nil,
                         :valid_values => ['value'],
                         :warning?     => nil,
                         :error?       => nil
                        ).by_default
    @model    = flexmock('model', :name => 'name')
    @form     = ODDB::View::Admin::EntityForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
  def test_association
    flexmock(@model, :association => 'association')
    assert_kind_of(HtmlGrid::InputText, @form.association(@model))
  end
  def test_set_pass?
    flexmock(@model, :is_a? => true)
    assert_equal(true, @form.set_pass?)
  end
  def test_pass
    flexmock(@model, :is_a? => true)
    flexmock(@session, :allowed? => true)
    assert_kind_of(HtmlGrid::Pass, @form.pass(@model, 'key'))
  end
  def test_set_pass
    flexmock(@model, :is_a? => false)
    flexmock(@session, :allowed? => true)
    assert_kind_of(HtmlGrid::Button, @form.set_pass(@model))
  end
end
