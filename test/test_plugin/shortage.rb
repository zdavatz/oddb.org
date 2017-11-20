#!/usr/bin/env ruby
$: << File.expand_path('../../src', File.dirname(__FILE__))
require 'minitest/autorun'
require 'flexmock/minitest'
require 'plugin/shortage'

module ODDB
  Today = Date.new(2014,5,1)
  class Plugin
    @@today ||= Today
    def self.next_day
      puts "next_day @@today #{@@today}"
      @@today = @@today + 1
      puts "next_day @@today is now #{@@today}"
    end
  end
  class ShortagePlugin < Plugin
    attr_reader :changes_shortages, :deleted_shortages, :found_shortages,
                :nomarketing_href, :latest_shortage, :latest_nomarketing, 
                :csv_file_path, :dated_csv_file_path, :yesterday_csv_file_path
    attr_accessor :duration_in_secs,  :has_relevant_changes
  end
end

module ODDB
  class TestShortagePluginWithFile <Minitest::Test
    # Aus ID=2934">ACETALGIN Filmtabl 1 g 16 Stk 7680623550019
    #     ID=3056">AEROCHAMBER PLUS 762860504332
    #     ID=2786">AGOPTON Kaps 30 680519690140

    TestGtinShortage      = '7680623550019' #  ACETALGIN Filmtabl 1 g 16 Stk
    TestGtinNoShortage    = '7680490590999'
    TestGtinNeverShortage = '7680490590777'
    def get_pack_mock(name = 'pack_mock')
      atc_class = flexmock('atc_class')
      atc_class.should_receive(:code).and_return('atc').by_default
      pack= flexmock(name)
      pack.should_receive(:atc_class).and_return(atc_class).by_default
      pack.should_receive(:nomarketing_date).and_return('nomarketing_date').by_default
      pack.should_receive(:nomarketing_since).and_return('nomarketing_since').by_default
      pack.should_receive(:nodelivery_since).and_return('nodelivery_since').by_default
      pack.should_receive(:nomarketing_link).and_return("nomarketing_link").by_default
      pack.should_receive(:update_nomarketing_list).and_return(true).by_default
      pack.should_receive(:shortage_state).and_return('aktuell keine Lieferungen')
      pack.should_receive(:shortage_delivery_date).and_return('shortage_delivery_date')
      pack.should_receive(:shortage_last_update).and_return('shortage_state')
      pack.should_receive(:shortage_link).and_return('shortage_link')
      pack.should_receive(:update_shortage_list).and_return('update_shortage_list')
      pack.should_receive(:name).and_return(name).by_default
      pack
    end
    def add_mock_package(name, gtin, add_shortage_fields = true)
      pack= flexmock(name)
      if add_shortage_fields
        PackageCommon::Shortage_fields.each do |item|
          pack.should_receive(item).and_return(item.to_s).by_default
        end
      else
        PackageCommon::NoMarketing_fields.each do |item|
          pack.should_receive(item).and_return(item.to_s).by_default
        end
      end
      atc_class = flexmock('atc_class')
      atc_class.should_receive(:code).and_return('atc').by_default
      pack.should_receive(:barcode).and_return(gtin).by_default
      pack.should_receive(:name).and_return('name').by_default
      pack.should_receive(:atc_class).and_return(atc_class).by_default
      pack.should_receive(:no_longer_in_shortage_list).and_return(true).by_default
      pack.should_receive(:update_shortage_list).and_return(true)
      pack.should_receive(:nomarketing_date).and_return('2016-01-01').by_default
      pack.should_receive(:nomarketing_since).and_return('2016-02-01').by_default
      pack.should_receive(:nodelivery_since).and_return('2016-03-01').by_default
      pack.should_receive(:no_longer_in_nomarketing_list).and_return(true).by_default
      pack.should_receive(:update_nomarketing_list).and_return(true).by_default
      @app.should_receive(:package_by_ean13).with(gtin).and_return(pack).by_default
      pack.should_receive(:shortage_last_update).and_return('shortage_last_update').by_default
      pack.should_receive(:shortage_last_update).and_return('shortage_state').by_default
      pack
    end
    def add_mock_registration(iksnr, packages = [])
      reg= flexmock(iksnr.to_s)
      reg.should_receive(:active_packages).and_return(packages).by_default
      @app.should_receive(:registration).with(iksnr.to_s).and_return(reg).by_default
      reg
    end
    def setup
      @@today = Date.new(2014,5,1)
      @app = flexmock('app')
      @app.should_receive(:package_by_ean13).and_return(get_pack_mock).by_default
      @session = flexmock('session')
      @session.should_receive(:flavor).and_return('flavor')
      @session.should_receive(:language).and_return('de')
      @session.should_receive(:default_language).and_return('de')
      @csv_file = File.expand_path(File.join(__FILE__, '../../../data/downloads/drugshortage.csv'))
      FileUtils.rm_f(Dir.glob(@csv_file))
      path = File.expand_path('../../data/html/drugshortage*.html', File.dirname(__FILE__))
      FileUtils.rm_f(Dir.glob(path))
      path = File.expand_path('../../data/xlsx/nomarketing*', File.dirname(__FILE__))
      FileUtils.rm_f(Dir.glob(path))

      @app.should_receive(:find).and_return(TestGtinShortage)
      @app.should_receive(:iksnr).and_return(TestGtinShortage)
      @drugshortage_name = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'html', 'drugshortage.html'))
      assert(File.exist?(@drugshortage_name))
      @html_drugshortage = File.read(@drugshortage_name)

      @drugshortage_changed_name = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'html', 'drugshortage-changed.html'))
      assert(File.exist?(@drugshortage_changed_name))
      @html_drugshortage_changed = File.read(@drugshortage_changed_name)

      @nomarketing_name = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'html', 'swissmedic', 'nomarketing.html'))
      assert(File.exist?(@nomarketing_name))
      @html_nomarketing = File.read(@nomarketing_name)

      @nomarketing_xlsx_name = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'xlsx', 'nomarketing_2017_03_13.xlsx'))
      assert(File.exist?(@nomarketing_xlsx_name))
      @xlxs_nomarketing = File.read(@nomarketing_xlsx_name)
      @reg_47431 = add_mock_registration(62294)
      @reg_62294 = add_mock_registration(62294)
      @reg_49059 = add_mock_registration(49059)
      @reg_59893 = add_mock_registration(59893)
      @app.should_receive(:registration).with('59893').and_return(nil)
      @app.should_receive(:registration).with('62294').and_return(@reg_62294)

      @package_no_changes = add_mock_package('package_no_changes', '7680519690140')
      @package_no_changes.should_receive(:shortage_state).and_return('aktuell keine Lieferungen')
      @package_no_changes.should_receive(:shortage_last_update).and_return('2017-01-13')
      @package_no_changes.should_receive(:shortage_delivery_date).and_return('offen')
      @package_no_changes.should_receive(:shortage_link).and_return('https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2786')
      @package_never_in_short = add_mock_package('package_never_in_short', TestGtinNeverShortage)
      @package_deleted_in_short = add_mock_package('package_deleted_in_short', TestGtinNoShortage)
      @package_new_in_short = add_mock_package('package_never_in_short', TestGtinShortage)
      @app.should_receive(:active_packages).and_return([@package_never_in_short, @package_deleted_in_short, @package_new_in_short]).by_default
      @agent    = flexmock('agent', Mechanize.new)
      @agent.should_receive(:get).with(ShortagePlugin::SOURCE_URI).and_return(@html_drugshortage)
      @agent.should_receive(:get).with(ShortagePlugin::NoMarketingSource).and_return(@html_nomarketing)
      @agent.should_receive(:get).with('https://www.swissmedic.ch/arzneimittel/00156/00221/00225/index.html'+
                                       '?lang=de&download=NHzLpZeg7t,lnp6I0NTU042l2Z6ln1acy4Zn4Z2qZpnO2Yuq2Z6gpJCDdX57e2ym162epYbg2c_JjKbNoKSn6A--').and_return(@xlxs_nomarketing)
      @pack_62294_001 = add_mock_package('pack_62294_001', '7680622940010', false)
      @pack_62294_007 = add_mock_package('pack_62294_007', '7680622940070', false)
      @pack_62294_007.should_receive(:atc_class).and_return(nil)
      @pack_59893_001 = add_mock_package('pack_59893_001', '7680598930010', false)
      @reg_62294.should_receive(:active_packages).and_return([@pack_62294_001, @pack_62294_007])  #.by_default
      @reg_59893.should_receive(:active_packages).and_return([@pack_59893_001])# .by_default
      @archive = File.expand_path('../var', File.dirname(__FILE__))
      @plugin = flexmock('ShortagePlugin', ShortagePlugin.new(@app))
      @latest = flexmock('latest', Latest)
      @latest.should_receive(:fetch_with_http).with( ODDB::ShortagePlugin::SOURCE_URI).and_return(File.open(@drugshortage_name).read).by_default
      @latest.should_receive(:fetch_with_http).with( ODDB::ShortagePlugin::NoMarketingSource).and_return(File.open(@nomarketing_xlsx_name).read).by_default
    end
    def expected_test_result
            @plugin.duration_in_secs = 25
 %(Update job took #{sprintf('%3i', @plugin.duration_in_secs)} seconds
Found             2 shortages in https://www.drugshortage.ch/UebersichtaktuelleLieferengpaesse2.aspx
Deleted           2 shortages
Changed           2 shortages
Found             2 nomarketings packages for 
Deleted           3 nomarketings
Changed           2 nomarketings
Nr. IKSNR         1 not in oddb.org database


Nomarketing changes:
7680622940010;atc;pack_mock nodelivery_since: nodelivery_since =>
              nomarketing_date: nomarketing_date => 27.03.2017
              nomarketing_since: nomarketing_since => 13.06.2014
              nomarketing_link: nomarketing_link =>
7680622940070;atc;pack_mock nodelivery_since: nodelivery_since =>
              nomarketing_date: nomarketing_date => 27.03.2017
              nomarketing_since: nomarketing_since => 13.06.2014
              nomarketing_link: nomarketing_link =>

Nomarketing deletions:
7680490590777;atc;name
7680490590999;atc;name
7680623550019;atc;name

IKSNR not found in oddb database:
59893


DrugShortag changes:
7680623550019;atc;pack_mock shortage_last_update: shortage_state => 2017-02-24
              shortage_delivery_date: shortage_delivery_date => offen
              shortage_link: shortage_link => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934
7680519690140;atc;pack_mock shortage_last_update: shortage_state => 2017-01-13
              shortage_delivery_date: shortage_delivery_date => offen
              shortage_link: shortage_link => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2786

DrugShortag deletions:
7680490590777;atc;name
7680490590999;atc;name)
    end
    def test_report
      @plugin.update(@agent)
      @app.flexmock_verify
      assert_equal(expected_test_result, @plugin.report)
    end
    def test_changes_with_test_file
      @plugin.update(@agent)
      expected = {"7680623550019;atc;pack_mock"=>["shortage_last_update: shortage_state => 2017-02-24", "shortage_delivery_date: shortage_delivery_date => offen",
                                                  "shortage_link: shortage_link => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934"],
                  "7680519690140;atc;pack_mock"=>["shortage_last_update: shortage_state => 2017-01-13", "shortage_delivery_date: shortage_delivery_date => offen",
                                                  "shortage_link: shortage_link => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2786"]}
      assert_equal(expected , @plugin.changes_shortages)
    end
    def check_csv_lines(content)
      lines = content.split("\n")
      assert_equal('GTIN;ATC-Code;Präparatbezeichnung;Datum der Meldung (Swissmedic);Nicht-Inverkehrbringen ab (Swissmedic);Vertriebsunterbruch ab (Swissmedic);Link (Swissmedic);Datum letzte Mutation (Drugshortage);Status (Drugshortage);Datum Lieferfähigkeit (Drugshortage);Link (Drugshortage)',
                   lines.first.strip)
      assert(lines.find{|line| line.strip.eql?("7680622940010;atc;pack_mock;27.03.2017;13.06.2014;;#{@plugin.nomarketing_href};;;;") })
      assert(lines.find{|line| line.strip.eql?("7680519690140;atc;pack_mock;;;;;2017-01-13;aktuell keine Lieferungen;offen;https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2786") })
      assert(lines.find{|line| line.strip.eql?("7680519690140;atc;pack_mock;;;;;2017-01-13;aktuell keine Lieferungen;offen;https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2786") })

    end
    def test_export_csv
      FileUtils.rm(@plugin.csv_file_path) if File.exist?(@plugin.csv_file_path)
      @plugin.update(@agent)
      assert_equal(@csv_file , @plugin.export_drugshortage_csv)
      assert(File.exist?(@csv_file))
      check_csv_lines(IO.read(@csv_file))
      assert(File.exist?(@plugin.csv_file_path))
      assert_equal(@plugin.yesterday_csv_file_path, @csv_file.sub('.csv', '-2014.04.30.csv'))
      assert_equal(@plugin.dated_csv_file_path, @csv_file.sub('.csv', '-2014.05.01.csv'))
      assert(File.exist?(@plugin.dated_csv_file_path)) unless `which ssconvert`.chomp.empty?
    end
    def test_date
      @plugin.update(@agent)
      assert_equal(@@today , @plugin.date)
    end
    def add_no_changes_for_second_run(add_date_change = false)
      @package_changed_7680623550019 = add_mock_package('changed_7680623550019', TestGtinNeverShortage)
      @package_changed_7680623550019.should_receive(:shortage_state).and_return("aktuell keine Lieferungen")
      @package_changed_7680623550019.should_receive(:shortage_last_update).and_return(Date.new(2017,02,24))
      @package_changed_7680623550019.should_receive(:shortage_last_update).and_return(Date.new(2017,02,24))
      @package_changed_7680623550019.should_receive(:shortage_delivery_date).and_return("offen")
      if add_date_change
        @package_changed_7680623550019.should_receive(:shortage_link).and_return("https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934")
      else
        @package_changed_7680623550019.should_receive(:shortage_link).and_return("https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934")
      end
      @app.should_receive(:package_by_ean13).with('7680623550019').and_return(@package_changed_7680623550019)
      @app.should_receive(:package_by_ean13).with('7680519690140').and_return(@package_no_changes)
      @app.should_receive(:package_by_ean13).with('7680490590777').and_return(@package_never_in_short).by_default
      @app.should_receive(:active_packages).and_return([@package_no_changes, @package_changed_7680623550019])
      @plugin = ShortagePlugin.new @app
    end
    def test_run_with_same_content
      FileUtils.makedirs(File.dirname(@plugin.latest_shortage)) unless File.exist?(File.dirname(@plugin.latest_shortage))
      FileUtils.makedirs(File.dirname(@plugin.latest_nomarketing)) unless File.exist?(File.dirname(@plugin.latest_nomarketing))
      FileUtils.cp(@drugshortage_name, @plugin.latest_shortage)
      FileUtils.cp(@nomarketing_xlsx_name, @plugin.latest_nomarketing)
      FileUtils.rm_f(@plugin.yesterday_csv_file_path)
      File.open(@plugin.dated_csv_file_path, 'w+') {|f| f.write( %(GTIN;ATC-Code;Präparatbezeichnung;Datum der Meldung (Swissmedic);Nicht-Inverkehrbringen ab (Swissmedic);Vertriebsunterbruch ab (Swissmedic);Link (Swissmedic);Datum letzte Mutation (Drugshortage);Status (Drugshortage);Datum Lieferfähigkeit (Drugshortage);Link (Drugshortage)
))}

      FileUtils.cp(@plugin.dated_csv_file_path, @plugin.yesterday_csv_file_path, :verbose => true)
      @app.package_by_ean13("7680623550033")
      @plugin.update(@agent)
      assert_equal(false, File.exist?(@plugin.yesterday_csv_file_path))
      assert_equal(true, File.exist?(@plugin.dated_csv_file_path))
      assert_equal(false, File.exist?(@plugin.yesterday_csv_file_path))

      add_no_changes_for_second_run
      @app.should_receive(:package_by_ean13).with('7680490590777').and_return(nil)
      @plugin = ShortagePlugin.new @app
      @plugin.update(@agent)
      result =  @plugin.report
      assert_equal(0, result.size)
      assert_equal(false, File.exist?(Latest.get_daily_name(@plugin.latest_shortage)))
      assert_equal(false, File.exist?(Latest.get_daily_name(@plugin.latest_nomarketing)))
      assert_equal(true, File.exist?(@plugin.dated_csv_file_path))
    end
    def test_run_with_changed_content
      @agent    = flexmock('agent', Mechanize.new)
      @agent.should_receive(:get).with(ShortagePlugin::SOURCE_URI).and_return(@html_drugshortage)
      @agent.should_receive(:get).with(ShortagePlugin::NoMarketingSource).and_return(@html_nomarketing)
      @agent.should_receive(:get).with('https://www.swissmedic.ch/arzneimittel/00156/00221/00225/index.html'+
                                       '?lang=de&download=NHzLpZeg7t,lnp6I0NTU042l2Z6ln1acy4Zn4Z2qZpnO2Yuq2Z6gpJCDdX57e2ym162epYbg2c_JjKbNoKSn6A--').and_return(@xlxs_nomarketing)
      FileUtils.makedirs(File.dirname(@plugin.latest_shortage)) unless File.exist?(File.dirname(@plugin.latest_shortage))
      FileUtils.makedirs(File.dirname(@plugin.latest_nomarketing)) unless File.exist?(File.dirname(@plugin.latest_nomarketing))
      FileUtils.cp(@drugshortage_name, @plugin.latest_shortage)
      FileUtils.cp(@nomarketing_xlsx_name, @plugin.latest_nomarketing)
      puts ShortagePlugin::SOURCE_URI
      @plugin.update(@agent)
      @drugshortage_changed_name
#      FileUtils.cp(@drugshortage_changed_name, @plugin.latest_shortage, :verbose => true)
      Plugin.next_day
      FileUtils.cp(@drugshortage_changed_name, @plugin.latest_shortage.sub('latest', @@today.strftime("%Y.%m.%d")), :verbose => true)
      @latest.should_receive(:fetch_with_http).with( ODDB::ShortagePlugin::SOURCE_URI).and_return(File.open(@drugshortage_changed_name).read)
      @latest.should_receive(:fetch_with_http).with( ODDB::ShortagePlugin::NoMarketingSource).and_return(File.open(@nomarketing_xlsx_name).read)
      @plugin.update(@agent)
      result =  @plugin.report
      assert_equal(false, result.empty?)
      assert(/Changed\s+2\s+shortages/.match(result))
      expected = %(DrugShortag changes:
7680623550019;atc;pack_mock shortage_last_update: shortage_state => 2017-04-22
              shortage_delivery_date: shortage_delivery_date => in Abklärung / en cours de clarification
              shortage_link: shortage_link => https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=2934
)
      assert(result.index(expected))
      FileUtils.rm_f(@plugin.latest_shortage)
      FileUtils.rm_f(@plugin.latest_nomarketing)
    end
    def test_create_drugshortage_csv
      FileUtils.makedirs(File.dirname(@plugin.latest_shortage)) unless File.exist?(File.dirname(@plugin.latest_shortage))
      FileUtils.makedirs(File.dirname(@plugin.latest_nomarketing)) unless File.exist?(File.dirname(@plugin.latest_nomarketing))
      FileUtils.cp(@drugshortage_name, @plugin.latest_shortage)
      FileUtils.cp(@nomarketing_xlsx_name, @plugin.latest_nomarketing)
      FileUtils.rm(@plugin.csv_file_path) if File.exist?(@plugin.csv_file_path)
      @plugin.update(@agent)
      assert(File.exist?(@plugin.csv_file_path))
    end
    def test_sending_email
      Util.configure_mail :test
      Util.clear_sent_mails
      subj = 'my_mail_subject'
      @plugin.update(@agent)
      @plugin.export_drugshortage_csv
      log = Log.new(@plugin.date)
      result = log.update_values(@plugin.log_info)
      res = result.index(expected_test_result)
      assert(result.to_s.index(/Found\s+2 shortages/))
      mails_sent = Util.sent_mails
      assert_equal(0, mails_sent.size)
      log.notify(subj)
      assert_equal(1, mails_sent.size)
      assert_equal(mails_sent.first.to, ['ywesee_test@ywesee.com'])
      assert_equal(1, mails_sent.first.attachments.size)
      attached = mails_sent.first.attachments.first
      assert_equal('drugshortage.csv', attached.filename)
      check_csv_lines(attached.body.decoded)
    end
    def test_update_opts_nil
      @plugin = ShortagePlugin.new @app, nil
    end
  end
end
