#!/usr/bin/env ruby
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/odba'
require 'plugin/refdata_partner'
require 'tempfile'
begin require 'pry'; rescue => LoadError; end

# stub Address2
module ODDB
  class Address2
    def initialize
      return {}
    end
  end
end
module ODDB
  module Companies
    class RefdataPartnerPlugin < Plugin
      puts "Suppressed logging in RefdataPartnerPlugin via #{__FILE__} #{__LINE__}"

      def log(msg)
        # puts msg
      end
    end
  end
end
class TestCompanyPlugin <Minitest::Test
  Test_Companies_XML = File.expand_path(File.join(__FILE__, '../../data/xml/partners.xml'))
  def teardown
    ODBA.storage = nil
    super # to clean up FlexMock
  end
  NR_SKIPPED = 3
  def setup
    FileUtils.rm_f(ODDB::Companies::Companies_XML)
    @config  = flexmock('config',
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @config  = flexmock('config')
    @company = flexmock('company', :pointer => 'pointer',
                        :name => 'name',
                        :business_area= => 'business_area',
                        :odba_isolated_store => 'odba_isolated_store',
                        :oid => 'oid',
                        :narcotics= => 'narcotics',
                        :odba_store => 'odba_store',
                        :name => 'name',
                        :business_area => 'business_area',
                        :narcotics => 'narcotics',
                       )
    @company = flexmock('bb company', ODDB::Company.new,
                        :ean13= => 'ean13',
                        :pointer => 'pointer',
                        :name => 'name',
                        :business_area => 'business_area',
                        :narcotics => 'narcotics',
                        :odba_isolated_store => 'odba_isolated_store',
                        :oid => 'oid',
                        :odba_store => 'odba_store',
                       )
    @company.should_receive(:addresses).and_return([]).by_default
    @company.should_receive(:addresses=).and_return([]).by_default
    @company.should_receive(:name=).and_return(nil).by_default
    @company.should_receive(:narcotics=).and_return(nil).by_default
    @company.should_receive(:business_area=).and_return(nil).by_default
    @app     = flexmock('app',
              :config => @config,
              :create_company => @company,
              :companies => [@company],
              :company_by_origin => @company,
              :update           => 'update',
            )
    @app.should_receive(:company_by_gln).and_return(nil).by_default
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataPartnerPlugin.new(@app))
  end

  def test_update_7601001396371
    gln_linden = 7601001396371
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataPartnerPlugin.new(@app, [gln_linden]))
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XML])
    flexmock(@plugin, :get_company_data => {})
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(3, created)
    assert_equal(0, updated)
    assert_equal(0, deleted)
    assert_equal(NR_SKIPPED, skipped)
    linden = ODDB::Companies::RefdataPartnerPlugin.all_partners.find {|x| x['GLN'].to_i == gln_linden }
    assert_equal(linden[:business_area], ODDB::BA_type::BA_public_pharmacy)
    addresses = linden[:addresses]
    assert_equal(1, addresses.size)
    first_address = addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_nil(first_address.fon)
    assert_equal('5102 Rupperswil', first_address.location)
    assert_equal('5102', first_address.plz)
    assert_equal('Rupperswil', first_address.city)
    assert_equal('4', first_address.number)
    assert_equal('Mitteldorf', first_address.street)
    assert_nil(first_address.additional_lines)
    assert_equal('AB Lindenapotheke AG', first_address.name)
    assert_equal(linden[:narcotics], '6011 Verzeichnis a/b/c BetmVV-EDI')
  end

  def test_update_7601001397835
    gln_sandoz = 7601001397835
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataPartnerPlugin.new(@app, [gln_sandoz]))
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XML])
    flexmock(@plugin, :get_company_data => {})
    created, updated, deleted, skipped = @plugin.update
    sandoz = ODDB::Companies::RefdataPartnerPlugin.all_partners.find {|x| x['GLN'].to_i == gln_sandoz }
    assert_equal(sandoz[:business_area], ODDB::BA_type::BA_pharma)
    addresses = sandoz[:addresses]
    assert_equal(1, addresses.size)
    first_address = addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_nil(first_address.fon)
    assert_equal('4056 Basel', first_address.location)
    assert_equal('4056', first_address.plz)
    assert_equal('Basel', first_address.city)
    assert_equal('35', first_address.number)
    assert_equal('Lichtstrasse', first_address.street)
    assert_nil(first_address.additional_lines)
    assert_equal('Sandoz AG', first_address.name)
    assert_nil(sandoz[:narcotics])
  end

  def test_update_must_keep_telefon_and_fax
    gln_sandoz = 7601001397835
    fon_sandoz = '077 123 45 67'
    fax_sandoz = '077 123 45 99'
    sandoz = flexmock('sandoz', :oid => 'oid')
    old_address = ODDB::Address2.new
    old_address.name    =  'Sandoz must be changed'
    old_address.address =  'must be changed 3555'
    old_address.location = '333 must be changed'
    old_address.fon = [fon_sandoz]
    old_address.fax = [fax_sandoz]
    @company.should_receive(:addresses).and_return([old_address])
    @app.should_receive(:company_by_gln).with("7601001372689" ).and_return([sandoz])
    @app.should_receive(:company_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_company).with('oid').never
    @plugin = flexmock('refdata_partner_plugin', ODDB::Companies::RefdataPartnerPlugin.new(@app, [gln_sandoz]))
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XML])
    flexmock(@plugin, :get_company_data => {})
    created, updated, deleted, skipped = @plugin.update
    sandoz = ODDB::Companies::RefdataPartnerPlugin.all_partners.find {|x| x['GLN'].to_i == gln_sandoz }
    assert_equal(sandoz[:business_area], ODDB::BA_type::BA_pharma)
    addresses = sandoz[:addresses]
    assert_equal(1, addresses.size)
    first_address = addresses.first
    assert_equal(ODDB::Address2, first_address.class)
    assert_equal('Sandoz AG', first_address.name)
    assert_equal('4056 Basel', first_address.location)
    assert_equal('4056', first_address.plz)
    assert_equal('Basel', first_address.city)
    assert_equal('35', first_address.number)
    assert_equal([fax_sandoz], first_address.fax)
    assert_equal([fon_sandoz], first_address.fon)
    assert_equal('Lichtstrasse', first_address.street)
    assert_nil(first_address.additional_lines)
    assert_nil(sandoz[:narcotics])
  end

  def test_update_all
    globofarm = flexmock('globofarm', :oid => 'oid')
    @app.should_receive(:company_by_gln).with("7601001372689" ).and_return(globofarm)
    @app.should_receive(:company_by_gln).with(any).and_return(nil)
    @app.should_receive(:delete_company).with('oid').never
    @plugin = ODDB::Companies::RefdataPartnerPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XML])
    flexmock(@plugin, :get_company_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(4, created)
    assert_equal(0, updated)
    assert_equal(1, deleted)
    assert_equal(NR_SKIPPED, skipped) # 1 inactive, 1 not Pharm
  end

  def test_get_latest_file
    current  = File.expand_path(File.join(__FILE__, "../../../data/xml/partners_#{Time.now.strftime('%Y.%m.%d')}.xml"))
    FileUtils.rm_f(current) if File.exists?(current)
    @plugin = ODDB::Companies::RefdataPartnerPlugin.new(@app)
    res = @plugin.get_latest_file
    assert(res[0], 'needs_update must be true')
    assert(res[1].match(/latest/), 'filename must match latest')
    assert(File.exists?(res[1]), 'companies_latest.xml must exist')
    assert(File.size(Test_Companies_XML) <File.size(res[1]))
  end
end
