#!/usr/bin/env ruby
# State::Global -- oddb -- 25.11.2002 -- hwyss@ywesee.com

require 'htmlgrid/urllink'
require 'state/admin/login'
require 'state/ajax/ddd_price'
require 'state/ajax/swissmedic_cat'
require 'state/analysis/group'
require 'state/analysis/position'
require 'state/analysis/alphabetical'
require 'state/analysis/result'
require 'state/companies/company'
require 'state/companies/companylist'
require 'state/drugs/atcchooser'
require 'state/drugs/compare'
require 'state/drugs/ddd'
require 'state/drugs/fachinfo'
require 'state/drugs/fachinfos'
require 'state/drugs/feedbacks'
require 'state/drugs/notify'
require 'state/drugs/package'
require 'state/drugs/register_download'
require 'state/drugs/init'
require 'state/drugs/limitationtext'
require 'state/drugs/limitationtexts'
require 'state/drugs/vaccines'
require 'state/admin/orphaned_patinfos'
require 'state/admin/orphaned_patinfo'
require 'state/admin/patinfo_deprived_sequences'
require 'state/admin/password_lost'
require 'state/admin/password_reset'
require 'state/drugs/patinfo'
require 'state/drugs/patinfos'
require 'state/drugs/recentregs'
require 'state/drugs/result'
require 'state/drugs/sequences'
require 'state/drugs/narcotic'
require 'state/drugs/narcotics'
require 'state/doctors/init'
require 'state/hospitals/init'
require 'state/doctors/doctorlist'
require 'state/hospitals/hospitallist'
require 'state/drugs/patinfo'
require 'state/exception'
require 'state/interactions/basket'
require 'state/interactions/init'
require 'state/interactions/result'
require 'state/migel/init'
require 'state/migel/alphabetical'
require 'state/migel/limitationtext'
require 'state/migel/group'
require 'state/migel/subgroup'
require 'state/migel/product'
require 'state/migel/notify'
require 'state/migel/feedbacks'
require 'state/substances/init'
require 'state/substances/result'
require 'state/suggest_address'
require 'state/user/download'
require 'state/user/download_export'
require 'state/user/fipi_offer_input'
require 'state/user/fipi_offer_confirm'
require	'state/user/help'
require 'state/user/mailinglist'
require 'state/user/passthru'
require 'state/user/register_poweruser'
require 'state/user/suggest_registration'
require 'state/paypal/return'
require 'state/paypal/ipn'
require 'state/user/paypal_thanks'
require 'state/user/powerlink'
require 'state/user/plugin'
require 'state/user/init'
require 'state/user/sponsorlink'
require 'util/umlautsort'
require 'sbsm/state'

module ODDB
	module State
		class Global < SBSM::State
			include UmlautSort
			include Admin::LoginMethods
			attr_reader :model, :snapback_model
			DIRECT_EVENT = nil 
			GLOBAL_MAP = {
				:ajax_ddd_price				=>	State::Ajax::DDDPrice,
				:ajax_swissmedic_cat	=>	State::Ajax::SwissmedicCat,
				:analysis_alphabetical	=>	State::Analysis::Alphabetical,
				:companylist					=>	State::Companies::CompanyList,
				:compare							=>	State::Drugs::Compare,
				:ddd									=>	State::Drugs::DDD,
				:download_export			=>	State::User::DownloadExport,
				:fachinfos						=>	State::Drugs::Fachinfos,
				:fipi_offer_input			=>	State::User::FiPiOfferInput,
				:help									=>	State::User::Help,
				:home									=>	State::Drugs::Init,
				:home_admin						=>	State::Admin::Init,
				:home_analysis				=>	State::Analysis::Init,
				:home_companies				=>	State::Companies::Init,
				:home_doctors					=>	State::Doctors::Init,
				:home_hospitals				=>	State::Hospitals::Init,
				:home_drugs						=>  State::Drugs::Init,
				:home_interactions		=>  State::Interactions::Init,
				:home_migel						=>	State::Migel::Init,
				:home_substances			=>  State::Substances::Init,
				:home_user						=>  State::User::Init,
				:hospitallist					=>	State::Hospitals::HospitalList,
				:limitation_texts			=>	State::Drugs::LimitationTexts,
				:login_form						=>	State::Admin::Login,
				:mailinglist					=>	State::User::MailingList,
				:migel_alphabetical		=>	State::Migel::Alphabetical,
				:password_lost				=>	State::Admin::PasswordLost,
				:patinfos							=>	State::Drugs::Patinfos,
				:narcotics						=>	State::Drugs::Narcotics,
				:plugin								=>	State::User::Plugin,
				:passthru							=>	State::User::PassThru,
				:paypal_ipn						=>	State::PayPal::Ipn,
				:paypal_thanks				=>	State::User::PayPalThanks,
				:recent_registrations =>	State::Drugs::RecentRegs,
				:sequences						=>	State::Drugs::Sequences,
				:vaccines							=>	State::Drugs::Vaccines,
			}	
			HOME_STATE = State::Drugs::Init
			LIMITED = false
			RESOLVE_STATES = {
				[ :analysis_group, :position ]	=>	State::Analysis::Position,
				[ :analysis_group ]		=>	State::Analysis::Group,
				[ :company ]	=>	State::Companies::Company,
				[ :doctor	]  =>	State::Doctors::Doctor,
				[ :hospital ]  =>	State::Hospitals::Hospital,
				[ :fachinfo ]	=>	State::Drugs::Fachinfo,
				[ :incomplete_registration ]	=>	State::User::SuggestRegistration, 
				[ :incomplete_registration,
					:sequence ]									=>	State::User::SuggestSequence, 
				[ :incomplete_registration,
					:sequence, :package ]				=>	State::User::SuggestPackage, 
				[ :incomplete_registration,
					:sequence, :active_agent ]	=>	State::User::SuggestActiveAgent,
				[	:registration, :sequence, 
					:package, :sl_entry, 
					:limitation_text ] =>	State::Drugs::LimitationText,
				[ :migel_group, :subgroup, 
					:product ]	=>	State::Migel::Product,
				[ :migel_group, :subgroup] => State::Migel::Subgroup,
				[ :migel_group] => State::Migel::Group,
				[	:migel_group, :subgroup, :product, 
					:limitation_text ] =>	State::Migel::LimitationText,
				[	:migel_group, :subgroup, 
					:limitation_text ] =>  State::Migel::LimitationText,
				[	:migel_group,
					:limitation_text ] => State::Migel::LimitationText,
				[ :narcotic ]	=>	State::Drugs::Narcotic,
				[ :patinfo ]	=>	State::Drugs::Patinfo,
				[ :registration, :sequence, 
					:package, :narcotics ]	=>	State::Drugs::NarcoticPlus,
			}	
			READONLY_STATES = RESOLVE_STATES.dup.update({
				[	:registration, :sequence, 
					:package ]	=>	State::Drugs::Package,
			})
			PRINT_STATES = {
				[ :fachinfo ]	=>	State::Drugs::FachinfoPrint,
				[ :patinfo ]	=>	State::Drugs::PatinfoPrint,
			}
			REVERSE_MAP = {}
			VIEW = View::Search
			ZONE_NAVIGATION = []
			def add_to_interaction_basket
				pointer = @session.user_input(:pointer)
				if(object = pointer.resolve(@session.app))
					@session.add_to_interaction_basket(object)
				end
				self
			end
			def allowed?(test = @model)
				if(test.is_a?(Persistence::CreateItem)) 
					test = test.parent(@session.app)
				end
				@session.user.allowed?('edit', test)
			end
			def atc_chooser
				mdl = @session.app.atc_chooser
				State::Drugs::AtcChooser.new(@session, mdl)
			end
=begin # was never used?
			def authenticate
				email = @session.user_input(:email)
				key = @session.user_input(:challenge)
				user = @session.admin_subsystem.download_user(email)
				if(user && user.authenticate!(key))
					State::User::Download.new(@session, nil)
				else
					State::User::RegisterDownload.new(@session, user)
				end
			end
=end
			def checkout
				case @session.zone
				when :user
					proceed_download.checkout
				when :drugs
					export_csv.checkout
				end
			end
			def clear_interaction_basket
				@session.clear_interaction_basket
				State::Interactions::EmptyBasket.new(@session, [])
			end
			def creditable?(item = @model)
				@session.user.creditable?(item)
			end
			def direct_request_path
				if(event = self.direct_event)
					@session.lookandfeel._event_url(event)
				else
					self.request_path
				end
			end
			def doctorlist
				model = @session.doctors.values
				State::Doctors::DoctorList.new(@session, model)
			end
			def download
				if(@session.is_crawler?)
					return State::Drugs::Init.new(@session, nil)
				end
				email = @session.user_input(:email)
				email ||= @session.get_cookie_input(:email)
				oid = @session.user_input(:invoice)
				file = @session.user_input(:filename)
				if((invoice = @session.invoice(oid)) \
          && invoice.yus_name == email \
					&& invoice.payment_received? \
					&& (item = invoice.item_by_text(file)) \
					&& !item.expired?)
					State::User::Download.new(@session, item)
				else
					State::PayPal::Return.new(@session, invoice)
				end
			end
			def hospitallist
				model = @session.hospitals.values
				State::Hospitals::HospitalList.new(@session, model)
			end
			def export_csv
				if(@session.zone == :drugs)
					state = self.search
					if(state.is_a?(State::Drugs::Result))
						state.export_csv
					end
				end
			end
			def extend(mod)
				if(mod.constants.include?('VIRAL'))
					@viral_module = mod 
				end
				super
			end
			def feedbacks
				if((pointer = @session.user_input(:pointer)) \
					&& pointer.is_a?(Persistence::Pointer) \
					&& (item = pointer.resolve(@session.app)))
					case item.odba_instance
					when ODDB::Package
						State::Drugs::Feedbacks.new(@session, item)
					when ODDB::Migel::Product
						State::Migel::Feedbacks.new(@session, item)
					when ODDB::Analysis::Position
						State::Analysis::Feedbacks.new(@session, item)
					end
				end
			end
			def notify 
				if((pointer = @session.user_input(:pointer)) \
					&& pointer.is_a?(Persistence::Pointer) \
					&& (item = pointer.resolve(@session.app)))
					case item.odba_instance
					when ODDB::Package
						State::Drugs::Notify.new(@session, item)
					when ODDB::Migel::Product
						State::Migel::Notify.new(@session, item)
					when ODDB::Analysis::Position
						State::Analysis::Notify.new(@session, item)
					end
				end
			end
			def help_navigation
				[
					:help_link,
					:faq_link,
				]
			end
			def home_navigation
				[
					self.home_state
				]
			end
			def home_state
				self::class::HOME_STATE
			end
			def interaction_basket
				if((array = @session.interaction_basket).empty?)
					State::Interactions::EmptyBasket.new(@session, array)
				else
					State::Interactions::Basket.new(@session, array)
				end
			end
			def limited?
				self.class.const_get(:LIMITED)
			end
			def limit_state
				State::User::Limit.new(@session, nil)
			end
			def logout
				user = @session.logout
				State::Drugs::Init.new(@session, user)
			end
			def navigation
				#+ zone_navigation \
				help_navigation \
				+ user_navigation \
				+ home_navigation
			end
			def password_reset
				keys = [:token, :email]
				input = user_input(keys, keys)
				unless(error?)
          email = input[:email]
          token = input[:token]
					if(@session.yus_allowed?(email, 'reset_password', token))
            model = OpenStruct.new
            model.token = token
            model.email = email
						State::Admin::PasswordReset.new(@session, model)
					end
				end
			end
			def paypal_return
				if(@session.is_crawler?)
					State::Drugs::Init.new(@session, nil)
				elsif((id = @session.user_input(:invoice)) \
					&& (invoice = @session.invoice(id)))
          state = State::PayPal::Return.new(@session, invoice)
					if(invoice.types.all? { |type| type == :poweruser } \
						&& @session.user.allowed?('view', 'org.oddb') \
						&& (des = @session.desired_state))
            # since the permissions of the current User may have changed, we
            # need to reconsider his viral modules
            if((user = @session.user).is_a?(YusUser))
              reconsider_permissions(user, des)
            end
            state = des
					end
          state
				else
					State::PayPal::Return.new(@session, nil)
				end
			end
			def powerlink
				pointer = @session.user_input(:pointer)
				unless(error?)
					comp = pointer.resolve(@session.app)
					State::User::PowerLink.new(@session, comp)
				end
			end
			def print
				pointer = @session.user_input(:pointer)
				begin
					if((model = pointer.resolve(@session.app)) \
						&& (klass = resolve_state(pointer, :print)))
						klass.new(@session, model)
					else
						self
					end
				rescue Persistence::UninitializedPathError
					self
				end
			end
			def proceed_download
				keys = [:download, :months, :compression]
				input = user_input(keys, keys) 
				items = []
				dir = File.expand_path('../../data/downloads', 
					File.dirname(__FILE__))
				compression = input[:compression]
				if(files = input[:download])
					files.each { |filename, val|
						if(val)
							item = AbstractInvoiceItem.new
							suffix = case compression
							when 'compr_gz'
								['.gz', '.tar.gz'].select { |sfx|
									File.exist?(File.join(dir, filename + sfx))
								}.first
							else 
								'.zip'
							end
							item.text = filename + suffix
							item.type = :download
							item.unit = 'Download'
							item.vat_rate = VAT_RATE
							months = input[:months][filename]
							item.quantity = months.to_f
							price_mth = 'price'
							duration_mth = 'duration'
							if(months == '12')
								price_mth = 'subscription_' << price_mth
								duration_mth = 'subscription_' << duration_mth
							end
							klass = State::User::DownloadExport
							item.total_netto = klass.send(price_mth, filename)
							item.duration = klass.send(duration_mth, filename)
							items.push(item)
						end
					}
				end
				if(items.empty?)
					@errors.store(:download, create_error('e_no_download_selected', 
						:download, nil))
				end
				if(error?)
					self
				else
					pointer = Persistence::Pointer.new(:invoice)
					invoice = Persistence::CreateItem.new(pointer)
					invoice.carry(:items, items)
          # experimental Implementation of Invoiced Download. 
          # Does not work yet, because an Invoice-Id is needed for downloading,
          # but no invoice is created until the next run of DownloadInvoicer
          #if(creditable?('org.oddb.download'))
          #  State::User::PaymentMethod.new(@session, invoice)
          #else
            State::User::RegisterDownload.new(@session, invoice)
          #end
				end
			end
			def proceed_poweruser
				keys = [:days]
				input = user_input(keys, keys)
				unless(error?)
					days = input[:days].to_i
					item = AbstractInvoiceItem.new
					item.text = "unlimited access"
					item.type = :poweruser
					item.vat_rate = VAT_RATE
					item.quantity = days
					item.duration = days
					item.total_netto = State::Limit.price(days)
					pointer = Persistence::Pointer.new(:invoice)
					invoice = Persistence::CreateItem.new(pointer)
					invoice.carry(:items, [item])
					if(usr = @session.user_input(:pointer))
						State::User::RenewPowerUser.new(@session, invoice)
					else
						State::User::RegisterPowerUser.new(@session, invoice)
					end
				end
			end
			def resolve
				if(@session.request_path == @request_path)
					self
				elsif((pointer = @session.user_input(:pointer)) \
					&& pointer.is_a?(Persistence::Pointer) \
					&& (model = pointer.resolve(@session.app)))
					if(klass = resolve_state(pointer))
						klass.new(@session, model)
					else
						State::Admin::TransparentLogin.new(@session, model)
					end
				else
					self
				end
			rescue Persistence::UninitializedPathError
				self
			end
			def resolve_state(pointer, type=:standard)
				state_map = {
					:standard	=>	self::class::RESOLVE_STATES,
					:readonly	=>	self::class::READONLY_STATES,
					:print		=>	self::class::PRINT_STATES,
				}
				type = :standard unless(state_map.include?(type))
				state_map[type][pointer.skeleton]
			end
			def search
				zone = @session.zone
				query = @session.persistent_user_input(:search_query)
				if(query.is_a? RuntimeError)
					State::Exception.new(@session, query)
				elsif(!query.nil?)
					query = ODDB.search_term(query)
					case zone
					when :hospitals
						result = @session.search_hospitals(query)
						State::Hospitals::HospitalResult.new(@session, result)
					when :doctors
						result = @session.search_doctors(query)
						State::Doctors::DoctorResult.new(@session, result)
					when :companies
						result = @session.search_companies(query)
						State::Companies::CompanyResult.new(@session, result)
					when :interactions
						result = @session.search_interactions(query)
						State::Interactions::Result.new(@session, result)
					when :substances
						result = @session.search_substances(query)
						State::Substances::Result.new(@session, result)
					when :migel
						result = @session.search_migel_products(query)
						State::Migel::Result.new(@session, result)
					when :analysis
						result = @session.search_analysis(query, @session.language)
						State::Analysis::Result.new(@session, result)
					else
						query = query.to_s.downcase
						stype = @session.user_input(:search_type) 
						_search_drugs_state(query, stype)
					end
				else
					self
				end
			end
			alias :result :search
			def _search_drugs(query, stype)
				case stype
				when 'st_sequence'
					@session.search_exact_sequence(query)
				when 'st_substance'
					@session.search_exact_substance(query)
				when 'st_company'
					@session.search_exact_company(query)
				when 'st_indication'
					@session.search_exact_indication(query)
				when 'st_interaction'
					@session.search_by_interaction(query, @session.language)
				when 'st_unwanted_effect'
					@session.search_by_unwanted_effect(query, @session.language)
				else
					@session.search_oddb(query)
				end
			end
			def _search_drugs_state(query, stype)
				result = _search_drugs(query, stype)
				state = State::Drugs::Result.new(@session, result)
				state.search_query = query
				state.search_type = stype
				state
			end
			def show
				if(@session.request_path == @request_path)
					self
				elsif((pointer = @session.user_input(:pointer)) \
					&& pointer.is_a?(Persistence::Pointer) \
					&& (model = pointer.resolve(@session.app)) \
					&& klass = resolve_state(pointer, :readonly))
					klass.new(@session, model)
				end
			rescue Persistence::UninitializedPathError
				self
			end
			def snapback_event
				if(defined?(self.class::SNAPBACK_EVENT))
					self.class::SNAPBACK_EVENT
				else
					self.class::DIRECT_EVENT
				end
			end
			def sort
				return self unless @model.is_a? Array
				get_sortby!
				@model.sort! { |a, b| compare_entries(a, b) }
				@model.reverse! if(@sort_reverse)
				self
			end
			def sponsorlink
				if((sponsor = @session.sponsor) && sponsor.valid?)
					State::User::SponsorLink.new(@session, sponsor)
				end
			end
			def suggest_address
				keys = [:pointer]
				input = user_input(keys, keys)
				pointer = input[:pointer]
				if(!error?) 
					addr = pointer.resolve(@session)
					if(addr.nil?)
						## simulate an address
						addr = Address2.new
						if(parent = pointer.parent.resolve(@session))
							addr.name = parent.fullname
						end
						addr.pointer = pointer
					end
					SuggestAddress.new(@session, addr)
				end	
			end
			def switch
				state = self.trigger(self.direct_event)
				if(state.zone == @session.zone)
					state
				else
					event = [
						'home',
						@session.zone
					].compact.join('_').intern
					self.trigger(event)
				end
			end
			def new_registration
				@session[:allowed] ||= []
				item = @session[:allowed].select { |obj| 
					obj.is_a?(ODDB::IncompleteRegistration)
				}.first
				unless(item)
					pointer = Persistence::Pointer.new(:incomplete_registration)
					item = Persistence::CreateItem.new(pointer)
				end
				State::User::SuggestRegistration.new(@session, item)
			end
			def unique_email
				user = @session.user
				if(user.respond_to?(:unique_email))
					user.unique_email
				end
			end
			def user_input(keys=[], mandatory=[])
				keys = [keys] unless keys.is_a?(Array)
				mandatory = [mandatory] unless mandatory.is_a?(Array)
				hash = @session.user_input(*keys)
				hash ||= {}
				unless(hash.is_a?(Hash))
					hash = {keys.first => hash}
				end
				keys.each { |key| 
					carryval = nil
					value = hash[key]
					if(value.is_a? RuntimeError)
						carryval = value.value
						@errors.store(key, hash.delete(key))
					elsif(mandatory.include?(key) && mandatory_violation(value))
						error = create_error('e_missing_' << key.to_s, key, value)
						@errors.store(key, error)
						hash.delete(key)
					else
						carryval = value
					end
					if(@model.is_a? Persistence::CreateItem)
						@model.carry(key, carryval)
					end
				}
				hash
			end
			def user_navigation
				[
					State::Admin::Login,
					State::User::YweseeContact,
				]
			end
			def ywesee_contact
				model = nil
				State::User::YweseeContact.new(@session, model)
			end
			def zones
			[ :analysis, :doctors, :interactions, :drugs, :migel, :user , :hospitals, :companies]
			end
			def zone_navigation
				self::class::ZONE_NAVIGATION
			end
			private
			def compare_entries(a, b)
				@sortby.each { |sortby|
					aval, bval = nil
					begin
						aval = umlaut_filter(a.send(sortby))
						bval = umlaut_filter(b.send(sortby))
					rescue
						next
					end
					res = if (aval.nil? && bval.nil?)
						0
					elsif (aval.nil?)
						1
					elsif (bval.nil?)
						-1
					else 
						aval <=> bval
					end
					return res unless(res == 0)
				}
				0
			end
			def get_sortby!
				@sortby ||= []
				sortvalue = @session.user_input(:sortvalue)
				if(sortvalue.is_a? String)
					sortvalue = sortvalue.intern
				end
				if(@sortby.first == sortvalue)
					@sort_reverse = !@sort_reverse 
				else
					@sort_reverse = self.class::REVERSE_MAP[sortvalue] 
				end
				@sortby.delete_if { |sortby| sortby == sortvalue }
				@sortby.unshift(sortvalue)
			end
			def mandatory_violation(value)
				value.nil? || (value.respond_to?(:empty?) && value.empty?)
			end
		end
	end
end
