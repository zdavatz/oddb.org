#!/usr/bin/env ruby
# TestIndexTherapeuticusPlugin  -- oddb.org -- 20.05.2008 -- hwyss@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'odba'
require 'flexmock'
require 'plugin/index_therapeuticus'

module ODDB
  class TestIndexTherapeuticusPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = flexmock 'system'
      @plugin = IndexTherapeuticusPlugin.new @app
      @cache = flexmock 'cache'
    end
    def setup_agent(agent, resultfile, symbol, &block)
      dir = File.expand_path('../data/html/it', File.dirname(__FILE__))
      agent.should_receive(symbol).and_return { |argument, *data|
        if(block)
          argument = block.call(argument, *data)
        end
        path = File.join(dir, resultfile)
        uri = URI.parse argument
        agent.pluggable_parser.parser("text/html").new(
          URI.parse("http://www.pharmnet-bund.de" + uri.path),
          {'content-type'=>'text/html'}, File.read(path), 200
        ) { |parser| parser.mech = agent }
      }
    end
    def test_get_toplevel
      agent = flexmock(WWW::Mechanize.new)
      setup_agent agent, 'IT.htm', :get
      pages = @plugin.get_toplevel agent
      assert_equal 28, pages.size
    end
    def test_01
      agent = flexmock(WWW::Mechanize.new)
      setup_agent agent, 'IT01.htm', :get
      codes = %w{01. 01.01. 01.01.10. 01.01.20. 01.01.21. 01.01.22. 01.01.22.
                 01.01.23. 01.01.24. 01.01.30. 01.01.40. 01.01.99. 01.02.
                 01.02.10. 01.02.20. 01.03. 01.03.10. 01.03.20. 01.04. 01.04.10.
                 01.04.20. 01.05. 01.06. 01.07. 01.07.10. 01.07.20. 01.08. 01.09.
                 01.10. 01.10.10. 01.10.20. 01.10.30. 01.11. 01.12. 01.13. 01.14.
                 01.98. 01.99.
                }
      @app.should_receive(:index_therapeuticus)
      @app.should_receive(:update).and_return { |creator, args|
        ptr = creator.last_step.last
        cmd, key = ptr.last_step
        case cmd
        when :index_therapeuticus
          assert codes.delete(key)
          assert_equal %w{de fr}, args.keys.collect { |key| key.to_s }.sort
          ith = IndexTherapeuticus.new key
          ith.pointer = ptr
          ith
        when :limitation_text
          expected = {
            :it => "Ammessi in totale 120 punti. Iniectabilia sine limitatione", 
            :de => "Gesamthaft zugelassen 120 Punkte. Iniectabilia sine limitatione", 
            :fr => "Prescription limit\351e au maximum \340 120 points. Iniectabilia sine limitatione"
          }
          assert_equal expected, args
        end

      }
      its = @plugin.get_details agent, 'IT01.htm'
      assert codes.empty?
    end
    def test_text_lines
      html = <<-EOS
<td id="SL2PRLLINE" width="70%"><b>Limitatio:</b> Gesamthaft zugelassen <b>120</b> Punkte. <b>Iniectabilia sine limitatione</b><br>Prescription limitée au maximum à <b>120</b> points. <b>Iniectabilia sine limitatione</b><br>Ammessi in totale <b>120</b> punti. <b>Iniectabilia sine limitatione</b></td>
      EOS
      cell = (Hpricot(html)/'td').first
      lines = @plugin.text_lines cell
      expected = [
        "Limitatio: Gesamthaft zugelassen 120 Punkte. Iniectabilia sine limitatione",
        "Prescription limitée au maximum à 120 points. Iniectabilia sine limitatione",
        "Ammessi in totale 120 punti. Iniectabilia sine limitatione",
      ]
      assert_equal expected, lines
    end
  end
end
