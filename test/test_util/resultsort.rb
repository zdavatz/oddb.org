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

# The following drugs needed ajustments
# Aricept, Axura, Gentamycin, Adenosin Iscover Fortex Budesonid

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
    @@seqnr ||= 1
    @@ikscd ||= 1
    @@iksnr ||= 12345
    def create_default_product_mock(product_name, out_of_trade = false, sl_generic_type = :original, generic_type = :original, gal_forms = nil)
      unless gal_forms
        gal_forms = flexmock('gal_forms')
        gal_forms.should_receive(:collect).by_default.and_return(['gal_def'])
      end
      @@iksnr += 1
      @@ikscd += 1
      @@seqnr += 1
      package = flexmock('package')
      package.should_receive(:iksnr).by_default.and_return(@@iksnr)
      package.should_receive(:sort_info).by_default.and_return('sort_info')
      package.should_receive(:sort_info=).by_default
      package.should_receive(:seqnr).by_default.and_return(@@seqnr)
      package.should_receive(:ikscd).by_default.and_return(@@ikscd)
      package.should_receive(:ikscat).by_default.and_return('D')
      package.should_receive(:odba_instance).by_default.and_return(nil)
      package.should_receive(:out_of_trade).by_default.and_return(out_of_trade)
      package.should_receive(:sl_generic_type).by_default.and_return(sl_generic_type)
      package.should_receive(:barcode).by_default.and_return('ean13')
      package.should_receive(:generic_type).by_default.and_return(generic_type)
      package.should_receive(:expired? ).by_default.and_return(nil)
      package.should_receive(:name_base).by_default.and_return(product_name)
      package.should_receive(:galenic_forms).by_default.and_return(gal_forms)
      package.should_receive(:dose).by_default.and_return(Quanty.new('1 mg'))
      if /desitin/i.match(product_name)
        package.should_receive(:company).and_return('desitin')
      else
        package.should_receive(:company).by_default.and_return('company_original')
      end
      package.should_receive(:comparable_size).by_default.and_return('comparable_size')
      package.should_receive(:inspect).by_default.and_return(product_name)
      package.should_receive(:sl_entry).by_default.and_return(nil)
      package.should_receive(:name).by_default.and_return(product_name)
      sequence =  flexmock('sequence')
      sequence.should_receive(:name).by_default.and_return(product_name)
      registration =  flexmock('registration')
      registration.should_receive(:name).by_default.and_return(product_name)
      registration.should_receive(:name_base).by_default.and_return(product_name)
      package.should_receive(:registration).by_default.and_return(registration)
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

      @paff_sl_original = create_default_product_mock('paff_sl_original')
      @paff_sl_original.should_receive(:sl_generic_type).and_return(:original)

      @pccc_generic_from_desitin = create_default_product_mock('pccc_generic_from_desitin',false, :generic, :generic)

      @pccc_unknown_from_desitin = create_default_product_mock('pccc_unknown_from_desitin',false, :unknown, nil)

      gal_liquid = flexmock('gal_liquid')
      gal_liquid.should_receive(:collect).and_return(['gal_liquid'])
      @pddd_sl_generic_nil_from_desitin = create_default_product_mock('pddd_sl_generic_nil_from_desitin', false, :generic, nil, gal_liquid)
      @pddd_sl_nil_from_desitin         = create_default_product_mock('pddd_sl_nil_from_desitin',         false, nil,      nil,  gal_liquid)

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
        @p017,
        @p018,
        @p015,
        @p016,
        @p020,
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
        @p017,
        @p018,
        @p015,
        @p016,
        @p020,
        @p019
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

    def create_leve_product(name, is_original=false)
      gen_or_original = is_original ? :original : :generic
      product = create_default_product_mock(name, false, is_original ? :original : :generic, @gal_levetiracetam)
      if m = name.match(/(\d+\s+mg)/)
        product.should_receive(:dose).and_return(Quanty.new(m[0]))
      end
      product.should_receive(:sl_entry).and_return(@sl_entry_valid)
      # product.should_receive(:sl_generic_type).and_return(gen_or_original)
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
      @keppra250 = create_leve_product('Keppra 250 mg', true)
      @keppra200 = create_leve_product('Keppra OutOfTrade 200 mg', true)
      @keppra200.should_receive(:out_of_trade).and_return(true)
      @keppra210 = create_default_product_mock('Keppra 210 mg', false, :original, :original, @gal_levetiracetam)
      @keppra210.should_receive(:sl_entry).and_return(nil)
      @rivoleve200 = create_leve_product('Rivoleve 200 mg')
      @rivoleve500  = create_leve_product('Rivoleve 500 mg')
      @rivoleve500.should_receive(:out_of_trade).and_return(true)

      @zzz = create_leve_product('ZZZ')
      @tm_products  = [@desitin, @actavis, @keppra250, @keppra200, @keppra210, @rivoleve200, @rivoleve500, @zzz]
      if url_with_name
        @session.should_receive(:request_path).and_return(
          "/de/evidentia/search/zone/drugs/search_query/#{URI.encode(url_with_name)}/search_type/st_combined")
      end
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

    def test_sort_result_evidentia_default_levetiracetam
      setup_evidentia_trademark('Levetiracetam')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      assert_equal(true, @keppra200.out_of_trade)
      assert_equal(false, @keppra210.out_of_trade)
      assert_equal(false, @keppra250.out_of_trade)
      assert_equal(:original, @keppra250.sl_generic_type)
      assert_equal(:original, @keppra200.sl_generic_type)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Keppra 250 mg', # has sl_entry and is not out_of_trade
        'Levetiracetam Desitin 1000 mg',
        'Levetiracetam Actavis 1000 mg',
        'Rivoleve 200 mg',
        'ZZZ',
        'Keppra 210 mg', # has no sl_entry and should come after ZZZ
        'Keppra OutOfTrade 200 mg', # is out of trade and must come after the other Keppra
        'Rivoleve 500 mg',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def test_sort_result_evidentia_default_levetiracetam_actavis
      setup_evidentia_trademark('Levetiracetam Actavis')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Levetiracetam Actavis 1000 mg',
        'Keppra 250 mg',
        'Levetiracetam Desitin 1000 mg',
        'Rivoleve 200 mg',
        'ZZZ',
        'Keppra 210 mg',
        'Keppra OutOfTrade 200 mg',
        'Rivoleve 500 mg',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def test_sort_result_evidentia_levetiracetam_search_Rivoleve
      setup_evidentia_trademark('Rivoleve')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Rivoleve 200 mg',
        'Keppra 250 mg',
        'Levetiracetam Desitin 1000 mg',
        'Levetiracetam Actavis 1000 mg',
        'ZZZ',
        'Keppra 210 mg',
        'Keppra OutOfTrade 200 mg',
        'Rivoleve 500 mg', # also out of trade
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
        assert_equal(expected_names, res.collect{|pack| pack.name_base}, "name #{name} #{expected_names}")
      end
    end

    def test_sort_result_evidentia_levetiracetam_search_Levetiracetam_Desitin
      setup_evidentia_trademark('Levetiracetam Desitin')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Levetiracetam Desitin 1000 mg',
        'Keppra 250 mg',
        'Levetiracetam Actavis 1000 mg',
        'Rivoleve 200 mg',
        'ZZZ',
        'Keppra 210 mg',
        'Keppra OutOfTrade 200 mg',
        'Rivoleve 500 mg',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end
    def test_sort_result_evidentia_default_Keppra
      setup_evidentia_trademark('Keppra')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Keppra 250 mg', # has sl_entry and is not out_of_trade
        'Keppra 210 mg', # has no sl_entry and should come after Keppra 250 mg
        'Levetiracetam Desitin 1000 mg',
        'Levetiracetam Actavis 1000 mg',
        'Rivoleve 200 mg',
        'ZZZ',
        'Keppra OutOfTrade 200 mg', # is out of trade and must come after the other Keppra
        'Rivoleve 500 mg',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def test_sort_result_evidentia_default_Keppra_first_via_Levetiracetam
      setup_evidentia_trademark('Levetiracetam')
      @sort    = ODDB::StubResultSort.new(@tm_products)
      res = @sort.sort_result(@tm_products, @session)
      expected_names =  [
        'Keppra 250 mg', # has sl_entry and is not out_of_trade
        'Levetiracetam Desitin 1000 mg',
        'Levetiracetam Actavis 1000 mg',
        'Rivoleve 200 mg',
        'ZZZ',
        'Keppra 210 mg', # has no sl_entry and should come after ZZZ
        'Keppra OutOfTrade 200 mg', # is out of trade and must come after the other Keppra
        'Rivoleve 500 mg',
      ]
      assert_equal(expected_names, res.collect{|pack| pack.name_base})
    end

    def setup_evidentia_avalox(lnf = nil)
      if lnf
        @session.should_receive(:flavor).and_return(@evidentia)
        @component = LookandfeelBase.new(@session)
        @evidentia = LookandfeelEvidentia.new(@component)
        @session.should_receive(:flavor).and_return(@evidentia)
        @session.should_receive(:lookandfeel).and_return(@evidentia)
      end
      @gal_avalox = flexmock('gal_avalox')
      @gal_avalox.should_receive(:collect).by_default.and_return(['gal_avalox'])
      @sl_entry_valid = flexmock('sl_entry_valid')
      @sl_entry_valid.should_receive(:odba_instance).by_default.and_return(nil)
      @sl_entry_valid.should_receive(:valid_until).by_default.and_return(Date.today + 1)
      gal_z = flexmock('gal_z')
      gal_z.should_receive(:collect).by_default.and_return(['gal_z'])
      @tablette = create_default_product_mock('Avalox', false, :original, :original, @gal_avalox)
      @tablette.should_receive(:sl_entry).and_return(@sl_entry_valid)
      @tablette.should_receive(:iksnr).and_return('55213')
      @tablette.should_receive(:expired?).and_return(false)
      @tablette.should_receive(:seqnr).and_return('01')

      @infusion = create_default_product_mock('Avalox', false, nil, :generic, @gal_avalox)
      @infusion.should_receive(:sl_entry).and_return(@sl_entry_valid)
      @infusion.should_receive(:iksnr).and_return('58257')
      @infusion.should_receive(:seqnr).and_return('01')
      @infusion.should_receive(:expired?).and_return(false)
      @avalox_products  = [@infusion, @tablette]
    end

    def test_evidentia_avalox
      setup_evidentia_avalox(true)
      @sort    = ODDB::StubResultSort.new(@avalox_products)
      @session.should_receive(:request_path).and_return("/de/evidentia/search/zone/drugs/search_query/Avalox/search_type/st_combined")
      res = @sort.sort_result(@avalox_products, @session)
      expected_iksnr = [55213, 58257]
      assert_equal(expected_iksnr, res.collect{|pack| pack.iksnr.to_i})
    end

    def test_gcc_avalox
      setup_evidentia_avalox(false)
      @sort    = ODDB::StubResultSort.new(@avalox_products)
      @session.should_receive(:request_path).and_return("/de/gcc/search/zone/drugs/search_query/Avalox/search_type/st_combined")
      res = @sort.sort_result(@avalox_products, @session)
      expected_iksnr = [55213, 58257]
      assert_equal(expected_iksnr, res.collect{|pack| pack.iksnr.to_i})
    end

    def setup_evidentia_torimat(lnf = nil)
      def create_topo(lnf, value)
        if lnf
          @session.should_receive(:flavor).and_return(@evidentia)
          @component = LookandfeelBase.new(@session)
          @evidentia = LookandfeelEvidentia.new(@component)
          @session.should_receive(:flavor).and_return(@evidentia)
          @session.should_receive(:lookandfeel).and_return(@evidentia)
        end
        @gal_avalox = flexmock('gal_avalox')
        @gal_avalox.should_receive(:collect).by_default.and_return(['gal_avalox'])
        @sl_entry_valid = flexmock('sl_entry_valid')
        @sl_entry_valid.should_receive(:odba_instance).by_default.and_return(nil)
        @sl_entry_valid.should_receive(:valid_until).by_default.and_return(Date.today + 1)
        gal_z = flexmock('gal_z')
        gal_z.should_receive(:collect).by_default.and_return(['gal_z'])
        name = "Torimat Desitin #{value} mg"
        product = create_default_product_mock(name, false, :original, :original, @gal_avalox)
        product.should_receive(:sl_entry).and_return(@sl_entry_valid)
        product.should_receive(:iksnr).and_return('53537')
        product.should_receive(:expired?).and_return(false)
        product.should_receive(:seqnr).and_return('01')
        product.should_receive(:dose).and_return(Quanty.new(value, 'mg'))
        product
      end
      @torimat_products  = [create_topo(lnf, 200), create_topo(lnf, 100),create_topo(lnf, 50), create_topo(lnf, 25)]
      @torimat_expected =["Torimat Desitin 25 mg", "Torimat Desitin 50 mg", "Torimat Desitin 100 mg", "Torimat Desitin 200 mg"]

    end

    def test_dose_desitin_1
      setup_evidentia_torimat(true)
      @sort    = ODDB::StubResultSort.new(@avalox_products)
      @session.should_receive(:request_path).and_return("/de/evidentia/search/zone/drugs/search_query/Torimat/search_type/st_combined")
      res = @sort.sort_result(@torimat_products, @session)
      assert_equal(@torimat_expected, res.collect{|pack| pack.name})
    end
    def test_dose_desitin_2
      setup_evidentia_torimat(false)
      @sort    = ODDB::StubResultSort.new(@avalox_products)
      @session.should_receive(:request_path).and_return("/de/gcc/search/zone/drugs/search_query/Torimat/search_type/st_combined")
      res = @sort.sort_result(@torimat_products, @session)
      assert_equal(@torimat_expected, res.collect{|pack| pack.name})
    end
  end
end # ODDB

