#!/usr/bin/env ruby
# encoding: utf-8
# RssPlugin -- oddb.org -- 25.10.2012 -- yasaka@ywesee.com
# RssPlugin -- oddb.org -- 16.08.2007 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'view/rss/price_cut'
require 'view/rss/price_rise'
require 'view/rss/sl_introduction'
require 'view/rss/recall'

module ODDB
  class RssPlugin < Plugin
    def sort_packages(packages)
      packages.sort_by { |pac|
        time = pac.price_public.valid_from
        [-time.year, -time.month, -time.day, pac]
      }
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
#print "news.length = "
#p news.length
#p news.select{|pac| pac.name =~ /Excipial U Lipolotio ohne Parfum/}.length
#p news.select{|pac| pac.name =~ /Excipial U Lipolotio ohne Parfum/}.map{|a| a.odba_id.to_s}.join(", ")
#news = [ODBA.cache.fetch('26781434')]
      #update_rss_feeds('sl_introduction.rss', sort_packages(news), View::Rss::SlIntroduction)
      #update_rss_feeds('sl_introduction.rss', sort_packages(news)[0..9], View::Rss::SlIntroduction)
      update_rss_feeds('sl_introduction.rss', news, View::Rss::SlIntroduction)
#p "after sl_introduction.rss"
#exit
      update_rss_feeds('price_cut.rss', sort_packages(cuts), View::Rss::PriceCut)
      update_rss_feeds('price_rise.rss', sort_packages(rises), View::Rss::PriceRise)
    end
    def download(uri)
      LogFile.append('oddb/debug', " getin RssPlugin#download", Time.now)
      agent = Mechanize.new
      agent.user_agent_alias = "Linux Firefox"
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
    def extract_recall_entry_from(page, host='')
      page.links.map do |link|
        entry = {}
        if href = link.href and
           href.match(/\/00091\/00118\/(\d{5})/) and $1 != '01459' # "Archiv Chargenrückrufe"
          entry_page = link.click
          if container = entry_page.at("div[@id='webInnerContentSmall']") and
             content   = container.xpath(".//div[@id='sprungmarke0_0']/div")
            if h1 = container.xpath(".//h1[@id='contentStart']")
              title = h1.text
            end
            if p = content.xpath(".//p").first and
               p.text.match(/^(\d{2}\.\d{2}\.\d+)/)
              date = $1 # some entry does not have date
            end
            entry[:title]       = title || ''
            entry[:date]        = date || ''
            entry[:description] = content.inner_html
            entry[:link]        = host + href
          end
        end
        if entry.empty?
          nil
        else
          entry
        end
      end.compact
    end
    def update_recall_feeds(month=@@today)
      entries = []
      host = "http://www.swissmedic.ch"
      per_page = 5
      base_uri = host + "/marktueberwachung/00091/00118/index.html?lang=de" # &start=0
      first_page = download(base_uri)
      if last_uri = first_page.link_with(:text => /»/).href and
         last_uri.match(/&start=([\d]*)/)
        entries += extract_recall_entry_from(first_page, host)
        (per_page..$1.to_i).step(per_page).to_a.each do |idx|
          if page = download("#{base_uri}&start=#{idx}")
            entries += extract_recall_entry_from(page, host)
          end
        end
      end
      update_rss_feeds('recall.rss', entries, View::Rss::Recall)
    end
  end
end
