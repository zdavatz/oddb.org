#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestResultSort -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/resultsort'
require 'model/dose'

module ODDB
  class StubResultStateSort
    include ODDB::ResultStateSort
    def initialize(model)
      @model = model
    end
    def get_sortby!
    end
  end

  class TestResultStateSort <Minitest::Test
    include FlexMock::TestCase
    def setup
      package = flexmock('package', :expired? => nil)
      @model = flexmock('model', :packages => [package])
      @sort  = ODDB::StubResultStateSort.new([@model])
    end
    def test_sort
      assert_equal(@sort, @sort.sort)
    end
  end

  class StubResultSort
    include ODDB::ResultSort
    def initialize(packages)
      @packages = packages
    end
  end

  class TestResultSort <Minitest::Test
    include FlexMock::TestCase
    def setup
      @session = flexmock('session', :language => 'language')
      @galenic_form = flexmock('galenic_form')
      @galenic_form.should_receive(:odba_instance).by_default.and_return(nil)
      @package = flexmock('package')
      @package.should_receive(:odba_instance).by_default.and_return(nil)
      @package.should_receive(:generic_type).by_default.and_return(:original)
      @package.should_receive(:expired? ).by_default.and_return(nil)
      @package.should_receive(:name_base).by_default.and_return('name_base')
      @package.should_receive(:galenic_forms).by_default.and_return([@package])
      @package.should_receive(:dose).by_default.and_return('dose')
      @package.should_receive(:comparable_size).by_default.and_return('comparable_size')
      @sort    = ODDB::StubResultSort.new([@package])
    end
    def test_galform_str__else
      @galenic_form.should_receive(:odba_instance).and_return('odba_instance')
      @galenic_form.should_receive(:language).and_return('language')
      assert_equal('language', @sort.galform_str(@galenic_form, @session))
    end
    def test_dose_value
      assert_equal(Quanty(0,''), @sort.dose_value(nil))
    end
    def test_package_count
      assert_equal(1, @sort.package_count)
    end
    def test_galform_str
      assert_equal('', @sort.galform_str(@galenic_form, @session))
    end
    def test_generic_type_weight__originel
      assert_equal(0, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__generic
      @package.should_receive(:generic_type).and_return('generic')
      assert_equal(5, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__comarketing
      @package.should_receive(:generic_type).and_return('comarketing')
      assert_equal(10, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__complementary
      @package.should_receive(:generic_type).and_return('complementary')
      assert_equal(15, @sort.generic_type_weight(@package))
    end
    def test_generic_type_weight__else
      @package.should_receive(:generic_type).and_return('else')
      assert_equal(20, @sort.generic_type_weight(@package))
    end
    def test_sort_result
      assert_equal([@package], @sort.sort_result([@package], @session))
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDERR
    end
    def test_sort_result__error
      flexmock(@package) do |p|
        p.should_receive(:expired?).and_raise(StandardError)
      end
      stdout_null do 
        assert_equal([@package], @sort.sort_result([@package], @session))
      end
    end
  end

end # ODDB

