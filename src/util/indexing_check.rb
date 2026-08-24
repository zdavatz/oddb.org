#!/usr/bin/env ruby

# IndexingCheck -- oddb.org -- 2026 -- zdavatz@ywesee.com
#
# Answers "does Google still see the 5xx it complained about?" by taking the
# urls that actually returned 500 from our own app log and asking the Search
# Console URL Inspection API what it knows about each one.
#
# The api has no endpoint that lists the urls behind a Page Indexing report,
# so the candidate list has to come from our side - see GoogleSearchConsole.

require "util/google_search_console"
require "util/logfile"
require "util/workdir"

module ODDB
  class IndexingCheck
    # Google reports these as "Serverfehler (5xx)" / "Seite mit Weiterleitung"
    # etc. SUCCESSFUL is the one we are working towards.
    BAD_FETCH_STATES = %w[
      SERVER_ERROR
      INTERNAL_CRAWL_ERROR
      SOFT_404
      REDIRECT_ERROR
    ]

    attr_reader :report_lines, :results

    def initialize(client = nil)
      @client = client
      @report_lines = []
      @results = {}
    end

    def client
      @client ||= GoogleSearchConsole.new
    end

    # Distinct paths that returned 500, newest logs first, per host.
    # The app log line looks like
    #   1.2.3.4, 127.0.0.1 - - [23/Aug/2026 21:50:27] "GET https://host/path HTTP/1.1" 500 1234 ...
    def self.failing_urls(log_files, limit = nil)
      urls = {}
      Array(log_files).each do |file|
        next unless File.exist?(file)
        File.foreach(file) do |line|
          next unless line.include?('" 500 ')
          next unless (match = /"[A-Z]+ (https?:\/\/[^\s"]+)/.match(line))
          url = match[1]
          next if url.include?("localhost")
          host = begin
            URI(url).host
          rescue
            nil
          end
          next unless host
          (urls[host] ||= []) << url
        end
      end
      urls.each do |host, list|
        list.uniq!
        list.replace(list.first(limit)) if limit
      end
      urls
    end

    def self.log_files(days = 7, today = Date.today)
      (0...days).collect { |back|
        date = today - back
        File.join(ODDB::LOG_DIR, date.strftime("%Y/%m/%d"), "oddb_log")
      }.select { |file| File.exist?(file) }
    end

    # A sc-domain: property covers every subdomain, so ch.oddb.org,
    # i.ch.oddb.org and oekk.oddb.org all belong to sc-domain:oddb.org. Try the
    # exact host first, then drop labels from the left. Returns nil for hosts we
    # have no property for - including the mangled ones some crawlers send
    # ("chahmer.ch" for nachahmer.ch), which must not eat quota.
    def self.site_url_for(host, site_urls)
      return nil if host.nil? || host.empty?
      labels = host.split(".", -1)
      # ".oddb.org" would otherwise match oddb.org by suffix, and Google would
      # reject the malformed url after we had already spent the quota on it.
      return nil if labels.size < 2 || labels.any?(&:empty?)
      (0...labels.size).each do |i|
        candidate = labels[i..].join(".")
        return site_urls[candidate] if site_urls[candidate]
      end
      nil
    end

    # urls_by_host: {"ch.oddb.org" => [url, ...]}
    # site_urls:    {"oddb.org" => "sc-domain:oddb.org"}
    def check(urls_by_host, site_urls)
      urls_by_host.each do |host, urls|
        site_url = self.class.site_url_for(host, site_urls)
        unless site_url
          @report_lines << "#{host}: no Search Console property configured, skipped #{urls.size} urls"
          next
        end
        check_host(host, urls, site_url)
      end
      @report_lines.join("\n")
    end

    def report
      @report_lines.join("\n")
    end

    private

    def check_host(host, urls, site_url)
      states = Hash.new(0)
      verdicts = Hash.new(0)
      # coverageState is the plain-text line Search Console itself shows
      # ("URL is unknown to Google", "Crawled - currently not indexed", …) and
      # is far more telling than the enums, especially when pageFetchState
      # comes back UNSPECIFIED because Google never fetched the url at all.
      coverage = Hash.new(0)
      still_failing = []
      errors = []

      client.inspect_urls(urls, site_url) do |url, status, error|
        if error
          errors << "#{url}: #{error.message}"
          next
        end
        fetch_state = status["pageFetchState"].to_s
        states[fetch_state.empty? ? "UNKNOWN" : fetch_state] += 1
        verdicts[status["verdict"].to_s] += 1
        coverage[status["coverageState"].to_s] += 1
        @results[url] = status
        if BAD_FETCH_STATES.include?(fetch_state)
          still_failing << [url, fetch_state, status["lastCrawlTime"]]
        end
      end

      @report_lines << "#{host} (#{site_url}): #{urls.size} urls inspected"
      coverage.sort_by { |_, count| -count }.each do |state, count|
        @report_lines << format("  %-44s %5d", state.empty? ? "(no coverageState)" : state, count)
      end
      states.sort_by { |_, count| -count }.each do |state, count|
        @report_lines << format("  fetch   %-36s %5d", state, count)
      end
      verdicts.sort_by { |_, count| -count }.each do |verdict, count|
        @report_lines << format("  verdict %-36s %5d", verdict, count)
      end
      unless still_failing.empty?
        @report_lines << "  still failing for Google (#{still_failing.size}):"
        still_failing.first(25).each do |url, state, crawled|
          @report_lines << "    #{state} #{crawled} #{url}"
        end
        if still_failing.size > 25
          @report_lines << "    ... and #{still_failing.size - 25} more"
        end
      end
      unless errors.empty?
        @report_lines << "  api errors (#{errors.size}):"
        errors.first(10).each { |line| @report_lines << "    #{line}" }
      end
      @report_lines << ""
    end
  end
end
