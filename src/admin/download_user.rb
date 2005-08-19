#!/usr/bin/env ruby
# Admin::DownloadUser -- oddb -- 21.12.2004 -- hwyss@ywesee.com

require 'util/persistence'
require 'model/invoice_observer'
require 'digest'

module ODDB
	module Admin
		class DownloadUser
			include Persistence
			include InvoiceObserver
			ODBA_SERIALIZABLE = ['@challenges']
			attr_reader :email
			attr_accessor :salutation, :name, :name_first, :company_name,
				:address, :plz, :location, :phone, :business_area
			class Challenge
				AGE_LIMIT = 72*60*60 # 72h
				attr_reader :key
				attr_reader :time
				def initialize
					@key = Digest::MD5.hexdigest(rand(2**32).to_s)
					@time = Time.now
					@authenticated = false
				end
				def authenticated?
					@authenticated
				end
				def authenticate!
					unless(@authenticated)
						@time = Time.now
						@authenticated = true
					end
				end
				def recent?
					Time.now - @time < AGE_LIMIT
				end
				def valid_until
					@time + AGE_LIMIT
				end
			end
			def initialize(email)
				@email = email
				@challenges = []
				@invoices = []
			end
			def authenticate!(key)
				if(challenge = self.challenge(key))
					challenge.authenticate!
					odba_isolated_store
				end
				authenticated?
			end
			def authenticated?
				@challenges.any? { |challenge| 
					challenge.authenticated? && challenge.recent?
				}
			end
			def challenge(key)
				@challenges.select { |challenge| challenge.key == key }.first
			end
			def create_challenge
				challenge = Challenge.new
				@challenges.push(challenge)
				odba_isolated_store
				challenge
			end
		end
	end
end
