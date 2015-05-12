#!/usr/bin/env ruby
# encoding: utf-8

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
    def create_default_product_mock(product_name, out_of_trade = false, sl_generic_type = :original, generic_type = :original)
      package = flexmock('package')
      package.should_receive(:odba_instance).by_default.and_return(nil)
      package.should_receive(:out_of_trade).by_default.and_return(out_of_trade)
      package.should_receive(:sl_generic_type).by_default.and_return(sl_generic_type)
      package.should_receive(:barcode).by_default.and_return('ean13')
      package.should_receive(:generic_type).by_default.and_return(generic_type)
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
      @paaa_original = create_default_product_mock('paaa_original')
      @sort    = ODDB::StubResultSort.new([@paaa_original])
    end

    def setup_more_products
      @p001 = create_default_product_mock("p001", false, :generic, :generic) # Example_7680655530096
      @p002 = create_default_product_mock("p002", false, :generic, nil) # Example_7680651880027
      @p003 = create_default_product_mock("p003", false, :original, :original) # Example_7680625700146
      @p004 = create_default_product_mock("p004", false, :original, nil) # Example_7680632000130
      @p005 = create_default_product_mock("p005", false, :unknown, :original) # Example_7680574890066
      @p006 = create_default_product_mock("p006", false, :unknown, nil) # Example_7680653310010
      @p007 = create_default_product_mock("p007", false, nil, :generic) # Example_7680626160017
      @p008 = create_default_product_mock("p008", false, nil, nil) # Example_7680656280013
      @p009 = create_default_product_mock("p009", nil, :generic, :generic) # Example_7680656450041
      @p010 = create_default_product_mock("p010", nil, :generic, nil) # Example_7680650500049
      @p011 = create_default_product_mock("p011", nil, :original, :original) # Example_7680560750527
      @p012 = create_default_product_mock("p012", nil, :original, nil) # Example_7680570620063
      @p013 = create_default_product_mock("p013", nil, :unknown, nil) # Example_7680652020026
      @p014 = create_default_product_mock("p014", nil, nil, nil) # Example_7680655760028
      @p015 = create_default_product_mock("p015", true, :generic, :generic) # Example_7680655530102
      @p016 = create_default_product_mock("p016", true, :generic, nil) # Example_7680653080043
      @p017 = create_default_product_mock("p017", true, :original, :original) # Example_7680550900017
      @p018 = create_default_product_mock("p018", true, :original, nil) # Example_7680625700160
      @p019 = create_default_product_mock("p019", true, :unknown, nil) # Example_7680651050062
      @p020 = create_default_product_mock("p020", true, nil, nil) # Example_7680656080019

      @pacc_generic = create_default_product_mock('pacc_generic', false, :generic, :generic)
      @pacc_generic.should_receive(:company).and_return('company_generic')

      @paff_sl_original = create_default_product_mock('paff_sl_original')
      @paff_sl_original.should_receive(:sl_generic_type).and_return(:original)

      @pccc_generic_from_desitin = create_default_product_mock('pccc_generic_from_desitin',false, :generic, :generic)
      @pccc_generic_from_desitin.should_receive(:company).and_return('desitin')

      @pccc_unknown_from_desitin = create_default_product_mock('pccc_unknown_from_desitin',false, :unknown, nil)
      @pccc_unknown_from_desitin.should_receive(:company).and_return('desitin')

      @pddd_sl_generic_nil_from_desitin = create_default_product_mock('pddd_sl_generic_nil_from_desitin', false, nil, :generic)
      @pddd_sl_generic_nil_from_desitin.should_receive(:company).and_return('desitin')

      @pzzz_original = create_default_product_mock('pzzz_original')
      @sort   = ODDB::StubResultSort.new([])
      @order_2 = [@paaa_original, @pacc_generic, @pddd_sl_generic_nil_from_desitin,
                  @pccc_generic_from_desitin, @pzzz_original, @paff_sl_original,
                  @p001, @p002, @p003, @p004, @p005, @p006, @p007, @p008, @p009, @p010, @pccc_unknown_from_desitin,
                  @p011, @p012, @p013, @p014, @p015, @p016, @p017, @p018, @p019, @p020,
                  ]
      @order_3 = [@paff_sl_original, @paaa_original, @pccc_generic_from_desitin, @pzzz_original,
                  @pacc_generic, @pddd_sl_generic_nil_from_desitin,
                  @p001, @p002, @p003, @p004, @p005, @p006, @p007, @p008, @p009, @p010, @pccc_unknown_from_desitin,
                  @p011, @p012, @p013, @p014, @p015, @p016, @p017, @p018, @p019, @p020,
                  ]
      @order_4 = [@pzzz_original, @pccc_generic_from_desitin, @pddd_sl_generic_nil_from_desitin,
                  @paff_sl_original, @pacc_generic, @paaa_original, @pccc_unknown_from_desitin,
                  @p001, @p002, @p003, @p004, @p005, @p006, @p007, @p008, @p009, @p010,
                  @p011, @p012, @p013, @p014, @p015, @p016, @p017, @p018, @p019, @p020,
                  ]
      @expected_default_order = [
        @p003,
        @p004,
        @p005,
        @p011,
        @p012,
        @paaa_original,
        @paff_sl_original,
        @pzzz_original,
        @p001,
        @p002,
        @p007,
        @p009,
        @p010,
        @pacc_generic,
        @pccc_generic_from_desitin,
        @pddd_sl_generic_nil_from_desitin,
        @p006,
        @p008,
        @p013,
        @p014,
        @pccc_unknown_from_desitin,
        @p015,
        @p016,
        @p017,
        @p018,
        @p019,
        @p020,
        ]

      @expected_order_desitin = [
        @p003,
        @p004,
        @p005,
        @p011,
        @p012,
        @paaa_original,
        @paff_sl_original,
        @pzzz_original,
        @pccc_unknown_from_desitin,
        @pccc_generic_from_desitin,
        @pddd_sl_generic_nil_from_desitin,
        @p001,
        @p002,
        @p007,
        @p009,
        @p010,
        @pacc_generic,
        @p006,
        @p008,
        @p013,
        @p014,
        @p015,
        @p016,
        @p017,
        @p018,
        @p019,
        @p020,
        ]
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
    def test_sort_result
      assert_equal([@paaa_original], @sort.sort_result([@paaa_original], @session))
    end
    def test_sort_result_sl_generic_type_is_nil
      @paaa_original.should_receive(:generic_type).and_return(:unknown)
      @paaa_original.should_receive(:sl_generic_type).and_return(nil)
      assert_equal([@paaa_original], @sort.sort_result([@paaa_original], @session))
    end
    def test_sort_result_default
      setup_more_products
      assert_equal(@expected_default_order, @sort.sort_result(@order_2, @session))
      assert_equal(@expected_default_order, @sort.sort_result(@order_3, @session))
      assert_equal(@expected_default_order, @sort.sort_result(@order_4, @session))
    end
    def test_sort_result_evidentia_sl_original_nil
      @session.should_receive(:flavor).and_return(@evidentia)
      @component = LookandfeelBase.new(@session)
      @evidentia = LookandfeelEvidentia.new(@component)
      @session.should_receive(:flavor).and_return(@evidentia)
      @session.should_receive(:lookandfeel).and_return(@evidentia)
      setup_more_products
      @expected_order_desitin.each{ |item| assert_equal(FlexMock, item.class) }
      assert_equal(@expected_order_desitin, @sort.sort_result(@order_2, @session))
      assert_equal(@expected_order_desitin, @sort.sort_result(@order_3, @session))
      assert_equal(@expected_order_desitin, @sort.sort_result(@order_4, @session))
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDERR
    end
    def test_sort_result__error
      flexmock(@paaa_original) do |p|
        p.should_receive(:expired?).and_raise(StandardError)
      end
      stdout_null do
        assert_equal([@paaa_original], @sort.sort_result([@paaa_original], @session))
      end
    end
    def test_sort_result_login_desitin
      user = flexmock('user', :name => 'dummy@desitin.ch')
      @session.should_receive(:user).and_return(user)
      setup_more_products
      @expected_order_desitin.each{ |item| assert_equal(FlexMock, item.class) }
      assert_equal(@expected_order_desitin, @sort.sort_result(@order_2, @session))
      assert_equal(@expected_order_desitin, @sort.sort_result(@order_3, @session))
      assert_equal(@expected_order_desitin, @sort.sort_result(@order_4, @session))
    end

    def test_sort_result_alphabetically_and_size
      user = flexmock('user', :name => 'dummy@desitin.ch')
      @session.should_receive(:user).and_return(user)
      @paaa = create_default_product_mock("paaa")
      @pabb_20_mg = create_default_product_mock("pabb 20 mg")
      @pabb_20_mg.should_receive(:dose).and_return(Quanty(20,'mg'))
      @pabb_50_mg = create_default_product_mock("pabb 50 mg")
      @pabb_50_mg.should_receive(:dose).and_return(Quanty(50,'mg'))
      @pabb_100_mg = create_default_product_mock("pabb 100 mg")
      @pabb_100_mg.should_receive(:dose).and_return(Quanty(100,'mg'))
      @pacc = create_default_product_mock("pacc") # original

      order_1        = [@pacc, @pabb_100_mg, @pabb_20_mg, @pabb_50_mg, @paaa]
      order_2        = [@pacc, @pabb_50_mg, @paaa, @pabb_100_mg, @pabb_20_mg]
      expected_order = [@paaa, @pabb_20_mg, @pabb_50_mg, @pabb_100_mg, @pacc]
      expected_order.each{ |item| assert_equal(FlexMock, item.class) }
      assert_equal(expected_order, @sort.sort_result(order_1, @session))
      assert_equal(expected_order, @sort.sort_result(order_2, @session))
      assert_equal(expected_order, @sort.sort_result(order_1.reverse, @session))
      assert_equal(expected_order, @sort.sort_result(order_2.reverse, @session))
    end

  end
end # ODDB

