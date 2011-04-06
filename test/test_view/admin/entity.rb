#!/usr/bin/env ruby
# ODDB::View::Admin::TestEntity -- oddb.org -- 06.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/entity'
require 'htmlgrid/inputcheckbox'

module ODDB
  module View
    module Admin

class TestYusPrivileges < Test::Unit::TestCase
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

class TestYusGroups < Test::Unit::TestCase
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
                          )
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

=begin
class TestEntityForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :attributes => {},
                         :lookup     => 'lookup'
                        )
    group     = flexmock('group', :name => 'name')
    user      = flexmock('user', :groups => [group])
    yus_model = flexmock('yus_model', :"pointer.to_yus_privilege" => 'privilege')
    @app      = flexmock('app', :yus_model => yus_model)
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :error       => 'error',
                         :yus_get_preference => 'yus_get_preference',
                         :user        => user,
                         :event       => 'event',
                         :app         => @app
                        )
    @model    = flexmock('model', :name => 'name')
    @form     = ODDB::View::Admin::EntityForm.new(@model, @session)
  end
  def test_init
    assert_equal('', nil)
  end
end
=end

    end # Admin
  end # View
end # ODDB
