#!/usr/bin/env ruby
# encoding: utf-8
# RssPlugin -- oddb.org -- 18.03.2013 -- yasaka@ywesee.com
# RssPlugin -- oddb.org -- 16.08.2007 -- hwyss@ywesee.com

require 'date'
require 'plugin/plugin'
require 'util/logfile'
require 'custom/lookandfeelbase'
require 'view/rss/price_cut'
require 'view/rss/price_rise'
require 'view/rss/sl_introduction'
require 'view/rss/swissmedic'
require 'mechanize'

module ODDB
  class RssPlugin < Plugin
    RSS_URLS = {
      :de  => {
               :hpc => {
                        # we use https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/health-professional-communication--hpc-/_jcr_content/par/teaserlist.content.paging-1.html?pageIndex=1
                        :human   => 'https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/health-professional-communication--hpc-.html',
                        },
                :recall => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/qualitaetsmaengel-und-chargenrueckrufe/chargenrueckrufe.html'
                           }
               },
      :fr  => {
               :hpc => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/fr/home/medicaments-a-usage-humain/surveillance-du-marche/health-professional-communication--hpc-.html'
                        },
                :recall => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/fr/home/medicaments-a-usage-humain/surveillance-du-marche/qualitaetsmaengel-und-chargenrueckrufe/retraits-de-lots.html',
                           }
               },
      :it  => {
               :hpc => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/it/home/medicamenti-per-uso-umano/sorveglianza-del-mercato/health-professional-communication--hpc-.html',
                        },
                :recall => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/it/home/medicamenti-per-uso-umano/sorveglianza-del-mercato/qualitaetsmaengel-und-chargenrueckrufe/ritiri-delle-partite.html',
                           }
               },
      :en  => {
               :hpc => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/en/home/humanarzneimittel/market-surveillance/health-professional-communication--hpc-.html',
                        },
                :recall => {
                        :human    => 'https://www.swissmedic.ch/swissmedic/en/home/humanarzneimittel/market-surveillance/qualitaetsmaengel-und-chargenrueckrufe/batch-recalls.html',
                           }
               },
      }
    RSS_URLS.keys.each do |lang|
      [:hpc, :recall].each do |rss_type|
        RSS_URLS[lang][rss_type][:index] = RSS_URLS[lang][rss_type][:human].sub(/\.html$/, '/_jcr_content/par/teaserlist.content.paging-1.html?pageIndex=1')
      end
    end

    FLAVORED_RSS = %w[
      just-medical
    ]
    attr_reader :report
    def initialize(app)
      super
      @report = {}
      @downloaded_urls = {}
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
    def compose_description(content)
      number = content.xpath(".//td").last
      current_lang = @lang || 'de'
      description  = content.inner_html
      content.xpath('.//td').each do |elem|
         if  matched = /^(\d{2})([‘']*)(\d{3})\s*$/.match(elem.text)
          number_str = matched[0]
          number_int = matched[0] + matched[2]
          oddb_link  = "#{root_url}/#{current_lang}/gcc/show/reg/#{number_int}"
          description.gsub!(
            number_str,
            "<a href='#{oddb_link}' target='_blank'>#{number_str}</a>"
          )
         end
      end
      require 'pry'; binding.pry
      description
    end
    def detail_info(host, container, count=false)
      entry = {}
      entry[:link] = host + container.xpath(".//h3/a").first.attributes['href'].text
      # require 'pry'; binding.pry
      @downloaded_urls[entry[:link]] = true
      @current_issue_count  ||= 0 # for unit test
      @new_entry_count      ||= 0
      title                 =  container.xpath(".//h3/a").text
      entry[:title]         = title
      date_field            = container.xpath(".//div/p[@class='teaserDate']").text
      entry[:date]          = date_field
      entry[:description]   = container.xpath(".//div/p")[1..-1].text
      date = Date.parse(date_field.to_s)
      if count
        if date.year == @@today.year and date.month ==  @@today.month
          # LogFile.append('oddb/debug', " rss adding current issue: #{date.to_s} #{title}", Time.now.utc)
          @current_issue_count += 1
        end
        if @app.rss_updates[@name] and date >= @app.rss_updates[@name].first
          @new_entry_count     += 1
          LogFile.append('oddb/debug', " rss adding new entry: #{date.to_s} #{title}", Time.now.utc)
        end
      end
      entry
    end
    def swissmedic_entries_of(type)
      entries = Hash.new{|h,k| h[k] = [] }
      return entries unless RSS_URLS[LookandfeelBase::DICTIONARIES.keys.first.to_sym].keys.index(type)
      LookandfeelBase::DICTIONARIES.each_key do |lang|
        @lang = lang # current_lang
        count = (lang == 'de' ? true : false)
        # require 'pry'; binding
        base_uri = RSS_URLS[lang.to_sym][type][:index]
        uri = URI(base_uri)
        host = uri.scheme + '://' + uri.host
        first_page =  Nokogiri::HTML(fetch_with_http(base_uri))
        step_nr = 1
        while true
          break unless first_page
          first_page.xpath(".//div[@class='row']").each do |item|
            result = detail_info(host, item, count)
            entries[lang] << result if result and not entries[lang].index{ |x| x[:title] == result[:title] and   x[:date] == result[:date] }
            
          end
          step_nr += 1
          first_page =  Nokogiri::HTML(fetch_with_http(base_uri.gsub('1', step_nr.to_s)))
          break if /Keine Resultate/i.match(first_page.text)
        end
      end
      entries
    end
    def generate_flavored_rss(name)
      FLAVORED_RSS.each do |flavor|
        l10n_sessions { |stub|
        orig = File.join(RSS_PATH, stub.language, name)
        file = File.basename(name, '.rss') + '-' + flavor + '.rss'
        path = File.join(RSS_PATH, stub.language, file)
        tmp = File.join(RSS_PATH, stub.language, '.' << file)
        FileUtils.mkdir_p(File.dirname(path))
        if File.exists?(orig)
          rss = File.read(orig, :encoding => 'utf-8')
          File.open(tmp, 'w:utf-8') do |fh|
            fh.puts rss.gsub(/\/gcc\//, "/#{flavor}/")
          end
          FileUtils.mv(tmp, path)
        end
      }
      end
    end
    def update_swissmedic_feed(type)
      @name = "#{type.to_s}.rss"
      @current_issue_count  = 0 # only de
      @new_entry_count      = 0
      entries = swissmedic_entries_of(type)
      LogFile.append('oddb/debug', " update_swissmedic_feed #{type} name #{@name}: #{entries.size} entries", Time.now.utc)
      unless entries.empty?
        previous_update = @app.rss_updates[@name]
        update_rss_feeds(@name, entries, View::Rss::Swissmedic)
        generate_flavored_rss(@name)
        # re-update (overwrite)
        if @current_issue_count > 0
          @app.rss_updates[@name] = [@@today, @current_issue_count]
        else
          @app.rss_updates[@name] = previous_update
        end
        @app.odba_isolated_store
        if @new_entry_count > 0
          @report = {
            "New #{type.to_s}.rss feeds"         => @new_entry_count,
            "This month(#{@@today.month}) total" => @current_issue_count,
          }
        end
      end
      entries
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
      update_rss_feeds('price_cut.rss', sort_packages(cuts), View::Rss::PriceCut)
      update_rss_feeds('price_rise.rss', sort_packages(rises), View::Rss::PriceRise)
    end
  end
end
