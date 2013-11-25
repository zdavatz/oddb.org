#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('../../src', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'fileutils'
require 'flexmock'
require 'plugin/text_info'
require 'model/text'

module ODDB
	class FachinfoDocument
		def odba_id
			1
		end
	end
  class TextInfoPlugin
    attr_accessor :parser, :iksless, :session_failures, :current_search,
                  :current_eventtarget
  end
  
  class TestTextInfoPluginMethods <Minitest::Test
    x = %(<p class="s4"><span class="s8"><span>62'728, 62'731, 62'730, 62’729 (</span></span><span class="s8"><span>Swissmedic</span></span><span class="s8"><span>)</span></span></p>)
    y = %(
data/html/fachinfo/de/Bisoprolol_Axapharm_swissmedicinfo.html:<p class="s4"><span class="s8"><span>62111 (Swissmedic)</span></span><span class="s8"><span>.</span></span></p>
data/html/fachinfo/de/Diclo_Acino_retard_rektale_Kapseln__Film__Retardtabletten_swissmedicinfo.html:<p class="s4"><span class="s8"><span>62'728, 62'731, 62'730, 62’729 (</span></span><span class="s8"><span>Swissmedic</span></span><span class="s8"><span>)</span></span></p>
data/html/fachinfo/de/Finasterid_Mepha__5_swissmedicinfo.html:    <p class="noSpacing">58107 (Swissmedic).</p>
data/html/fachinfo/de/Finasterid_Streuli__5_swissmedicinfo.html:<p class="s4"><span class="s8"><span>58</span></span><span class="s8"><span>’</span></span><span class="s8"><span>106 </span></span><span class="s8"><span>(Swissmedic)</span></span></p>
data/html/fachinfo/de/Olanpax__Filmtabletten_Schmelztabletten_swissmedicinfo.html:<p class="s4"><span class="s8"><span>Filmtabletten: </span></span><span class="s8"><span>62</span></span><span class="s8"><span>‘</span></span><span class="s8"><span>223</span></span><span class="s8"><span> (Swissmedic).</span></span></p>
data/html/fachinfo/de/Olanpax__Filmtabletten_Schmelztabletten_swissmedicinfo.html:<p class="s4"><span class="s8"><span>Schmelztabletten: </span></span><span class="s8"><span>62</span></span><span class="s8"><span>‘</span></span><span class="s8"><span>224</span></span><span class="s8"><span> (Swissmedic).</span></span></p>
data/html/fachinfo/de/Xalos_Duo_swissmedicinfo.html:<p class="s4"><span class="s8"><span>62’439</span></span><span class="s8"><span> (Swissmedic).</span></span></p>
data/html/fachinfo/de/Zyloric__swissmedicinfo.html:<p class="s5"><span class="s8"><span>32917</span></span><span class="s8"><span> </span></span><span class="s8"><span>(</span></span><span class="s8"><span>Swissmedic)</span></span><span class="s8"><span> </span></span></p>
)
  end
  
  class TestTextInfoPlugin <Minitest::Test
    @@datadir = File.expand_path '../data/html/text_info', File.dirname(__FILE__)
    @@vardir = File.expand_path '../var/', File.dirname(__FILE__)
    include FlexMock::TestCase
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
      super
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
    def test_init_searchform__not_configured
      ODDB.config.text_info_searchform = nil
      agent = setup_mechanize
      assert_raises RuntimeError do
        @plugin.init_searchform agent
      end
    end
    def test_init_searchform__accept
      mapping = [
        [ 'AcceptForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
          'frmNutzungsbedingungen',
          'SearchForm.html',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      page = @plugin.init_searchform agent
      refute_nil page.form_with(:name => 'frmSearchForm')
    end
    def test_search_company
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
          'frmSearchForm',
          'Companies.html',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      page = @plugin.search_company 'novartis', agent
      refute_nil page.form_with(:name => 'frmResulthForm')
      assert_equal 1, @pages.size
    end
    def test_import_companies
      ## we return an empty result here, to contain testing the import_companies method
      mapping = [
        [ 'ResultEmpty.html',
          :submit,
          'Result.aspx?lang=de',
        ],
      ]
      agent = setup_mechanize mapping
      path = File.join @@datadir, 'Companies.html'
      result = setup_page 'http://textinfo.ch/Search.aspx', path, agent
      page = nil
      @plugin.import_companies result, agent
      ## we've touched only one page here, because we returned ResultEmpty.html
      assert_equal 1, @pages.size
    end
    def test_import_company
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
        ],
        [ 'Companies.html',
          :submit,
          'Search.aspx',
        ],
        [ 'ResultAlcaC.html',
          :submit,
          'Result.aspx?lang=de',
        ],
        [ 'Aclasta.de.html',
          :submit,
          'CompanyProdukte.aspx?lang=de',
        ],
        [ 'Aclasta.fr.html',
          :get,
          'CompanyProdukte.aspx?lang=fr',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      @parser.should_receive(:parse_fachinfo_html).and_return FachinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).and_return PatinfoDocument.new
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      @plugin.import_company ['novartis'], agent, :both
      assert_equal 5, @pages.size
      ## we didn't set up @parser to return a FachinfoDocument with an iksnr.
      #  the rest of the process is tested in test_update_product
      assert_equal ['Alca-C®'], @plugin.iksless[:fi].uniq
    end
    def test_import_company__session_failure
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
        ],
        [ 'Companies.html',
          :submit,
          'Search.aspx',
        ],
        [ 'ResultAlcaC.html',
          :submit,
          'Result.aspx?lang=de',
        ],
        [ 'SearchForm.html',
          :submit,
          'CompanyProdukte.aspx?lang=de',
        ],
        [ 'SearchForm.html',
          :get,
          'CompanyProdukte.aspx?lang=fr',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      @parser.should_receive(:parse_fachinfo_html).and_return FachinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).and_return PatinfoDocument.new
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      @plugin.import_company ['novartis'], agent
      assert_equal 5, @pages.size
      ## we didn't set up @parser to return a FachinfoDocument with an iksnr.
      #  the rest of the process is tested in test_update_product
      assert_equal ['Alca-C®'], @plugin.iksless[:fi].uniq
      assert_equal ['Alca-C®'], @plugin.iksless[:pi].uniq
      assert_equal 8, @plugin.session_failures
    end
    def test_identify_eventtargets
      agent = setup_mechanize
      path = File.join @@datadir, 'Result.html'
      page = setup_page 'http://textinfo.ch/Search.aspx', path, agent
      targets = @plugin.identify_eventtargets page, /btnFachinformation/
      assert_equal 77, targets.size
      assert_equal "dtgFachinformationen$_ctl2$btnFachinformation", targets['Alca-C®']
      assert_equal "dtgFachinformationen$_ctl78$btnFachinformation",
                   targets['Zymafluor®']
      targets = @plugin.identify_eventtargets page, /btnPatientenn?information/
      assert_equal 79, targets.size
      assert_equal "dtgPatienteninformationen$_ctl2$btnPatientenninformation",
                   targets['Alca-C®']
      assert_equal "dtgPatienteninformationen$_ctl80$btnPatientenninformation",
                   targets['Zymafluor®']
    end
    def test_import_products
      mapping = [
        [ 'Aclasta.de.html',
          :submit,
          'http://textinfo.ch/MonographieTxt.aspx?lang=de&MonType=fi',
        ],
        [ 'Aclasta.fr.html',
          :get,
          'http://textinfo.ch/MonographieTxt.aspx?lang=fr&MonType=fi',
        ]
      ]
      agent = setup_mechanize mapping
      path = File.join @@datadir, 'ResultEmpty.html'
      result = setup_page 'http://textinfo.ch/Search.aspx', path, agent
      page = nil
      @parser.should_receive(:parse_fachinfo_html).and_return FachinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).and_return PatinfoDocument.new
      @plugin.import_products result, agent
    end
    def test_download_info
      mapping = [
        [ 'Aclasta.de.html',
          :submit,
          'CompanyProdukte.aspx?lang=de',
        ],
        [ 'Companies.html',
          :get,
          'CompanyProdukte.aspx?lang=fr',
        ]
      ]
      agent = setup_mechanize mapping
      path = File.join @@datadir, 'Result.html'
      page = setup_page 'http://textinfo.ch/CompanyProdukte.aspx?lang=de', path, agent
      form = page.form_with :name => 'frmResultProdukte'
      eventtarget = 'dtgFachinformationen$_ctl3$btnFachinformation'
      paths, flags = @plugin.download_info :fachinfo, 'Aclasta',
                                           agent, form, eventtarget
      expected = {}
      path = File.join @@vardir, 'html', 'fachinfo', 'de', 'Aclasta.html'
      expected.store :de, path
      assert File.exist?(path)
      path = File.join @@vardir, 'html', 'fachinfo', 'fr', 'Aclasta.html'
      expected.store :fr, path
      assert File.exist?(path)
      assert_equal expected, paths
      skip("Niklaus does not know why we don't get consistent results for the flags")
      assert_equal({:de=>:up_to_date, :fr=>:up_to_date}, flags)
      paths, flags = @plugin.download_info :fachinfo, 'Aclasta',
                                           agent, form, eventtarget
      ## existing identical files are flagged as up-to-date
      assert_equal expected, paths
      assert_equal({:fr => :up_to_date, :de => :up_to_date}, flags)
    end
    def test_extract_iksnrs
      de = setup_fachinfo_document 'Zulassungsnummer', '57363 (Swissmedic).'
      fr = setup_fachinfo_document 'Numéro d’autorisation', '57364 (Swissmedic).'
      assert_equal %w{57363}, @plugin.extract_iksnrs(:de => de, :fr => fr).sort
    end
    def test_update_product__new_infos
      de = setup_fachinfo_document 'Zulassungsnummer', '57363 (Swissmedic).'
      fr = setup_fachinfo_document 'Numéro d’autorisation', '57363 (Swissmedic).'
      fi_path_de = File.join(@@datadir, 'Aclasta.de.html')
      fi_path_fr = File.join(@@datadir, 'Aclasta.fr.html')
      fi_paths = { :de => fi_path_de, :fr => fi_path_fr }
      pi_path_de = File.join(@@datadir, 'Aclasta.pi.de.html')
      pi_path_fr = File.join(@@datadir, 'Aclasta.pi.fr.html')
      pi_paths = { :de => pi_path_de, :fr => pi_path_fr }
      pi_de = PatinfoDocument.new
      pi_fr = PatinfoDocument.new
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_de, :documed, "", nil).and_return de
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_fr, :documed, "", nil).and_return fr
      @parser.should_receive(:parse_patinfo_html).with(pi_path_de, :documed, "", nil).and_return pi_de
      @parser.should_receive(:parse_patinfo_html).with(pi_path_fr, :documed, "", nil).and_return pi_fr

      reg = flexmock 'registration'
      reg.should_receive(:fachinfo)
      ptr = Persistence::Pointer.new([:registration, '57363'])
      reg.should_receive(:pointer).and_return ptr
      seq = flexmock 'sequence'
      seq.should_receive(:patinfo)
      seq.should_receive(:pointer).and_return ptr + [:sequence, '01']
      reg.should_receive(:each_sequence).and_return do |block| block.call seq end
      reg.should_receive(:sequences).and_return({'01' => seq})
      @app.should_receive(:registration).with('57363').and_return reg
      fi = flexmock 'fachinfo'
      fi.should_receive(:pointer).and_return Persistence::Pointer.new([:fachinfo,1])
      pi = flexmock 'patinfo'
      pi.should_receive(:pointer).and_return Persistence::Pointer.new([:patinfo,1])
      @app.should_receive(:update).and_return do |pointer, data|
        case pointer.to_s
        when ':!create,:!fachinfo..'
          assert_equal({:de => de, :fr => fr}, data)
          fi
        when ':!create,:!patinfo..'
          assert_equal({:de => pi_de, :fr => pi_fr}, data)
          pi
        when ':!registration,57363.'
          assert_equal({:fachinfo => fi.pointer}, data)
          reg
        when ':!registration,57363!sequence,01.'
          assert_equal({:patinfo => pi.pointer}, data)
          seq
        else
          flunk "unhandled call to update(#{pointer})"
        end
      end
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      result = @plugin.update_product 'Aclasta', fi_paths, pi_paths
      assert_equal <<-EOS, @plugin.report
Searched for 
Stored 1 Fachinfos
Ignored 0 Pseudo-Fachinfos
Ignored 0 up-to-date Fachinfo-Texts
Stored 0 Patinfos
Ignored 0 up-to-date Patinfo-Texts

Checked 0 companies


Unknown Iks-Numbers: 0


Fachinfos without iksnrs: 0


Session failures: 0

Download errors: 0


Parse Errors: 0




EOS
    end
    def test_update_product__existing_infos
      de = setup_fachinfo_document 'Zulassungsnummer', '57363 (Swissmedic).'
      fr = setup_fachinfo_document 'Numéro d’autorisation', '57363 (Swissmedic).'
      fi_path_de = File.join(@@datadir, 'Aclasta.de.html')
      fi_path_fr = File.join(@@datadir, 'Aclasta.fr.html')
      fi_paths = { :de => fi_path_de, :fr => fi_path_fr }
      pi_path_de = File.join(@@datadir, 'Aclasta.pi.de.html')
      pi_path_fr = File.join(@@datadir, 'Aclasta.pi.fr.html')
      pi_paths = { :de => pi_path_de, :fr => pi_path_fr }
      pi_de = PatinfoDocument.new
      pi_fr = PatinfoDocument.new
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_de, :documed, "", nil).and_return de
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_fr, :documed, "", nil).and_return fr
      @parser.should_receive(:parse_patinfo_html).with(pi_path_de).and_return pi_de
      @parser.should_receive(:parse_patinfo_html).with(pi_path_fr).and_return pi_fr

      fi = flexmock 'fachinfo'
      fi.should_receive(:pointer).and_return Persistence::Pointer.new([:fachinfo,1])
      fi.should_receive(:empty?).and_return(true)
      pi = flexmock 'patinfo'
      pi.should_receive(:pointer).and_return Persistence::Pointer.new([:patinfo,1])
      ## this is conceptually a bit of a leap, but it tests all the code: even though
      #  pi is used to update the patinfo, I'm making it claim empty?, so that the
      #  deletion-code is triggered
      pi.should_receive(:empty?).and_return(true)
      reg = flexmock 'registration'
      reg.should_receive(:fachinfo).and_return fi
      ptr = Persistence::Pointer.new([:registration, '57363'])
      reg.should_receive(:pointer).and_return ptr
      seq = flexmock 'sequence'
      seq.should_receive(:patinfo).and_return pi
      seq.should_receive(:pointer).and_return ptr + [:sequence, '01']
      reg.should_receive(:each_sequence).and_return do |block| block.call seq end
      reg.should_receive(:sequences).and_return({'01' => seq})
      @app.should_receive(:registration).with('57363').and_return reg
      @app.should_receive(:update).and_return do |pointer, data|
        case pointer.to_s
        when ':!create,:!fachinfo..'
          assert_equal({:de => de, :fr => fr}, data)
          fi
        ## existing patinfos are handled differently than fachinfos!
        when ':!patinfo,1.'
          assert_equal({:de => pi_de, :fr => pi_fr}, data)
          pi
        when ':!registration,57363.'
          assert_equal({:fachinfo => fi.pointer}, data)
          reg
        when ':!registration,57363!sequence,01.'
          assert_equal({:patinfo => pi.pointer}, data)
          seq
        else
          flunk "unhandled call to update(#{pointer})"
        end
      end
      @app.should_receive(:delete).and_return do |pointer, data|
        case pointer.to_s
        when ':!fachinfo,1.'
          assert true
          fi
        when ':!patinfo,1.'
          assert true
          pi
        else
          flunk "unhandled call to delete(#{pointer})"
        end
      end
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      result = @plugin.update_product 'Aclasta', fi_paths, pi_paths
    end
    def test_update_product__orphaned_infos
      de = setup_fachinfo_document 'Zulassungsnummer', '57363 (Swissmedic).'
      fr = setup_fachinfo_document 'Numéro d’autorisation', '57363 (Swissmedic).'
      fi_path_de = File.join(@@datadir, 'Aclasta.de.html')
      fi_path_fr = File.join(@@datadir, 'Aclasta.fr.html')
      fi_paths = { :de => fi_path_de, :fr => fi_path_fr }
      pi_path_de = File.join(@@datadir, 'Aclasta.pi.de.html')
      pi_path_fr = File.join(@@datadir, 'Aclasta.pi.fr.html')
      pi_paths = { :de => pi_path_de, :fr => pi_path_fr }
      pi_de = PatinfoDocument.new
      pi_fr = PatinfoDocument.new
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_de, :documed, "", nil).and_return de
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_fr, :documed, "", nil).and_return fr
      @parser.should_receive(:parse_patinfo_html).with(pi_path_de, :documed, "", nil).and_return pi_de
      @parser.should_receive(:parse_patinfo_html).with(pi_path_fr, :documed, "", nil).and_return pi_fr

      @app.should_receive(:registration).with('57363')
      @app.should_receive(:update).and_return do |pointer, data|
        case pointer.to_s
        when ":!create,:!orphaned_fachinfo.."
          expected = {
            :key => '57363',
            :languages => { :de => de, :fr => fr },
          }
          assert_equal expected, data
        when ":!create,:!orphaned_patinfo.."
          expected = {
            :key => '57363',
            :languages => { :de => pi_de, :fr => pi_fr },
          }
          assert_equal expected, data
        else
          flunk "unhandled call to update(#{pointer})"
        end
      end
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      result = @plugin.update_product 'Aclasta', fi_paths, pi_paths
    end
    def test_update_product__up_to_date_infos
      de = setup_fachinfo_document 'Zulassungsnummer', '57363 (Swissmedic).'
      fr = setup_fachinfo_document 'Numéro d’autorisation', '57363 (Swissmedic).'
      fi_path_de = File.join(@@datadir, 'Aclasta.de.html')
      fi_path_fr = File.join(@@datadir, 'Aclasta.fr.html')
      fi_paths = { :de => fi_path_de, :fr => fi_path_fr }
      pi_path_de = File.join(@@datadir, 'Aclasta.pi.de.html')
      pi_path_fr = File.join(@@datadir, 'Aclasta.pi.fr.html')
      pi_paths = { :de => pi_path_de, :fr => pi_path_fr }
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_de, :documed, "", nil).times(1).and_return de
      @parser.should_receive(:parse_fachinfo_html).with(fi_path_fr, :documed, "", nil).times(1).and_return fr

      reg = flexmock 'registration'
      reg.should_receive(:fachinfo)
      ptr = Persistence::Pointer.new([:registration, '57363'])
      reg.should_receive(:pointer).and_return ptr
      seq = flexmock 'sequence'
      seq.should_receive(:patinfo)
      seq.should_receive(:pointer).and_return ptr + [:sequence, '01']
      reg.should_receive(:each_sequence).and_return do |block| block.call seq end
      reg.should_receive(:sequences).and_return({'01' => seq})
      @app.should_receive(:registration).with('57363').and_return reg
      fi = flexmock 'fachinfo'
      fi.should_receive(:pointer).and_return Persistence::Pointer.new([:fachinfo,1])
      pi = flexmock 'patinfo'
      pi.should_receive(:pointer).and_return Persistence::Pointer.new([:patinfo,1])
      flags = {:de => :up_to_date, :fr => :up_to_date}
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      result = @plugin.update_product 'Aclasta', fi_paths, pi_paths, flags, flags
      assert true # no call to parse_patinfo or @app.update has been made
    end
    def test_detect_session_failure__failure
      agent = setup_mechanize
      path = File.join @@datadir, 'SearchForm.html'
      page = setup_page 'CompanyProdukte.aspx?lang=de', path, agent
      assert_equal true, @plugin.detect_session_failure(page)
    end
    def test_detect_session_failure__fine
      agent = setup_mechanize
      path = File.join @@datadir, 'Companies.html'
      page = setup_page 'Search.aspx', path, agent
      assert_equal false, @plugin.detect_session_failure(page)
      path = File.join @@datadir, 'ResultEmpty.html'
      page = setup_page 'Result.aspx?lang=de', path, agent
      assert_equal false, @plugin.detect_session_failure(page)
      path = File.join @@datadir, 'Result.html'
      page = setup_page 'Result.aspx?lang=de', path, agent
      assert_equal false, @plugin.detect_session_failure(page)
      path = File.join @@datadir, 'Aclasta.de.html'
      page = setup_page 'CompanyProdukte.aspx?lang=de', path, agent
      assert_equal false, @plugin.detect_session_failure(page)
    end
    def test_rebuild_resultlist
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
        ],
        [ 'Companies.html',
          :submit,
          'Search.aspx',
        ],
        [ 'ResultAlcaC.html',
          :submit,
          'Result.aspx?lang=de',
        ],
      ]
      agent = setup_mechanize mapping
      @plugin.current_search = [:search_company, 'Company Name']
      @plugin.current_eventtarget = "dtgFachinformationen$_ctl2$btnFachinformation"
      form = @plugin.rebuild_resultlist agent
      assert_instance_of Mechanize::Form, form
      assert_equal 'CompanyProdukte.aspx?lang=de', form.action
    end
    def test_search_fulltext
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
          'frmSearchForm',
          'ResultFulltext.html',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      page = @plugin.search_fulltext '53537', agent
      refute_nil page.form_with(:name => 'frmResulthForm')
      assert_equal 1, @pages.size
    end
    def test_import_fulltext
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
        ],
        [ 'ResultFulltext.html',
          :submit,
          'Search.aspx',
        ],
        [ 'Aclasta.de.html',
          :submit,
          'Result.aspx?lang=de',
        ],
        [ 'Aclasta.fr.html',
          :get,
          'Result.aspx?lang=fr',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      @parser.should_receive(:parse_fachinfo_html).and_return FachinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).and_return PatinfoDocument.new
      
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      @plugin.import_fulltext ['53537'], agent
      assert_equal 4, @pages.size
      ## we didn't set up @parser to return a FachinfoDocument with an iksnr.
      #  the rest of the process is tested in test_update_product
      assert_equal ['Topamax®'], @plugin.iksless[:fi].uniq
    end
    def test_fachinfo_news__unconfigured
      agent = setup_mechanize
      ODDB.config.text_info_newssource = nil
      assert_raises NoMethodError do
        @plugin.fachinfo_news agent
      end
    end
    def test_fachinfo_news
      mapping = [
        [ 'News.html',
          :get,
          ODDB.config.text_info_newssource,
        ],
      ]
      agent = setup_mechanize mapping
      news = nil
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      news = @plugin.fachinfo_news agent
      assert_equal 7, news.size
      assert_equal "Abilify\302\256", news.first
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
    def test_search_product
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
          'frmSearchForm',
          'ResultProduct.html',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      page = @plugin.search_product 'Trittico® retard', agent
      refute_nil page.form_with(:name => 'frmResulthForm')
      assert_equal 1, @pages.size
    end
    def test_import_name
      mapping = [
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
        ],
        [ 'ResultProduct.html',
          :submit,
          'Search.aspx',
        ],
        [ 'Aclasta.de.html',
          :submit,
          'Result.aspx?lang=de',
        ],
        [ 'Aclasta.fr.html',
          :get,
          'Result.aspx?lang=fr',
        ],
      ]
      agent = setup_mechanize mapping
      page = nil
      @parser.should_receive(:parse_fachinfo_html).and_return FachinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).and_return PatinfoDocument.new
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      @plugin.import_fulltext ['Trittico® retard'], agent
      assert_equal 4, @pages.size
      ## we didn't set up @parser to return a FachinfoDocument with an iksnr.
      #  the rest of the process is tested in test_update_product
      assert_equal ['Trittico® retard'], @plugin.iksless[:pi].uniq
    end
    def test_import_news
      logfile = File.join @@vardir, 'fachinfo.txt'
      File.open logfile, 'w' do |fh|
        fh.puts "8a7f708c-c738-4425-a9a5-5ad294f20be4 Aclasta\302\256"
      end
      mapping = [
        [ 'News.html',
          :get,
          ODDB.config.text_info_newssource,
        ],
        [ 'SearchForm.html',
          :get,
          'http://textinfo.ch/Search.aspx',
        ],
        [ 'ResultProduct.html',
          :submit,
          'Search.aspx',
        ],
        [ 'Aclasta.de.html',
          :submit,
          'Result.aspx?lang=de',
        ],
        [ 'Aclasta.fr.html',
          :get,
          'Result.aspx?lang=fr',
        ],
      ]
      agent = setup_mechanize mapping
      @parser.should_receive(:parse_fachinfo_html).and_return FachinfoDocument.new
      @parser.should_receive(:parse_patinfo_html).and_return PatinfoDocument.new
      @app.should_receive(:sorted_fachinfos).and_return []
      success = @plugin.import_news agent
      expected = "Abilify\302\256\nAbilify\302\256 Injektionsl\303\266sung\nAbseamed\302\256\nAceril\302\256- mite\nAcetaPhos\302\256 750 mg\nAcimethin\302\256\nAclasta\302\256"
      skip("The whole test-suite should probably be removed, including test as we parse no swissmedicinfo_xml!")
      assert_equal 5, @pages.size
      assert_equal expected, File.read(logfile)
      assert_equal true, success
    end
  end
  
  class TestExtractMatchedName <Minitest::Test
    include FlexMock::TestCase
    
    def setup
      file = File.expand_path('../data/xml/Aips_test.xml', File.dirname(__FILE__))
      @app = flexmock 'application'
      @app.should_receive(:registration).and_return ['registration']
      @plugin = TextInfoPlugin.new @app
      @plugin.swissmedicinfo_xml(file)
    end
    
    def test_Erbiumcitrat_de
      assert_equal('[169Er]Erbiumcitrat CIS bio international', @plugin.extract_matched_name('51704', :fi, 'de'))
    end
    def test_Erbiumcitrat_fr
      assert_equal('[169Er]Erbiumcitrat CIS bio international', @plugin.extract_matched_name('51704', :fi, 'de'))
    end
    def test_53662_pi_de
      assert_equal('3TC®', @plugin.extract_matched_name('53662', :fi, 'de'))
    end
    def test_53663_pi_de
      assert_equal('3TC®', @plugin.extract_matched_name('53663', :fi, 'de'))
    end
    
  end

end
