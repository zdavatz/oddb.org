#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('../..', File.dirname(__FILE__))

# gem 'minitest'
# require 'minitest/autorun'
# Here we don't use minitest, as with minitest wron numbers of calls are not correctly handled
# I should probably file a bug against it!
require 'test/unit'
require 'fileutils'
require 'flexmock'
require 'plugin/text_info'
require 'model/text'
require 'model/atcclass'
require 'model/registration'

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
    attr_accessor :parser, :iksless, :session_failures, :current_search,
                  :current_eventtarget
    def read_packages
      @packages = { '32917' => 'Zyloric®'} 
    end    
  end

  class TestTextInfoPluginAipsMetaData <Test::Unit::TestCase
    include FlexMock::TestCase
    unless defined?(@@datadir)
      @@datadir = File.expand_path '../data/xml', File.dirname(__FILE__)
      @@vardir = File.expand_path '../var/', File.dirname(__FILE__)
    end
    
    Test_Iksnr = '62630'
    Test_Name  = 'Xeljanz'
    Test_Atc   = 'L04AA29'
    def setup
      flexmock(ODDB::SequenceObserver) do 
        |klass|
        klass.should_receive(:set_oid).and_return('oid')
        klass.should_receive(:new).and_return('new')
        klass.should_receive(:initialize).and_return('initialize')
      end
      flexstub(ODDB::Persistence) do |klass|
        klass.should_receive(:set_oid).and_return('oid')
      end
      FileUtils.mkdir_p @@vardir
      ODDB.config.data_dir = @@vardir
      ODDB.config.log_dir = @@vardir
      @opts = {
        :target   => [:fi],
        :reparse  => false,
        :iksnrs   => [Test_Iksnr],
        :companies => [],
        :download => false,
      }
      @dest = File.join(@@vardir, 'xml', 'AipsDownload_latest.xml')
      FileUtils.makedirs(File.dirname(@dest))
      FileUtils.cp(File.join(@@datadir, 'AipsDownload_xeljanz.xml'), @dest)
      @sequence = flexmock('sequence', :creator => 'creator')
      @pointer = flexmock('pointer', :+ => @sequence)
      @company = flexmock('company',
                          :pointer => @pointer)
      @registration = flexmock('registration',
                          :pointer => @pointer)
      @registration2 = flexmock('registration2')
      @registrations = []
      @app = flexmock('application', 
                      :update => @registration, 
                      :delete => 'delete',
                      :registrations => [@registration, @registration2])
      @app.should_receive(:textinfo_swissmedicinfo_index)
      @parser = flexmock 'parser (simulates ext/fiparse for swissmedicinfo_xml)'
      @fi_path_de = File.join(@@vardir, "html/fachinfo/de/#{Test_Name}_swissmedicinfo.html")

      @fi_path_fr = File.join(@@vardir, "html/fachinfo/fr/#{Test_Name}_swissmedicinfo.html")    
      @plugin = TextInfoPlugin.new(@app, @opts)
      agent = @plugin.init_agent
      @plugin.parser = @parser
    end
    
    def teardown
#      FileUtils.rm_rf(@@vardir)
      super
    end

    def test_import_new_registration_from_swissmedicinfo_xml
      reg = flexmock('registration', :new => 'new')
      reg.should_receive(:fachinfo)
      ptr = Persistence::Pointer.new([:registration, Test_Iksnr])
      fi = flexmock 'fachinfo'
      flags = {:de => :up_to_date, :fr => :up_to_date}
      @parser.should_receive(:parse_fachinfo_html)

      newReg = ODDB::Registration.new(Test_Iksnr)
      atc    = ODDB::AtcClass.new(Test_Atc)
      @app.should_receive(:registration).with(Test_Iksnr).once.and_return(nil)
      @app.should_receive(:registration).with(Test_Iksnr).times(1).and_return(newReg)
      @app.should_receive(:registration).once.with("32917").and_return("32917")
#      @app.should_receive(:create_registration).once.with(Test_Iksnr).and_return(newReg)
      @app.should_receive(:company_by_name).and_return(@company)
      @company.should_receive(:pointer).and_return('pointerx')
#      @app.should_receive(:atc_class).with(Test_Atc).once.and_return(nil)
      @app.should_receive(:unique_atc_class).with(Test_Atc).once.and_return(nil)
      # @app.should_receive(:create_atc_class).with(Test_Atc).once.and_return(atc)
      @app.should_receive(:atc_classes).times(3).and_return({Test_Atc => atc})
      assert(@plugin.import_swissmedicinfo(@opts), 'must be able to run import_swissmedicinfo and add a new registration')
      meta = TextInfoPlugin::get_iksnrs_meta_info
      refute_nil(meta)
      assert_equal(2, meta.size, 'we must extract 2 meta info from 2 medicalInformation')
      expected =  TextInfoPlugin::SwissmedicMetaInfo.new(Test_Iksnr, Test_Atc, Test_Name, "Pfizer AG", "Tofacitinibum")
      assert_equal(expected, meta[Test_Iksnr], 'Meta information about Test_Iksnr must be correct')
      # @app.should_receive(:registration).with('08537')
      assert_equal(2, @app.registrations.size)
#      assert_equal("Tofacitinibums", @app.atc_classes[Test_Atc].id)
    end
  end
  
  class TestTextInfoPlugin <Test::Unit::TestCase
    unless defined?(@@datadir)
      @@datadir = File.expand_path '../data/xml', File.dirname(__FILE__)
      @@vardir = File.expand_path '../var/', File.dirname(__FILE__)
    end
    include FlexMock::TestCase
    
    def create(dateiname, content)
        FileUtils.makedirs(File.dirname(dateiname))
        ausgabe = File.open(dateiname, 'w+')
        ausgabe.write(content)
        ausgabe.close
    end
    
    def setup
      FileUtils.mkdir_p @@vardir
      ODDB.config.data_dir = @@vardir
      ODDB.config.log_dir = @@vardir
      @opts = {
        :target   => [:fi],
        :reparse  => false,
        :iksnrs   => ['32917'], # auf Zeile 2477310: 1234642 2477314
        :companies => [],
        :download => false,
        :xml_file => File.join(@@datadir, 'AipsDownload.xml'), 
      }
      @app = flexmock('application', 
                      :update => 'updated', 
                      :delete => 'delete') # , :registration => [])
      @app.should_receive(:textinfo_swissmedicinfo_index)
      @parser = flexmock 'parser (simulates ext/fiparse for swissmedicinfo_xml)'
      pi_path_de = File.join(@@vardir, 'html/patinfo/de/K_nzle_Passionsblume_Kapseln_swissmedicinfo.html')    
      pi_de = PatinfoDocument.new
      pi_path_fr = File.join(@@vardir, 'html/patinfo/fr/Capsules_PASSIFLORE__K_nzle__swissmedicinfo.html') 
      pi_fr = PatinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).with(pi_path_de, :swissmedicinfo, "Künzle Passionsblume Kapseln").and_return pi_de
      @parser.should_receive(:parse_patinfo_html).with(pi_path_fr, :swissmedicinfo, "Capsules PASSIFLORE \"Künzle\"").and_return pi_de
      @plugin = TextInfoPlugin.new(@app, @opts)
      agent = @plugin.init_agent
      @plugin.parser = @parser
    end # Fuer Problem mit fachinfo italic
    
    def teardown
      FileUtils.rm_r @@vardir
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
    
    def test_import_swissmedicinfo_xml
      reg = flexmock 'registration'
      reg.should_receive(:fachinfo)
      ptr = Persistence::Pointer.new([:registration, '32917'])
      reg.should_receive(:pointer).and_return ptr
      seq = flexmock('sequence', :patinfo= => 'patinfo', :odba_isolated_store => 'odba_isolated_store')
      seq.should_receive(:patinfo)
      seq.should_receive(:pointer).and_return ptr + [:sequence, '01']
      reg.should_receive(:each_sequence).and_return do |block| block.call seq end
      reg.should_receive(:sequences).and_return({'01' => seq})
      @app.should_receive(:registration).with('32917').and_return reg
      fi = flexmock 'fachinfo'
      fi.should_receive(:pointer).and_return Persistence::Pointer.new([:fachinfo,1])
      pi = flexmock 'patinfo'
      pi.should_receive(:pointer).and_return Persistence::Pointer.new([:patinfo,1])
      flags = {:de => :up_to_date, :fr => :up_to_date}
      @parser.should_receive(:parse_fachinfo_html).once
      @parser.should_receive(:parse_patinfo_html).never
      @plugin.extract_matched_content("Zyloric®", 'fi', 'de')
      assert(@plugin.import_swissmedicinfo(@opts), 'must be able to run import_swissmedicinfo')
    end

    def test_import_passion
      name = 'Capsules PASSIFLORE "Künzle"'
      stripped = name # With this line we get the error 
      # Nokogiri::XML::XPath::SyntaxError: Invalid expression: //medicalInformation[@type='pi' and @lang='fr']/title[match(., "Capsules PASSIFLORE "Künzle"")]
      stripped = name.gsub('"','.')
      title = 'Capsules PASSIFLORE "Künzle"'
      type = 'pi'
      lang = 'fr'
      path  = "//medicalInformation[@type='#{type[0].downcase + 'i'}' and @lang='#{lang.to_s}']/title[match(., \"#{stripped}\")]"
      fr = setup_fachinfo_document 'Numéro d’autorisation', '45928 (Swissmedic).'
      fi_path_fr = File.join(@@datadir, 'passion.fr.xml')
      @doc = @plugin.swissmedicinfo_xml(fi_path_fr)
      match = @doc.xpath(path, Class.new do
        def match(node_set, name)
          found_node = catch(:found) do
            node_set.find_all do |node|
              unknown_chars = /[^A-z0-9,\/\s\-]/
              title = (node.text + '®').gsub(unknown_chars, '')
              name  = name.gsub(unknown_chars, '')
              throw :found, node if title == name
              false
            end
            nil
          end
          found_node ? [found_node] : []
        end
      end.new).first
    end
  end  if false
  class TestTextInfoPluginChecks <Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @@datadir = File.expand_path '../data/xml', File.dirname(__FILE__)
      @@vardir = File.expand_path '../var/', File.dirname(__FILE__)
      FileUtils.mkdir_p @@vardir
      ODDB.config.data_dir = @@vardir
      ODDB.config.log_dir = @@vardir
      @opts = {
        :target   => [:fi],
        :reparse  => false,
        :iksnrs   => ['32917'], # auf Zeile 2477310: 1234642 2477314
        :companies => [],
        :download => false,
        :xml_file => File.join(@@datadir, 'AipsDownload.xml'), 
      }
      @app = flexmock('application', :update => 'updated',
                      :delete => 'delete', 
                      :registrations => [],
                      :registration => @registration,
                     )
      @app.should_receive(:registration).with(1, :swissmedicinfo, "Künzle Passionsblume Kapseln").and_return 0
      @app.should_receive(:textinfo_swissmedicinfo_index)
      @parser = flexmock 'parser (simulates ext/fiparse for swissmedicinfo_xml)'
      pi_path_de = File.join(@@vardir, 'html/patinfo/de/K_nzle_Passionsblume_Kapseln_swissmedicinfo.html')    
      pi_de = PatinfoDocument.new
      pi_path_fr = File.join(@@vardir, 'html/patinfo/fr/Capsules_PASSIFLORE__K_nzle__swissmedicinfo.html') 
      pi_fr = PatinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).with(pi_path_de, :swissmedicinfo, "Künzle Passionsblume Kapseln").and_return pi_de
      @parser.should_receive(:parse_patinfo_html).with(pi_path_fr, :swissmedicinfo, "Capsules PASSIFLORE \"Künzle\"").and_return pi_de
      @plugin = TextInfoPlugin.new(@app, @opts)
      agent = @plugin.init_agent
      @plugin.parser = @parser
    end # Fuer Problem mit fachinfo italic
    
    def teardown
      FileUtils.rm_r @@vardir
      super # to clean up FlexMock
    end    
  end  if false
        
  class TestTextInfoPlugin_iksnr <Test::Unit::TestCase
    include FlexMock::TestCase
    
    def test_get_iksnr_comprimes
      test_string = '59341 (comprimés filmés), 59342 (comprimés à mâcher), 59343 (granulé oral)'
      assert_equal(["59341", "59342", "59343" ], TextInfoPlugin::get_iksnrs_from_string(test_string))
    end
    
    def test_get_iksnr_lopresor
      test_string = "Zulassungsnummer Lopresor 100: 39'252 (Swissmedic) Lopresor Retard 200: 44'447 (Swissmedic)"
      assert_equal(["39252", "44447" ], TextInfoPlugin::get_iksnrs_from_string(test_string))
    end


    def test_get_iksnr_space_at_end
      test_string = '54577 '
      assert_equal(["54577",], TextInfoPlugin::get_iksnrs_from_string(test_string))       
    end
    
    def test_find_iksnr_in_string
      test_string = "54'577, 60’388 "
      assert_equal('54577', TextInfoPlugin.find_iksnr_in_string(test_string, '54577'))
      assert_equal('60388', TextInfoPlugin.find_iksnr_in_string(test_string, '60388'))
    end

    def test_get_iksnr_victrelis
      test_string = "62'105"
      assert_equal(['62105'], TextInfoPlugin::get_iksnrs_from_string(test_string))       
      assert_equal('62105', TextInfoPlugin.find_iksnr_in_string(test_string, '62105'))
    end
    
    def test_get_iksnr_temodal
      test_string = "54'577, 60’388 "
      assert_equal(["54577", '60388'], TextInfoPlugin::get_iksnrs_from_string(test_string))       
    end
   
  end if false
end
