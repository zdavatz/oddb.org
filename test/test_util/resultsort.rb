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
      package.should_receive(:sl_generic_type).by_default.and_return(nil)
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
      @session.should_receive(:user).by_default.and_return(nil)
      @session.should_receive(:flavor).and_return(@standard)
      @component = LookandfeelBase.new(@session)
      @standard = LookandfeelStandardResult.new(@component)
      @session.should_receive(:lookandfeel).by_default.and_return(@component)
      @galenic_form = flexmock('galenic_form')
      @galenic_form.should_receive(:odba_instance).by_default.and_return(nil)
      @p111_original = create_default_product_mock('111_original')
      @sort    = ODDB::StubResultSort.new([@p111_original])
    end

    def setup_more_products
      @p133_generic = create_default_product_mock('133_generic')
      @p133_generic.should_receive(:generic_type).and_return(:generic)
      @p133_generic.should_receive(:company).and_return('company_generic')
      @p333_generic_from_desitin = create_default_product_mock('333_generic_from_desitin')
      @p333_generic_from_desitin.should_receive(:generic_type).and_return(:generic)
      @p333_generic_from_desitin.should_receive(:company).and_return('desitin')
      @p999_original = create_default_product_mock('999_original')
      @sort    = ODDB::StubResultSort.new([@p111_original, @p133_generic, @p333_generic_from_desitin, @p999_original])

      @p166_sl_original = create_default_product_mock('166_sl_original')
      @p166_sl_original.should_receive(:generic_type).and_return(:unknown)
      @p166_sl_original.should_receive(:sl_generic_type).and_return(:original)
      @sort    = ODDB::StubResultSort.new([@p111_original, @p133_generic, @p333_generic_from_desitin, @p999_original, @p166_sl_original])
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
      assert_equal(0, @sort.generic_type_weight(@p111_original))
    end
    def test_generic_type_weight__generic
      @p111_original.should_receive(:generic_type).and_return('generic')
      assert_equal(5, @sort.generic_type_weight(@p111_original))
    end
    def test_generic_type_weight__comarketing
      @p111_original.should_receive(:generic_type).and_return('comarketing')
      assert_equal(10, @sort.generic_type_weight(@p111_original))
    end
    def test_generic_type_weight__complementary
      @p111_original.should_receive(:generic_type).and_return('complementary')
      assert_equal(15, @sort.generic_type_weight(@p111_original))
    end
    def test_generic_type_weight__else
      @p111_original.should_receive(:generic_type).and_return('else')
      assert_equal(20, @sort.generic_type_weight(@p111_original))
    end
    def test_sort_result
      assert_equal([@p111_original], @sort.sort_result([@p111_original], @session))
    end
    def test_sort_result_sl_generic_type_is_nil
      @p111_original.should_receive(:generic_type).and_return(:unknown)
      @p111_original.should_receive(:sl_generic_type).and_return(nil)
      assert_equal([@p111_original], @sort.sort_result([@p111_original], @session))
    end
    def test_sort_result_default
      setup_more_products
      expected_order = [
                        @p111_original, # original
                        @p166_sl_original,
                        @p999_original, # original
                        @p133_generic, # alphabetically sorted
                        @p333_generic_from_desitin,
                        ]
      assert_equal(expected_order, @sort.sort_result([@p111_original, @p133_generic, @p333_generic_from_desitin, @p999_original, @p166_sl_original], @session))
      assert_equal(expected_order, @sort.sort_result([@p166_sl_original, @p111_original, @p333_generic_from_desitin, @p999_original, @p133_generic], @session))
      assert_equal(expected_order, @sort.sort_result([@p999_original, @p333_generic_from_desitin, @p166_sl_original, @p133_generic, @p111_original], @session))
    end
    def test_sort_result_evidentia_sl_original_nil
      @session.should_receive(:flavor).and_return(@evidentia)
      @component = LookandfeelBase.new(@session)
      @evidentia = LookandfeelEvidentia.new(@component)
      @session.should_receive(:flavor).and_return(@evidentia)
      @session.should_receive(:lookandfeel).and_return(@evidentia)
      setup_more_products
      expected_order = [@p111_original, # original
                        @p166_sl_original,
                        @p999_original, # original
                        @p333_generic_from_desitin, # because it is from desitin
                        @p133_generic, # alphabetically sorted
                        ]
      expected_order.each{ |item| assert_equal(FlexMock, item.class) }
      assert_equal(expected_order, @sort.sort_result([@p111_original, @p133_generic, @p333_generic_from_desitin, @p999_original, @p166_sl_original], @session))
      assert_equal(expected_order, @sort.sort_result([@p166_sl_original, @p111_original, @p333_generic_from_desitin, @p999_original, @p133_generic], @session))
      assert_equal(expected_order, @sort.sort_result([@p999_original, @p333_generic_from_desitin, @p166_sl_original, @p133_generic, @p111_original], @session))
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDERR
    end
    def test_sort_result__error
      flexmock(@p111_original) do |p|
        p.should_receive(:expired?).and_raise(StandardError)
      end
      stdout_null do
        assert_equal([@p111_original], @sort.sort_result([@p111_original], @session))
      end
    end
    def test_sort_result_login_desiting
      user = flexmock('user', :name => 'dummy@desitin.ch')
      @session.should_receive(:user).and_return(user)
      setup_more_products
      expected_order = [@p111_original, # original
                        @p166_sl_original,
                        @p999_original, # original
                        @p333_generic_from_desitin, # because it is from desitin
                        @p133_generic, # alphabetically sorted
                        ]
      expected_order.each{ |item| assert_equal(FlexMock, item.class) }
      assert_equal(expected_order, @sort.sort_result([@p111_original, @p133_generic, @p333_generic_from_desitin, @p999_original, @p166_sl_original], @session))
      assert_equal(expected_order, @sort.sort_result([@p166_sl_original, @p111_original, @p333_generic_from_desitin, @p999_original, @p133_generic], @session))
      assert_equal(expected_order, @sort.sort_result([@p999_original, @p333_generic_from_desitin, @p166_sl_original, @p133_generic, @p111_original], @session))
    end
  end
end # ODDB

