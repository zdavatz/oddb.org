#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::DosingDePlugin -- oddb.org -- 15.06.2012 -- yasaka@ywesee.com

require 'mechanize'

module ODDB
  class DosingDePlugin < Plugin
    @index_url = nil
    def initialize(app=nil)
      super app
      @index_url = "http://dosing.de/Niere/nierelst.htm"
      @links = []
      # report
      @checked   = 0
      @nolinked  = 0
      @activated = 0
    end
    def update_ni_id
      _index
      @app.atc_classes.values.each do |atc|
        next if atc.description.empty? # skip parent atc_class
        ni_id = _extract_ni_id_of(atc)
        args = { :ni_id => ni_id }
        @app.update atc.pointer, args
        unless ni_id.nil?
          @activated += 1
        else
          @nolinked += 1
        end
        @checked += 1
      end
    end
    def report
      [
        "Checked ATC classes : #{@checked}",
        "Activate Niere Link : #{@activated}",
        "No link ATC classes : #{@nolinked}",
      ].join("\n")
    end
    private
    def _index
      agent = Mechanize.new
      agent.user_agent_alias = "Linux Firefox"
      page = agent.get @index_url
      @links = page.links.select do |link|
        link unless link.text.length < 5 # except "" and "#ABC"
      end
    end
    def _extract_ni_id_of(atc)
      ni_id = nil
      catch :ni_id do
        pattern = atc.to_s.gsub /[^A-Za-z]/u, '.'
        @links.each do |link|
          if /#{pattern}/iu.match link.text
            # http://dosing.de/Niere/arzneimittel/NI_00000.html
            if link.uri.to_s =~ /(NI_\d{5})/iu
              ni_id = $1
              throw :ni_id
            end
          end
        end
      end
      ni_id
    end
  end
end
