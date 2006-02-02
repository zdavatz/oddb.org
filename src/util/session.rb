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
		attr_writer :desired_state
		LF_FACTORY = LookandfeelFactory
		DEFAULT_FLAVOR = "gcc"
		DEFAULT_LANGUAGE = "de"
		DEFAULT_STATE = State::Drugs::Init
		DEFAULT_ZONE = :drugs
		SERVER_NAME = 'www.oddb.org'
		PERSISTENT_COOKIE_NAME = 'oddb-preferences'
		QUERY_LIMIT = 5
		QUERY_LIMIT_AGE = 60 * 60 * 24
		PROCESS_TIMEOUT = 30
		HTML_TIMEOUT = 30
		begin
			@@stub_html = File.read(File.expand_path('../../data/stub.html', File.dirname(__FILE__)))
		rescue
			@@stub_html = ''
		end
		@@requests ||= {}
		@@html_cache ||= {}
		def Session.clear_html_cache
			@@html_cache.clear
		end
		def Session.html_cache
			@@html_cache
		end
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
		def event
			if(@lookandfeel \
				&& persistent_user_input(:flavor) != @lookandfeel.flavor)
				:home
			else
				super
			end
		end
		def limit_queries
			requests = (@@requests[remote_ip] ||= [])
			if(@state.limited?)
				requests.delete_if { |other| 
					(@process_start - other) >= QUERY_LIMIT_AGE 
				}
				requests.push(@process_start)
				if(requests.size > QUERY_LIMIT)
					request_log('DENY')
					@desired_state = @state
					@active_state = @state = @state.limit_state
				end
			end
		end
		def process(request)
			logtype = 'PRIN'
			timeout(PROCESS_TIMEOUT) { 
				Thread.current.priority = -1
				@request = request
				unless(is_crawler?)
					@@html_cache.delete(@request_path)
				end
				@request_id = request.object_id
				@request_path = request.unparsed_uri
				@process_start = Time.now
				request_log('INIT')
				logtype = 'PRCS'
				if(is_crawler?)
					if(@@html_cache[@request_path].nil?)
						Thread.current.priority = -3
						super
					end
				else
					super
					## @lookandfeel.nil?: the first access from a client has no
					## lookandfeel here
					if(self.lookandfeel.enabled?(:query_limit))
						limit_queries 
					end
					## return empty string across the drb-border
					''
				end
			}
		rescue Timeout::Error
			logtype = 'PRTO'
			'your request has timed out. please try again later.'
		rescue Exception => ex
			logtype = ex.message
		ensure
			Thread.current.priority = 0
			request_log(logtype)
		end
		def request_log(phase)
			bytes = File.read("/proc/#{$$}/stat").split(' ').at(22).to_i
			asterisk = is_crawler? ? "*" : " "
			now = Time.now
			Session.request_log.puts(sprintf(
				"%s | %sip: %15s | session:%12i | request:%12i | time:%4is | mem:%6iMB | %s %s",
				now.strftime('%Y-%m-%d %H:%M:%S'), asterisk, remote_ip, self.object_id, @request_id, 
				now - @process_start, bytes / (2**20), phase, @request_path))
			Session.request_log.flush
		rescue Exception
			## don't die for logging
		end
		def to_html
			logtype = 'HTML'
			timeout(HTML_TIMEOUT) {
				Thread.current.priority = 0
				if(is_crawler?)
					if(html = @@html_cache[@request_path])
						logtype = 'CCHE'
						html
					else
						#Thread.current.priority = -3
						logtype = 'CRWL'
						sleep(5)
						#@@stub_html
						super
					end
				else
					html = super
					if(@user.cache_html?)
						@@html_cache[@request_path] = html
					end
					html
				end.dup
			}
		rescue Timeout::Error
			logtype = 'TMOT'
			'your request has timed out. please try again later.'
		rescue Exception => ex
			logtype = ex.message
		ensure
			Thread.current.priority = 0
			request_log(logtype)
		end
		def initialize(key, app, validator=nil)
			super(key, app, validator)
			@interaction_basket = []
		end
		def add_to_interaction_basket(object)
			@interaction_basket.push(object)
		end
		def __checkout
			@@html_cache.delete(@request_path)
			true
		end
		def clear_interaction_basket
			@interaction_basket.clear
		end
		def currency 
			cookie_set_or_get(:currency) || "CHF"
		end
		def desired_state
			if(mod = @user.viral_module)
				@desired_state.extend(mod)
			end
			@desired_state
		end
		def interaction_basket_count
			@interaction_basket.size
		end
		def migel_alphabetical(range)
			@app.search_migel_alphabetical(range, self.language)
		end
		def navigation
			@active_state.navigation
		end
		def user
			@user.odba_instance
		end
		def user_equiv?(test)
			return true if(@user.is_a?(ODDB::AdminUser))
			mdl = if(test.is_a?(Persistence::Pointer))
				test.resolve(@app)
			else
				test
			end 
			# odba hack: ensure that we are not comparing stubs by mistake
			(mdl.odba_instance == @user.model.odba_instance)
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
