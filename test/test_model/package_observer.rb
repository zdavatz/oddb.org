#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestPackageObserver -- oddb.org -- 01.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/package_observer'
require 'util/persistence'

module ODDB
  class StubSuper
  end
  class StubPackageObserver < StubSuper
    include PackageObserver
  end
  class TestPackageObserver <Minitest::Test
    include FlexMock::TestCase
    def setup
      @observer = ODDB::StubPackageObserver.new
    end
    def test_add_package
      flexmock(ODBA.cache, 
               :next_id => 123,
               :store   => 'store'
              )
      assert_equal('package', @observer.add_package('package'))
    end
    def test_empty
      assert(@observer.empty?)
    end
    def test_package_count
      flexmock(ODBA.cache, 
               :next_id => 123,
               :store   => 'store'
              )
      @observer.add_package('package')
      assert_equal(1, @observer.package_count)
    end
    def test_remove_package
      flexmock(ODBA.cache, 
               :next_id => 123,
               :store   => 'store'
              )
      @observer.add_package('package')
      assert_equal('package', @observer.remove_package('package'))
      assert_equal(0, @observer.package_count)
    end
  end

end # ODDB
