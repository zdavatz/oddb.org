#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Session -- oddb.org -- 01.07.2012 -- yasaka@ywesee.com
# ODDB::Session -- oddb.org -- 16.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Session -- oddb.org -- 12.05.2009 -- hwyss@ywesee.com

require 'sbsm/session'
require 'custom/lookandfeelfactory'
require 'state/states'
require 'util/validator'
require 'model/user'
require 'fileutils'

module ODDB
  class Session < SBSM::Session
		attr_accessor :desired_state
    attr_reader :request
		LF_FACTORY = LookandfeelFactory
		DEFAULT_FLAVOR = "gcc"
		DEFAULT_LANGUAGE = "de"
		DEFAULT_STATE = State::Drugs::Init
		DEFAULT_ZONE = :drugs
    EXPIRES = 30 * 60
		SERVER_NAME = 'www.oddb.org'
		PERSISTENT_COOKIE_NAME = 'oddb-preferences'
		QUERY_LIMIT = 5
		QUERY_LIMIT_AGE = 60 * 60 * 24
		@@requests ||= {}
		def Session.reset_query_limit(ip = nil)
			if(ip)
				@@requests.delete(ip)
			else
				@@requests.clear
			end
		end
    def initialize(app:,
                   trans_handler: nil,
                   validator: nil,
                   unknown_user: nil,
                   cookie_name: nil,
                   multi_threaded: true)
      super
      require 'util/csstemplate'
      # ODDB::CssTemplate::FLAVORS.keys
      @app = app
			@interaction_basket = []
			@interaction_basket_atc_codes = []
      @currency_rates = {}
		end
    def active_state
      state = super
      unless @token_login_attempted
        @token_login_attempted = true
        if user = login_token
          state = state.autologin user
        end
      end
      state
    end
    def allowed?(*args)
      @user.allowed?(*args)
    end
		def event
			if(@lookandfeel \
				&& persistent_user_input(:flavor) != @lookandfeel.flavor)
				:home
			else
				super || :home
			end
		end
		def expired?(now=Time.now)
      super || (logged_in? && @user.expired?)
		end
		def flavor
      #phyto-pharma
      # oekk is not in CssTemplate!
      if @flavor.nil? && !/(^ch\.oddb\.org|^oddb-ci)/i.match(server_name)
        @flavor = ODDB::CssTemplate::FLAVORS.keys.find do |key| /(www|)#{key}\./i.match(server_name) end
        case server_name
        when /^(www\.|)*(anthroposophika\.|anthroposophy\.|anthroposophica.)/i
          @flavor = 'anthroposophy'
        when /^(www\.|)(xn--|)(homeopathy|homopathika|homoeopathika)(-tfb|)\./i
          @flavor = 'homeopathy'
        when /(^i\.|^mobile\.)/i
          @flavor = 'mobile'
        when /^oekk\./i
          @flavor = 'oekk'
        when /^(www\.|)(phyto-pharma|phytotherapeutika)\./i
          @flavor = 'phyto-pharma'
        else
          if (m = /^\/[a-z]{2}\/([a-z]+)/.match(request_path))
            @flavor = m[1]
          end
        end unless @flavor
        @flavor ||= 'gcc'
        @flavor = @flavor.to_s if @flavor
      end
			@flavor ||= (@valid_input[:partner] || super)
		end
		def limit_queries
			requests = (@@requests[remote_ip] ||= [])
      # puts (msg = "limit_queries #{remote_ip} @state.limited? #{@state.limited? } has #{requests.size} entries #{request_path}")
			if(@state.limited?)
				requests.delete_if { |other| (@process_start - other) >= QUERY_LIMIT_AGE }
				requests.push(@process_start)
				if(requests.size > QUERY_LIMIT)
					@desired_state = @state
					@active_state = @state = @state.limit_state
          @state.request_path = @desired_state.request_path
				end
			end
		end
    def login
      # @app.login raises Yus::YusError
      # caller must rescue Yus::UnknownEntityError and Yus::AuthenticationError
      @user = @app.login(user_input(:email), user_input(:pass))
      if cookie_set_or_get(:remember_me)
        set_cookie_input :remember, @user.generate_token
        set_cookie_input :email, @user.email
      else
        @cookie_input.delete :remember
        # TODO
        # This works always same with remember_me ... (temporary solution)
        set_cookie_input :remember, @user.generate_token
        set_cookie_input :email, @user.email
        # This does not work in session, expectedly
        set_persistent_user_input(:remember, @user.generate_token)
        set_persistent_user_input(:email, @user.email)
      end
      @user
    end
    def login_token
      # @app.login_token raises Yus::YusError
      email = (persistent_user_input(:email) || get_cookie_input(:email))
      token = (persistent_user_input(:remember) || get_cookie_input(:remember))
      if email && token && !token.empty? && !@user.valid?
        @user = @app.login_token(email, token)
        set_cookie_input :remember, @user.generate_token
        @user
      end
    rescue Yus::YusError
    end
    def logout
      token = get_cookie_input(:remember)
      @cookie_input.delete :remember
      if(@user.respond_to?(:yus_session))
        @user.remove_token token
        @app.logout(@user.yus_session)
      end
      super
    end

    def process_late
      @process_start = Time.now
      if(!is_crawler? &&
         !is_mobile_app? &&
         self.lookandfeel.enabled?(:query_limit))
        limit_queries
      end
    end

    def is_mobile_app?
      config = ODDB.config
      return false if config.app_user_agent.empty?
      app_pattern = /#{config.app_user_agent}/
      !!@rack_request && app_pattern.match(@rack_request.user_agent) && flavor == 'mobile'
    end
		def add_to_interaction_basket(object)
			@interaction_basket = @interaction_basket.push(object).uniq
		end
		def clear_interaction_basket
			@interaction_basket.clear
      @interaction_basket_atc_codes.clear
		end
		def currency
			cookie_set_or_get(:currency) || "CHF"
		end
    def get_currency_rate(currency)
      @currency_rates[currency] ||= @app.get_currency_rate(currency)
    end
    def convert_price(price, currency)
      if(price and rate = get_currency_rate(currency))
        price * rate
      end
    end
    def interaction_basket
      if(ids = user_input(:substance_ids))
        ids = ids.split(/,/).collect { |id| id.to_i }
        @interaction_basket.delete_if { |sub| !ids.delete(sub.oid) }
        ids.each { |id| @interaction_basket.push @app.substance(id, false) }
      end
      @interaction_basket = @interaction_basket.compact.uniq
    end
    def interaction_basket_atc_codes
      if atc_codes = user_input(:atc_code) and event == :interaction_basket
        codes = atc_codes.split(/,/)
        @interaction_basket_atc_codes.delete_if { |code| !codes.delete(code) }
        codes.each { |code| @interaction_basket_atc_codes.push(code)}
        @interaction_basket_atc_codes = @interaction_basket_atc_codes.compact.uniq
      else
        @interaction_basket_atc_codes
      end
    end
		def interaction_basket_count
			@interaction_basket.size
		end
    def interaction_basket_ids
      @interaction_basket.collect { |sub| sub.oid }.join(',')
    end
    def interaction_basket_link
      lookandfeel._event_url(:interaction_basket,
                             :substance_ids => interaction_basket_ids)
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
    def search_form
      search_form = cookie_set_or_get(:search_form) || \
                    @persistent_user_input[:search_form] || \
                    "plus"
      @persistent_user_input[:search_form] = search_form
      search_form
    end
		def search_oddb(query)
			@persistent_user_input[:search_query] ||= query
			@app.search_oddb(query, self.language)
		end
    def search_exact_indication(query)
      @app.search_exact_indication(query)
    end
    def search_hospital(ean)
      @persistent_user_input[:ean] ||= ean
      @app.hospital_by_gln(ean)
    end
    def search_pharmacy(ean)
      @persistent_user_input[:ean] ||= ean
      @app.pharmacy_by_gln(ean)
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
    def search_doctor(oid)
			@persistent_user_input[:oid] ||= oid
      @app.doctor(oid)
    end
    def search_doctors(ean)
      @persistent_user_input[:ean] ||= ean
      @app.search_doctors(ean)
    end
    def search_hospitals(ean)
      @persistent_user_input[:ean] ||= ean
      @app.search_hospitals(ean)
    end
    def search_pharmacies(ean)
      @persistent_user_input[:ean] ||= ean
      @app.search_pharmacies(ean)
    end
		def set_persistent_user_input(key, val)
			@persistent_user_input.store(key, val)
		end
		def sponsor
			@app.sponsor(flavor)
		end
    # we expect a european date in the format tt.dd.yyyy
    FI_DIFF_REGEXP = /show\/fachinfo\/(\d{5})\/diff(?:\/(\d{2}\.\d{1,2}\.\d{1,4}))*/
    PI_DIFF_REGEXP = /show\/patinfo\/(\d{5})\/(\d{2})\/(\d{3})\/diff(?:\/(\d{1,2}\.\d{1,2}\.\d{1,4}))*/
    def choosen_info_diff
      item = nil
      m = FI_DIFF_REGEXP.match(request_path)
      found = log = item = date = nil
      if  m = FI_DIFF_REGEXP.match(request_path)
        found = @app.registration(m[1])
        log = found.fachinfo.send(self.language).change_log.sort!{|x,y| y.time.to_s <=> x.time.to_s}
        date = m[2]
      elsif m = PI_DIFF_REGEXP.match(request_path)
        found = @app.registration(m[1]).sequence(m[2]).package(m[3])
        log = found.patinfo.send(self.language).change_log.sort!{|x,y| y.time.to_s <=> x.time.to_s}
        date = m[4]
      end
      if log
        if found && date
          item = log.find{|item| item.time.strftime('%d.%m.%Y').eql?(date)}
          return [found, log, item].compact
        else
          return [found, log]
        end
      end
      return []
    end
    ZsrAndEAN_Regexp = /(\/zsr_.+|)\/(ean|home_interactions)\/+([^\\?].+)/
    def choosen_drugs
      persistent = persistent_user_input(:drugs)
      m = ZsrAndEAN_Regexp.match(request_path)
      return {} unless m or persistent
      ean13s = m ? m[3].split(/[,?\/]/) : []
      drugs = {}
      ean13s.each {
        |ean13|
        pack = @app.package_by_ean13(ean13)
        drugs[ean13] = pack if pack
      }
      drugs.merge!(persistent) if persistent
      drugs
    end
    def zsr_id
      verified_id = nil
      id = cookie_set_or_get(:zsr_id) || @persistent_user_input[:zsr_id]
      if m = /\/zsr_([a-z][\d]+|)/i.match((request_path))
        verified_id = m[1] if m[1].length == 7
      end
      if not verified_id and m = /([a-z][\d]+)/i.match(id)
        verified_id =  m[1] if m[1].length == 7
      end
      @persistent_user_input[:zsr_id] = verified_id
      verified_id
    end
    def create_search_url(prefix=:rezept, drugs=choosen_drugs)
      drugs = drugs.keys if drugs.is_a?(Hash)
      lookandfeel._event_url(prefix, [zsr_id ? "zsr_#{zsr_id}" : [] , (drugs and prefix != :home_interactions and drugs.size > 0) ? :ean : [], drugs].flatten).sub(/\/+$/, '')
    end
    def get_address_parent
      ean_from_url = request_path.match(/\/(\d{13})/)
      ean_from_url = ean_from_url[1] if ean_from_url
      ean_from_url ||= @persistent_user_input[:ean]
      parent = nil
      if parent = search_hospital(ean_from_url)
        parent
      elsif parent =  search_pharmacy(ean_from_url)
        parent
      elsif (ean_or_oid = persistent_user_input(:ean) || persistent_user_input(:oid)) \
        and (parent = search_doctor(ean_or_oid) || search_doctors(ean_or_oid).first)
          parent
      end if ean_from_url
      parent
    end
  end
end
