#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestRegistrationObserver -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com


$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/registration_observer'
require 'odba'

module ODDB
  class StubRegistrationObserver
    include RegistrationObserver
  end

  class TestRegistrationObserver < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, 
               :next_id => 123,
               :store   => nil
              )
      @observer = ODDB::StubRegistrationObserver.new
      flexmock(@observer, :odba_isolated_store => 'odba_isolated_store')
    end
    def test_add_registration
      assert_equal('registration', @observer.add_registration('registration'))
    end
    def test_article_codes
      package      = flexmock('package', 
                              :barcode    => 'barcode',
                              :pharmacode => 'pharmacode',
                              :size       => 'size',
                              :dose       => 'dose'
                             )
      registration = flexmock('registration') do |reg|
        reg.should_receive(:each_package).and_yield(package)
      end
      @observer.add_registration(registration)
      expected = [{
        :article_ean13 => "barcode", 
        :article_pcode => "pharmacode",
        :article_size  => 'size',
        :article_dose  => 'dose'
      }]
      assert_equal(expected, @observer.article_codes)
    end
    def test_empty
      assert(@observer.empty?)
    end
    def test_registration_count
      assert_equal(0, @observer.registration_count)
      @observer.add_registration('registration')
      assert_equal(1, @observer.registration_count)
    end
    def test_remove_registration
      registration = flexmock('registration') 
      @observer.add_registration(registration)
      assert_equal(registration, @observer.remove_registration(registration))
    end
    def test_iksnrs
      registration = flexmock('registration', :iksnr => 'iksnr') 
      @observer.add_registration(registration)
      assert_equal(['iksnr'], @observer.iksnrs)
    end
  end
end
