#!/usr/bin/env ruby
# Session -- oddb -- hwyss@ywesee.com

require 'sbsm/session'
require 'custom/lookandfeelfactory'
require 'state/states'
require 'util/validator'
require 'model/user'
require 'benchmark'

module ODDB
  class Session < SBSM::Session
		attr_reader :interaction_basket
		LF_FACTORY = LookandfeelFactory
		DEFAULT_FLAVOR = "gcc"
		DEFAULT_LANGUAGE = "de"
		DEFAULT_STATE = InitState
		SERVER_NAME = 'www.oddb.org'
=begin
		def process(request)
			res = nil
			Benchmark.bm { |bm|
				bm.item('process') { res = super }
			}
			res
			''
		end
		def to_html
			res = nil
			Benchmark.bm { |bm|
				bm.item('to_html') { res = super }
			}
			puts res.size
			res
		end
=end
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
		def interaction_basket_count
			@interaction_basket.size
		end
		def user_equiv?(test)
			return true if(@user.is_a? RootUser)
			mdl = if(test.is_a?(Persistence::Pointer))
				test.resolve(@app)
			else
				test
			end 
			mdl == @user.model
		end
		def search(query)
			@persistent_user_input[:search_query] ||= query
			@app.search(query)
		end
		def search_interaction(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_interaction(query)
		end
  end
end
