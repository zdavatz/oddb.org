#!/usr/bin/env ruby

# Plugin -- oddb -- 01.11.2011 -- yasaka@ywesee.com
# Plugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com

require "cgi"
require "sbsm/cgi"
require "util/http"
require "util/logfile"
require "util/today"
require "ostruct"
require "custom/lookandfeelbase"
require "fileutils"

module ODDB
  class Plugin
    class SessionStub
      attr_reader :app, :flavor, :http_protocol, :server_name, :default_language, :currency
      attr_accessor :language, :lookandfeel
      def initialize(app)
        @app = app
        @cgi = CGI.initialize_without_offline_prompt("html4")
        @flavor = "gcc"
        @http_protocol = "https"
        @server_name = SERVER_NAME
        @default_language = "de"
        @currency = "CHF"
        @currency_rates = {}
      end

      def method_missing(*args)
      end
    end
    SWISSMEDIC_HUMAN_URL_DE = "https://www.swissmedic.ch//swissmedic/de/home/humanarzneimittel"
    SWISSMEDIC_HUMAN_URL_FR = "https://www.swissmedic.ch//swissmedic/fr/medicaments-a-usage-humain"
    SWISSMEDIC_HUMAN_URL_IT = "https://www.swissmedic.ch//swissmedic/it/home/medicamenti-per-uso-umano"
    include HttpFile
    # Recipients for Plugin-Specific Update-Logs can be added in
    # 'Plugin's subclasses
    RECIPIENTS = []
    attr_reader :change_flags, :month
    def initialize(app, params = nil)
      @app = app
      @change_flags = {}
    end

    def l10n_sessions(&block)
      stub = SessionStub.new(@app)
      LookandfeelBase::DICTIONARIES.each_key { |lang|
        stub.language = lang
        stub.lookandfeel = LookandfeelBase.new(stub)
        block.call(stub)
      }
    end

    def log_info
      [:change_flags, :report, :recipients].each_with_object({}) { |key, inj|
        inj.store(key, send(key))
      }
    end

    def recipients
      @recipients ||= self.class::RECIPIENTS.dup
    end

    def report
      ""
    end

    def root_url
      "https://#{SERVER_NAME}"
    end

    def resolve_link(model)
      pointer = model.pointer
      str = if model.respond_to?(:name_base)
        (model.name_base.to_s + ": ").ljust(50)
      else
        ""
      end
      str += "#{root_url}/de/gcc/resolve/pointer/" + CGI.escape(pointer.to_s) + " "
    rescue
      "Error creating Link for #{pointer.inspect}"
    end

    def update_yearly_fachinfo_feeds
      @app.sorted_fachinfos.collect { |x| x.revision.utc.year }.sort.uniq.each do |year|
        LogFile.debug "update_yearly_fachinfo_feeds for #{year}"
        update_rss_feeds("fachinfo-#{year}.rss", @app.sorted_fachinfos, View::Rss::Fachinfo, year)
      end
      LogFile.debug "Done update_yearly_fachinfo_feeds"
    end

    # update_rss_feeds comes these different paths
    # * update_yearly_fachinfo_feeds
    # * postprocess of import_swissmedicinfo
    def update_rss_feeds(name, model, view_klass, args = nil)
      return if model.empty?
      l10n_sessions do |stub|
        view = args ? view_klass.new(model, stub, nil, args) : view_klass.new(model, stub, nil)
        if view.respond_to?(:name=)
          view.name = name
        end
        path = File.join(RSS_PATH, stub.language, name)
        tmp = File.join(RSS_PATH, stub.language, "." + name)
        @cgi ||= CGI.initialize_without_offline_prompt("html4")
        FileUtils.mkdir_p(File.dirname(path))
        File.open(tmp, "w+") { |fh|
          fh.puts view.to_html(@cgi)
        }
        FileUtils.mv(tmp, path) if File.exist?(tmp)
      end
      LogFile.debug("#{@name}: month #{@month} today #{@@today} with #{model.size} entries")
      @app.rss_updates[name] = [@month || @@today, model.size]
      @app.odba_isolated_store
    end

    def fetch_with_http(url)
      URI.open(url) do |input|
        input.read
      end
    end

    def save_file(filename, content)
      open(filename, "w+") { |output| output.write(content) }
    end
  end
end
