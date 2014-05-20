#!/usr/bin/env ruby
# encoding: utf-8
# Swissreg -- oddb.org -- 16.04.2013 -- yasaka@ywesee.com
# Swissreg -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com
require 'mechanize'
require 'pp'
require 'hpricot'
require 'writer'

module ODDB
  module Swissreg
    class Session
      def initialize
        @number = nil
        @results = []
        @errors  = Hash.new
        @lastDetail =nil
        @counterDetails = 0
      end
      # Weitere gesehene Fehler
      BekannteFehler =
            ['Das Datum ist ung', # ültig'
            '500 Internal Server Error',
            'Vereinfachte Trefferliste anzeigen',
              'Es wurden keine Daten gefunden.',
              'Die Suchkriterien sind teilweise unzul', # ässig',
              'Geben Sie mindestens ein Suchkriterium ein',
              'Die Suche wurde abgebrochen, da die maximale Suchzeit von 60 Sekunden',
            'Erweiterte Suche',
            ]
      Base_uri = 'https://www.swissreg.ch'
      Start_uri = "#{Base_uri}/srclient/faces/jsp/start.jsp"
      HitsPerPage = 250
      LogDir = 'log'

      def writeResponse(agent, filename)
        if defined?(RSpec) or defined?(MiniTest) or $VERBOSE
          File.open(filename, 'w+') { |ausgabe| ausgabe.puts agent.page.body }
        else
          puts "Skipping writing #{filename}" if $VERBOSE
        end
      end

      def checkErrors(body)
        BekannteFehler.each {
          |errMsg|
          if body.to_s.index(errMsg)
            $stdout.puts "Swissreg: search has error <#{errMsg}>"
          end
        }
      end

      def Swissreg.init_swissreg
        @session = Session.new
        begin
          @agent = Mechanize.new{
          |agent|
              agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0'
              agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
              FileUtils.makedirs(LogDir) if $VERBOSE or defined?(RSpec)
              agent.log = Logger.new("#{LogDir}/mechanize.log") if $VERBOSE
          }
          @agent.get_file  Start_uri # 'https://www.swissreg.ch/srclient/faces/jsp/start.jsp'
          @session.writeResponse(@agent, "#{LogDir}/session_expired.html")
          @session.checkErrors(@agent.page.body)
          @agent.page.links[3].click
          @session.writeResponse(@agent, "#{LogDir}/homepage.html")
          @state = @agent.page.form["javax.faces.ViewState"]
        rescue Net::HTTPInternalServerError, Mechanize::ResponseCodeError
          puts "Net::HTTPInternalServerError oder Mechanize::ResponseCodeError gesehen.\n   #{Base_uri} hat wahrscheinlich Probleme"
          raise
        end
      end
    public
      def Swissreg.search(iksnr) # search patent(s) for a given iksnr
        $stdout.puts "Swissreg: search iksnr #{iksnr}"
        Swissreg.init_swissreg
        data = [
          ["autoScroll", "0,0"],
          ["id_swissreg:_link_hidden_", ""],
          ["id_swissreg_SUBMIT", "1"],
          ["id_swissreg:_idcl", "id_swissreg_sub_nav_ipiNavigation_item10"],
          ["javax.faces.ViewState", @state],
        ]
        @agent.page.form['id_swissreg:_idcl'] = 'id_swissreg_sub_nav_ipiNavigation_item10'
        @agent.page.forms.first.submit
        @session.writeResponse(@agent, "#{LogDir}/esz_simple.html")
        data = [
          ["autoScroll", "0,0"],
          ["id_swissreg:_link_hidden_", ""],
          ["id_swissreg:mainContent:id_txf_basic_pat_no",""],
          ["id_swissreg:mainContent:id_txf_spc_no",""],
          ["id_swissreg:mainContent:id_txf_title",""],
          ["id_swissreg_SUBMIT", "1"],
          ["id_swissreg:_idcl", "id_swissreg_sub_nav_ipiNavigation_item10_item13"],
          ["javax.faces.ViewState", @state],
          ]
        @agent.page.form['id_swissreg:_idcl'] = 'id_swissreg_sub_nav_ipiNavigation_item10_item13'
        @agent.page.forms.first.submit
        @session.writeResponse(@agent, "#{LogDir}/esz_extended.html")

        form = @agent.page.forms.first
        form.add_button_to_query(form.button(:value => /suchen/))
        form.field(:name => 'id_swissreg:mainContent:id_txf_auth_no').value=iksnr
        response = form.submit
        @session.writeResponse(@agent, "#{LogDir}/first_results.html")
        @session.checkErrors(@agent.page.body)
        @session.extract_result_links(@agent.page)
      end

      def Swissreg.get_detail(url)
        Swissreg.init_swissreg
        response = @agent.get(Base_uri + url)
        writer = DetailWriter.new
        formatter = ODDB::HtmlFormatter.new(writer)
        parser = ODDB::HtmlParser.new(formatter)
        parser.feed(response.body)
        writer.extract_data
      rescue Timeout::Error
        {}
      end

      def extract_result_links(response)
        if response.is_a?(String)
          body = Mechanize::Page.new(nil,{'content-type'=>'text/html'},response,nil, Mechanize.new)
        else
          body = response
        end
        detail_link = body.links.find{ |l| l.attributes[:id] && l.attributes[:id].match(/0:id_detail/)}
        return [] unless detail_link
        url =  "#{Base_uri}/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=#{detail_link.to_s}"
        return [url]
      end
    end
  end
end
