#!/usr/bin/env ruby
# GlobalState -- oddb -- 25.11.2002 -- hwyss@ywesee.com

require 'htmlgrid/urllink'
require 'model/comparison'
require 'state/added_to_interaction'
require 'state/atcchooser'
require 'state/company'
require 'state/companylist'
require 'state/compare'
require 'state/ddd'
require 'state/fachinfo'
require 'state/galdatdownload'
require 'state/genericdefinition'
require 'state/passthru'
require 'state/powerlink'
require	'state/help'
require 'state/init'
require 'state/interaction_init'
require 'state/legalnote'
require	'state/limitationtext'
require 'state/login'
require 'state/mailinglist'
require 'state/orphaned_patinfos'
require 'state/orphaned_patinfo'
require 'state/patinfo_deprived_sequences'
require 'state/plugin'
require 'state/recentregs'
require 'state/result'
require 'state/paypal_thanks'
require 'state/patinfo'
require 'state/yamlexport'
require 'util/umlautsort'
require 'state/download'
require 'sbsm/state'

module ODDB
	class GlobalState < SBSM::State
		include UmlautSort
		attr_reader :model
		DIRECT_EVENT = nil
		GLOBAL_MAP = {
			:added_to_interaction	=>	AddedToInteractionState,
			:companylist					=>	CompanyListState,
			:ddd									=>	DDDState,
			:download							=>	DownloadState,
			:galdat_download			=>	GaldatDownloadState,
			:help									=>	HelpState,
			:home									=>	InitState,
			:interaction_home			=>	InteractionInitState,
			:login_form						=>	LoginState,
			:mailinglist					=>	MailingListState,
			:plugin								=>	PluginState,
			:recent_registrations =>	RecentRegsState,
			:download_export			=>	YamlExportState,
			:passthru							=>	PassThruState,
			:paypal_thanks				=>	PayPalThanksState,
		}	
		RESOLVE_STATES = {
			[ :company ]	=>	CompanyState,
			[ :fachinfo ]	=>	FachinfoState,
			[	:registration, :sequence, 
				:package, :sl_entry, 
				:limitation_text ]	=>	LimitationTextState,
			[ :patinfo ]	=>	PatinfoState,
		}	
		PRINT_STATES = {
			[ :fachinfo ]	=>	FachinfoPrintState,
			[ :patinfo ]	=>	PatinfoPrintState,
		}
		REVERSE_MAP = {}
		VIEW = SearchView
		def atc_chooser
			mdl = @session.app.atc_chooser
			AtcChooserState.new(@session, mdl)
		end
		def compare
			pointer = @session.user_input(:pointer)
			package = pointer.resolve(@session.app)
			if(package.is_a? Package)
				begin
					CompareState.new(@session, Comparison.new(package))
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
		def extend(mod)
			if(mod.constants.include?('VIRAL'))
				@viral_module = mod 
			end
			super
		end
		def generic_definition
			GenericDefinitionState.new(@session, nil)
		end
		def legal_note
			LegalNoteState.new(@session, nil)
		end
		def logout
			user = @session.logout
			InitState.new(@session, user)
		end
		def powerlink
			pointer = @session.user_input(:pointer)
			unless(error?)
				comp = pointer.resolve(@session.app)
				PowerLinkState.new(@session, comp)
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
			pointer = @session.user_input(:pointer)
			begin
				if((model = pointer.resolve(@session.app)))
					if(klass = resolve_state(pointer))
						klass.new(@session, model)
					else
						TransparentLoginState.new(@session, model)
					end
				else
					self
				end
			rescue Persistence::UninitializedPathError
				self
			end
		end
		def resolve_state(pointer, type=:standard)
			state_map = {
				:standard	=>	self::class::RESOLVE_STATES,
				:print		=>	self::class::PRINT_STATES,
			}
			type = :standard unless(state_map.include?(type))
			state_map[type][pointer.skeleton]
		end
		def result
			search() || if(@model.respond_to? :name_base)
				result = @session.search(@model.name_base)
				ResultState.new(@session, result)
			end
		end
		def search
			query = @session.persistent_user_input(:search_query)
			if (query.is_a? RuntimeError) 
				ExceptionState.new(@session, query)
			elsif(!query.nil?)
				result = @session.search(query)
				ResultState.new(@session, result)
			end
		end
		def search_interaction
			query = @session.persistent_user_input(:search_query)
			if (query.is_a? RuntimeError) 
				ExceptionState.new(@session, query)
			elsif(!query.nil?)
				result = @session.search_interaction(query)
				InteractionResultState.new(@session, result)
			end
		end
		def sort
			return self unless @model.is_a? Array
			get_sortby!
			@model.sort! { |a, b| compare_entries(a, b) }
			@model.reverse! if(@sort_reverse)
			self
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
		def ywesee_contact
			model = nil
			YweseeContactState.new(@session, model)
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
