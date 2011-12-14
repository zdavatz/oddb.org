#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestRecentRegs -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/drugs/global'
module ODDB
  module State
    module Drugs
      class RecentRegs < ODDB::State::Drugs::Global
      end
    end
  end
end
require 'test/unit'
require 'flexmock'
require 'state/drugs/recentregs'

module ODDB
  module State
    module Drugs

class TestPackageMonth < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    galenic_form = flexmock('galenic_form', :language => 'language')
    package = flexmock('package', 
                       :generic_type    => 'generic_type',
                       :galenic_forms   => [galenic_form],
                       :comparable_size => 'comparable_size',
                       :expired?  => nil,
                       :name_base => 'name_base',
                       :dose      => 'dose'
                      )
    registration = flexmock('registration') do |reg|
      reg.should_receive(:each_package).and_yield(package)
    end
    session = flexmock('session', :language => 'language')
    @month = ODDB::State::Drugs::RecentRegs::PackageMonth.new('date', [registration], session)
  end
  def test_package_count
    assert_equal(1, @month.package_count)
  end
end
class TestRecentRegs < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    log_group = flexmock('log_group', 
                         :newest_date => Time.local(2011,2,3),
                         :years       => [2011],
                         :months      => [2]
                        )
    @app     = flexmock('app', :log_group => log_group)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => nil,
                        :language    => 'language'
                       )
    @model   = flexmock('model')
    galenic_form = flexmock('galenic_form', :language => 'language')
    package  = flexmock('package', 
                       :generic_type    => 'generic_type',
                       :galenic_forms   => [galenic_form],
                       :comparable_size => 'comparable_size',
                       :expired?  => nil,
                       :name_base => 'name_base',
                       :dose      => 'dose'
                      )

    @registration = flexmock('registration') do |reg|
      reg.should_receive(:each_package).and_yield(package)
    end
    cache = flexmock('cache', :retrieve_from_index => [@registration])
    flexmock(ODBA, :cache => cache)
    @state   = ODDB::State::Drugs::RecentRegs.new(@session, @model)
  end
  def test_regs_by_month
    assert_equal([@registration], @state.regs_by_month(Time.local(2011,2,3)))
  end
  def test_create_package_month
    assert_kind_of(ODDB::State::Drugs::RecentRegs::PackageMonth, @state.create_package_month(Time.local(2011,2.3)))
  end
  def test_init
    assert_equal([2], @state.init)
  end
  def test_init__user_input
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:year).once.and_return(2011)
      s.should_receive(:user_input).with(:month).once.and_return(2)
    end
    assert_equal([2], @state.init)
  end

end

    end # Drugs
  end # State
end # ODDB

