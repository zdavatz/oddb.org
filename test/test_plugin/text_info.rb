#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'stub/odba'

require 'minitest/autorun'
require 'stub/oddbapp'
require 'fileutils'
require 'flexmock/minitest'
require 'plugin/text_info'
require 'model/text'
module ODDB
  RUN_ALL = false
  class FachinfoDocument
		def odba_id
			1
		end
	end
  class TextInfoPlugin
    attr_accessor :parser
    attr_reader :to_parse, :iksnrs_meta_info, :updated_fis, :updated_pis,
        :corrected_pis, :corrected_fis, :up_to_date_fis, :up_to_date_pis,
        :details_dir
  end

  class TestTextInfoPlugin <MiniTest::Test
    @@datadir = File.expand_path '../data/html/text_info', File.dirname(__FILE__)
    @@vardir = File.expand_path '../var/', File.dirname(__FILE__)
    def setup
      super
      @app = flexmock 'application'
      FileUtils.mkdir_p @@vardir
      ODDB.config.data_dir = @@vardir
      ODDB.config.log_dir = @@vardir
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
  end if RUN_ALL

  class TestExtractMatchedName <MiniTest::Test
    Nr_FI_in_AIPS_test = 4
    Nr_PI_in_AIPS_test = 1
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup
      pointer = flexmock 'pointer'
      @aips_download = File.expand_path('../data/xml/Aips_test.xml', File.dirname(__FILE__))
      latest_from = File.expand_path('../data/xlsx/Packungen-latest.xlsx', File.dirname(__FILE__))
      latest_to = File.expand_path('../../data/xls/Packungen-latest.xlsx', File.dirname(__FILE__))
      FileUtils.cp(latest_from, latest_to, :verbose => true, :preserve => true)
      @app = flexmock 'application'
      @reg = flexmock 'registration'
      @reg.should_receive(:pointer).and_return(pointer).by_default
      @reg.should_receive(:odba_store).and_return(nil).by_default
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

      @fachinfo = flexmock 'fachinfo'
      @fachinfo.should_receive(:de).and_return(lang_de)
      @fachinfo.should_receive(:fr).and_return(lang_de)
      @fachinfo.should_receive(:it).and_return(lang_de)
      @fachinfo.should_receive(:oid).and_return('oid')
      @fachinfo.should_receive(:pointer).and_return(pointer)
      @fachinfo.should_receive(:descriptions).and_return(@descriptions)
      @fachinfo.should_receive(:odba_store)
      @fachinfo.should_receive(:iksnrs).and_return(['56079'])
      @fachinfo.should_receive(:name_base).and_return('name_base')

      @app.should_receive(:create_patinfo).and_return(Patinfo.new)

      atc_class = flexmock('atc_class')
      atc_class.should_receive(:code).and_return('code')
      @sequence = flexmock 'sequence'
      @sequence.should_receive(:seqnr).and_return('01')
      @sequence.should_receive(:pointer).and_return(pointer)
      @sequence.should_receive(:odb_store)
      @sequence.should_receive(:atc_class).and_return(atc_class)
      @sequence.should_receive(:patinfo).and_return(nil).by_default
      @sequence.should_receive(:patinfo=).and_return(nil).by_default
      @sequence.should_receive(:odba_store)
      @package = flexmock('package')
      @sequence.should_receive(:package).and_return(@package)

      atc_class = flexmock 'atc_class'
      atc_class.should_receive(:pointer).and_return(pointer)
      @app.should_receive(:atc_class).and_return(atc_class)
      @app.should_receive(:update).and_return(@fachinfo)
      @reg.should_receive(:fachinfo).and_return(@fachinfo)
      @reg.should_receive(:iksnr).and_return('56079')
      @reg.should_receive(:name_base).and_return('name_base')
      @reg.should_receive(:packages).and_return([])
      @app.should_receive(:registration).and_return(@reg)
      @app.should_receive(:registrations).and_return({'x' => @reg})
      @app.should_receive(:sequences).and_return([@sequence])
      @reg.should_receive(:sequences).and_return({'01' => @sequence})
      @reg.should_receive(:sequence).and_return(@sequence)
      @parser = flexmock('parser (simulates ext/fiparse)',
                         :parse_fachinfo_html => 'fachinfo_html',
                         :parse_patinfo_html => 'patinfo_html',
                         )
      @reg.should_receive(:each_package).and_return([]).by_default
      @reg.should_receive(:each_sequence).and_return([@sequence]).by_default
      @plugin = TextInfoPlugin.new @app
      FileUtils.rm_rf(@plugin.details_dir, :verbose => true)
      @plugin.parser = @parser
      @plugin.download_swissmedicinfo_xml(@aips_download)
      @options = {:target => :both,
                  :download => false,
                  :xml_file => @aips_download,
                  }
    end
if RUN_ALL
    def test_53662_pi_de
      @options[:iksnrs] = ['53662']
      @plugin.import_swissmedicinfo(@options)
      assert_equal('3TC®', @plugin.iksnrs_meta_info[["53662", 'fi', 'de']].first.title)
      assert_equal('3TC®', @plugin.iksnrs_meta_info[["53663", 'fi', 'de']].first.title)
    end
    def test_Erbiumcitrat_de
      @options[:iksnrs] = ['51704']
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
      @options[:newest] = true
      # Add tests that fachinfo gets updated
      # @reg.should_receive(:odba_store).at_least.once
      # @fachinfo.should_receive(:odba_store).at_least.once
      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size > 0, 'must find at least one find fachinfo')

      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'must find patinfo')

      assert_equal(Nr_PI_in_AIPS_test, @plugin.updated_fis.size, 'nr updated fis must match')
      assert_equal(0, @plugin.updated_pis.size, 'nr updated pis must match')

      assert_equal(0, @plugin.corrected_fis.size, 'corrected_fis must match')
      assert_equal(0, @plugin.corrected_pis.size, 'corrected_pis must match')

      assert_equal(0, @plugin.up_to_date_pis, 'up_to_date_pis must match')
      # nr_fis = 6 # we add all missing
      assert_equal(3, @plugin.up_to_date_fis, 'up_to_date_fis must match')

      @plugin = TextInfoPlugin.new @app
      @plugin.parser = @parser
      @plugin.download_swissmedicinfo_xml(@aips_download)
      @plugin.import_swissmedicinfo(@options)
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size, 'must find fachinfo')
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'may not find patinfo')
    end
    def test_import_daily_pi
      @options[:target] = :pi
      @options[:newest] = true
      # Add tests that patinfo gets updated
      # @reg.should_receive(:odba_store).at_least.once
      # @sequence.should_receive(:odba_store).at_least.once
      # @descriptions.should_receive(:[]=).at_least.once

      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size > 0, 'must find at least one find patinfo')
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size, 'must find fachinfo')
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'may not find patinfo')

      assert_equal(Nr_PI_in_AIPS_test , @plugin.updated_pis.size, 'nr updated pis must match')
      assert_equal(0, @plugin.up_to_date_pis, 'up_to_date_pis must match')
      assert_equal(Nr_PI_in_AIPS_test , @plugin.corrected_pis.size, 'nr corrected_pis must match')

      assert_equal(0, @plugin.corrected_fis.size, 'nr corrected_fis must match')
      assert_equal(0, @plugin.updated_fis.size, 'nr updated fis must match')
      assert_equal(0, @plugin.up_to_date_fis, 'up_to_date_fis must match')
    end
  end
    def test_import_daily_packungen
      @options[:target] = :pi
      @options[:newest] = true
      # Add tests that patinfo gets updated
      @plugin.import_swissmedicinfo(@options)
      assert(@plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size > 0, 'must find at least one find patinfo')
      assert_equal(Nr_FI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'fi'}.size, 'must find fachinfo')
      assert_equal(Nr_PI_in_AIPS_test, @plugin.iksnrs_meta_info.keys.find_all{|key| key[1] == 'pi'}.size, 'may not find patinfo')

      puts @plugin.report
      assert_equal(Nr_PI_in_AIPS_test , @plugin.updated_pis.size, 'nr updated pis must match')
      assert_equal(0, @plugin.up_to_date_pis, 'up_to_date_pis must match')
      assert_equal(Nr_PI_in_AIPS_test , @plugin.corrected_pis.size, 'nr corrected_pis must match')

      assert_equal(0, @plugin.corrected_fis.size, 'nr corrected_fis must match')
      assert_equal(0, @plugin.updated_fis.size, 'nr updated fis must match')
      assert_equal(0, @plugin.up_to_date_fis, 'up_to_date_fis must match')
    end

  end
end
