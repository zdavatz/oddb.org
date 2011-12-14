#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestFiPiOfferConfirm -- oddb.org -- 06.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/fipi_offer_confirm'

module ODDB
  module View
    module User

class TestFiPiCalculations < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :fi_activation_count => 1,
                          :pi_activation_count => 1,
                          :fi_charge           => 'fi_charge',
                          :fi_update           => 'fi_update',
                          :fi_update_charge    => 'fi_update_charge',
                          :pi_charge           => 'pi_charge',
                          :pi_update           => 'pi_update',
                          :pi_update_charge    => 'pi_update_charge',
                          :fi_calculate_activation_charge => 'fi_calculate_activation_charge',
                          :calculate_fi_charge => 'calculate_fi_charge',
                          :calculate_fi_update => 'calculate_fi_update',
                          :pi_calculate_activation_charge => 'pi_calculate_activation_charge',
                          :calculate_pi_charge => 'calculate_pi_charge',
                          :calculate_pi_update => 'calculate_pi_update',
                          :calculate_total_charges => 'calculate_total_charges',
                          :calculate_total     => 'calculate_total'
                         )
    @composite = ODDB::View::User::FiPiCalculations.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
end

class TestFiPiOfferConfirmComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :fi_activation_count => 1,
                          :pi_activation_count => 1,
                          :fi_charge           => 'fi_charge',
                          :fi_update           => 'fi_update',
                          :fi_update_charge    => 'fi_update_charge',
                          :pi_charge           => 'pi_charge',
                          :pi_update           => 'pi_update',
                          :pi_update_charge    => 'pi_update_charge',
                          :fi_calculate_activation_charge => 'fi_calculate_activation_charge',
                          :calculate_fi_charge => 'calculate_fi_charge',
                          :calculate_fi_update => 'calculate_fi_update',
                          :pi_calculate_activation_charge => 'pi_calculate_activation_charge',
                          :calculate_pi_charge => 'calculate_pi_charge',
                          :calculate_pi_update => 'calculate_pi_update',
                          :calculate_total_charges => 'calculate_total_charges',
                          :calculate_total     => 'calculate_total'
                         )
    @composite = ODDB::View::User::FiPiOfferConfirmComposite.new(@model, @session)
  end
  def test_amzv_link
    assert_kind_of(HtmlGrid::Link, @composite.amzv_link(@model, @session))
  end
end

    end # User
  end # View
end # ODDB
