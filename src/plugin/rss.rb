#!/usr/bin/env ruby
# encoding: utf-8
# RssPlugin -- oddb.org -- 29.10.2012 -- yasaka@ywesee.com
# RssPlugin -- oddb.org -- 16.08.2007 -- hwyss@ywesee.com

require 'date'
require 'plugin/plugin'
require 'util/logfile'
require 'custom/lookandfeelbase'
require 'view/rss/price_cut'
require 'view/rss/price_rise'
require 'view/rss/sl_introduction'
require 'view/rss/recall'

module ODDB
  class RssPlugin < Plugin
    def initialize(app)
      super
      @report = {}
    end
    def report
      lines = []
      @report.each_pair do |name, count|
        lines << sprintf("%-32s %3i", "#{name}:", count)
      end
      lines.join("\n")
    end
    def sort_packages(packages)
      packages.sort_by { |pac|
        time = pac.price_public.valid_from
        [-time.year, -time.month, -time.day, pac]
      }
    end
    def download(uri, agent=nil)
      LogFile.append('oddb/debug', " getin RssPlugin#download", Time.now)
      unless agent
        agent = Mechanize.new
        agent.user_agent_alias = "Linux Firefox"
      end
      return agent.get(uri)
    rescue EOFError
      retries ||= 3
      if retries > 0
        retries -= 1
        sleep 5
        retry
      else
        raise
      end
    end
    def extract_swissmedic_entry_from(category, page, host)
      page.links.map do |link|
        entry = {}
        if !@found_old_feed and
           href = link.href and
           href.match(/\/00091\/#{category}\/(\d{5})/) and $1 != '01459' # "Archiv Chargenrückrufe"
          if pub = link.node.next and
             pub.text.match(/(\d{2}\.\d{2}\.\d{4})/)
            date = $1
          end
          if date and # only current month
             date =~ /^\d{2}\.#{@@today.month}\.#{@@today.year}/o
            entry_page = link.click
            if container = entry_page.at("div[@id='webInnerContentSmall']") and
               content   = container.xpath(".//div[starts-with(@id, 'sprungmarke')]/div")
              if h1 = container.xpath(".//h1[@id='contentStart']")
                title = h1.text
              end
              entry[:title]       = title || ''
              entry[:date]        = Date.parse(date).to_s
              entry[:description] = content.inner_html
              entry[:link]        = host + href
            end
          elsif !date.nil? # found previous month
            @found_old_feed = true
          end
        end
        if entry.empty?
          nil
        else
          entry
        end
      end.compact
    end
    def update_swissmedic_feed(type)
      types = {
        :recall => '00118',
        :hpc    => '00092',
      }
      return unless types.include?(type)
      host = "http://www.swissmedic.ch"
      category = types[type]
      per_page = 5
      entries = Hash.new{|h,k| h[k] = [] }
      LookandfeelBase::DICTIONARIES.each_key do |lang|
        base_uri = host + "/marktueberwachung/00091/#{category}/index.html?lang=#{lang}" # &start=0
        @found_old_feed = false
        first_page = download(base_uri)
        if last_uri = first_page.link_with(:text => /»/).href and
           last_uri.match(/&start=([\d]*)/)
          entries[lang] += extract_swissmedic_entry_from(category, first_page, host)
          (per_page..$1.to_i).step(per_page).to_a.each do |idx|
            break if @found_old_feed
            if page = download("#{base_uri}&start=#{idx}")
              entries[lang] += extract_swissmedic_entry_from(category, page, host)
            end
          end
        end
      end
      unless entries.empty?
        name = "#{type.to_s}.rss"
        update_rss_feeds(name, entries, View::Rss::Recall)
        # recount only with de entries
        @app.rss_updates[name] = [@month || @@today, entries['de'].length]
        @app.odba_isolated_store
        @report = {"#{type.to_s.capitalize} Feed" => entries['de'].length}
      end
    end
    def update_recall_feed
      update_swissmedic_feed(:recall)
    end
    def update_hpc_feed
      update_swissmedic_feed(:hpc)
    end
    def update_price_feeds(month=@@today)
      @month = month
      cuts = []
      rises = []
      news = []
      cutoff = (month << 1) + 1 
      first = Time.local(cutoff.year, cutoff.month, cutoff.day)
      last = Time.local(month.year, month.month, month.day)
      range = first..last
      @app.each_package { |package|
        if((current = package.price_public) \
          && (range.cover?(current.valid_from)))
          #&& (range.include?(current.valid_from)))
          previous = package.price_public(1)
          target = if previous.nil?
                     news if current.authority == :sl
                   elsif [:sl, :lppv, :bag].include?(package.data_origin(:price_public))
                     if previous > current
                       cuts
                     elsif current > previous
                       rises
                     end
                   end
          target.push(package) if(target)
        end
      }
      update_rss_feeds('sl_introduction.rss', news, View::Rss::SlIntroduction)
      update_rss_feeds('price_cut.rss', _sort_packages(cuts), View::Rss::PriceCut)
      update_rss_feeds('price_rise.rss', _sort_packages(rises), View::Rss::PriceRise)
      # no report
    end
  end
end
