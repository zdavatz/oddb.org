#!/usr/bin/env ruby
# RssPlugin -- oddb.org -- 16.08.2007 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'view/rss/price_cut'
require 'view/rss/price_rise'
require 'view/rss/sl_introduction'

module ODDB
  class RssPlugin < Plugin
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
          && (range.include?(current.valid_from)))
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
      update_rss_feeds('sl_introduction.rss', sort_packages(news), View::Rss::SlIntroduction)
      update_rss_feeds('price_cut.rss', sort_packages(cuts), View::Rss::PriceCut)
      update_rss_feeds('price_rise.rss', sort_packages(rises), View::Rss::PriceRise)
    end
    def sort_packages(packages)
      packages.sort_by { |pac|
        time = pac.price_public.valid_from
        [-time.year, -time.month, -time.day, pac]
      }
    end
  end
end
