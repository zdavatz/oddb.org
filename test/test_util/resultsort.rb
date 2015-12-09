#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/resultsort'
require 'model/dose'
require 'model/slentry'
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
    def create_default_product_mock(product_name, out_of_trade = false, sl_generic_type = :original, generic_type = :original, gal_forms = nil)
      unless gal_forms
        gal_forms = flexmock('gal_forms')
        gal_forms.should_receive(:collect).by_default.and_return(['gal_def'])
      end
      package = flexmock('package')
      package.should_receive(:iksnr).by_default.and_return('61848')
      package.should_receive(:sort_info).by_default.and_return('sort_info')
      package.should_receive(:sort_info=).by_default
      package.should_receive(:seqnr).by_default.and_return('88')
      package.should_receive(:ikscd).by_default.and_return('999')
      package.should_receive(:odba_instance).by_default.and_return(nil)
      package.should_receive(:out_of_trade).by_default.and_return(out_of_trade)
      package.should_receive(:sl_generic_type).by_default.and_return(sl_generic_type)
      package.should_receive(:barcode).by_default.and_return('ean13')
      package.should_receive(:generic_type).by_default.and_return(generic_type)
      package.should_receive(:expired? ).by_default.and_return(nil)
      package.should_receive(:name_base).by_default.and_return(product_name)
      package.should_receive(:galenic_forms).by_default.and_return(gal_forms)
      package.should_receive(:dose).by_default.and_return('dose')
      package.should_receive(:company).by_default.and_return('company_original')
      package.should_receive(:comparable_size).by_default.and_return('comparable_size')
      package.should_receive(:inspect).by_default.and_return(product_name)
      package.should_receive(:sl_entry).by_default.and_return(nil)
      sequence =  flexmock('sequence')
      sequence.should_receive(:name).by_default.and_return(product_name)
      package.should_receive(:sequence).by_default.and_return(sequence)
      package
    end

    def setup_session
      @session = flexmock('session', :language => 'language')
      @session.should_receive(:user).by_default.and_return(nil)
      @session.should_receive(:flavor).and_return(@standard)
      @session.should_receive(:request_path).by_default.and_return('/de/gcc/')
      component = LookandfeelBase.new(@session)
      gcc = LookandfeelStandardResult.new(component)
      @session.should_receive(:flavor).by_default.and_return(gcc)
      @session.should_receive(:lookandfeel).by_default.and_return(gcc)
    end

    def setup
      setup_session
      @galenic_form = flexmock('galenic_form')
      @galenic_form.should_receive(:odba_instance).by_default.and_return(nil)
      @paaa_original = create_default_product_mock('paaa_original')
      @sort    = ODDB::StubResultSort.new([@paaa_original])
    end

    def setup_more_products
      gal_a = flexmock('gal_a')
      gal_a.should_receive(:collect).by_default.and_return(['gal_a'])
      gal_z = flexmock('gal_z')
      gal_z.should_receive(:collect).by_default.and_return(['gal_z'])
      @p001 = create_default_product_mock("p001", false, :generic, :generic, gal_z) # Example_7680655530096
      @p002 = create_default_product_mock("p002", false, :generic, nil, gal_a) # Example_7680651880027
      @p003 = create_default_product_mock("p003", false, :original, :original) # Example_7680625700146
      @p004 = create_default_product_mock("p004", false, :original, nil) # Example_7680632000130
      @p005 = create_default_product_mock("p005", false, :unknown, :original) # Example_7680574890066
      @p006 = create_default_product_mock("p006", false, :unknown, nil) # Example_7680653310010
      @p007 = create_default_product_mock("p007", false, nil, :generic) # Example_7680626160017
      @p008 = create_default_product_mock("p008", false, nil, nil) # Example_7680656280013
      @p009za = create_default_product_mock("p009za", nil, :generic, :generic, gal_a) # Example_7680656450041
      @p009zz = create_default_product_mock("p009zz", nil, :generic, :generic, gal_z) # Example_7680656450041
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
      @p019 = create_default_product_mock("p019", true, :unknown, nil, gal_z) # Example_7680651050062
      @p020 = create_default_product_mock("p020", true, nil, nil, gal_a) # Example_7680656080019

      @pacc_generic = create_default_product_mock('pacc_generic', false, :generic, :generic)
      @pacc_generic.should_receive(:company).and_return('company_generic')

      @paff_sl_original = create_default_product_mock('paff_sl_original')
      @paff_sl_original.should_receive(:sl_generic_type).and_return(:original)

      @pccc_generic_from_desitin = create_default_product_mock('pccc_generic_from_desitin',false, :generic, :generic)
      @pccc_generic_from_desitin.should_receive(:company).and_return('desitin')

      @pccc_unknown_from_desitin = create_default_product_mock('pccc_unknown_from_desitin',false, :unknown, nil)
      @pccc_unknown_from_desitin.should_receive(:company).and_return('desitin')

      gal_liquid = flexmock('gal_liquid')
      gal_liquid.should_receive(:collect).and_return(['gal_liquid'])
      #     def create_default_product_mock(product_name, out_of_trade = false, sl_generic_type = :original, generic_type = :original, gal_forms = nil)

      @pddd_sl_generic_nil_from_desitin = create_default_product_mock('pddd_sl_generic_nil_from_desitin', false, :generic, nil, gal_liquid)
      @pddd_sl_nil_from_desitin         = create_default_product_mock('pddd_sl_nil_from_desitin',         false, nil,      nil,  gal_liquid)

      @pddd_sl_nil_from_desitin.should_receive(:company).and_return('desitin')
      @pddd_sl_generic_nil_from_desitin.should_receive(:company).and_return('desitin')
      @pddd_sl_generic_nil_from_desitin.should_receive(:sl_entry).and_return(nil)


      @pzzz_original = create_default_product_mock('pzzz_original')
      @sort   = ODDB::StubResultSort.new([])
      @order_2 = [@paaa_original, @pacc_generic, @pddd_sl_generic_nil_from_desitin, @pddd_sl_nil_from_desitin,
                  @pccc_generic_from_desitin, @pzzz_original, @paff_sl_original,
                  @p001, @p002, @p003, @p004, @p005, @p006, @p007, @p008, @p009, @p009za, @p009zz, @p010, @pccc_unknown_from_desitin,
                  @p011, @p012, @p013, @p014, @p015, @p016, @p017, @p018, @p019, @p020
                  ]
      @order_3 = [@paff_sl_original, @paaa_original, @pccc_generic_from_desitin, @pzzz_original, @pddd_sl_nil_from_desitin,
                  @pacc_generic, @pddd_sl_generic_nil_from_desitin,
                  @p001, @p002, @p003, @p004, @p005, @p006, @p007, @p008, @p009, @p009za, @p009zz, @p010, @pccc_unknown_from_desitin,
                  @p011, @p012, @p013, @p014, @p015, @p016, @p017, @p018, @p019, @p020, @pddd_sl_nil_from_desitin,
                  ]
      @order_4 = [@pzzz_original, @pccc_generic_from_desitin, @pddd_sl_generic_nil_from_desitin, @pddd_sl_nil_from_desitin,
                  @paff_sl_original, @pacc_generic, @paaa_original, @pccc_unknown_from_desitin,
                  @p001, @p002, @p003, @p004, @p005, @p006, @p007, @p008, @p009, @p009za, @p009zz, @p010,
                  @p011, @p012, @p013, @p014, @p015, @p016, @p017, @p018, @p019, @p020,
                  ]
      @expected_default_order = [
        @p003,
        @p004,
        @p011,
        @p012,
        @paaa_original,
        @paff_sl_original,
        @pzzz_original,
        @p002,
        @p009za,
        @p009,
        @p010,
        @pacc_generic,
        @pccc_generic_from_desitin,
        @pddd_sl_generic_nil_from_desitin,
        @p001,
        @p009zz,
        @p005,
        @p006,
        @p007,
        @p008,
        @p013,
        @p014,
        @pccc_unknown_from_desitin,
        @pddd_sl_nil_from_desitin,
        @p020,
        @p015,
        @p016,
        @p017,
        @p018,
        @p019,
        ]

      @expected_order_desitin = [
        @p003,
        @p004,
        @p011,
        @p012,
        @paaa_original,
        @paff_sl_original,
        @pzzz_original,
        @pccc_generic_from_desitin,
        @pccc_unknown_from_desitin,
        @pddd_sl_generic_nil_from_desitin,
        @pddd_sl_nil_from_desitin,
        @p002,
        @p009za,
        @p009,
        @p010,
        @pacc_generic,
        @p001,
        @p009zz,
        @p005,
        @p006,
        @p007,
        @p008,
        @p013,
        @p014,
        @p020,
        @p018,
        @p015,
        @p016,
        @p017,
        @p019,
        ]
    end
    def setup_evidentia
      setup_more_products
      @component = LookandfeelBase.new(@session)
      @evidentia = LookandfeelEvidentia.new(@component)
      sl_entry_valid = flexmock('sl_entry_valid')
      sl_entry_valid.should_receive(:odba_instance).by_default.and_return(nil)
      sl_entry_valid.should_receive(:valid_until).by_default.and_return(Date.today + 1)
      sl_entry_invalid = flexmock('sl_entry_invalid')
      sl_entry_invalid.should_receive(:odba_instance).by_default.and_return(nil)
      sl_entry_invalid.should_receive(:valid_until).by_default.and_return(Date.today - 1)
      @p001.should_receive(:sl_entry).and_return(nil)
      @p002.should_receive(:sl_entry).and_return(sl_entry_valid)
      @p003.should_receive(:sl_entry).and_return(sl_entry_invalid)
      @evidentia_products       = [@p001, @p002, @p003]
      @expected_order_evidentia = [@p003, @p001, @p002]
    end

    def test_sort_result_evidentia_sl_before_non_sl
      setup_evidentia
      @expected_order_evidentia.each{ |item| assert_equal(FlexMock, item.class) }
      res = @sort.sort_result(@evidentia_products, @session)
      found_non_sl = false
      res.each_with_index{
        |item, idx|
        if not found_non_sl and item.sl_entry and (item.sl_entry.valid_until > Date.today)
          found_non_sl = idx
        elsif found_non_sl
          found_sl = false
          found_sl = (item.sl_entry.valid_until > Date.today) if item.sl_entry
          assert_equal(false, found_sl, "Non-SL #{found_non_sl} #{res[found_non_sl].name_base} must come before SL #{idx} #{res[idx].name_base}")
        end
      }
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
    def test_sort_result_order_2
      setup_more_products
      assert_equal(@expected_default_order, @sort.sort_result(@order_2, @session))
    end
    def test_sort_result_order_3
      setup_more_products
      assert_equal(@expected_default_order, @sort.sort_result(@order_3, @session))
    end

    def test_sort_result_order_4
      setup_more_products
      assert_equal(@expected_default_order, @sort.sort_result(@order_4, @session))
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
      @sort.sort_result(@order_2, @session)
      @p018.should_receive(:name_base).and_return('Levetiracetam Desitin 100 mg/mL')
      @p019.should_receive(:name_base).and_return('Levetiracetam Desitin 100 mg/mL')
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

    def create_leve_product(name)
      product = create_default_product_mock(name, false, :generic, :generic, @gal_levetiracetam)
      product.should_receive(:sl_entry).and_return(@sl_entry_valid)
      product
    end

    def setup_evidentia_trademark(url_with_name)
      @session.should_receive(:flavor).and_return(@evidentia)
      @component = LookandfeelBase.new(@session)
      @evidentia = LookandfeelEvidentia.new(@component)
      @session.should_receive(:flavor).and_return(@evidentia)
      @session.should_receive(:lookandfeel).and_return(@evidentia)
      @gal_levetiracetam = flexmock('gal_levetiracetam')
      @gal_levetiracetam.should_receive(:collect).by_default.and_return(['gal_levetiracetam'])
      @sl_entry_valid = flexmock('sl_entry_valid')
      @sl_entry_valid.should_receive(:odba_instance).by_default.and_return(nil)
      @sl_entry_valid.should_receive(:valid_until).by_default.and_return(Date.today + 1)
      gal_z = flexmock('gal_z')
      gal_z.should_receive(:collect).by_default.and_return(['gal_z'])
      @desitin = create_leve_product('Levetiracetam Desitin 1000 mg')
      @actavis = create_leve_product('Levetiracetam Actavis 1000 mg')
      @keppra = create_leve_product('Keppra 250 mg')
      @keppra2 = create_leve_product('Keppra 200 mg')
      @keppra2.should_receive(:out_of_trade).and_return(true)
      @keppra3 = create_default_product_mock('Keppra 210 mg', false, :generic, :generic, @gal_levetiracetam)
      @rivoleve = create_leve_product('Rivoleve 1000')
      @zzz = create_leve_product('ZZZ')
      @rivoleve.should_receive(:out_of_trade).and_return(true)
      @tm_products  = [@desitin, @actavis, @keppra, @keppra2, @keppra3, @rivoleve, @zzz]
      if url_with_name
        @session.should_receive(:request_path).and_return(
          "/de/evidentia/search/zone/drugs/search_query/#{URI.encode(url_with_name)}/search_type/st_combined")
      end
    end

    def test_sort_result_evidentia_default_levetiracetam
      setup_evidentia_trademark('Levetiracetam')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Keppra 210 mg',
        'Keppra 250 mg',
        'Levetiracetam Actavis 1000 mg',
        'Levetiracetam Desitin 1000 mg',
        'ZZZ',
        'Keppra 200 mg',
        'Rivoleve 1000',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def test_sort_result_evidentia_levetiracetam_search_Rivoleve
      setup_evidentia_trademark('Rivoleve')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Rivoleve 1000',
        'Keppra 210 mg',
        'Keppra 250 mg',
        'Levetiracetam Actavis 1000 mg',
        'Levetiracetam Desitin 1000 mg',
        'ZZZ',
        'Keppra 200 mg',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def test_sort_case_insensitive
      aaa_name = 'AAAA'
      aaa_first =  [ aaa_name, 'Duodopa' ]
      aaa_last =  [ 'Duodopa', aaa_name ]

      { aaa_name => aaa_first,
        'aaa' => aaa_first,
        'Duodopa' => aaa_last,
        'DUODOPA' => aaa_last,
        }.each do |name, expected_names|
        setup_session
        setup_evidentia_trademark(nil)
        gal_z = flexmock('gal_z')
        gal_z.should_receive(:collect).by_default.and_return(['gal_z'])
        aaa = create_default_product_mock(aaa_name, false, :generic, :generic, gal_z)
        aaa.should_receive(:sl_entry).and_return(@sl_entry_valid)
        duodopa = create_default_product_mock('Duodopa', false, :generic, :generic, gal_z)
        duodopa.should_receive(:sl_entry).and_return(@sl_entry_valid)
        products = [aaa, duodopa]
        test_session = @session.clone
        test_session.should_receive(:request_path).and_return(
          "/de/evidentia/search/zone/drugs/search_query/#{name}/search_type/st_combined")
        # puts "products #{products.collect {|x| x.name_base}} test_session #{test_session.request_path}"
        @sort    = ODDB::StubResultSort.new(products)
        res = @sort.sort_result(products, test_session)
        assert_equal(expected_names, res.collect{|pack| pack.name_base})
      end
    end

    def test_sort_result_evidentia_levetiracetam_search_Levetiracetam_Desitin
      setup_evidentia_trademark('Levetiracetam Desitin')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Levetiracetam Desitin 1000 mg',
        'Keppra 250 mg',
        'Keppra 210 mg',
        'Levetiracetam Actavis 1000 mg',
        'ZZZ',
        'Keppra 200 mg',
        'Rivoleve 1000',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def test_sort_result_evidentia_default_Keppra
      setup_evidentia_trademark('Keppra')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Keppra 250 mg', # has sl_entry and is not out_of_trade
        'Keppra 210 mg', # has no sl_entry and should come
        'Keppra 200 mg', # is out of trade and must come after the other Keppra
        'Levetiracetam Actavis 1000 mg',
        'Levetiracetam Desitin 1000 mg',
        'ZZZ',
        'Rivoleve 1000',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end


  end
end # ODDB

