#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
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
  class TestTextInfoPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    
    def setup
      @datadir = File.expand_path '../data/xml', File.dirname(__FILE__)
      @vardir = File.expand_path '../var/', File.dirname(__FILE__)
      FileUtils.mkdir_p @vardir
      ODDB.config.data_dir = @vardir
      ODDB.config.log_dir = @vardir
      $opts = {
        :target   => [:fi, :pi],
        :reparse  => false,
        :iksnrs   => [],
        :companies => [],
        :download => false,
        :xml_file => File.join(@datadir, 'AipsDownload.xml'), 
      }
      @app = flexmock 'application'
      @app.should_receive(:textinfo_swissmedicinfo_index)
#      @parser = flexmock 'parser (simulates ext/fiparse for swissmedicinfo_xml)'
      pp $opts
      @parser = flexmock 'parser (simulates ext/fiparse)'
      @plugin = TextInfoPlugin.new(@app, $opts)
      agent = @plugin.init_agent
      @plugin.parser = @parser
    end
    
    def teardown
      FileUtils.rm_r @vardir
      super
    end
    
    def setup_mechanize mapping=[]
      agent = flexmock Mechanize.new
      @pages = Hash.new(0)
      @actions = {}
      mapping.each do |page, method, url, formname, page2|
        path = File.join @datadir, page
        page = setup_page url, path, agent
        if formname
          form = flexmock page.form(formname)
          action = form.action
          page = flexmock page
          page.should_receive(:form).with(formname).and_return(form)
          path2 = File.join @datadir, page2
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
      pp 600
      response = {'content-type' => 'text/html'}
      Mechanize::Page.new(URI.parse(url), response,
                          File.read(path), 200, agent)
      pp 601
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
      # need partial_mock here for @plugin
#      @plugin = flexmock 'plugin' TextInfoPlugin.new(@app, opts)
 #      @plugin.textinfo_swissmedicinfo_index = flexmock 'fachinfo'
            agent = setup_mechanize

      reg = flexmock 'registration'
      reg.should_receive(:fachinfo)
      ptr = Persistence::Pointer.new([:registration, '45928'])
      reg.should_receive(:pointer).and_return ptr
        seq = flexmock 'sequence'
      seq.should_receive(:patinfo)
      seq.should_receive(:pointer).and_return ptr + [:sequence, '01']
      reg.should_receive(:each_sequence).and_return do |block| block.call seq end
      reg.should_receive(:sequences).and_return({'01' => seq})
      @app.should_receive(:registration).with('45928').and_return reg
      fi = flexmock 'fachinfo'
      fi.should_receive(:pointer).and_return Persistence::Pointer.new([:fachinfo,1])
      pi = flexmock 'patinfo'
      pi.should_receive(:pointer).and_return Persistence::Pointer.new([:patinfo,1])
      flags = {:de => :up_to_date, :fr => :up_to_date}
#      ng = TextInfoPlugin.new @app
#      ng.update_textinfo_swissmedicinfo(opts)
      # ng.update_textinfo_swissmedicinfo(opts)
      pp 50
      @plugin.import_swissmedicinfo($opts)
      pp 51

#      result = @plugin.update_product '45928', fi_paths, pi_paths, flags, flags
      assert true # no call to parse_patinfo or @app.update has been made
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
      puts "Matching title #{title} regexp #{path}"
      fr = setup_fachinfo_document 'Numéro d’autorisation', '45928 (Swissmedic).'
      fi_path_fr = File.join(@datadir, 'passion.fr.xml')
      pp fi_path_fr 
      @doc = @plugin.swissmedicinfo_xml(fi_path_fr)
      match = @doc.xpath(path, Class.new do
        def match(node_set, name)
          found_node = catch(:found) do
            node_set.find_all do |node|
              unknown_chars = /[^A-z0-9,\/\s\-]/
              title = node.text.gsub(unknown_chars, '')
              name  = name.gsub(unknown_chars, '')
              throw :found, node if title == name
              false
            end
            nil
          end
          found_node ? [found_node] : []
        end
      end.new).first
    end if false
    
  end
end
