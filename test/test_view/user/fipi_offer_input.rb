#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestFiPiOfferInput -- oddb.org -- 06.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/fipi_offer_input'

module ODDB
  module View
    module User

class TestFiPiRadioButtons < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {}
                       )
    @session = flexmock('session', 
                        :event       => 'event',
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model', 
                        :name     => 'name',
                        :value    => 'value',
                        :checked? => nil
                       )
    @list    = ODDB::View::User::FiPiRadioButtons.new([@model], @session)
  end
  def test_radio_text__fi
    flexmock(@model, :name => 'fi')
    assert_equal('lookup', @list.radio_text(@model, @session))
  end
  def test_radio_text__pi
    flexmock(@model, 
             :name  => 'pi',
             :value => 'update_ywesee' 
            )
    assert_equal('lookup', @list.radio_text(@model, @session))
  end
end

class TestRadioButton < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_checked
    @button = ODDB::View::User::FiPiOfferInputForm::RadioButton.new('name', 'value', 'current')
    assert_equal(false, @button.checked?)
    @button = ODDB::View::User::FiPiOfferInputForm::RadioButton.new('name', 'value', 'value')
    assert_equal(true, @button.checked?)
  end
end

class TestFiPiOfferInputForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::User::FiPiOfferInputForm.new(@model, @session)
  end
  def test_fi_quantity_txt
    assert_kind_of(HtmlGrid::RichText, @form.fi_quantity_txt(@model, @session))
  end
end

class TestFiPiOfferInputComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :event       => 'event'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::User::FiPiOfferInputComposite.new(@model, @session)
  end
  def test_amzv_link
    assert_kind_of(HtmlGrid::Link, @composite.amzv_link(@modle, @session))
  end
end

    end # User
  end # View
end # ODDB
