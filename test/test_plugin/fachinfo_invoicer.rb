#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestFachinfoInvoicer -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# ODDB::TestFachinfoInvoicer -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/fachinfo_invoicer'
require 'model/registration'

module ODDB
  class TestFachinfoInvoicer  <Minitest::Test
    include FlexMock::TestCase
    def setup
      @app    = flexmock('app')
      @plugin = ODDB::FachinfoInvoicer.new(@app)
    end
    def test_activation_fee
      assert_equal(1500, @plugin.activation_fee)
    end
    def test_active_infos
      flexmock(@app, :active_fachinfos => 'active_fachinfos')
      assert_equal('active_fachinfos', @plugin.active_infos)
    end
    def test_parent_item_class
      assert_equal(ODDB::Registration, @plugin.parent_item_class)
    end
    def test_unique_name
      item = flexmock('item', :item_pointer => 'item_pointer')
      assert_equal('item_pointer', @plugin.unique_name(item))
    end
    def test_report
      registration = flexmock('registration', :iksnr => 'iksnr')
      fachinfo  = flexmock('fachinfo', 
                           :name_base => 'name_base',
                           :pointer   => 'pointer',
                           :registrations => [registration]
                          )
      companies = {'company_name' => [fachinfo]}
      @plugin.instance_eval('@companies = companies')
      expected = "company_name\nname_base:\n  http://ch.oddb.org/de/gcc/fachinfo/reg/iksnr\n\n"
      assert_equal(expected, @plugin.report)
    end
    def test_report_edited_fachinfos
      item     = flexmock('item', :time => Time.local(2011,2,3))
      fachinfo = flexmock('fachinfo', 
                          :change_log   => [item],
                          :company_name => 'company_name'
                         )
      flexmock(@app, :fachinfos => {'key' => fachinfo}) 
      assert_equal([fachinfo], @plugin.report_edited_fachinfos(Date.new(2011,2,3)))
    end
    def test_run
      item     = flexmock('item', 
                          :time => Time.local(2011,2,3),
                          :type => :processing,
                          :expired? => false,
                          :item_pointer => 'item_pointer'
                         )
      fachinfo = flexmock('fachinfo', 
                          :change_log   => [item],
                          :company_name => 'company_name'
                         )
      slate    = flexmock('slate', :items => {'key' => item})
      invoice  = flexmock('invoice', :items => {'key' => item})
      flexmock(@app, 
               :slate    => slate,
               :invoices => {'key' => invoice},
               :fachinfos        => {'key' => fachinfo},
               :active_fachinfos => {'key' => fachinfo}
              )

      assert_equal({}, @plugin.run(Date.new(2011,2,4)))
    end
  end
end # ODDB
