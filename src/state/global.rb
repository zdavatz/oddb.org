#!/usr/bin/env ruby
# State::Global -- oddb -- 25.11.2002 -- hwyss@ywesee.com

require 'htmlgrid/urllink'
require 'model/comparison'
require 'state/legalnote'
require 'state/admin/login'
require 'state/companies/company'
require 'state/companies/companylist'
require 'state/drugs/atcchooser'
require 'state/drugs/compare'
require 'state/drugs/ddd'
require 'state/drugs/fachinfo'
require 'state/drugs/feedbacks'
require 'state/drugs/init'
require	'state/drugs/limitationtext'
require 'state/drugs/orphaned_patinfos'
require 'state/drugs/orphaned_patinfo'
require 'state/drugs/patinfo_deprived_sequences'
require 'state/drugs/recentregs'
require 'state/drugs/result'
require 'state/doctors/init'
require 'state/hospitals/init'
require 'state/doctors/doctorlist'
require 'state/hospitals/hospitallist'
require 'state/drugs/patinfo'
require 'state/exception'
require 'state/interactions/basket'
require 'state/interactions/init'
require 'state/interactions/result'
require 'state/substances/init'
require 'state/substances/result'
require 'state/user/download'
require 'state/user/download_export'
require 'state/user/fipi_offer_input'
require 'state/user/fipi_offer_confirm'
require 'state/user/genericdefinition'
require	'state/user/help'
require 'state/user/mailinglist'
require 'state/user/passthru'
require 'state/user/paypal_thanks'
require 'state/user/powerlink'
require 'state/user/plugin'
require 'state/user/init'
require 'util/umlautsort'
require 'sbsm/state'

module ODDB
	module State
		class Global < SBSM::State
			include UmlautSort
			attr_reader :model
			DIRECT_EVENT = nil 
			GLOBAL_MAP = {
				:companylist					=>	State::Companies::CompanyList,
				#:doctorlist						=>	State::Doctors::DoctorList,
				:ddd									=>	State::Drugs::DDD,
				:download							=>	State::User::Download,
				:download_export			=>	State::User::DownloadExport,
				:fipi_offer_input			=>	State::User::FiPiOfferInput,
				:help									=>	State::User::Help,
				:home									=>	State::Drugs::Init,
				:home_admin						=>	State::Admin::Init,
				:home_companies				=>	State::Companies::Init,
				:home_doctors					=>	State::Doctors::Init,
				:home_hospitals				=>	State::Hospitals::Init,
				:home_drugs						=>  State::Drugs::Init,
				:home_interactions		=>  State::Interactions::Init,
				:home_substances			=>  State::Substances::Init,
				:home_user						=>  State::User::Init,
				:hospitallist					=>	State::Hospitals::HospitalList,
				:login_form						=>	State::Admin::Login,
				:mailinglist					=>	State::User::MailingList,
				:plugin								=>	State::User::Plugin,
				:passthru							=>	State::User::PassThru,
				:paypal_thanks				=>	State::User::PayPalThanks,
				:recent_registrations =>	State::Drugs::RecentRegs,
			}	
			HOME_STATE = State::Drugs::Init
			RESOLVE_STATES = {
				[ :company ]	=>	State::Companies::Company,
				[ :doctor	]  =>	State::Doctors::Doctor,
				[ :hospital ]  =>	State::Hospitals::Hospital,
				[ :fachinfo ]	=>	State::Drugs::Fachinfo,
				[	:registration, :sequence, 
					:package, :sl_entry, 
					:limitation_text ]	=>	State::Drugs::LimitationText,
				[ :patinfo ]	=>	State::Drugs::Patinfo,
			}	
			PRINT_STATES = {
				[ :fachinfo ]	=>	State::Drugs::FachinfoPrint,
				[ :patinfo ]	=>	State::Drugs::PatinfoPrint,
			}
			REVERSE_MAP = {}
			VIEW = View::Search
			def add_to_interaction_basket
				pointer = @session.user_input(:pointer)
				if(object = pointer.resolve(@session.app))
					@session.add_to_interaction_basket(object)
				end
				self
			end
			def atc_chooser
				mdl = @session.app.atc_chooser
				State::Drugs::AtcChooser.new(@session, mdl)
			end
			def compare
				pointer = @session.user_input(:pointer)
				package = pointer.resolve(@session.app)
				if(package.is_a? Package)
					begin
						State::Drugs::Compare.new(@session, ODDB::Comparison.new(package))
					rescue StandardError => e
						puts e.class
						puts e.message
						puts e.backtrace
						self
					end
				else
					self
				end
			end
			def clear_interaction_basket
				@session.clear_interaction_basket
				State::Interactions::EmptyBasket.new(@session, [])
			end
			def doctorlist
				model = @session.doctors.values
				State::Doctors::DoctorList.new(@session, model)
			end
			def hospitallist
				model = @session.hospitals.values
				State::Hospitals::HospitalList.new(@session, model)
			end
			def extend(mod)
				if(mod.constants.include?('VIRAL'))
					@viral_module = mod 
				end
				super
			end
			def feedbacks
				if((pointer = @session.user_input(:pointer)) \
					&& (pack = pointer.resolve(@session.app)))
					State::Drugs::Feedbacks.new(@session, pack)
				end
			end
			def home_navigation
				[
					self::class::HOME_STATE
				]
			end
			def interaction_basket
				if((array = @session.interaction_basket).empty?)
					State::Interactions::EmptyBasket.new(@session, array)
				else
					State::Interactions::Basket.new(@session, array)
				end
			end
			def generic_definition
				State::User::GenericDefinition.new(@session, nil)
			end
			def legal_note
				State::LegalNote.new(@session, nil)
			end
			def logout
				user = @session.logout
				State::Drugs::Init.new(@session, user)
			end
			def navigation
				zone_navigation + user_navigation + home_navigation
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
			def resolve
				if((pointer = @session.user_input(:pointer)) \
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
					else
						result = if(@session.user_input(:exact_match))
							@session.search_exact(query)
						else
							@session.search(query)
						end
						State::Drugs::Result.new(@session, result)
					end
				else
					self
				end
			end
			alias :result :search
			def sort
				return self unless @model.is_a? Array
				get_sortby!
				@model.sort! { |a, b| compare_entries(a, b) }
				@model.reverse! if(@sort_reverse)
				self
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
			def user_input(keys=[], mandatory=[])
				keys = [keys] unless keys.is_a?(Array)
				mandatory = [mandatory] unless mandatory.is_a?(Array)
				if(hash = @session.user_input(*keys))
					hash.each { |key, value| 
						carryval = nil
						if (value.is_a? RuntimeError)
							carryval = value.value
							@errors.store(key, hash.delete(key))
						elsif (mandatory.include?(key) && mandatory_violation(value))
							error = create_error('e_missing_' << key.to_s, key, value)
							@errors.store(key, error)
							hash.delete(key)
						else
							carryval = value
						end
						if (@model.is_a? Persistence::CreateItem)
							@model.carry(key, carryval)
						end
					}
					hash
				else
					{}
				end
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
				[:drugs, :interactions, :companies, :doctors, :hospitals, :user ]
			end
			def zone_navigation
				[
					:help_link,
					:faq_link,
				]
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
