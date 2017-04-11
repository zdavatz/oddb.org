#!/usr/bin/env ruby
$: << File.expand_path('../../src', File.dirname(__FILE__))
require 'minitest/autorun'
require 'flexmock/minitest'
require 'plugin/shortage'

module ODDB
  class TestShortagePluginWithFile <Minitest::Test
    TestGtinShortage      = '7680623550019' #  ACETALGIN Filmtabl 1 g 16 Stk
    TestGtinNoShortage    = '7680490590999'
    TestGtinNeverShortage = '7680490590777'
    def add_mock_package(name, gtin)
      pack= flexmock(name)
      PackageCommon::Shortage_fields.each do |item|
        pack.should_receive(item).and_return(item.to_s).by_default
      end
      pack.should_receive(:barcode).and_return(gtin).by_default
      pack.should_receive(:no_longer_in_shortage_list).and_return(true)
      pack.should_receive(:update_shortage_list).and_return(true)
      @app.should_receive(:package_by_ean13).with(gtin).and_return(pack)
      pack
    end
    def setup
      @@today = Date.new(2014,5,1)
      @app = flexmock('app')
      # @app.should_receive(:delete).by_default
      path = File.expand_path('../../data/html/drugshortage*.html', File.dirname(__FILE__))
      FileUtils.rm_f(Dir.glob(path))
      @app.should_receive(:find).and_return(TestGtinShortage)
      @app.should_receive(:iksnr).and_return(TestGtinShortage)
      file_name = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'html', 'drugshortage.html'))
      assert(File.exist?(file_name))
      @html = File.read(file_name)
      @package_no_changes = add_mock_package('package_no_changes', '7680519690140')
      @package_no_changes.should_receive(:shortage_state).and_return('aktuell keine Lieferungen')
      @package_no_changes.should_receive(:shortage_last_update).and_return('2017-01-13')
      @package_no_changes.should_receive(:shortage_delivery_date).and_return('offen')
      @package_no_changes.should_receive(:shortage_url).and_return('https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2786')
      @package_never_in_short = add_mock_package('package_never_in_short', TestGtinNeverShortage)
      @package_deleted_in_short = add_mock_package('package_deleted_in_short', TestGtinNoShortage)
      @package_new_in_short = add_mock_package('package_never_in_short', TestGtinShortage)
      @app.should_receive(:packages).and_return([@package_never_in_short, @package_deleted_in_short, @package_new_in_short])
      @agent    = flexmock('agent', Mechanize.new)
      @agent.should_receive(:get).with(ShortagePlugin::SOURCE_URI).and_return @html
      @plugin = ShortagePlugin.new @app
    end
    def test_report_with_test_file
      @plugin.update(@agent)
      @app.flexmock_verify
      expected = %(Found               2 shortages in https://www.drugshortage.ch/UebersichtaktuelleLieferengpaesse2.aspx
Deleted           2 shortages
Changed           1 shortages
Update job took   0 seconds
GTIN of concerned packages is
7680623550019
Changes were:
7680623550019 shortage_state: shortage_state => aktuell keine Lieferungen
              shortage_last_update: shortage_last_update => 2017-02-24
              shortage_delivery_date: shortage_delivery_date => offen
              shortage_url: shortage_url => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934)
      assert_equal(expected, @plugin.report)
    end
    def test_changes_with_test_file
      @plugin.update(@agent)
      expected = {"7680623550019"=>["shortage_state: shortage_state => aktuell keine Lieferungen",
                                    "shortage_last_update: shortage_last_update => 2017-02-24",
                                    "shortage_delivery_date: shortage_delivery_date => offen",
                                    "shortage_url: shortage_url => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934"
                                   ]}
      assert_equal(expected , @plugin.changes)
    end
  end
end
