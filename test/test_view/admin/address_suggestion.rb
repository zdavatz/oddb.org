#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestAddressSuggestion -- oddb.org -- 18.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'view/privatetemplate'
require 'view/admin/address_suggestion'
require 'htmlgrid/textarea'

class TestAddressSuggestionForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model', :fon => ['fon'], :fax => ['fax'])
    @form    = ODDB::View::Admin::AddressSuggestionForm.new(@model, @session)
  end
  def test_init
    assert_nil(@form.init)
  end
end

class TestAddressSuggestionInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def test_message
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error'
                         )
    @model     = flexmock('model', :message => 'message')
    @composite = ODDB::View::Admin::AddressSuggestionInnerComposite.new(@model, @session)
    assert_equal('message', @composite.message(@model))
  end
end

class TestActiveAddress <Minitest::Test
  include FlexMock::TestCase
  def test_parent_class
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    parent     = flexmock('parent', :resolve => 'resolve')
    pointer    = flexmock('pointer', :parent => parent)
    @model     = flexmock('model', 
                          :fon     => ['fon'],
                          :fax     => ['fax'],
                          :plz     => 'plz',
                          :city    => 'city',
                          :street  => 'street',
                          :number  => 'number',
                          :lines   => ['line'],
                          :pointer => pointer,
                          :type    => 'type'
                         )

    @composite = ODDB::View::Admin::ActiveAddress.new(@model, @session)
    assert_equal('lookup', @composite.parent_class(@model))
  end
end

class TestAddressSuggestionComposite <Minitest::Test
  include FlexMock::TestCase
  def test_address
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    parent     = flexmock('parent', :resolve => 'resolve')
    pointer    = flexmock('pointer', :parent => parent)

    active_address = flexmock('active_address', 
                              :fon     => ['fon'],
                              :fax     => ['fax'],
                              :plz     => 'plz',
                              :city    => 'city',
                              :street  => 'street',
                              :number  => 'number', 
                              :lines   => ['line'],
                              :pointer => pointer,
                              :type    => 'type'
                             )
    state      = flexmock('state', :active_address => active_address)
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil,
                          :state       => state
                         )
    @model     = flexmock('model', :message => 'message', :fon => ['fon'], :fax => ['fax'])
    @composite = ODDB::View::Admin::AddressSuggestionComposite.new(@model, @session)
    assert_kind_of(ODDB::View::Admin::ActiveAddress, @composite.address(@model))
  end

end

