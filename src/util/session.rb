#!/usr/bin/env ruby
# Session -- oddb -- hwyss@ywesee.com

require 'sbsm/session'
require 'custom/lookandfeelfactory'
require 'state/states'
require 'util/validator'
require 'model/user'
require 'fileutils'
require 'timeout'

module ODDB
  class Session < SBSM::Session
		attr_reader :interaction_basket
		attr_accessor :desired_state
		LF_FACTORY = LookandfeelFactory
		DEFAULT_FLAVOR = "gcc"
		DEFAULT_LANGUAGE = "de"
		DEFAULT_STATE = State::Drugs::Init
		DEFAULT_ZONE = :drugs
		SERVER_NAME = 'www.oddb.org'
		PERSISTENT_COOKIE_NAME = 'oddb-preferences'
		QUERY_LIMIT = 5
		QUERY_LIMIT_AGE = 60 * 60 * 24
		PROCESS_TIMEOUT = 30 * 5
		HTML_TIMEOUT = 30 * 5
		@@requests ||= {}
		def Session.reset_query_limit(ip = nil)
			if(ip)
				@@requests.delete(ip)
			else
				@@requests.clear
			end
		end
		def Session.request_log
			path = File.expand_path('../../log/request_log', 
				File.dirname(__FILE__))
			FileUtils.mkdir_p(File.dirname(path))
			@@request_log ||= File.open(path, 'a')
		end
		def Session.restart_logging
			@@request_log = nil
		end
		def initialize(key, app, validator=nil)
			super(key, app, validator)
			@interaction_basket = []
      @currency_rates = {}
		end
    def allowed?(*args)
      @user.allowed?(*args)
    end
		def event
			if(@lookandfeel \
				&& persistent_user_input(:flavor) != @lookandfeel.flavor)
				:home
			else
				super
			end
		end
		def expired?
      super || (logged_in? && @user.expired?)
		end
		def flavor
			@flavor ||= (@valid_input[:partner] || super)
		end
		def limit_queries
			requests = (@@requests[remote_ip] ||= [])
			if(@state.limited?)
				requests.delete_if { |other| 
					(@process_start - other) >= QUERY_LIMIT_AGE 
				}
				requests.push(@process_start)
				if(requests.size > QUERY_LIMIT)
					#request_log('DENY')
					@desired_state = @state
					@active_state = @state = @state.limit_state
          @state.request_path = @desired_state.request_path
				end
			end
		end
    def login
      # @app.login raises Yus::YusError
			@user = @app.login(user_input(:email), user_input(:pass))
    end
    def logout
      if(@user.respond_to?(:yus_session))
        @app.logout(@user.yus_session)
      end
      super
    end
		def process(request)
			#logtype = 'PRIN'
			timeout(PROCESS_TIMEOUT) { 
				@request = request
				@request_id = request.object_id
				@request_path = request.unparsed_uri
				@process_start = Time.now
				#request_log('INIT')
				#logtype = 'PRCS'
				super
				if(!is_crawler? && self.lookandfeel.enabled?(:query_limit))
					limit_queries 
				end
			}
			'' ## return empty string across the drb-border
		rescue Timeout::Error
			#logtype = 'PRTO'
			'your request has timed out. please try again later.'
		rescue StandardError => ex
			#logtype = ex.message
			''
		#ensure
			#request_log(logtype)
		end
		def request_log(phase)
			bytes = File.read("/proc/#{$$}/stat").split(' ').at(22).to_i
			asterisk = is_crawler? ? "*" : " "
			now = Time.now
			Session.request_log.puts(sprintf(
				"%s | %sip: %15s | session:%12i | request:%12i | time:%7.3fs | mem:%6iMB | %s %s",
				now.strftime('%Y-%m-%d %H:%M:%S'), asterisk, remote_ip, self.object_id, @request_id, 
				now - @process_start, bytes / (2**20), phase, @request_path))
			Session.request_log.flush
		rescue Exception
			## don't die for logging
		end
		def to_html
			#logtype = 'HTML'
			timeout(HTML_TIMEOUT) {
				super
			}
		rescue Timeout::Error
			#logtype = 'TMOT'
			'your request has timed out. please try again later.'
		rescue Exception => ex
			#logtype = ex.message
		#ensure
			#request_log(logtype)
		end
		def add_to_interaction_basket(object)
			@interaction_basket = @interaction_basket.push(object).uniq
		end
		def clear_interaction_basket
			@interaction_basket.clear
		end
		def currency 
			cookie_set_or_get(:currency) || "CHF"
		end
    def get_currency_rate(currency)
      @currency_rates[currency] ||= @app.get_currency_rate(currency)
    end
		def interaction_basket_count
			@interaction_basket.size
		end
		def analysis_alphabetical(range)
			@app.search_analysis_alphabetical(range, self.language)
		end
		def migel_alphabetical(range)
			@app.search_migel_alphabetical(range, self.language)
		end
		def navigation
			@active_state.navigation
		end
		def search_oddb(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_oddb(query, self.language)
		end
		def search_exact_indication(query)
			@app.search_exact_indication(query, self.language)
		end
		def search_interactions(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_interactions(query)
		end
		def search_migel_products(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_migel_products(query, self.language)
		end
		def search_substances(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_substances(query)
		end
		def set_persistent_user_input(key, val)
			@persistent_user_input.store(key, val)
		end
		def sponsor
			@app.sponsor(flavor)
		end
  end
end
