#!/usr/bint_most_precise_doseenv ruby
# encoding: utf-8
# ODDB::View::Drugs::TestResultLimit -- oddb.org -- 14.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/errormessage'
require 'view/drugs/resultlimit'
require 'htmlgrid/inputradio'
require 'model/registration'


module ODDB
  module View
    module Drugs

class TestResultLimitList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :enabled?   => nil,
                        :resource   => 'resource',
                        :resource_global => 'resource_global'
                       )
    @state   = flexmock('state', :package_count => 0)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :allowed?    => nil,
                        :language    => 'language',
                        :state       => @state,
                        :error       => 'error'
                       )
    minifi   = flexmock('minifi', :pointer => 'pointer')
    commercial_form = flexmock('commercial_form', :language => 'language')
    part     = flexmock('part', 
                        :multi   => 'multi',
                        :count   => 'count',
                        :measure => 'measure',
                        :commercial_form => commercial_form
                       )
    registration = flexmock('registration', :iksnr => 'iksnr')
    @model   = flexmock('model', 
                        :minifi => minifi,
                        :fachinfo_active? => nil,
                        :has_fachinfo?    => nil,
                        :has_patinfo?     => nil,
                        :narcotic?        => nil,
                        :vaccine          => 'vaccine',
                        :name_base        => 'name_base',
                        :commercial_forms => ['commercial_form'],
                        :parts            => [part],
                        :price_exfactory  => 'price_exfactory',
                        :price_public     => 'price_public',
                        :ikscat           => 'ikscat',
                        :sl_entry         => 'sl_entry',
                        :lppv             => 'lppv',
                        :sl_generic_type  => 'sl_generic_type',
                        :pointer          => 'pointer',
                        :localized_name   => 'localized_name',
                        :registration     => registration,
                        :iksnr            => 'iksnr',
                        :seqnr            => 'seqnr',
                        :ikscd            => 'ikscd'

                       )
    @list    = ODDB::View::Drugs::ResultLimitList.new([@model], @session)
  end
  def test_compose_empty_list
    offset = [0, 0]
    assert_equal([0, 1], @list.compose_empty_list(offset))
  end
  FlexMock::QUERY_LIMIT = 5
  def test_compose_empty_list__package_count
    flexmock(@state, :package_count => 1)
    offset = [0, 0]
    assert_nil(@list.compose_empty_list(offset))
  end
  def test_most_precise_dose
    flexmock(@model, 
             :pretty_dose   => nil,
             :active_agents => ['active_agent'],
             :dose          => 'dose'
            )
    assert_equal('dose', @list.most_precise_dose(@model, @session))
  end
end

class TestResultLimitComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url',
                        :enabled?   => nil,
                        :resource   => 'resource',
                        :resource_global => 'resource_global',
                        :format_price    => 'format_price'
                       )
    state    = flexmock('state', 
                        :price         => 'price',
                        :package_count => 1
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :zone        => 'zone',
                        :event       => 'event',
                        :allowed?    => nil,
                        :language    => 'language',
                        :remote_ip   => 'remote_ip',
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil,
                        :cookie_set_or_get => 'cookie_set_or_get',
                        :persistent_user_input => 'persistent_user_input'
                       )
    minifi   = flexmock('minifi', :pointer => 'pointer')
    commercial_form = flexmock('commercial_form', :language => 'language')
    part     = flexmock('part', 
                        :multi   => 'multi',
                        :count   => 'count',
                        :measure => 'measure',
                        :commercial_form => commercial_form
                       )
    registration = flexmock('registration', :iksnr => 'iksnr')
    @model   = flexmock('model', 
                        :minifi           => minifi,
                        :fachinfo_active? => nil,
                        :has_fachinfo?    => nil,
                        :has_patinfo?     => nil,
                        :narcotic?        => nil,
                        :vaccine          => 'vaccine',
                        :name_base        => 'name_base',
                        :commercial_forms => ['commercial_form'],
                        :parts            => [part],
                        :price_exfactory  => 'price_exfactory',
                        :price_public     => 'price_public',
                        :ikscat           => 'ikscat',
                        :sl_entry         => 'sl_entry',
                        :lppv             => 'lppv',
                        :sl_generic_type  => 'sl_generic_type',
                        :pointer          => 'pointer',
                        :localized_name   => 'localized_name',
                        :registration     => registration,
                        :iksnr            => 'iksnr',
                        :seqnr            => 'seqnr',
                        :ikscd            => 'ikscd'
                       )
    @composite = ODDB::View::Drugs::ResultLimitComposite.new([@model], @session)
  end
  def test_export_csv
    assert_kind_of(ODDB::View::Drugs::DivExportCSV, @composite.export_csv(@model))
  end
end

    end # Drugs
  end # View
end # ODDB
