#!/usr/bin/env ruby
# State::Admin::TestPatinfoStats -- oddb -- 25.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/patinfo_stats'


module ODDB
	module State
		module Admin
      class TestInvoiceItemFacade < Test::Unit::TestCase
        include FlexMock::TestCase
        def test_initialize
          invoice_item = flexmock('invoice_item') do |item|
            item.should_receive(:time).and_return('time')
          end
          facade = PatinfoStatsCommon::InvoiceItemFacade.new(invoice_item)
          assert_equal('time', facade.time)
        end
      end
      class TestSequenceFacade < Test::Unit::TestCase
        include FlexMock::TestCase
        def setup
          sequence = flexmock('sequence') do |seq|
            seq.should_receive(:iksnr).and_return('iksnr')
            seq.should_receive(:seqnr).and_return('seqnr')
            seq.should_receive(:pointer)
            seq.should_receive(:name_base).and_return('name')
          end
          @facade = PatinfoStatsCommon::SequenceFacade.new(sequence)
          @invoice_item = flexmock('invoice_item') do |item|
            item.should_receive(:time).and_return('time')
          end
          @facade.instance_eval('@invoice_items') << @invoice_item
        end
        def test_add_invoice_item
          assert_equal([@invoice_item, @invoice_item], @facade.add_invoice_item(@invoice_item))
        end
        def test_iksnr_seqnr
          assert_equal('iksnr seqnr: name', @facade.iksnr_seqnr)
        end
        def test_invoice_items
          assert_equal([@invoice_item], @facade.invoice_items)
        end
        def test_newest_date
          assert_equal('time', @facade.newest_date)
        end
      end
      class TestCompanyFacade < Test::Unit::TestCase
        include FlexMock::TestCase
        def setup
          @company = flexmock('company') do |comp|
            comp.should_receive(:name).and_return('name')
            comp.should_receive(:pointer).and_return('pointer')
            comp.should_receive(:user).and_return('user')
          end
          @facade = PatinfoStatsCommon::CompanyFacade.new(@company)
          @sequence = flexmock('sequence') do |seq|
            seq.should_receive(:iksnr).and_return('iksnr')
            seq.should_receive(:seqnr).and_return('seqnr')
            seq.should_receive(:pointer)
            seq.should_receive(:name_base).and_return('name')
            seq.should_receive(:newest_date).and_return('newest_date')
          end
          @facade.instance_eval('@slate_sequences')['key'] = @sequence
        end
        def test_add_sequence
          item_facade = flexmock('item_facade') do |fac|
            fac.should_receive(:sequence).and_return(@sequence)
          end
          assert_equal([item_facade], @facade.add_sequence(item_facade))
        end
        def test_slate_sequences
          assert_equal([@sequence], @facade.slate_sequences)
        end
        def test_slate_count
          assert_equal(1, @facade.slate_count)
        end
        def test_name
          assert_equal('name', @facade.name)
        end
        def test_newest_date
          assert_equal('newest_date', @facade.newest_date)
        end
        def test_pointer
          assert_equal('pointer', @facade.pointer)
        end
        def test_user
          assert_equal('user', @facade.user)
        end
      end
      def setup_patinfo_stats_common
          @company_facade = flexmock('company_facade') do |fac|
            fac.should_receive(:add_sequence)
            fac.should_receive(:name).and_return('name')
          end
          flexstub(PatinfoStatsCommon::CompanyFacade) do |klass|
            klass.should_receive(:new).and_return(@company_facade)
          end
          item_facade = flexmock('facade') do |fac|
            fac.should_receive(:sequence=)
            fac.should_receive(:email=)
          end
          flexstub(PatinfoStatsCommon::InvoiceItemFacade) do |klass|
            klass.should_receive(:new).and_return(item_facade)
          end
          item = flexmock('item') do |item|
            item.should_receive(:type).and_return(:annual_fee)
            item.should_receive(:item_pointer)
            item.should_receive(:yus_name).and_return('yus_name')
          end
          slate = flexmock('slate') do |sla|
            sla.should_receive(:items).and_return({'key' => item})
          end
          @company = flexmock('company') do |cmp|
            cmp.should_receive(:name).and_return('name')
          end
          sequence = flexmock('sequence') do |seq|
            seq.should_receive(:company).and_return(@company)
          end
          pointer = flexmock('pointer') do |ptr|
            ptr.should_receive(:resolve).and_return(@company_facade)
          end
          @session = flexmock('session') do |ses|
            ses.should_receive(:slate).and_return(slate)
            ses.should_receive(:"app.resolve").and_return(sequence)
            ses.should_receive(:"user.model.name").and_return('name')
            ses.should_receive(:user_input).and_return(pointer)
          end
      end
      class TestPatinfoStatsCommon < Test::Unit::TestCase
        include FlexMock::TestCase
        include ODDB::State::Admin
        def test_init
          setup_patinfo_stats_common
          @patinfo_stats = PatinfoStatsCommon.new(@session, 'model')
          assert_equal([@company_facade], @patinfo_stats.init)
          assert_equal([@company_facade], @patinfo_stats.model)
        end
      end
      class TestPatinfoStatsCompanyUser < Test::Unit::TestCase
        include FlexMock::TestCase
        include ODDB::State::Admin
        def test_init
          setup_patinfo_stats_common
          model = [@company]
          @patinfo_stats = PatinfoStatsCompanyUser.new(@session, model)
          assert_equal([@company_facade], @patinfo_stats.init)
        end
      end
      class TestPatinfoStats < Test::Unit::TestCase
        include FlexMock::TestCase
        include ODDB::State::Admin
        def test_symbol
          setup_patinfo_stats_common
          @patinfo_stats = PatinfoStats.new(@session, 'model')
          assert_equal(:name, @patinfo_stats.symbol)
        end
        def test_init
          setup_patinfo_stats_common
          @patinfo_stats = PatinfoStats.new(@session, 'model')
          assert_kind_of(Proc, @patinfo_stats.init)
        end
      end
    end
  end
end

