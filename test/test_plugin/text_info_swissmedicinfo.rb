#!/usr/bin/env ruby
$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "fileutils"
require "test_helpers"
require "flexmock/minitest"
require "stub/odba"
require "stub/oddbapp"
require "stub/oddbapp"
require "plugin/text_info"
begin require "debug"; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)

RunAll = true
module ODDB
  class FachinfoDocument
    def odba_id
      1
    end
  end

  module SequenceObserver
    def initialize
    end

    def select_one(param)
    end
  end

  class TextInfoPlugin < Plugin
    attr_accessor :parser
    attr_reader :updated, :iksnrs_meta_info, :details_dir
    def read_packages
      @packages = {}
      @packages["32917"] = IKS_Package.new("32917", "01", "001")
      @packages["43788"] = IKS_Package.new("43788", "01", "019")
    end
  end

  class TestTextInfoChangeLogin < Minitest::Test
    def setup
      FileUtils.rm_rf(ODDB::WORK_DIR)
      super
    end # Fuer Problem mit fachinfo italic

    def teardown
      ODBA.storage = nil
      super
    end

    def test_odba_store
      old_text = "Some text\nLine 2\nLine 3"
      new_text = "Some text\nLine 2 was changed\nLine 3"
      txt_diff = Diffy::Diff.new(old_text, new_text)
      result = Marshal.dump(txt_diff)
      expected = "Line 2
Line 3\x06;\bT:\r@string2I\"(Some text
Line 2 was changed
Line 3\x06;\bT"
      assert(result.index(expected) > 0)
    end
  end

  if RunAll
    class TestTextInfoPluginAipsMetaData < Minitest::Test
      NrRegistration = 4
      Test_57435_Iksnr = "57435"
      Test_57435_Name = "Baraclude®"
      Test_57435_Atc = "J05AF10"
      Test_57435_Inhaber = "Bristol-Myers Squibb SA"
      Test_57435_Substance = "Entecavir"
      Test_Iksnr = "62630"
      Test_Name = "Xeljanz"
      Test_Atc = "L04AA29"

      def run_import(iksnr, opts = {
        target: :fi,
        reparse: false,
        iksnrs: [iksnr],
        companies: [],
        download: false
      })
        @app.registrations = {}
        @plugin = TextInfoPlugin.new(@app, opts)
        FileUtils.rm_rf(@plugin.details_dir)
        @plugin.init_agent
        @plugin.parser = @parser
        @plugin.import_swissmedicinfo(opts)
      end

      def setup
        ODDB::TestHelpers.vcr_setup
        FileUtils.rm_rf(ODDB::WORK_DIR)
        flexmock(ODDB::SequenceObserver) do |klass|
          klass.should_receive(:set_oid).and_return("oid")
          klass.should_receive(:new).and_return("new")
        end
        flexstub(ODDB::Persistence) do |klass|
          klass.should_receive(:set_oid).and_return("oid")
        end
        FileUtils.mkdir_p ODDB::XML_DIR
        @dest = File.join(ODDB::XML_DIR, "AipsDownload_latest.xml")
        FileUtils.makedirs(File.dirname(@dest))
        FileUtils.cp(File.join(ODDB::TEST_DATA_DIR, "xml/AipsDownload_xeljanz.xml"), @dest)
        @app = ODDB::App.new

        @parser = flexmock "parser (simulates ext/fiparse for swissmedicinfo_xml)"
        @fi_path_de = File.join(ODDB::TEST_DATA_DIR, "html/fachinfo/de/#{Test_Name}_swissmedicinfo.html")
        @fi_path_fr = File.join(ODDB::TEST_DATA_DIR, "html/fachinfo/fr/#{Test_Name}_swissmedicinfo.html")
      end

      def teardown
        super
      end

      def test_import_nothing_imported_with_wrong_companies
        @parser.should_receive(:parse_fachinfo_html)
        @parser.should_receive(:parse_patinfo_html)

        assert(run_import("88888", {reparse: true, target: :both, download: false}), "must be able to run import_swissmedicinfo and add a new registration")
        res = @plugin.report
        assert(/Stored 4 Fachinfos/.match(res))
        assert(/Stored 0 Patinfos/.match(res))
        assert(/Checked 0 companies/.match(res))
        assert_nil(/:iksnr=>/.match(res))
      end

      def test_import_new_registration_xeljanz_from_swissmedicinfo_xml
        reg = flexmock("registration2",
          new: "new",
          store: "store",
          export_flag: false,
          inactive?: false,
          expiration_date: false)
        reg.should_receive(:fachinfo).with(Test_Iksnr).and_return(reg)
        Persistence::Pointer.new([:registration, Test_Iksnr])
        flexmock "fachinfo"
        @parser.should_receive(:parse_fachinfo_html)

        ODDB::AtcClass.new(Test_Atc)
        assert(run_import(Test_Iksnr), "must be able to run import_swissmedicinfo and add a new registration")
        meta = @plugin.iksnrs_meta_info
        refute_nil(meta)
        assert_equal(NrRegistration, meta.size, "we must extract #{NrRegistration} meta info from 2 medicalInformation")
        entry = SwissmedicMetaInfo.new(Test_Iksnr, [Test_Iksnr], Test_Atc, Test_Name, "Pfizer AG", "Tofacitinibum", "fi", "de")
        entry.xml_file = File.join(ODDB::WORK_DIR, "details", "#{Test_Iksnr}_fi_de.xml")
        expected = [entry]
        assert_equal(expected, meta[[Test_Iksnr, "fi", "de"]], "Meta information about Test_Iksnr must be correct")
        assert(@app.registrations.keys.index(Test_Iksnr), "must have created registration " + Test_Iksnr.to_s)
      end

      # Here we used to much memory
      def test_import_57435_baraclude_from_swissmedicinfo_xml
        reg = flexmock("registration3",
          new: "new",
          store: "store")
        reg.should_receive(:fachinfo)
        Persistence::Pointer.new([:registration, Test_57435_Iksnr])
        flexmock "fachinfo"
        @parser.should_receive(:parse_fachinfo_html)

        ODDB::AtcClass.new(Test_57435_Atc)
        assert(run_import(Test_57435_Iksnr), "must be able to run import_swissmedicinfo and add a new registration")
        meta = @plugin.iksnrs_meta_info
        refute_nil(meta)
        assert_equal(NrRegistration, meta.size, "we must extract #{NrRegistration} meta info from 2 medicalInformation")
        entry = SwissmedicMetaInfo.new(Test_57435_Iksnr, ["57435", "57436"], Test_57435_Atc, Test_57435_Name, Test_57435_Inhaber, Test_57435_Substance, "fi", "de")
        entry.xml_file = File.join(ODDB::WORK_DIR, "details", "#{Test_57435_Iksnr}_fi_de.xml")
        expected = [entry]
        assert_equal(expected, meta[[Test_57435_Iksnr, "fi", "de"]], "Meta information about Test_57435_Iksnr must be correct")
        assert(@app.registrations.keys.index(Test_57435_Iksnr), "must have created registration " + Test_57435_Iksnr)
      end
    end

    class TestTextInfoPlugin < Minitest::Test
      def create(dateiname, content)
        FileUtils.makedirs(File.dirname(dateiname))
        ausgabe = File.open(dateiname, "w+")
        ausgabe.write(content)
        ausgabe.close
      end

      def teardown
        ODBA.storage = nil
        super
      end

      def setup
        ODDB::TestHelpers.vcr_setup
        FileUtils.rm_rf(ODDB::WORK_DIR)
        FileUtils.mkdir_p ODDB::WORK_DIR
        @opts = {
          target: :fi,
          reparse: false,
          iksnrs: ["32917"], # auf Zeile 2477310: 1234642 2477314
          companies: [],
          download: false,
          xml_file: File.join(ODDB::TEST_DATA_DIR, "xml", "AipsDownload.xml")
        }
        @app = ODDB::App.new
        @parser = flexmock "parser (simulates ext/fiparse for swissmedicinfo_xml)"
        pi_path_de = File.join(ODDB::TEST_DATA_DIR, "html/patinfo/de/K_nzle_Passionsblume_Kapseln_swissmedicinfo.html")
        pi_de = PatinfoDocument.new
        pi_path_fr = File.join(ODDB::TEST_DATA_DIR, "html/patinfo/fr/Capsules_PASSIFLORE__K_nzle__swissmedicinfo.html")
        PatinfoDocument.new
        @parser.should_receive(:parse_patinfo_html).with(pi_path_de, :swissmedicinfo, "Künzle Passionsblume Kapseln").and_return pi_de
        @parser.should_receive(:parse_patinfo_html).with(pi_path_fr, :swissmedicinfo, "Capsules PASSIFLORE \"Künzle\"").and_return pi_de
        @plugin = TextInfoPlugin.new(@app, @opts)
        @plugin.init_agent
        @plugin.parser = @parser
      end # Fuer Problem mit fachinfo italic

      def teardown
        #      FileUtils.rm_rf ODDB::TEST_DATA_DIR
        ODBA.storage = nil
        super # to clean up FlexMock
      end

      def setup_fachinfo_document heading, text
        fi = FachinfoDocument.new
        fi.iksnrs = Text::Chapter.new
        fi.iksnrs.heading << heading
        fi.iksnrs.next_section.next_paragraph << text
        fi
      end

      def test_import_swissmedicinfo_xml
        fi = flexmock "fachinfo"
        fi.should_receive(:pointer).never.and_return Persistence::Pointer.new([:fachinfo, 1])
        flexmock "patinfo"
        @parser.should_receive(:parse_textinfo).never
        @parser.should_receive(:parse_patinfo_html).never
        @parser.should_receive(:parse_fachinfo_html).at_least.once
        @plugin.extract_matched_content("Zyloric®", "fi", "de")
        assert(@plugin.import_swissmedicinfo(@opts), "must be able to run import_swissmedicinfo")
      end

      def test_import_swissmedicinfo_no_iksnr
        fi = flexmock "fachinfo"
        fi.should_receive(:pointer).and_return Persistence::Pointer.new([:fachinfo, 1])
        pi = flexmock "patinfo"
        pi.should_receive(:pointer).and_return Persistence::Pointer.new([:patinfo, 1])
        # only german fachinfo is present
        @parser.should_receive(:parse_fachinfo_html).at_least.once
        @parser.should_receive(:parse_patinfo_html).never
        opts = {iksnrs: [], xml_file: File.join(ODDB::TEST_DATA_DIR, "xml", "AipsDownload.xml")}
        @plugin = TextInfoPlugin.new(@app, opts)
        @plugin.init_agent
        base = File.join(ODDB::TEST_DATA_DIR, "html/swissmedic")
        {"http://www.swissmedicinfo.ch/Accept.aspx?ReturnUrl=%2f" => File.join(base, "accept.html"),
         "http://www.swissmedicinfo.ch/?Lang=DE" => File.join(base, "lang.html"),
         "http://www.swissmedicinfo.ch/?Lang=FR" => File.join(base, "lang.html")}
        @plugin.parser = @parser
        def @plugin.download_swissmedicinfo_xml
          @dest = File.join(ODDB::WORK_DIR, "xml", "AipsDownload_latest.xml")
          FileUtils.makedirs(File.dirname(@dest))
          FileUtils.cp(File.join(ODDB::TEST_DATA_DIR, "AipsDownload_xeljanz.xml"), @dest)
          File.join(@dest, "AipsDownload_xeljanz.xml")
        end

        def @plugin.textinfo_swissmedicinfo_index
          {new: {de: {fi: [["Zyloric®", "Jan 2014"]],
                      pi: [["Zyloric®", "Jan 2014"]]},
                 fr: {fi: [["Zyloric®", "janv. 2014"]],
                      pi: [["Zyloric®", "janv. 2014"]]}},
           change: {de: {fi: [["Zyloric®", "Jan 2014"]],
                         pi: [["Zyloric®", "Jan 2014"]]},
                    fr: {fi: [["Zyloric®", "janv. 2014"]],
                         pi: [["Zyloric®", "janv. 2014"]]}}}
        end
        @plugin.extract_matched_content("Zyloric®", "fi", "de")
        assert(@plugin.import_swissmedicinfo(@opts), "must be able to run import_swissmedicinfo")
      end
    end

    class TestTextInfoPluginChecks < Minitest::Test
      def teardown
        ODBA.storage = nil
        super # to clean up FlexMock
      end

      def setup
        ODDB::TestHelpers.vcr_setup
        FileUtils.rm_rf(ODDB::WORK_DIR)
        FileUtils.mkdir_p File.join(ODDB::TEST_DATA_DIR, "xml")
        @opts = {
          target: :fi,
          reparse: false,
          iksnrs: ["32917"], # auf Zeile 2477310: 1234642 2477314
          companies: [],
          download: false,
          xml_file: File.join(ODDB::TEST_DATA_DIR, "xml", "AipsDownload.xml")
        }
        @app = flexmock("application", update: @pointer,
          delete: "delete",
          registrations: [],
          registration: @registration)
        @app.should_receive(:registration).with(1, :swissmedicinfo, "Künzle Passionsblume Kapseln").and_return 0
        @app.should_receive(:textinfo_swissmedicinfo_index)
        @parser = flexmock "parser (simulates ext/fiparse for swissmedicinfo_xml)"
        pi_path_de = File.join(ODDB::TEST_DATA_DIR, "html/patinfo/de/K_nzle_Passionsblume_Kapseln_swissmedicinfo.html")
        pi_de = PatinfoDocument.new
        pi_path_fr = File.join(ODDB::TEST_DATA_DIR, "html/patinfo/fr/Capsules_PASSIFLORE__K_nzle__swissmedicinfo.html")
        PatinfoDocument.new
        @parser.should_receive(:parse_patinfo_html).with(pi_path_de, :swissmedicinfo, "Künzle Passionsblume Kapseln").and_return pi_de
        @parser.should_receive(:parse_patinfo_html).with(pi_path_fr, :swissmedicinfo, "Capsules PASSIFLORE \"Künzle\"").and_return pi_de
        @plugin = TextInfoPlugin.new(@app, @opts)
        @plugin.init_agent
        @plugin.parser = @parser
      end # Fuer Problem mit fachinfo italic
    end

    class TestTextInfoPlugin_iksnr < Minitest::Test
      def test_get_iksnr_comprimes
        test_string = "59341 (comprimés filmés), 59342 (comprimés à mâcher), 59343 (granulé oral)"
        assert_equal(["59341", "59342", "59343"], TextInfoPlugin.get_iksnrs_from_string(test_string))
      end

      def test_get_iksnr_lopresor
        test_string = "Zulassungsnummer Lopresor 100: 39'252 (Swissmedic) Lopresor Retard 200: 44'447 (Swissmedic)"
        assert_equal(["39252", "44447"], TextInfoPlugin.get_iksnrs_from_string(test_string))
      end

      def test_get_iksnr_space_at_end
        test_string = "54577 "
        assert_equal(["54577"], TextInfoPlugin.get_iksnrs_from_string(test_string))
      end

      def test_find_iksnr_in_string
        test_string = "54'577, 60’388 "
        assert_equal("54577", TextInfoPlugin.find_iksnr_in_string(test_string, "54577"))
        assert_equal("60388", TextInfoPlugin.find_iksnr_in_string(test_string, "60388"))
      end

      def test_get_iksnr_victrelis
        test_string = "62'105"
        assert_equal(["62105"], TextInfoPlugin.get_iksnrs_from_string(test_string))
        assert_equal("62105", TextInfoPlugin.find_iksnr_in_string(test_string, "62105"))
      end

      def test_get_iksnr_temodal
        test_string = "54'577, 60’388 "
        assert_equal(["54577", "60388"], TextInfoPlugin.get_iksnrs_from_string(test_string))
      end

      def test_get_iksnr_Ringerlactat
        test_string = "Zulassungsnummer\nRingerlactat B. Braun/Ringerlactat + Glucose 5% B. Braun: 38207 (Swissmedic).\nRingerlactat ohne K: 65724 (Swissmedic)."
        assert_equal(["38207", "65724"], TextInfoPlugin.get_iksnrs_from_string(test_string))
      end
    end
  end
  class TestTextInfoTramalPlugin < Minitest::Test
    Auth_15219 = "MEDA Pharma GmbH"
    Aut_43788 = "Grünenthal Pharma AG"

    def stderr_null
      require "tempfile"
      $stderr = Tempfile.open("stderr")
      yield
      $stderr.close
      $stderr = STDERR
    end

    def replace_constant(constant, temp)
      stderr_null do
        eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end

    def create(dateiname, content)
      FileUtils.makedirs(File.dirname(dateiname))
      ausgabe = File.open(dateiname, "w+")
      ausgabe.write(content)
      ausgabe.close
    end

    def teardown
      ODBA.storage = nil
      super
    end

    def setup
      ODDB::TestHelpers.vcr_setup
      FileUtils.rm_rf(ODDB::WORK_DIR)
      FileUtils.mkdir_p ODDB::WORK_DIR
      @opts = {
        target: :pi,
        reparse: true,
        iksnrs: ["43788"],
        companies: [],
        download: false,
        xml_file: File.join(ODDB::TEST_DATA_DIR, "xml", "43788.xml")
      }
      @app = ODDB::App.new
      @plugin = TextInfoPlugin.new(@app, @opts)
      @plugin.init_agent
      File.open(ODDB::TextInfoPlugin::Override_file, "w+") do |file|
        file.puts %(---
7680437880197_pi_de: 'Tramal® Tropfen, Lösung zum Einnehmen mit Dosierpumpe.'
7680437880197_pi_it: 'Tramal® gocce, soluzione orale con pompetta dosatrice'
7680437880869_pi_de: 'Tramal® Tropfen, Lösung zum Einnehmen mit Dosierpumpe.'
)
      end
      @parser = flexmock "parser (simulates ext/fiparse for swissmedicinfo_xml)"
      @plugin.parser = @parser
    end

    def setup_texinfo_mock(type = :fachinfo)
      textinfo = flexmock(type)
      textinfo.should_receive(:change_log).and_return([]).by_default
      textinfo.should_receive(:change_log=).and_return(nil).by_default
      textinfo.should_receive(:iksnr).and_return("iksnr")
      textinfo.should_receive(:iksnrs).and_return("iksnrs")
      textinfo.should_receive(:pointer).and_return(Persistence::Pointer.new(type))
      textinfo.should_receive(:text).and_return("text #{type}")
      textinfo.should_receive(:odba_isolated_store).and_return("odba_isolated_store")
      textinfo
    end

    def setup_refdata_mock
      @swissindex = flexmock("swissindex", search_item: {gtin: "7658123456789"})
      @server = flexmock("server") do |serv|
        serv.should_receive(:session).and_yield(@swissindex)
      end
    end
    if RunAll
      def test_import_patinfo_tramal_43788
        @opts[:iksnrs] = ["43788", "15219"]
        @opts[:target] = :pi
        @plugin = TextInfoPlugin.new(@app, @opts)
        @plugin.init_agent
        patinfo = Patinfo.new
        @parser.should_receive(:parse_fachinfo_html).never
        @parser.should_receive(:parse_patinfo_html).and_return(patinfo).at_least.once
        @parser.should_receive(:parse_textinfo).never
        @plugin.parser = @parser

        @app.create_registration("15219")
        info2 = flexmock("info 15219")
        info2.should_receive(:iksnr).and_return("15219")
        info2.should_receive(:title).and_return("Zymafluor® ¼ mg + 1 mg")
        info2.should_receive(:authHolder).and_return("authHolder")
        TextInfoPlugin.create_registration(@app, info2, "01", "001")
        info = flexmock("info")
        info.should_receive(:iksnr).and_return("43788")
        info.should_receive(:title).and_return("Tramal, Tropfen")
        info.should_receive(:authHolder).and_return("authHolder")
        TextInfoPlugin.create_registration(@app, info, "01", "019") # Ohne Dosierpumpe
        TextInfoPlugin.create_registration(@app, info, "01", "086") # Mit Dosierpumpe
        @app.registration("15219").company = Auth_15219
        @app.registration("43788").company = Aut_43788

        setup_refdata_mock
        replace_constant("ODDB::RefdataPlugin::REFDATA_SERVER", @server) do
          assert(@plugin.import_swissmedicinfo(@opts), "must be able to run import_swissmedicinfo")
        end
        assert(File.exist?(@plugin.problematic_fi_pi), "Datei #{@plugin.problematic_fi_pi} must exist")
        path = File.join(ODDB::PROJECT_ROOT, "doc/resources/images/pi/de/43788_Tramal__Tr/1.png")
        assert(File.exist?(path), "Created image file #{path} must exist")
        @app.registration("15219").packages.size
        @app.registration("15219").packages.values.find_all { |x| x.patinfo }
        @app.registration("15219").sequences.values.find_all { |x| x.patinfo }
      end

      def test_import_fachinfo_tramal_43788
        Fachinfo.new
        info = flexmock("info 43788")
        info.should_receive(:iksnr).and_return("43788")
        info.should_receive(:title).and_return("Tramal, Tropfen")
        info.should_receive(:authHolder).and_return("authHolder")
        TextInfoPlugin.create_registration(@app, info, "01", "019") # Ohne Dosierpumpe
        TextInfoPlugin.create_registration(@app, info, "01", "086") # Mit Dosierpumpe
        @app.registration("43788").company = Aut_43788

        setup_refdata_mock
        @parser.should_receive(:parse_fachinfo_html)
        replace_constant("ODDB::RefdataPlugin::REFDATA_SERVER", @server) do
          @opts[:target] = :fi
          assert(@plugin.import_swissmedicinfo(@opts), "must be able to run import_swissmedicinfo")
        end
        assert(File.exist?(@plugin.problematic_fi_pi), "#{@plugin.problematic_fi_pi} must exist")
        assert(File.size(@plugin.problematic_fi_pi) > 100, "#{@plugin.problematic_fi_pi} must be > 100 bytes")
      end
    end

    def test_import_newest_only
      fachinfo = setup_texinfo_mock(:fachinfo)
      @parser.should_receive(:parse_patinfo_html).never
      @parser.should_receive(:parse_fachinfo_html).at_least.once.and_return { fachinfo }
      info = flexmock("info 43788")
      info.should_receive(:iksnr).and_return("43788")
      info.should_receive(:title).and_return("Tramal, Tropfen")
      info.should_receive(:authHolder).and_return("authHolder")
      TextInfoPlugin.create_registration(@app, info, "01", "019") # Ohne Dosierpumpe
      TextInfoPlugin.create_registration(@app, info, "01", "086") # Mit Dosierpumpe
      @app.registration("43788").company = Aut_43788
      # Test Changelog
      fachinfo.should_receive(:change_log).and_return([]).at_least.once
      fachinfo.should_receive(:change_log=).and_return(nil).at_least.once

      setup_refdata_mock
      replace_constant("ODDB::RefdataPlugin::REFDATA_SERVER", @server) do
        @opts[:target] = :fi
        @opts[:newest] = false # TODO:
        @opts[:parse] = false
        assert(@plugin.import_swissmedicinfo(@opts), "must be able to run import_swissmedicinfo")
      end
      assert(File.exist?(@plugin.problematic_fi_pi))
      assert(File.size(@plugin.problematic_fi_pi) > 100)
      nr_fis = 8
      nr_pis = 0
      puts @plugin.report
      skip("What are the expectations for test_import_newest_only newest with true and/or false")
      assert_equal(nr_fis, @plugin.updated_fis.size)
      assert_equal(nr_pis, @plugin.updated_pis.size)
      assert(nr_fis + nr_pis, @plugin.updated.size)
    end
  end
end
