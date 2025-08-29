#!/usr/bin/env ruby

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))

require "stub/odba"
USE_RUBY_PROF = false
require "ruby-prof" if USE_RUBY_PROF

require "minitest/autorun"
require "stub/oddbapp"
require "stub/session"
require "fileutils"
require "flexmock/minitest"
require "plugin/text_info"
require "model/text"
require "util/workdir"
require "test_helpers" # for VCR setup

begin require "debug"; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)

module ODDB
  class FachinfoDocument
    def odba_id
      1
    end
  end

  class PatinfoDocument
    attr_reader :changelog
  end

  class TextInfoPlugin
    attr_accessor :parser
    attr_reader :to_parse, :iksnrs_meta_info, :updated_fis, :updated_pis,
      :up_to_date_fis, :up_to_date_pis, :updated, :details_dir, :dirs
  end

  class TestRefdataCache < Minitest::Test
    def setup
      @app = flexmock("application_#{__LINE__}", App.new)
      @plugin = TextInfoPlugin.new @app
      @plugin.parser = ::ODDB::FiParse
      @aips_xml = File.join(ODDB::TEST_DATA_DIR, "xml", "AipsDownload_latest.xml")
      @all_html_zip = File.join(ODDB::TEST_DATA_DIR, "AllHtml.zip")
      super
    end

    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def test_get_aips_download_xml
      one_MB = 1024*1024
      @plugin.get_aips_download_xml
      assert(File.exist?(@plugin.aips_xml))
      assert(File.size(@plugin.aips_xml) > one_MB)
      @aips_xml = File.join(ODDB::TEST_DATA_DIR, "xml", "AipsDownload_latest.xml")
      assert(File.exist?(@aips_xml))
      old_size = File.size(@aips_xml)
      assert(old_size < one_MB)
      @plugin.get_aips_download_xml(@aips_xml)
      assert(File.exist?(@plugin.aips_xml))
      assert_equal(old_size,  File.size(@plugin.aips_xml))
    end

    @@saved_meta_info ||= {}
    def get_iksnrs_meta_info
      if @@saved_meta_info.size > 0
        @plugin.iksnrs_meta_info = @@saved_meta_info.dup
      else
        FileUtils.rm_rf(ODDB::WORK_DIR, verbose: true)
        @plugin.get_aips_download_xml(@aips_xml)
        @plugin.parse_aips_download(@aips_xml)
        @@saved_meta_info = @plugin.iksnrs_meta_info.dup
      end
    end

    def test_create_missing_registrations
      get_iksnrs_meta_info
      res = @plugin.create_missing_registrations
      assert_equal(18, res.size)
      firstMeta = res.values.flatten.first
      assert_equal(["40858", "40859", "43787", "43788"], firstMeta.authNrs)
      assert_equal("40858", firstMeta.iksnr)
    end

    def get_tramal_fi_and_pi
      @tramal_pi = @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(43788) && x.type.eql?("pi") && x.lang.eql?("de")}.first
      @tramal_fi = @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(43788) && x.type.eql?("pi") && x.lang.eql?("de")}.first
    end

    def test_parse_aips_download
      get_iksnrs_meta_info
      assert_equal(3, @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(43788) && x.type.eql?("pi")}.size)
      # failing at the moment
      # Tramal has 4 IKSNR for 1 FI
      [40858, 40859, 43787, 43788].each do |iksnr|
        assert_equal(3, @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(iksnr) && x.type.eql?("fi")}.size)
      end
      assert_equal(1, @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(40858) && x.type.eql?("fi") && x.lang.eql?("de")}.size)
      # but only 43788 has also a PI (for Kapseln)
      [40858, 40859, 43787].each do |iksnr|
        assert_equal(0, @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(iksnr) && x.type.eql?("pi") && x.lang.eql?("de")}.size)
      end
      assert_equal(1, @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(43788) && x.type.eql?("pi") && x.lang.eql?("de")}.size)
    end

    def test_save_meta_and_xref_info
      get_iksnrs_meta_info
      @plugin.save_meta_and_xref_info
      get_tramal_fi_and_pi
      assert(File.exist?(@plugin.meta_xml))
      assert(File.exist?(@plugin.aips_xml))
      assert(File.exist?(@plugin.xref_xml))
      assert_equal(43788, @tramal_fi.iksnr.to_i)
      assert_equal(43788, @tramal_pi.iksnr.to_i)
    end

    def test_download_all_html_zip
      FileUtils.rm_rf(File.join(ODDB::WORK_DIR, "html_cache"), :verbose => true)
      FileUtils.rm_rf(@plugin.zip_file, :verbose => true)
      assert(File.exist?(@all_html_zip))
      tst_file = File.join(ODDB::WORK_DIR, "html_cache", "3719e544ca4d466e8f51454e162078cd-de.html")
      assert(!File.exist?(tst_file))
      @plugin.download_all_html_zip(@all_html_zip)
      assert(File.exist?(@plugin.zip_file))
      old_size = File.size(@all_html_zip)
      assert(old_size > 1024)
      assert_equal(File.join(ODDB::WORK_DIR, "AllHtml.zip"), @plugin.zip_file)
      assert_equal(old_size, File.size(@plugin.zip_file))
      assert(File.exist?(tst_file))
    end

    def test_unpack_beautify_sha256
      get_iksnrs_meta_info
      @plugin.save_meta_and_xref_info
      get_tramal_fi_and_pi
      assert(!File.exist?(@tramal_pi.cache_file))
      assert(!File.exist?(@tramal_fi.cache_file))
      @plugin.download_all_html_zip(@all_html_zip)
      @remove_fi = @plugin.iksnrs_meta_info.values.flatten.find_all{|x| x.iksnr.to_i.eql?(32917) && x.type.eql?("fi") && x.lang.eql?("de")}.first
      FileUtils.rm_f(@remove_fi.cache_file, :verbose => true)
      @plugin.unpack_and_beautify_files
      get_tramal_fi_and_pi
      assert(File.exist?(@tramal_pi.cache_file))
      assert(File.exist?(@tramal_fi.cache_file))
      assert(File.exist?(@tramal_pi.cache_file))
      assert(File.size(@tramal_pi.cache_file) > 1024)
      assert_nil(@tramal_pi.cache_sha256)
      assert_nil(@tramal_pi.cache_sha256)
      assert_nil(@tramal_fi.cache_sha256)
      @plugin.calc_and_save_sha256
      assert(@tramal_pi.cache_sha256)
      assert(@tramal_pi.cache_sha256)
      assert_equal(64, @tramal_fi.cache_sha256.size)
      assert_equal(64, @tramal_pi.cache_sha256.size)
      nr_sha = @plugin.iksnrs_meta_info.values.flatten.collect{|x| x.cache_sha256}.compact.size
      nr_uniq = @plugin.iksnrs_meta_info.values.flatten.collect{|x| x.cache_sha256}.compact.uniq.size
      assert_equal(nr_sha, nr_uniq) # SHA256 value must be uniq
    end
  end

  class TestChangeLog < Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def prepare_plugin(remove_details = true, xml_file = "61467_fi_de.xml")
      @plugin = TextInfoPlugin.new @app
      FileUtils.makedirs(@details_dir)
      xml_full = File.join(ODDB::TEST_DATA_DIR, "xml", xml_file)
      FileUtils.rm_rf(@plugin.details_dir, verbose: false) if remove_details
      @plugin.parser = ::ODDB::FiParse
      @aips_download = xml_full
      @plugin.get_aips_download_xml(@aips_download)
      @latest_from = File.join(ODDB::TEST_DATA_DIR, "/xlsx/Packungen-61467.xlsx")
      latest_to = File.join(ODDB::WORK_DIR, "xls/Packungen-latest.xlsx")
      FileUtils.mkdir_p(File.dirname(latest_to))
      FileUtils.cp(@latest_from, latest_to, verbose: false, preserve: true)
      @options[:xml_file] = xml_full
    end

    def setup
      ODDB::TestHelpers.vcr_setup
      require "ext/fiparse/src/fiparse"
      @details_dir = File.join(ODDB::WORK_DIR, "details")
      path_check = File.join(ODDB::PROJECT_ROOT, "etc", "barcode_minitest.yml")
      assert_equal(ODDB::TextInfoPlugin::Override_file, path_check)
      FileUtils.rm_f(path_check, verbose: false)
      FileUtils.rm_f(File.expand_path("../data/"), verbose: false)
      flexmock "pointer"
      @app = flexmock("application_#{__LINE__}", App.new)
      @app.should_receive(:company_by_name)
    end


    def check_whether_changed(should_change = false)
      pi = @app.registrations.values.first.sequences.values.first.patinfo

      fi = @app.registrations.values.first.fachinfo

      puts "\n\ncheck_whether_changed should_change #{should_change} change_logs: fi #{fi[:de].change_log&.size}  pi #{pi[:de].change_log&.size}"
      puts fi.descriptions["de"].galenic_form
      puts pi.descriptions["de"].contra_indications
      assert_match(/Actikerall/, pi.descriptions["de"].contra_indications.to_s)
      assert_match(/Actikerall/, fi.descriptions["de"].contra_indications.to_s)
      if should_change
        assert_match(@test_change, fi.descriptions["de"].galenic_form.to_s)
        assert_match(@test_change, pi.descriptions["de"].contra_indications.to_s)
        assert_match(@test_change, fi[:de].change_log.first.diff.to_s)
        assert_equal(1, fi[:de].change_log.size)
        assert_equal(0, pi.descriptions["it"].to_s.size)
        assert_equal(0, pi.descriptions["fr"].to_s.size)
        assert_equal(0, fi.descriptions["it"].to_s.size)
        assert_equal(0, fi.descriptions["fr"].to_s.size)
        assert_equal(1, pi[:de].change_log.size)
        assert_match(@test_change, pi[:de].change_log.first.diff.to_s)
      else
        assert_nil(fi.descriptions["de"].galenic_form.to_s.match(@test_change))
        assert_nil(pi.descriptions["de"].contra_indications.to_s.match(@test_change))
      end
    end

    def test_61467_pi_fi
      @options = {target: :both,
                  download: false,
                  newest: false, # with true this takes a lot of time
                  xml_file: @aips_download}
      @test_change = /CHANGED FOR MINITEST......../
      @test_actikierall = /Was ist Actikerall/
      skip("Not yet ready for")
      prepare_plugin
      pi_de_html_src = File.join(ODDB::TEST_DATA_DIR, "html", "Actikerall_.html")
      assert(File.exist?(pi_de_html_src))
      pi_de_html_dst = File.join(ODDB::WORK_DIR, "html", "pi", "de", "Actikerall_.html")
      FileUtils.makedirs(File.dirname(pi_de_html_dst), verbose: false)
      FileUtils.cp(pi_de_html_src, pi_de_html_dst, verbose: false, preserve: true)
      @app.create_registration("61467")
      @plugin.import_swissmedicinfo(@options)

      assert_equal(["61467"], @app.registrations.keys)
      assert_equal(["01"], @app.registration("61467").sequences.keys)
      assert_equal(Date.today, @app.registrations.values.first.sequences.values.first.packages.values.first.revision.to_date)
      assert_equal(ODDB::Patinfo, @app.registrations.values.first.sequences.values.first.patinfo.class)
      check_whether_changed(false)
      assert_match("61467", @plugin.updated_fis.join(";"))
      assert_match("61467", @plugin.updated_pis.join(";"))
      puts("\n\n\nRerun import and assert that nothing has changed")
      prepare_plugin
      @plugin.import_swissmedicinfo(@options)
      check_whether_changed(false)

      puts("\n\n\nRerun import and assert that PI/FI haved changed")
      prepare_plugin(false, "61467_changed.xml")
      @plugin.import_swissmedicinfo(@options)
      check_whether_changed(true)
      @app.registrations.values.first.sequences.values.first.patinfo
      @app.registrations.values.first.fachinfo
      assert_match("61467", @plugin.updated_fis.join(";")) if @options[:target].eql?(:both)
      assert_match("61467", @plugin.updated_pis.join(";"))
    end

    def test_ignore_missing_iksnr
      skip("Not yet ready for")
      not_found = "99999"
      @options = {target: :pi,
                  download: false,
                  newest: false, # with true this takes a lot of time
                  reparse: true,
                  iksnrs: [not_found],
                  xml_file: @aips_download}
      prepare_plugin
      @plugin.import_swissmedicinfo(@options)
      assert_nil(/#{not_found}/.match(@plugin.report))
    end

    def test_Rubrace
      skip("Not yet ready for")
      rubrace_iksnr = "67402"
      @app.create_registration(rubrace_iksnr)
      @app.registration(rubrace_iksnr).create_sequence("01")
      @app.registration(rubrace_iksnr).create_sequence("02")
      @app.registration(rubrace_iksnr).create_sequence("03")
      @app.registration(rubrace_iksnr).sequence("01").create_package("001")
      @app.registration(rubrace_iksnr).sequence("02").create_package("002")
      @app.registration(rubrace_iksnr).sequence("03").create_package("003")
      @app.registration(rubrace_iksnr).sequence("01").create_package("004")
      @app.registration(rubrace_iksnr).sequence("02").create_package("005")
      @app.registration(rubrace_iksnr).sequence("03").create_package("006")
      @app.registration(rubrace_iksnr).packages.each do |package|
        package.patinfo = Patinfo.new if package.ikscd.eql?("001")
        #        puts "#{package.ikscd} odba_id #{package.odba_id} has #{package.patinfo.class}"
      end
      assert_equal(6, @app.registration(rubrace_iksnr).packages.size)
      assert_equal(false, @app.registration(rubrace_iksnr).packages.first.patinfo.description(:de).respond_to?(:add_change_log_item))
      assert_nil(@app.registration(rubrace_iksnr).packages.last.patinfo)

      @options = {target: :both,
                  download: false,
                  newest: false, # this takes a lot of time
                  xml_file: @aips_download}
      prepare_plugin(false, "Rubrace.xml")
      @plugin.import_swissmedicinfo(@options)
      assert_match(rubrace_iksnr, @plugin.updated_fis.join(";")) if @options[:target].eql?(:both)
      assert_match(rubrace_iksnr, @plugin.updated_pis.join(";"))
      assert_equal(6, @app.registration(rubrace_iksnr).packages.size)
      patinfo_odba_id = @app.registration(rubrace_iksnr).packages.first.patinfo.odba_id
      assert_match(/Rubraca®, Filmtabletten/, @app.registration(rubrace_iksnr).packages.first.patinfo["de"].to_s[0..70])
      assert_equal(["01", "02", "03"], @app.registration(rubrace_iksnr).packages.collect { |x| x.seqnr }.uniq.sort)
      assert_equal(["001", "002", "003", "004", "005", "006"], @app.registration(rubrace_iksnr).packages.collect { |x| x.ikscd }.uniq.sort)
      @app.registration(rubrace_iksnr).packages.each do |package|
        # puts "#{package.ikscd} expect #{patinfo_odba_id} odba_id #{package.patinfo.odba_id}"
        assert_match(/Rubraca®, Filmtabletten/, package.patinfo["de"].to_s[0..70])
        assert_equal(patinfo_odba_id, package.patinfo.odba_id) if package.seqnr.eql?("01")
      end
      assert_equal(patinfo_odba_id, @app.registration(rubrace_iksnr).sequence("01").packages.values.first.patinfo.odba_id)
      assert(patinfo_odba_id != @app.registration(rubrace_iksnr).sequence("02").packages.values.first.patinfo.odba_id)
      assert(patinfo_odba_id != @app.registration(rubrace_iksnr).sequence("03").packages.values.first.patinfo.odba_id)
    end

  end

  class TestTextInfoPlugin < Minitest::Test
    @@datadir = File.join(ODDB::TEST_DATA_DIR, "html/text_info")
    def setup
      super
      ODDB::TestHelpers.vcr_setup
      @app = flexmock "application"
      FileUtils.mkdir_p(ODDB::WORK_DIR)
      ODDB.config.text_info_searchform = "http://textinfo.ch/Search.aspx"
      ODDB.config.text_info_newssource = "http://textinfo.ch/news.aspx"
      @parser = flexmock("parser (simulates ext/fiparse)", parse_fachinfo_html: nil)
      @plugin = TextInfoPlugin.new @app
      @plugin.parser = @parser
    end

    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup_mechanize mapping = []
      agent = flexmock Mechanize.new
      @pages = Hash.new(0)
      @actions = {}
      mapping.each do |page, method, url, formname, page2|
        path = File.join @@datadir, page
        page = setup_page url, path, agent
        if formname
          form = flexmock page.form(formname)
          action = form.action
          page = flexmock page
          page.should_receive(:form).with(formname).and_return(form)
          path2 = File.join @@datadir, page2
          page2 = setup_page action, path2, agent
          agent.should_receive(:submit).and_return page2
        end
        case method
        when :get, :post
          agent.should_receive(method).with(url).and_return do |*args|
            @pages[[method, url, *args]] += 1
            page
          end
        when :submit
          @actions[url] = page
          agent.should_receive(method).and_return do |form, *args|
            action = form.action
            @pages[[method, action, *args]] += 1
            @actions[action]
          end
        else
          agent.should_receive(method).and_return do |*args|
            @pages[[method, *args]] += 1
            page
          end
        end
      end
      agent
    end

    def setup_page url, path, agent
      response = {"content-type" => "text/html"}
      Mechanize::Page.new(URI.parse(url), response,
        File.read(path), 200, agent)
    end

    def setup_fachinfo_document heading, text
      fi = FachinfoDocument.new
      fi.iksnrs = Text::Chapter.new
      fi.iksnrs.heading << heading
      fi.iksnrs.next_section.next_paragraph << text
      fi
    end

    def test_init_agent
      agent = @plugin.init_agent
      assert_instance_of Mechanize, agent
      assert(/Mozilla/.match(agent.user_agent))
    end

    def test_fachinfo_news__unconfigured
      agent = setup_mechanize
      ODDB.config.text_info_newssource = nil
      assert_raises NoMethodError do
        @plugin.fachinfo_news agent
      end
    end

    def test_true_news
      ## there are no news
      news = [
        "Abseamed\302\256",
        "Aclasta\302\256",
        "Alcacyl\302\256 500 Instant-Pulver",
        "Aldurazyme\302\256",
        "Allopur\302\256",
        "Allopurinol - 1 A Pharma100 mg/300 mg",
        "Amavita Acetylcystein 600",
        "Amavita Carbocistein",
        "Amavita Ibuprofen 400",
        "Amavita Paracetamol 500"
      ]
      old_news = [
        "Abseamed\302\256",
        "Aclasta\302\256"
      ]
      expected_news = [
        "Alcacyl\302\256 500 Instant-Pulver",
        "Aldurazyme\302\256",
        "Allopur\302\256",
        "Allopurinol - 1 A Pharma100 mg/300 mg",
        "Amavita Acetylcystein 600",
        "Amavita Carbocistein",
        "Amavita Ibuprofen 400",
        "Amavita Paracetamol 500"
      ]
      assert_equal expected_news, @plugin.true_news(news, old_news)
      ## clean disection
      old_news = [
        "Allopurinol - 1 A Pharma100 mg/300 mg",
        "Amavita Acetylcystein 600",
        "Amavita Carbocistein",
        "Amavita Ibuprofen 400",
        "Amavita Paracetamol 500"
      ]
      expected = [
        "Abseamed\302\256",
        "Aclasta\302\256",
        "Alcacyl\302\256 500 Instant-Pulver",
        "Aldurazyme\302\256",
        "Allopur\302\256"
      ]
      assert_equal expected, @plugin.true_news(news, old_news)
      ## recorded news don't appear on the news-page
      old_news = ["Amiodarone Winthrop\302\256/- Mite"]
      assert_equal news, @plugin.true_news(news, old_news)
    end
  end

  class TestExtractMatchedName < Minitest::Test
    Nr_FI_in_AIPS_test = 15
    Nr_PI_in_AIPS_test = 3
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup
      ODDB::TestHelpers.vcr_setup
      path_check = File.join(ODDB::PROJECT_ROOT, "etc", "barcode_minitest.yml")
      assert_equal(ODDB::TextInfoPlugin::Override_file, path_check)
      FileUtils.rm_rf(ODDB::WORK_DIR, verbose: false)
      FileUtils.rm_f(path_check, verbose: false)
      FileUtils.rm_f(File.expand_path("../data/"), verbose: false)
      pointer = flexmock "pointer"
      latest_from = File.join(ODDB::TEST_DATA_DIR, "/xls/Packungen-latest.xlsx")
      latest_to = File.join(ODDB::WORK_DIR, "xls/Packungen-latest.xlsx")
      FileUtils.mkdir_p(File.dirname(latest_to))
      FileUtils.cp(latest_from, latest_to, verbose: false, preserve: true)
      @app = flexmock "application_#{__LINE__}"
      @reg = flexmock "registration_#{__LINE__}"
      @reg.should_receive(:pointer).and_return(pointer).by_default
      @reg.should_receive(:odba_store).and_return(nil).by_default
      @reg.should_receive(:odba_isolated_store).and_return(nil).by_default
      @reg.should_receive(:company).and_return("company")
      @reg.should_receive(:inactive?).and_return(false)
      lang_de = flexmock "lang_de"
      lang_de.should_receive(:de).and_return("fi_de")
      lang_de.should_receive(:text).and_return("fi_text")
      @descriptions = flexmock "descriptions"
      @descriptions.should_receive(:[]).and_return("desc")
      @descriptions.should_receive(:[]=).and_return("desc").by_default
      @descriptions.should_receive(:odba_isolated_store)
      @descriptions = ODDB::SimpleLanguage::Descriptions.new

      @fachinfo = flexmock("fachinfo", Fachinfo.new)
      @fachinfo.should_receive(:de).and_return(lang_de)
      @fachinfo.should_receive(:fr).and_return(lang_de)
      @fachinfo.should_receive(:it).and_return(lang_de)
      @fachinfo.should_receive(:oid).and_return("oid")
      @fachinfo.should_receive(:pointer).and_return(pointer)
      @fachinfo.should_receive(:descriptions).and_return(@descriptions)
      @fachinfo.should_receive(:change_log).and_return([])
      @fachinfo.should_receive(:odba_store)
      @fachinfo.should_receive(:iksnrs).and_return(["56079"])
      @fachinfo.should_receive(:name_base).and_return("name_base")

      @app.should_receive(:create_patinfo).and_return(Patinfo.new)

      atc_class = flexmock("atc_class_#{__LINE__}")
      atc_class.should_receive(:oid).and_return("oid")
      atc_class.should_receive(:code).and_return("code")
      @sequence = flexmock("sequence_#{__LINE__}", Sequence.new("01"))
      @sequence.should_receive(:seqnr).and_return("01")
      @sequence.should_receive(:pointer).and_return(pointer)
      @sequence.should_receive(:odb_store)
      @sequence.should_receive(:odba_isolated_store)
      @sequence.should_receive(:atc_class=).and_return(atc_class)
      @sequence.should_receive(:atc_class).and_return(atc_class)
      @sequence.should_receive(:patinfo).and_return(nil).by_default
      @sequence.should_receive(:patinfo=).and_return(nil).by_default
      @package = flexmock("package_#{__LINE__}", Package.new("001"))
      @sequence.should_receive(:package).and_return(@package)
      @sequence.should_receive(:create_package).and_return(@package)
      @reg.should_receive(:create_sequence).and_return(@sequence)
      @package.should_receive(:sequence).and_return(@sequence)

      atc_class = flexmock("atc_class_#{__LINE__}")
      atc_class.should_receive(:oid).and_return("oid")
      atc_class.should_receive(:code).and_return("code")
      atc_class.should_receive(:pointer).and_return(pointer)
      atc_class.should_receive(:odba_store).and_return(true)
      @app.should_receive(:atc_class).and_return(atc_class)
      @app.should_receive(:update).and_return(@fachinfo)
      @reg.should_receive(:fachinfo).and_return(@fachinfo)
      @reg.should_receive(:iksnr).and_return("56079")
      @reg.should_receive(:name_base).and_return("name_base")
      @reg.should_receive(:packages).and_return([@package])
      @app.should_receive(:registration).and_return(@reg)
      @app.should_receive(:registrations).and_return({"x" => @reg})
      @app.should_receive(:sequences).and_return([@sequence])
      @reg.should_receive(:sequences).and_return({"01" => @sequence})
      @reg.should_receive(:sequence).and_return(@sequence)
      @parser = flexmock("parser (simulates ext/fiparse)",
        parse_fachinfo_html: "fachinfo_html",
        parse_patinfo_html: Patinfo.new)
      @reg.should_receive(:each_package).and_return([]).by_default
      @reg.should_receive(:each_sequence).and_return([@sequence]).by_default
      @plugin = TextInfoPlugin.new @app
      FileUtils.rm_rf(@plugin.details_dir, verbose: false)
      @plugin.parser = @parser
      @aips_xml = File.join(ODDB::TEST_DATA_DIR, "xml", "AipsDownload_latest.xml")
      @all_html_zip = File.join(ODDB::TEST_DATA_DIR, "AllHtml.zip")
      @plugin.get_aips_download_xml(@aips_xml)
      @plugin.zip_url = @all_html_zip
      @options = {target: :both,
                  download: false,          # 1007050 772494
                  xml_file: @aips_xml} # 1006998 772442
      #      052     52
      @details_dir = File.join(ODDB::WORK_DIR, "details")
      FileUtils.makedirs(@details_dir)
    end

    def test_53662_pi_de
      skip("Not yet ready for")
      @options[:iksnrs] = ["53662"]
      @plugin.import_swissmedicinfo(@options)
      assert_equal("3TC®", @plugin.iksnrs_meta_info[["53662", "fi", "de"]].first.title)
      assert_equal("3TC®", @plugin.iksnrs_meta_info[["53663", "fi", "de"]].first.title)
      assert_match("61467", @plugin.updated_fis.join(";"))
    end

    def test_Erbiumcitrat_de
      skip("Not yet ready for")
      @options[:iksnrs] = ["51704"]
      # 132 259 -> 198
      @plugin.import_swissmedicinfo(@options)
      assert_equal("[169Er]Erbiumcitrat CIS bio international", @plugin.iksnrs_meta_info[["51704", "fi", "de"]].first.title)
    end

    def test_Erbiumcitrat_fr
      @options[:iksnrs] = ["51704"]
      @plugin.import_swissmedicinfo(@options)
      assert_nil(@plugin.iksnrs_meta_info[["51704", "fi", "fr"]])
    end

    def test_53663_pi_de
      skip("Not yet ready for")
      @options[:iksnrs] = ["53662"]
      @plugin.import_swissmedicinfo(@options)
      assert_equal("3TC®", @plugin.iksnrs_meta_info[["53662", "fi", "de"]].first.title)
      assert_equal("3TC®", @plugin.iksnrs_meta_info[["53663", "fi", "de"]].first.title)
    end

    def test_get_swissmedicinfo_changed_items
      @options = {target: :both,
                  download: false,
                  newest: true,
                  xml_file: @aips_download}

      res = @plugin.import_swissmedicinfo(@options)
      puts @plugin.report
    end

    def test_import_daily_fi
      @options[:target] = :fi
      # Add tests that fachinfo gets updated
      # @reg.should_receive(:odba_store).at_least.once
      # @fachinfo.should_receive(:odba_store).at_least.once
      @latest_from = File.join(ODDB::TEST_DATA_DIR, "xlsx", "Packungen-2021.04.01.xlsx")
      latest_to = File.join(ODDB::WORK_DIR, "xls", "Packungen-latest.xlsx")
      FileUtils.mkdir_p(File.dirname(latest_to))
      FileUtils.cp(@latest_from, latest_to, verbose: false, preserve: true)
      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "fi" }.size > 0, "must find at least one find fachinfo")

      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "pi" }.size, "must find patinfo")
      assert_equal(Nr_FI_in_AIPS_test, @plugin.updated_fis.size, "nr updated fis must match")
      assert_equal(0, @plugin.updated_pis.size, "nr updated pis must match")
      assert_equal([], @plugin.up_to_date_pis, "up_to_date_pis must match")
      # nr_fis = 6 # we add all missing
      assert_equal([], @plugin.up_to_date_fis, "up_to_date_fis must match")

      @plugin = TextInfoPlugin.new @app
      @plugin.parser = @parser
      @plugin.zip_url = @all_html_zip
      @plugin.import_swissmedicinfo(@options)
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "fi" }.size, "must find fachinfo")
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "pi" }.size, "may not find patinfo")
    end

    def test_import_daily_pi
      @options[:target] = :pi
      # Add tests that patinfo gets updated
      # @reg.should_receive(:odba_store).at_least.once
      # @sequence.should_receive(:odba_store).at_least.once
      # @descriptions.should_receive(:[]=).at_least.once
      @plugin = TextInfoPlugin.new @app
      @plugin.parser = @parser
      @plugin.zip_url = @all_html_zip
      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "pi" }.size > 0, "must find at least one find patinfo")
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "fi" }.size, "must find fachinfo")
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "pi" }.size, "may not find patinfo")
      assert_equal(Nr_PI_in_AIPS_test, @plugin.updated_pis.size, "nr updated pis must match")
      assert_equal([], @plugin.up_to_date_pis, "up_to_date_pis must match")

      assert_equal(0, @plugin.updated_fis.size, "nr updated fis must match")
      assert_equal([], @plugin.up_to_date_fis, "up_to_date_fis must match")
    end

    def test_import_daily_packungen
      @options[:target] = :pi
      old_missing = {"680109990223_pi_de" => "Osanit® Kügelchen",
                     "7680109990223_pi_fr" => "Osanit® globules",
                     "7680109990224_pi_fr" => "Test mit langem Namen der nicht umgebrochen sein sollte mehr als 80 Zeichen lang"}
      real_override_file = File.join(ODDB::PROJECT_ROOT, "etc", "barcode_to_text_info.yml")
      assert_equal(false, File.exist?(ODDB::TextInfoPlugin::Override_file), "File #{ODDB::TextInfoPlugin::Override_file} must not exist")
      assert_equal(true, File.exist?(real_override_file), "File #{real_override_file} must exist")
      YAML.load_file(real_override_file)
      File.open(ODDB::TextInfoPlugin::Override_file, "w+") do |out|
        YAML.dump(old_missing, out)
      end
      assert_equal(5, File.readlines(ODDB::TextInfoPlugin::Override_file).size, "File must be now 5 lines long, as one is too long")
      old_time = File.ctime(ODDB::TextInfoPlugin::Override_file)
      # Add tests that patinfo gets updated
      @plugin.import_swissmedicinfo(@options)
      puts @plugin.report
      assert(@plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "pi" }.size > 0, "must find at least one find patinfo")
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "fi" }.size, "must find fachinfo")
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all { |key| key[1] == "pi" }.size, "may not find patinfo")
      assert_equal(3, @plugin.updated_pis.size, "nr updated pis must match")
      new_time = File.ctime(ODDB::TextInfoPlugin::Override_file)
      assert(new_time > old_time, "ctime of #{ODDB::TextInfoPlugin::Override_file} should have changed")
      assert_equal(4, File.readlines(ODDB::TextInfoPlugin::Override_file).size, "File must be now 4 lines long")
      assert_equal(0, @plugin.updated_fis.size, "nr updated fis must match")
      assert_equal(0, @plugin.up_to_date_fis.size, "up_to_date_fis must match")
      # why does next check fail in a github action, but never locally
      puts("why does next check fail in a github action, but never locally. hostname = #{`hostname`}")
      skip("why does next check fail in a github action, but never locally. hostname = #{`hostname`}")
      assert_equal(0, @plugin.up_to_date_pis.size, "up_to_date_pis must match")
    end
  end
end
