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

module ODDB
  class RssPlugin < Plugin
    attr_reader :report
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
      LogFile.append('oddb/debug', " getin RssPlugin#download #{uri}", Time.now.utc)
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
    def compose_description(content)
      current_lang = @lang || 'de'
      description  = content.inner_html
      if dd = content.xpath('.//p/strong') and
         nn = dd.text.scan(/(\d{2})([‘'])(\d{3})/) and !nn.empty?
        nn.each do |matched|
          number_str = matched.join
          number_int = matched[0] + matched[2]
          oddb_link  = "http://#{SERVER_NAME}/#{current_lang}/gcc/show/reg/#{number_int}"
          description.gsub!(
            number_str,
            "<a href='#{oddb_link}' target='_blank'>#{number_str}</a>"
          )
        end
      end
      description
    end
    def extract_swissmedic_entry_from(category, page, host, count=false)
      return nil unless page and page.links
      page.links.map do |link|
        entry = {}
        if href = link.href and href.match(/\/00135\/#{category}\/(\d{5})/) and $1 != '01711' # "Archiv Chargenrückrufe"
          title = ''
          container = Nokogiri::HTML(open(host + href))
          if h1 = container.xpath(".//h1[@id='contentStart']")
            title = h1.text
          end
          return nil unless container and date_field = /\d\d\.\d\d.\d\d\d\d/.match(container.text)
          date = Date.parse(date_field.to_s).to_s
          if count
            if date =~ /^(\d{2})\.(#{("%02d" % @@today.month)})\.(#{@@today.year})/o
              @current_issue_count += 1
              @new_entry_count     += 1 if Date.new($3.to_i, $2.to_i, $1.to_i) >= @app.rss_updates[@name].first
            end
          end
          entry[:title]       = title || ''
          entry[:date]        = date
          entry[:description] = compose_description(container.xpath(".//div[starts-with(@id, 'sprungmarke')]/div"))
          entry[:link]        = host + href
        end
        if entry.empty?
          nil
        else
          entry
        end
      end.compact
    end
    def swissmedic_entries_of(type)
      entries = Hash.new{|h,k| h[k] = [] }
      host = "https://www.swissmedic.ch"
      per_page = 5
      swissmedic_categories = {
        :recall => '00166',
        :hpc    => '00157',
      }
      category = swissmedic_categories[type]
      return entries unless category
      LookandfeelBase::DICTIONARIES.each_key do |lang|
        @lang = lang # current_lang
        count = (lang == 'de' ? true : false)
        base_uri   = host + "/marktueberwachung/00135/#{category}/index.html?lang=#{lang}" # &start=0
        first_page = download(base_uri)
        last_uri = first_page.link_with(:text => /1/)
        # TODO: this loop does not work! only the first 10 entries are fetched
        if last_uri and last_uri.href # and last_uri.match(/&start=([\d]*)/)
          result = extract_swissmedic_entry_from(category, first_page, host, count)
          entries[lang] += result if result
          (per_page..$1.to_i).step(per_page).to_a.each do |idx|
            if page = download("#{base_uri}&start=#{idx}")
              entries[lang] += extract_swissmedic_entry_from(category, page, host, count)
            end
          end
        end
      end
      entries
    end
    def generate_flavored_rss(name)
      %w[
        just-medical
      ].each do |flavor|
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
