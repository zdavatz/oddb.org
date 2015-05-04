#!/usr/bin/env ruby
# encoding: utf-8
# vim:  tabstop=2 shiftwidth=2 expandtab
# ODDB::TestResultSort -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/resultsort'
require 'model/dose'
require 'custom/lookandfeelwrapper'

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
    def create_default_product_mock(product_name)
      package = flexmock('package')
      package.should_receive(:odba_instance).by_default.and_return(nil)
      package.should_receive(:generic_type).by_default.and_return(:original)
      package.should_receive(:expired? ).by_default.and_return(nil)
      package.should_receive(:name_base).by_default.and_return(product_name)
      package.should_receive(:galenic_forms).by_default.and_return([package])
      package.should_receive(:dose).by_default.and_return('dose')
      package.should_receive(:company).by_default.and_return('company_original')
      package.should_receive(:comparable_size).by_default.and_return('comparable_size')
      package.should_receive(:inspect).by_default.and_return(product_name)
      package
    end
    def setup
      @session = flexmock('session', :language => 'language')
      @session.should_receive(:flavor).and_return(@standard)
      @component = LookandfeelBase.new(@session)
      @standard = LookandfeelStandardResult.new(@component)
      @session.should_receive(:lookandfeel).by_default.and_return(@component)
      @galenic_form = flexmock('galenic_form')
      @galenic_form.should_receive(:odba_instance).by_default.and_return(nil)
      @package = create_default_product_mock('product_1')
      @sort    = ODDB::StubResultSort.new([@package])
    end

    def setup_more_products
      @package2 = create_default_product_mock('product_2')
      @package2.should_receive(:generic_type).and_return(:generic)
      @package2.should_receive(:company).and_return('company_generic')
      @package3 = create_default_product_mock('product_3')
      @package3.should_receive(:generic_type).and_return(:generic)
      @package3.should_receive(:company).and_return('desitin')
      @package4 = create_default_product_mock('product_4')
      @package4.should_receive(:name_base).and_return('product_4_orignal')
      @sort    = ODDB::StubResultSort.new([@package, @package2, @package3, @package4])
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
    def test_sort_result_default
      setup_more_products
      expected_order = [@package, # original
                        @package4, # original
                        @package2, # alphabetically sorted
                        @package3,
                        ]
      assert_equal(expected_order, @sort.sort_result([@package, @package2, @package3, @package4], @session))
      assert_equal(expected_order, @sort.sort_result([@package, @package3, @package4, @package2], @session))
      assert_equal(expected_order, @sort.sort_result([@package4, @package3, @package2, @package], @session))
    end
    def test_sort_result_evidentia
      @session.should_receive(:flavor).and_return(@evidentia)
      @component = LookandfeelBase.new(@session)
      @evidentia = LookandfeelEvidentia.new(@component)
      @session.should_receive(:flavor).and_return(@evidentia)
      @session.should_receive(:lookandfeel).and_return(@evidentia)
      setup_more_products
      expected_order = [@package3, # because it is from desitin
                        @package, # original
                        @package4, # original
                        @package2, # alphabetically sorted
                        ]
      assert_equal(expected_order,  @sort.sort_result([@package, @package2, @package3, @package4], @session))
#      assert_equal(expected_order, @sort.sort_result([@package, @package3, @package4, @package2], @session))
#      assert_equal(expected_order, @sort.sort_result([@package4, @package3, @package2, @package], @session))
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

