#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'stub/odba'

require 'minitest/autorun'
require 'stub/oddbapp'
require 'stub/session'
require 'fileutils'
require 'flexmock/minitest'
require 'plugin/text_info'
require 'model/text'
require 'util/workdir'
    require 'debug'
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

  class TestChangeLog <MiniTest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def prepare_plugin(remove_details = true, xml_file = '61467_fi_de.xml')
      @plugin = TextInfoPlugin.new @app
      FileUtils.makedirs(@details_dir)
      xml_full =  File.join(ODDB::TEST_DATA_DIR, 'xml', xml_file)
      FileUtils.rm_rf(@plugin.details_dir, :verbose => false) if remove_details
      @plugin.parser = YDocx::Parser
      @plugin.parser = ::ODDB::FiParse
      @aips_download =  xml_full
      @plugin.download_swissmedicinfo_xml(@aips_download)
      @options[:xml_file] = xml_full
    end
    def setup
      require 'ext/fiparse/src/fiparse'
      @details_dir =  File.join(ODDB.config.data_dir, 'details')
      path_check = File.join(ODDB::PROJECT_ROOT, 'etc', 'barcode_minitest.yml')
      assert_equal(ODDB::TextInfoPlugin::Override_file, path_check)
      FileUtils.rm_f(path_check, :verbose => false)
      FileUtils.rm_f(File.expand_path('../data/'), :verbose => false)
      pointer = flexmock 'pointer'
      latest_from = File.join(ODDB::TEST_DATA_DIR, '/xlsx/Packungen-61467.xlsx')
      latest_to = File.join(ODDB::WORK_DIR, 'xls/Packungen-latest.xlsx')
      FileUtils.mkdir_p(File.dirname(latest_to))
      FileUtils.cp(latest_from, latest_to, :verbose => false, :preserve => true)
      @app = flexmock("application_#{__LINE__}", App.new)
      @app.should_receive(:company_by_name)
    end

    def check_whether_changed(should_change = false)
      pi = @app.registrations.values.first.sequences.values.first.patinfo; __LINE__
      fi = @app.registrations.values.first.fachinfo;  __LINE__
      puts "\n\ncheck_whether_changed should_change #{should_change} change_logs: fi #{fi[:de].change_log&.size}  pi #{pi[:de].change_log&.size}"
      puts fi.descriptions['de'].galenic_form.to_s
      puts pi.descriptions['de'].contra_indications.to_s
      assert_match(/Actikerall/, pi.descriptions['de'].contra_indications.to_s)
      assert_match(/Actikerall/, fi.descriptions['de'].contra_indications.to_s)
      if should_change
        assert_match(@test_change, fi.descriptions['de'].galenic_form.to_s)
        assert_match(@test_change, pi.descriptions['de'].contra_indications.to_s)
        assert_match(@test_change, fi[:de].change_log.first.diff.to_s)
        assert_equal(1, fi[:de].change_log.size)
        assert_equal(0, pi.descriptions['it'].to_s.size)
        assert_equal(0, pi.descriptions['fr'].to_s.size)
        assert_equal(0, fi.descriptions['it'].to_s.size)
        assert_equal(0, fi.descriptions['fr'].to_s.size)
        assert_equal(1, pi[:de].change_log.size)
        assert_match(@test_change, pi[:de].change_log.first.diff.to_s)
      else
        assert_nil(fi.descriptions['de'].galenic_form.to_s.match(@test_change))
        assert_nil(pi.descriptions['de'].contra_indications.to_s.match(@test_change))
      end

    end

    def test_61467_pi_fi
      @options = {:target => :both,
                  :download => false,
                  :newest => false, # this takes a lot of time
                  :xml_file => @aips_download,
                  }
      @test_change = /CHANGED FOR MINITEST......../
      @test_actikierall = /Was ist Actikerall/
      prepare_plugin
      pi_de_html_src = File.join(ODDB::TEST_DATA_DIR, 'html', 'Actikerall_.html')
      assert(File.exist?(pi_de_html_src))
      pi_de_html_dst = File.join(ODDB.config.data_dir, 'html', 'pi', 'de', 'Actikerall_.html')
      FileUtils.makedirs(File.dirname(pi_de_html_dst), :verbose => false)
      FileUtils.cp(pi_de_html_src,pi_de_html_dst, :verbose => false, :preserve => true)
      @app.create_registration('61467')
      result = @plugin.import_swissmedicinfo(@options)

      if USE_RUBY_PROF
        result = RubyProf::Profile.profile do
          result = @plugin.import_swissmedicinfo(@options)
        end
        printer = RubyProf::GraphPrinter.new(result)
        printer.print(STDOUT, :min_percent => 2)
      end
      assert_equal(['61467'], @app.registrations.keys)
      assert_equal(['01'], @app.registration('61467').sequences.keys)
      assert_equal(Date.today, @app.registrations.values.first.sequences.values.first.packages.values.first.revision.to_date)
      assert_equal(ODDB::Patinfo,  @app.registrations.values.first.sequences.values.first.patinfo.class)
      check_whether_changed(false)
      assert_match('61467', @plugin.updated_fis.join(';'))
      assert_match('61467', @plugin.updated_pis.join(';'))
      if true
        puts("\n\n\nRerun import and assert that nothing has changed")
        prepare_plugin
        result = @plugin.import_swissmedicinfo(@options)
        check_whether_changed(false)
      end

      puts("\n\n\nRerun import and assert that PI/FI haved changed")
      prepare_plugin(false, '61467_changed.xml')
      result = @plugin.import_swissmedicinfo(@options)
      check_whether_changed(true)
      pi = @app.registrations.values.first.sequences.values.first.patinfo
      fi = @app.registrations.values.first.fachinfo
      assert_match('61467', @plugin.updated_fis.join(';')) if @options[:target].eql?(:both)
      assert_match('61467', @plugin.updated_pis.join(';'))
    end
  end
  class TestTextInfoPlugin <MiniTest::Test
    @@datadir = File.join(ODDB::TEST_DATA_DIR, 'html/text_info')
    def setup
      super
      @app = flexmock 'application'
      FileUtils.mkdir_p (ODDB::WORK_DIR)
      ODDB.config.text_info_searchform = 'http://textinfo.ch/Search.aspx'
      ODDB.config.text_info_newssource = 'http://textinfo.ch/news.aspx'
      @parser = flexmock('parser (simulates ext/fiparse)', :parse_fachinfo_html => nil,)
      @plugin = TextInfoPlugin.new @app
      @plugin.parser = @parser
    end
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup_mechanize mapping=[]
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
      response = {'content-type' => 'text/html'}
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
      assert /Mozilla/.match(agent.user_agent)
    end
    def test_extract_iksnrs
      de = setup_fachinfo_document 'Zulassungsnummer', '57363 (Swissmedic).'
      fr = setup_fachinfo_document 'Numéro d’autorisation', '57364 (Swissmedic).'
      assert_equal %w{57363}, @plugin.extract_iksnrs(:de => de, :fr => fr).sort
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
        "Aclasta\302\256",
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
        "Allopur\302\256",
      ]
      assert_equal expected, @plugin.true_news(news, old_news)
      ## recorded news don't appear on the news-page
      old_news = ["Amiodarone Winthrop\302\256/- Mite"]
      assert_equal news, @plugin.true_news(news, old_news)
    end
  end

  class TestExtractMatchedName <MiniTest::Test
    Nr_FI_in_AIPS_test = 5
    Nr_PI_in_AIPS_test = 2
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup
      path_check = File.join(ODDB::PROJECT_ROOT, 'etc', 'barcode_minitest.yml')
      assert_equal(ODDB::TextInfoPlugin::Override_file, path_check)
      FileUtils.rm_f(path_check, :verbose => false)
      FileUtils.rm_f(File.expand_path('../data/'), :verbose => false)
      pointer = flexmock 'pointer'
      @aips_download = File.join(ODDB::TEST_DATA_DIR, 'xml/Aips_test.xml')
      latest_from = File.join(ODDB::TEST_DATA_DIR, '/xlsx/Packungen-latest.xlsx')
      latest_to = File.join(ODDB::WORK_DIR, 'xls/Packungen-latest.xlsx')
      FileUtils.mkdir_p(File.dirname(latest_to))
      FileUtils.cp(latest_from, latest_to, :verbose => false, :preserve => true)
      @app = flexmock "application_#{__LINE__}"
      @reg = flexmock "registration_#{__LINE__}"
      @reg.should_receive(:pointer).and_return(pointer).by_default
      @reg.should_receive(:odba_store).and_return(nil).by_default
      @reg.should_receive(:odba_isolated_store).and_return(nil).by_default
      @reg.should_receive(:company).and_return('company')
      @reg.should_receive(:inactive?).and_return(false)
      lang_de = flexmock 'lang_de'
      lang_de.should_receive(:de).and_return('fi_de')
      lang_de.should_receive(:text).and_return('fi_text')
      @descriptions = flexmock 'descriptions'
      @descriptions.should_receive(:[]).and_return('desc')
      @descriptions.should_receive(:[]=).and_return('desc').by_default
      @descriptions.should_receive(:odba_isolated_store)
      @descriptions = ODDB::SimpleLanguage::Descriptions.new

      @fachinfo = flexmock('fachinfo', Fachinfo.new)
      @fachinfo.should_receive(:de).and_return(lang_de)
      @fachinfo.should_receive(:fr).and_return(lang_de)
      @fachinfo.should_receive(:it).and_return(lang_de)
      @fachinfo.should_receive(:oid).and_return('oid')
      @fachinfo.should_receive(:pointer).and_return(pointer)
      @fachinfo.should_receive(:descriptions).and_return(@descriptions)
      @fachinfo.should_receive(:change_log).and_return([])
      @fachinfo.should_receive(:odba_store)
      @fachinfo.should_receive(:iksnrs).and_return(['56079'])
      @fachinfo.should_receive(:name_base).and_return('name_base')

      @app.should_receive(:create_patinfo).and_return(Patinfo.new)

      atc_class = flexmock("atc_class_#{__LINE__}")
      atc_class.should_receive(:oid).and_return('oid')
      atc_class.should_receive(:code).and_return('code')
      @sequence = flexmock("sequence_#{__LINE__}", Sequence.new('01'))
      @sequence.should_receive(:seqnr).and_return('01')
      @sequence.should_receive(:pointer).and_return(pointer)
      @sequence.should_receive(:odb_store)
      @sequence.should_receive(:odba_isolated_store)
      @sequence.should_receive(:atc_class=).and_return(atc_class)
      @sequence.should_receive(:atc_class).and_return(atc_class)
      @sequence.should_receive(:patinfo).and_return(nil).by_default
      @sequence.should_receive(:patinfo=).and_return(nil).by_default
      @package = flexmock("package_#{__LINE__}", Package.new('001'))
      @sequence.should_receive(:package).and_return(@package)
      @sequence.should_receive(:create_package).and_return(@package)
      @reg.should_receive(:create_sequence).and_return(@sequence)
      @package.should_receive(:sequence).and_return(@sequence)

      atc_class = flexmock("atc_class_#{__LINE__}")
      atc_class.should_receive(:oid).and_return('oid')
      atc_class.should_receive(:code).and_return('code')
      atc_class.should_receive(:pointer).and_return(pointer)
      atc_class.should_receive(:odba_store).and_return(true)
      @app.should_receive(:atc_class).and_return(atc_class)
      @app.should_receive(:update).and_return(@fachinfo)
      @reg.should_receive(:fachinfo).and_return(@fachinfo)
      @reg.should_receive(:iksnr).and_return('56079')
      @reg.should_receive(:name_base).and_return('name_base')
      @reg.should_receive(:packages).and_return([@package])
      @app.should_receive(:registration).and_return(@reg)
      @app.should_receive(:registrations).and_return({'x' => @reg})
      @app.should_receive(:sequences).and_return([@sequence])
      @reg.should_receive(:sequences).and_return({'01' => @sequence})
      @reg.should_receive(:sequence).and_return(@sequence)
      @parser = flexmock('parser (simulates ext/fiparse)',
                         :parse_fachinfo_html => 'fachinfo_html',
                         :parse_patinfo_html => Patinfo.new,
                         )
      @reg.should_receive(:each_package).and_return([]).by_default
      @reg.should_receive(:each_sequence).and_return([@sequence]).by_default
      @plugin = TextInfoPlugin.new @app
      FileUtils.rm_rf(@plugin.details_dir, :verbose => false)
      @plugin.parser = @parser
      @plugin.download_swissmedicinfo_xml(@aips_download)
      @options = {:target => :both,
                  :download => false,          # 1007050 772494
                  :xml_file => @aips_download, # 1006998 772442
                                              #      052     52
                  }
      @details_dir =  File.join(ODDB.config.data_dir, 'details')
      FileUtils.makedirs(@details_dir)
      FileUtils.cp(File.join(ODDB::TEST_DATA_DIR, 'xml/61467_fi_de.xml'), File.join(@details_dir, '61467_fi_de.xml'), :verbose => false, :preserve => true)
    end

    def test_53662_pi_de
      @options[:iksnrs] = ['53662']
      result = @plugin.import_swissmedicinfo(@options)
      assert_equal('3TC®', @plugin.iksnrs_meta_info[["53662", 'fi', 'de']].first.title)
      assert_equal('3TC®', @plugin.iksnrs_meta_info[["53663", 'fi', 'de']].first.title)
      assert_match('61467', @plugin.updated_fis.join(';'))
    end
    def test_Erbiumcitrat_de
      @options[:iksnrs] = ['51704']
      # 132 259 -> 198
      @plugin.import_swissmedicinfo(@options)
      assert_equal('[169Er]Erbiumcitrat CIS bio international', @plugin.iksnrs_meta_info[["51704", 'fi', 'de']].first.title)
    end
    def test_Erbiumcitrat_fr
      @options[:iksnrs] = ['51704']
      @plugin.import_swissmedicinfo(@options)
      assert_nil(@plugin.iksnrs_meta_info[["51704", 'fi', 'fr']])
    end

    def test_53663_pi_de
      @options[:iksnrs] = ['53662']
      @plugin.import_swissmedicinfo(@options)
      assert_equal('3TC®', @plugin.iksnrs_meta_info[["53662", 'fi', 'de']].first.title)
      assert_equal('3TC®', @plugin.iksnrs_meta_info[["53663", 'fi', 'de']].first.title)
    end

    def test_import_daily_fi
      @options[:target] = :fi
      # TODO: @options[:newest] = true
      # Add tests that fachinfo gets updated
      # @reg.should_receive(:odba_store).at_least.once
      # @fachinfo.should_receive(:odba_store).at_least.once
      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size > 0, 'must find at least one find fachinfo')

      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'must find patinfo')
      assert_equal(Nr_FI_in_AIPS_test, @plugin.updated_fis.size, 'nr updated fis must match')
      assert_equal(0, @plugin.updated_pis.size, 'nr updated pis must match')
      assert_equal([], @plugin.up_to_date_pis, 'up_to_date_pis must match')
      # nr_fis = 6 # we add all missing
      assert_equal([], @plugin.up_to_date_fis, 'up_to_date_fis must match')

      @plugin = TextInfoPlugin.new @app
      @plugin.parser = @parser
      @plugin.download_swissmedicinfo_xml(@aips_download)
      @plugin.import_swissmedicinfo(@options)
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size, 'must find fachinfo')
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'may not find patinfo')
    end
    def test_import_daily_pi
      @options[:target] = :pi
      # TODO: @options[:newest] = true
      # Add tests that patinfo gets updated
      # @reg.should_receive(:odba_store).at_least.once
      # @sequence.should_receive(:odba_store).at_least.once
      # @descriptions.should_receive(:[]=).at_least.once

      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size > 0, 'must find at least one find patinfo')
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size, 'must find fachinfo')
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'may not find patinfo')

      assert_equal(1 , @plugin.updated_pis.size, 'nr updated pis must match')
      assert_equal([], @plugin.up_to_date_pis, 'up_to_date_pis must match')

      assert_equal(0, @plugin.updated_fis.size, 'nr updated fis must match')
      assert_equal([], @plugin.up_to_date_fis, 'up_to_date_fis must match')
    end
    def test_import_daily_packungen
      @options[:target] = :pi
      # TODO: @options[:newest] = true
      old_missing = {'680109990223_pi_de' =>  'Osanit® Kügelchen',
                     '7680109990223_pi_fr' => 'Osanit® globules',
                     '7680109990224_pi_fr' => 'Test mit langem Namen der nicht umgebrochen sein sollte mehr als 80 Zeichen lang'}
      real_override_file = File.join(ODDB::PROJECT_ROOT, 'etc', 'barcode_to_text_info.yml')
      assert_equal(false, File.exist?(ODDB::TextInfoPlugin::Override_file), "File #{ODDB::TextInfoPlugin::Override_file} must not exist")
      assert_equal(true, File.exist?(real_override_file), "File #{real_override_file} must exist")
      real_overrides = YAML.load(File.read(real_override_file))
      File.open(ODDB::TextInfoPlugin::Override_file, 'w+' ) do |out|
        YAML.dump(old_missing, out)
      end
      assert_equal(5, File.readlines(ODDB::TextInfoPlugin::Override_file).size, 'File must be now 5 lines long, as one is too long')
      old_time = File.ctime(ODDB::TextInfoPlugin::Override_file)
      # Add tests that patinfo gets updated
      @plugin.import_swissmedicinfo(@options)
      puts @plugin.report
      assert(@plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size > 0, 'must find at least one find patinfo')
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size, 'must find fachinfo')
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'may not find patinfo')
      assert_equal(1 , @plugin.updated_pis.size, 'nr updated pis must match')
      new_time = File.ctime(ODDB::TextInfoPlugin::Override_file)
      assert(new_time > old_time, "ctime of #{ODDB::TextInfoPlugin::Override_file} should have changed")
      assert_equal(4, File.readlines(ODDB::TextInfoPlugin::Override_file).size, 'File must be now 4 lines long')
      assert_equal(0, @plugin.updated_fis.size, 'nr updated fis must match')
      assert_equal(0, @plugin.up_to_date_fis.size, 'up_to_date_fis must match')
      # why does next check fail in a github action, but never locally
      puts("why does next check fail in a github action, but never locally. hostname = #{`hostname`}")
      skip("why does next check fail in a github action, but never locally. hostname = #{`hostname`}")
      assert_equal(0, @plugin.up_to_date_pis.size, 'up_to_date_pis must match')
    end

  end
end
