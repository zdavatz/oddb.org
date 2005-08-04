#!/usr/bin/env ruby
# Session -- oddb -- hwyss@ywesee.com

require 'sbsm/session'
require 'custom/lookandfeelfactory'
require 'state/states'
require 'util/validator'
require 'model/user'
require 'fileutils'
#require 'benchmark'

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
		QUERY_LIMIT = 10
		QUERY_LIMIT_AGE = 60 * 60 * 24
		@@requests = {}
		def Session.request_log
			path = File.expand_path('../../log/request_log', 
				File.dirname(__FILE__))
			FileUtils.mkdir_p(File.dirname(path))
			@@request_log ||= File.open(path, 'a')
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
			@request = request
			@request_id = request.object_id
			@request_path = request.unparsed_uri
			@process_start = Time.now
			if(is_crawler?)
				Thread.current.priority = -1
				super
			else
				super
				## @lookandfeel.nil?: the first access from a client has no
				## lookandfeel here
				if(self.lookandfeel.enabled?(:query_limit))
					limit_queries 
				end
			end
		ensure
			request_log('PRCS')
		end
		def request_log(phase)
			bytes = File.read("/proc/#{$$}/stat").split(' ').at(22).to_i
			Session.request_log.puts(sprintf(
				"session:%12i request:%12i time:%4is mem:%6iMB %s %s",
				self.object_id, @request_id, Time.now - @process_start, 
				bytes / (2**20), phase, @request_path))
			Session.request_log.flush
		rescue Exception
			## don't die for logging
		end
		def to_html
			if(is_crawler?)
				Thread.current.priority = -1
			end
			super
		ensure
			request_log('HTML')
		end
		def initialize(key, app, validator=nil)
			super(key, app, validator)
			@interaction_basket = []
		end
		def add_to_interaction_basket(object)
			@interaction_basket.push(object)
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
		def navigation
			@active_state.navigation
		end
		def user_equiv?(test)
			return true if(@user.is_a? ODDB::AdminUser)
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
		def search_substances(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_substances(query)
		end
		def set_persistent_user_input(key, val)
			@persistent_user_input.store(key, val)
		end
  end
end
