#!/usr/bin/env ruby
# encoding: utf-8
# TestDoctorPlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestDoctorPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'stub/odba'
require 'flexmock'
require 'plugin/medreg_doctor'
require 'tempfile'
require 'ostruct'

Minitest::Test.i_suck_and_my_tests_are_order_dependent!()

class TestDoctorPlugin <Minitest::Test
  include FlexMock::TestCase
  Test_Personen_XLSX = File.expand_path(File.join(__FILE__, '../../data/xlsx/Personen_20141014.xlsx'))
  def setup
    @config = flexmock('config')
    @doctor = flexmock('doctor', :pointer => 'pointer', :oid => 'oid')
    @app    = flexmock('app',
              :config => @config,
             :doctors => [@doctor],
             :create_doctor => @doctor,
             :doctor_by_gln => nil,
             :doctor_by_origin => @doctor,
             :update           => 'update'
            )
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app)
    flexmock(@plugin, :get_latest=> Test_Personen_XLSX)
  end

  SomeTestCases = {
    7601000010735 => OpenStruct.new(:family_name => 'Cevey',        :first_name => 'Philippe Marc', :authority  => 'Waadt'),
    7601000813282 => OpenStruct.new(:family_name => 'ABANTO PAYER', :first_name => 'Dora Carmela',  :authority  => 'Waadt'),
  }

  # Anita Hensel 7601000972620
  def test_aaa_zuest # name starts with aaa we want this test to be run as first
    {  7601000254207 => OpenStruct.new(:family_name => 'Züst', :first_name => 'Peter', :authority  => 'Glarus')}.each do
      |gln, info|
      @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [gln])
      flexmock(@plugin, :get_latest_file => [ true, Test_Personen_XLSX ] )
      flexmock(@plugin, :get_doctor_data => {})
      assert(File.exists?(Test_Personen_XLSX))
      startTime = Time.now
      csv_file = ODDB::Doctors::Personen_YAML
      FileUtils.rm_f(csv_file) if File.exists?(csv_file)
      created, updated, deleted, skipped = @plugin.update
      diffTime = (Time.now - startTime).to_i
      assert_equal(0, deleted)
      assert_equal(0, skipped)
      assert_equal(1, created)
      assert_equal(0, updated)
      assert_equal(1, ODDB::Doctors::MedregDoctorPlugin.all_doctors.size)
      zuest = ODDB::Doctors::MedregDoctorPlugin.all_doctors.first[1] # a hash
      assert_equal(true, zuest[:may_dispense_narcotics])
      assert_equal(true, zuest[:may_sell_drugs])
      assert_equal(nil, zuest[:remark_sell_drugs])
      assert_equal(1992, zuest[:exam])
      assert_equal('Züst', zuest[:name])
      assert_equal('Peter', zuest[:firstname])
      assert_equal([["Allgemeine Innere Medizin",2003,"Schweiz"]], zuest[:specialities])
      [ ["Sportmedizin",2004,"Schweiz"],
        ["Praxislabor",2002,"Schweiz"],
        ["Sachkunde für dosisintensives Röntgen",2004,"Schweiz"],
      ].each {
        |cap|
          assert(zuest[:capabilities].index(cap), "Muss Erfahrung #{cap} fuer Züst finden")
      }
      addresses = zuest[:addresses]
      assert_equal(1, addresses.size)
      first_address = addresses.first
      assert_equal(1, first_address.fon.size)
      assert_equal('055 6122353', first_address.fon.first)
#      require 'pry'; binding.pry
    end
  end

  def test_parse
    SomeTestCases.each{
      |gln, info|
      info.gln = gln
      root = File.expand_path(File.join(__FILE__, "../.."))
      @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [gln])
      html_file = "#{root}/data/html/medreg/#{gln}.html"
      assert(File.exist?(html_file), "File \#{html_file} must exist")
      doc_hash = @plugin.parse_details(Nokogiri::HTML(File.read(html_file)),
                                      gln,
                                      info,
                                      )
      assert(doc_hash.is_a?(Hash), 'doc_hash must be a Hash')
      assert(doc_hash[:addresses], 'doc_hash must have addresses')
      assert(doc_hash[:addresses].size > 0, 'doc_hash must have at least one address')
    }
  end

  def test_update_single
    SomeTestCases.each{
      |gln, info|
      @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [gln])
      flexmock(@plugin, :get_latest_file => [ true, Test_Personen_XLSX ] )
      flexmock(@plugin, :get_doctor_data => {})
      assert(File.exists?(Test_Personen_XLSX))
      startTime = Time.now
      csv_file = ODDB::Doctors::Personen_YAML
      FileUtils.rm_f(csv_file) if File.exists?(csv_file)
      created, updated, deleted, skipped = @plugin.update
      diffTime = (Time.now - startTime).to_i
      assert_equal(0, deleted)
      assert_equal(0, skipped)
      assert_equal(1, created)
      assert_equal(0, updated)
      assert(File.exists?(csv_file), "file #{csv_file} must be created")
      expected = "Doctors update \n\nNumber of doctors: 1\nSkipped doctors: 0\nNew doctors: 1\nUpdated doctors: 0\nDeleted doctors: 0\n"
      assert_equal(expected, @plugin.report)
    }
  end

  def test_update_some_glns
    glns_ids_to_search = [7601000078261, 7601000813282, 7601000254207, 7601000186874, 7601000201522, 7601000295958,
                          7601000010735, 7601000268969, 7601000019080, 7601000239730 ]
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, glns_ids_to_search)

    flexmock(@plugin, :get_latest_file => [ true, Test_Personen_XLSX ] )
    flexmock(@plugin, :get_doctor_data => {})
    assert(File.exists?(Test_Personen_XLSX))
    startTime = Time.now
    csv_file = ODDB::Doctors::Personen_YAML
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    assert_equal(0, deleted)
    assert_equal(0, skipped)
    assert_equal(0, updated)
    assert_equal(glns_ids_to_search.size - 1 , created) # we have one gln_id mentioned twice
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
  end

  def test_zzz_get_latest_file # name starts with zzz we want this test to be run as last one (takes longest)
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [7601000813282])
    needs_update, latest = @plugin.get_latest_file
  end if false
end