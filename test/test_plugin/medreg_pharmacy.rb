#!/usr/bin/env ruby
# encoding: utf-8
# TestCompanyPlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestCompanyPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/odba'
require 'plugin/medreg_pharmacy'
require 'tempfile'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = nil

# stub Address2
module ODDB
  class Address2
    def initialize
      return {}
    end
  end
end
class TestCompanyPlugin <Minitest::Test
  Test_Companies_XLSX = File.expand_path(File.join(__FILE__, '../../data/xlsx/companies_20141014.xlsx'))
  def teardown
    ODBA.storage = nil
    super # to clean up FlexMock
  end
  def setup
    @config  = flexmock('config',
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @config  = flexmock('config')
    @company = flexmock('company', :pointer => 'pointer',
                        :ean13= => 'ean13',
                        :name= => 'name',
                        :addresses= => 'addresses',
                        :business_area= => 'business_area',
                        :odba_isolated_store => 'odba_isolated_store',
                        :oid => 'oid',
                        :narcotics= => 'narcotics',
                        :odba_store => 'odba_store',
                       )
    @app     = flexmock('appX',
              :config => @config,
              :create_company => @company,
              :companies => [@company],
              :company_by_gln => nil,
              :company_by_origin => @company,
              :update           => 'update',
            )
    @plugin = ODDB::Companies::MedregPharmacyPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XLSX])
  end

  def test_update_7601002026444
    @plugin = ODDB::Companies::MedregPharmacyPlugin.new(@app, [7601001396371])
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XLSX])
    flexmock(@plugin, :get_company_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    csv_file = ODDB::Companies::Companies_YAML
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(1, created)
    assert_equal(0, updated)
    assert_equal(0, deleted)
    assert_equal(0, skipped)
    assert_equal(1, ODDB::Companies::MedregPharmacyPlugin.all_companies.size)
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
    linden = ODDB::Companies::MedregPharmacyPlugin.all_companies.first
    addresses = linden[:addresses]
    assert_equal(1, addresses.size)
    first_address = addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal(nil, first_address.fon)
    assert_equal('5102 Rupperswil', first_address.location)
    assert_equal('öffentliche Apotheke', linden[:ba_type])
    assert_equal('5102', first_address.plz)
    assert_equal('Rupperswil', first_address.city)
    assert_equal('4', first_address.number)
    assert_equal('Mitteldorf', first_address.street)
    assert_equal(nil, first_address.additional_lines)
    assert_equal('AB Lindenapotheke AG', first_address.name)
    inhalt = IO.read(csv_file)
    assert(inhalt.index('6011 Verzeichnis a/b/c BetmVV-EDI') > 0, 'must find btm')
#	7601001396371	AB Lindenapotheke AG		Mitteldorf	4	5102	Rupperswil	Aargau	Schweiz	öffentliche Apotheke	6011 Verzeichnis a/b/c BetmVV-EDI
  end
  def test_update_all
    @plugin = ODDB::Companies::MedregPharmacyPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XLSX])
    flexmock(@plugin, :get_company_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    csv_file = ODDB::Companies::Companies_YAML
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(3, created)
    assert_equal(0, updated)
    assert_equal(0, deleted)
    assert_equal(1, skipped)
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
  end

  def test_get_latest_file
    current  = File.expand_path(File.join(__FILE__, "../../../data/xls/companies_#{Time.now.strftime('%Y.%m.%d')}.xlsx"))
    FileUtils.rm_f(current) if File.exists?(current)
    @plugin = ODDB::Companies::MedregPharmacyPlugin.new(@app)
    res = @plugin.get_latest_file
    assert(res[0], 'needs_update must be true')
    assert(res[1].match(/latest/), 'filename must match latest')
    assert(File.exists?(res[1]), 'companies_latest.xls must exist')
    assert(File.size(Test_Companies_XLSX) <File.size(res[1]))
  end
end
