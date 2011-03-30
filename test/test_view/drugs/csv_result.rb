#!/usr/bin/env ruby
# ODDB::View::Drugs::TestCsvResult -- oddb.org -- 31.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/csv_result'

class TestCsvResult < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel', :lookup => 'lookup')
    @session     = flexmock('session', :lookandfeel => @lookandfeel)
    @model       = flexmock('model')
    @result      = ODDB::View::Drugs::CsvResult.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @result.init)
  end
  def test_boolean
    assert_equal('lookup', @result.boolean('bool'))
  end
  def test_bsv_dossier
    sl_entry = flexmock('sl_entry', :bsv_dossier => 'bsv_dossier')
    package  = flexmock('package', :sl_entry => sl_entry)
    assert_equal('bsv_dossier', @result.bsv_dossier(package))
  end
  def test_bsv_dossier__error
    sl_entry = flexmock('sl_entry') do |s|
      s.should_receive(:bsv_dossier).and_raise(StandardError)
    end
    package  = flexmock('package', 
                        :sl_entry => sl_entry,
                        :barcode  => 'barcode'
                       )
    assert_raise(RuntimeError) do 
      @result.bsv_dossier(package)
    end
  end
  def test_casrn
    narcotic = flexmock('narcotic', :casrn => 'casrn')
    package  = flexmock('package', :narcotics => [narcotic])
    assert_equal('casrn', @result.casrn(package))
  end
  def test_c_type
    package = flexmock('package', :complementary_type => 'anthroposophy')
    assert_equal('lookup', @result.c_type(package))
    assert_equal(1, @result.instance_eval('@counts["anthroposophy"]'))
  end
  def test_c_type__error
    package = flexmock('package', :complementary_type => 'ctype')
    assert_raise(NoMethodError) do 
      @result.c_type(package)
    end
  end
  def test_ddd_dose
    ddd = flexmock('ddd', :dose => 'dose')
    flexmock(@model, :ddd => ddd)
    assert_equal('dose', @result.ddd_dose(@model, @session))
  end
  def test_deductible
    package = flexmock('package', 
                       :sl_entry => 'sl_entry',
                       :deductible => nil
                      )
    assert_equal('lookup', @result.deductible(package))
  end
  def test_formatted_date
    package = flexmock('package', :anthroposophy => 'date')
    flexmock(@lookandfeel, :format_date => 'format_date')
    assert_equal('format_date', @result.formatted_date(package, :anthroposophy))
  end
  def test_expiration_date
    package = flexmock('package', :expiration_date => 'date')
    flexmock(@lookandfeel, :format_date => 'format_date')
    assert_equal('format_date', @result.expiration_date(package))
  end
  def test_export_flag
    package = flexmock('package', :export_flag => 'export_flag')
    assert_equal('export_flag', @result.export_flag(package))
  end
  def test_galenic_form
    flexmock(@lookandfeel, :language => 'language')
    galenic_form = flexmock('galenic_form', :description => 'description')
    package = flexmock('package', :galenic_forms => [galenic_form])
    assert_equal('description', @result.galenic_form(package))
  end
  def test_galenic_form_de
    galenic_form = flexmock('galenic_form', :description => 'description')
    package = flexmock('package', :galenic_forms => [galenic_form])
    assert_equal('description', @result.galenic_form_de(package))
  end
  def test_galenic_form_fr
    galenic_form = flexmock('galenic_form', :description => 'description')
    package = flexmock('package', :galenic_forms => [galenic_form])
    assert_equal('description', @result.galenic_form_fr(package))
  end
  def test_galenic_group
    galenic_group = flexmock('galenic_group', :description => 'description')
    package = flexmock('package', :galenic_group => galenic_group)
    assert_equal('description', @result.galenic_group(package, 'language'))
  end
  def test_galenic_group_de
    galenic_group = flexmock('galenic_group', :description => 'description')
    package = flexmock('package', :galenic_group => galenic_group)
    assert_equal('description', @result.galenic_group_de(package))
  end
  def test_galenic_group_fr
    galenic_group = flexmock('galenic_group', :description => 'description')
    package = flexmock('package', :galenic_group => galenic_group)
    assert_equal('description', @result.galenic_group_fr(package))
  end
  def test_has_generic
    package = flexmock('package', :has_generic? => true)
    assert_equal('lookup', @result.has_generic(package))
  end
  def test_http_headers
    flexmock(@lookandfeel, :_event_url => 'url')
    flexmock(@session, :user_input => nil)
    flexmock(@model, 
             :search_query => 'query',
             :search_type  => nil
            )
    expected = {"Content-Disposition"=>"attachment;filename=query.lookup.csv",
               "Content-Type"=>"text/csv"}
    assert_equal(expected, @result.http_headers)
  end
  def test_inactive_date
    package = flexmock('package', :inactive_date => 'date')
    flexmock(@lookandfeel, :format_date => 'format_date')
    assert_equal('format_date', @result.inactive_date(package))
  end
  def test_introduction_date
    flexmock(@lookandfeel, :format_date => 'format_date')
    sl_entry = flexmock('sl_entry', :introduction_date => 'date')
    package  = flexmock('package', :sl_entry => sl_entry)
    assert_equal('format_date', @result.introduction_date(package))
  end
  def test_limitation
    sl_entry = flexmock('sl_entry', :limitation => 'limitation')
    package  = flexmock('package', :sl_entry => sl_entry)
    assert_equal('lookup', @result.limitation(package))
  end
  def test_limitation_points
    sl_entry = flexmock('sl_entry', 
                        :limitation_points => 1,
                        :limitation_text   => 'text'
                       )
    package  = flexmock('package', :sl_entry => sl_entry)
    assert_equal(1, @result.limitation_points(package))
  end
  def test_limitation_text
    flexmock(@lookandfeel, :language => 'language')
    text     = flexmock('text', :language => "aaa\nbbb\nccc\n")
    sl_entry = flexmock('sl_entry', :limitation_text => text)
    package  = flexmock('package', :sl_entry => sl_entry)
    expected = "aaa|bbb|ccc|"
    assert_equal(expected, @result.limitation_text(package))
  end
  def test_lppv
    package = flexmock('package', :lppv => 'lppv')
    assert_equal('lookup', @result.lppv(package))
  end
  def test_narcotic
    package = flexmock('package', :narcotic? => true)
    assert_equal('lookup', @result.narcotic(package))
  end
  def test_numerical_size
    package = flexmock('package', :"comparable_size.qty" => 0)
    assert_equal(0, @result.numerical_size(package))
  end
  def test_numerical_size_extended
    group   = flexmock('group', :de => 'Brausetabletten')
    package = flexmock('package', 
                       :galenic_group => group, 
                       :"comparable_size.qty" => 123
                      )
    assert_equal(123, @result.numerical_size_extended(package))
  end
  def test_numerical_size_extended__else
    group   = flexmock('group', :de => 'hogehoge')
    package = flexmock('package', 
                       :galenic_group => group, 
                       :"comparable_size.qty" => 0
                      )
    assert_equal(0, @result.numerical_size_extended(package))
  end
  def test_out_of_trade
    package = flexmock('package', :public? => false)
    assert_equal('lookup', @result.out_of_trade(package))
  end
  def test_price_exfactory
    flexmock(@lookandfeel) do |l|
      l.should_receive(:format_price).once.with(123).and_return(123)
    end
    package = flexmock('package', :price_exfactory => 123)
    assert_equal(123, @result.price_exfactory(package))
  end
  def test_price_public
    flexmock(@lookandfeel) do |l|
      l.should_receive(:format_price).once.with(123).and_return(123)
    end
    package = flexmock('package', :price_public => 123)
    assert_equal(123, @result.price_public(package))
  end
  def test_rectype
    assert_equal('#Medi', @result.rectype('package'))
  end
  def test_registration_date
    package = flexmock('package', :registration_date => 'date')
    flexmock(@lookandfeel, :format_date => 'format_date')
    assert_equal('format_date', @result.registration_date(package))
  end
  def test_route_of_administration
    package = flexmock('package', :route_of_administration => 'roa_route_of_administration')
    assert_equal('route_of_administration', @result.route_of_administration(package))
  end
  def test_sl_entry
    package = flexmock('package', :sl_entry => 'sl_entry')
    assert_equal('lookup', @result.sl_entry(package))
  end
  def test_renewal_flag
    package = flexmock('package', :renewal_flag => 'renewal_flag')
    assert_equal('lookup', @result.renewal_flag(package))
  end
  def test_size
    flexmock(@session, :language => 'language')
    commercial_form = flexmock('commercial_form', :language => 'language')
    part = flexmock('part', 
                    :multi   => 123,
                    :count   => 456,
                    :measure => 0,
                    :commercial_form => commercial_form
                   )
    flexmock(@model, :parts => [part])
    expected = "123 x 456 language à 0"
    assert_equal(expected, @result.size(@model, @session))
  end
  def test_generic_type__original
    package = flexmock('package', :sl_generic_type => :original)
    assert_equal('O', @result.generic_type(package))
  end
  def test_generic_type__generic
    package = flexmock('package', :sl_generic_type => :generic)
    assert_equal('G', @result.generic_type(package))
  end
  def test_vaccine
    package = flexmock('package', :vaccine => true)
    assert_equal('lookup', @result.vaccine(package))
  end
  def test_to_csv
    flexmock(@lookandfeel, :language => 'language')
    package = flexmock('package',
                   :ikskey           => 'ikskey',
                   :key1             => 'key1'
                      )
    atc = flexmock('atc', 
                   :code              => 'code',
                   :active_packages   => [package],
                   :description       => 'description'
                  )
    flexmock(@model) do |m|
      m.should_receive(:each).and_yield(atc)
    end
    expected = "lookup;lookup\n#MGrp;code;description\nkey1;key2"
    flexmock(@result, :key2 => 'key2') 
    keys = ['key1', 'key2']
    assert_equal(expected, @result.to_csv(keys))
  end
  def test_to_html
    flexmock(@lookandfeel, 
             :language     => 'language',
             :format_price => 'format_price',
             :format_date  => 'format_date'
            )
    flexmock(@session, :language => 'language')
    galenic_form    = flexmock('galenic_form', :description => 'desciption')
    commercial_form = flexmock('commercial_form', :language => 'language')
    part    = flexmock('part', 
                       :multi   => 'multi',
                       :count   => 'count',
                       :measure => 'measure',
                       :commercial_form => commercial_form
                      )
    comparable_size = flexmock('comparable_size', :qty => 'qty')
    narcotic = flexmock('narcotic', :casrn => 'casrn')
    ddd      = flexmock('ddd', :dose => 'dose')
    package  = flexmock('package',
                   :ikskey            => 'ikskey',
                   :rectype           => 'rectype',
                   :barcode           => 'barcode',
                   :name_base         => 'name_base',
                   :galenic_form      => 'galenic_form',
                   :most_precise_dose => 'most_precise_dose',
                   :size              => 'size',
                   :numerical_size    => 'numerical_size',
                   :price_exfactory   => 'price_exfactory',
                   :price_public      => 'price_public',
                   :company_name      => 'company_name',
                   :ikscat            => 'ikscat',
                   :sl_entry          => 'sl_entry',
                   :registration_date => 'registration_date',
                   :casrn             => 'casrn',
                   :ddd_dose          => 'ddd_dose',
                   :ddd_price         => 'ddd_price',
                   :galenic_forms     => [galenic_form],
                   :parts             => [part],
                   :narcotics         => [narcotic],
                   :comparable_size   => comparable_size,
                   :ddd               => ddd
                      )
    atc = flexmock('atc', 
                   :code              => 'code',
                   :active_packages   => [package],
                   :description       => 'description'
                  )
    flexmock(@model) do |m|
      m.should_receive(:each).and_yield(atc)
    end
    expected = "lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup;lookup\n#MGrp;code;description\n#Medi;barcode;name_base;desciption;most_precise_dose;count language à measure;qty;format_price;format_price;company_name;ikscat;lookup;format_date;casrn;dose;ddd_price"
    assert_equal(expected, @result.to_html('context'))
  end
  def test_to_csv_file
    flexmock(@lookandfeel, 
             :language     => 'language',
             :format_price => 'format_price',
             :format_date  => 'format_date'
            )
    flexmock(@session, :language => 'language')
    galenic_form    = flexmock('galenic_form', :description => 'desciption')
    commercial_form = flexmock('commercial_form', :language => 'language')
    part    = flexmock('part', 
                       :multi   => 'multi',
                       :count   => 'count',
                       :measure => 'measure',
                       :commercial_form => commercial_form
                      )
    comparable_size = flexmock('comparable_size', :qty => 'qty')
    narcotic = flexmock('narcotic', :casrn => 'casrn')
    ddd      = flexmock('ddd', :dose => 'dose')
    package  = flexmock('package',
                   :ikskey            => 'ikskey',
                   :rectype           => 'rectype',
                   :barcode           => 'barcode',
                   :name_base         => 'name_base',
                   :galenic_form      => 'galenic_form',
                   :most_precise_dose => 'most_precise_dose',
                   :size              => 'size',
                   :numerical_size    => 'numerical_size',
                   :price_exfactory   => 'price_exfactory',
                   :price_public      => 'price_public',
                   :company_name      => 'company_name',
                   :ikscat            => 'ikscat',
                   :sl_entry          => 'sl_entry',
                   :registration_date => 'registration_date',
                   :casrn             => 'casrn',
                   :ddd_dose          => 'ddd_dose',
                   :ddd_price         => 'ddd_price',
                   :galenic_forms     => [galenic_form],
                   :parts             => [part],
                   :narcotics         => [narcotic],
                   :comparable_size   => comparable_size,
                   :ddd               => ddd
                      )
    atc = flexmock('atc', 
                   :code              => 'code',
                   :active_packages   => [package],
                   :description       => 'description'
                  )
    flexmock(@model) do |m|
      m.should_receive(:each).and_yield(atc)
    end

    flexmock(File, :open => 'open')
    assert_equal('open', @result.to_csv_file('keys', 'path'))
  end
end

