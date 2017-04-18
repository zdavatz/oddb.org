#!/usr/bin/env ruby
# encoding: utf-8
# Plugin -- oddb -- 01.11.2011 -- yasaka@ywesee.com
# Plugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com

require 'cgi'
require 'sbsm/cgi'
require 'util/http'
require 'util/logfile'
require 'util/today'
require 'ostruct'
require 'custom/lookandfeelbase'
require 'fileutils'

module ODDB
	class Plugin
    class SessionStub
      attr_reader :app, :flavor, :http_protocol, :server_name, :default_language,
        :currency
      attr_accessor :language, :lookandfeel
      def initialize(app)
        @app = app
        @cgi = CGI.initialize_without_offline_prompt('html4')
        @flavor = Session::DEFAULT_FLAVOR
        @http_protocol = 'http'
        @server_name = SERVER_NAME
        @default_language = 'de'
        @currency_rates = {}
        @currency = 'CHF'
      end
      def get_currency_rate(currency)
        @currency_rates[currency] ||= @app.get_currency_rate(currency)
      end
      def method_missing(*args)
      end
    end
		include HttpFile
		ARCHIVE_PATH = File.expand_path('../../data', File.dirname(__FILE__))
		# Recipients for Plugin-Specific Update-Logs can be added in
		# 'Plugin's subclasses
		RECIPIENTS = []
		attr_reader :change_flags, :month
		def initialize(app, params=nil)
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
			[:change_flags, :report, :recipients].inject({}) { |inj, key|
				inj.store(key, self.send(key))
				inj
			}
		end
		def recipients
			@recipients ||= self::class::RECIPIENTS.dup
		end
		def report
			''
		end
		def resolve_link(model)
			pointer = model.pointer
			str = if(model.respond_to?(:name_base))
				(model.name_base.to_s + ': ').ljust(50)
			else
				''
			end
			str << "http://#{SERVER_NAME}/de/gcc/resolve/pointer/" << CGI.escape(pointer.to_s) << ' '
		rescue StandardError
			"Error creating Link for #{pointer.inspect}"
		end
    def update_yearly_fachinfo_feeds
      @app.sorted_fachinfos.collect{|x| x.revision.utc.year}.sort.uniq.each do |year|
        update_rss_feeds("fachinfo-#{year}.rss", @app.sorted_fachinfos, View::Rss::Fachinfo, year)
      end
    end
    def update_rss_feeds(name, model, view_klass, args = nil)
      return if model.empty?
      l10n_sessions do |stub|
        view = args ? view_klass.new(model, stub, nil, args) : view_klass.new(model, stub, nil)
        if view.respond_to?(:name=)
          view.name = name
        end
        path = File.join(RSS_PATH, stub.language, name)
        tmp = File.join(RSS_PATH, stub.language, '.' + name)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(tmp, 'w+') { |fh|
          fh.puts view.to_html(@cgi)
        }
        FileUtils.mv(tmp, path) if File.exists?(tmp)
      end
      LogFile.append('oddb/debug', " update_rss_feeds #{@name}: month #{@month} today #{@@today} with #{model.size} entries", Time.now.utc)
      @app.rss_updates[name] = [@month || @@today, model.size]
      @app.odba_isolated_store
    end
	end
end
