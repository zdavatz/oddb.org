#!/usr/bin/env ruby
# State::Admin::Root -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/admin/user'
require 'state/admin/incompleteregistrations'
require 'state/admin/galenicgroups'
require 'state/admin/indications'
require 'state/admin/logout'
require 'state/admin/init'
require 'state/drugs/fachinfo'

module ODDB
	module State
		module Admin
class State::Admin::ActiveAgent < State::Admin::Global; end
class State::Admin::AddressSuggestion < State::Admin::Global; end
class State::Admin::AssignDeprivedSequence < State::Admin::Global; end
class State::Admin::AtcClass < State::Admin::Global; end
class State::Companies::Company < State::Companies::Global; end
class State::Companies::UserCompany < State::Companies::Company; end
class State::Companies::RootCompany < State::Companies::UserCompany; end
class State::Admin::Addresses < State::Admin::Global; end
class State::Admin::GalenicForm < State::Admin::Global; end
class State::Admin::GalenicGroup < State::Admin::Global; end
class State::Admin::GalenicGroups < State::Admin::Global; end
class State::Admin::OrphanedFachinfos < State::Admin::Global; end
class State::Admin::OrphanedFachinfoAssign < State::Admin::Global; end
class State::Admin::OrphanedPatinfo < State::Admin::Global; end
class State::Admin::OrphanedPatinfos < State::Admin::Global; end
class State::Admin::Package < State::Admin::Global; end
class State::Admin::PatinfoDeprivedSequences < State::Admin::Global; end
class State::Admin::Registration < State::Admin::Global; end
class State::Admin::Sequence < State::Admin::Global; end
class State::Admin::SlEntry < State::Admin::Global; end
class State::Admin::PatinfoStatsCommon < State::Admin::Global; end
class State::Admin::PatinfoStats < State::Admin::PatinfoStatsCommon; end
class State::Admin::Sponsor < State::Admin::Global; end
class State::Substances::Substance < State::Substances::Global; end
class State::Substances::Substances < State::Substances::Global; end
class State::Substances::EffectiveSubstances < State::Substances::Substances; end
class State::Admin::IncompleteRegs < State::Admin::Global; end
class State::Admin::IncompleteReg < State::Admin::Registration; end
class State::Admin::IncompleteSequence < State::Admin::Sequence; end
class State::Admin::IncompletePackage < State::Admin::Package; end
class State::Admin::IncompleteActiveAgent < State::Admin::ActiveAgent; end
class State::Admin::Indication < State::Admin::Global; end
class State::Admin::Indication < State::Admin::Global; end
module Root
	include State::Admin::User
	RESOLVE_STATES = {
		[ :address_suggestion ]				=>	State::Admin::AddressSuggestion,
		[ :atc_class ]								=>	State::Admin::AtcClass,
		[ :company ]									=>	State::Companies::RootCompany,
		[ :fachinfo ]									=>	State::Drugs::RootFachinfo,
		[ :galenic_group ]						=>	State::Admin::GalenicGroup,
		[ :galenic_group,
			:galenic_form ]							=>	State::Admin::GalenicForm,
			[ :select_seq ]									=>  State::Admin::AssignDeprivedSequence,
		[ :incomplete_registration ]	=>	State::Admin::IncompleteReg, 
		[ :incomplete_registration,
			:sequence ]									=>	State::Admin::IncompleteSequence, 
		[ :incomplete_registration,
			:sequence, :package ]				=>	State::Admin::IncompletePackage, 
		[ :incomplete_registration,
			:sequence, :active_agent ]	=>	State::Admin::IncompleteActiveAgent, 
		[ :orphaned_fachinfo ]				=>	State::Admin::OrphanedFachinfoAssign,
		[ :orphaned_patinfo ]					=>	State::Admin::OrphanedPatinfo,
		[ :registration ]							=>	State::Admin::Registration,
		[ :registration, :sequence ]	=>	State::Admin::Sequence,
		[ :registration,
			:sequence, :active_agent ]	=>	State::Admin::ActiveAgent,
		[ :registration,
			:sequence, :package ]				=>	State::Admin::Package,
		[ :registration, :sequence,
			:package, :sl_entry ]				=>	State::Admin::SlEntry,
		[ :indication ]								=>	State::Admin::Indication,
		[ :substance ]								=>	State::Substances::Substance,
	}	
	def addresses
		model = @session.app.address_suggestions.values
		State::Admin::Addresses.new(@session, model)
	end
	def galenic_groups
		model = @session.app.galenic_groups.values
		State::Admin::GalenicGroups.new(@session, model)
	end
	def incomplete_registrations
		model = @session.app.incomplete_registrations
		State::Admin::IncompleteRegs.new(@session, model)
	end
	def indications
		model = @session.app.indications
		State::Admin::Indications.new(@session, model)
	end
	def limited?
		false
	end
	def new_company
		pointer = Persistence::Pointer.new(:company)
		State::Companies::RootCompany.new(@session, Persistence::CreateItem.new(pointer))
	end
	def new_galenic_form
		pointer = @session.user_input(:pointer)
		model = pointer.resolve(@session.app)
		item = Persistence::CreateItem.new(pointer + [:galenic_form])
		item.carry(:galenic_group, model)
		State::Admin::GalenicForm.new(@session, item)
	end
	def new_galenic_group
		pointer = Persistence::Pointer.new(:galenic_group)
		State::Admin::GalenicGroup.new(@session, Persistence::CreateItem.new(pointer))
	end
	def new_indication
		pointer = Persistence::Pointer.new([:indication])
		item = Persistence::CreateItem.new(pointer)
		State::Admin::Indication.new(@session, item)
	end
	def new_registration
		pointer = Persistence::Pointer.new(:registration)
		item = Persistence::CreateItem.new(pointer)
		if(@model.is_a?(Company))
			item.carry(:company, @model)
			item.carry(:company_name, @model.name)
		end
		State::Admin::Registration.new(@session, item)
	end
	def new_substance
		pointer = Persistence::Pointer.new(:substance)
		item = Persistence::CreateItem.new(pointer)
		item.carry(:synonyms, [])
		item.carry(:connection_keys, [])
		State::Substances::Substance.new(@session, item)
	end
	def	orphaned_fachinfos
		model = @session.app.orphaned_fachinfos.values
		State::Admin::OrphanedFachinfos.new(@session, model)
	end	
	def orphaned_patinfos
		model = @session.app.orphaned_patinfos.values
		State::Admin::OrphanedPatinfos.new(@session, model)
	end
	def patinfo_deprived_sequences	
		model = []
		@session.app.registrations.each_value { |reg|
			sequences = reg.sequences.values
			candidates =	sequences.select { |seq|
				!seq.patinfo_shadow \
					&& seq.patinfo.nil? \
					&& seq.active? \
					&& !seq.packages.empty? \
					&& (gf = seq.galenic_form) \
					&& (gg = gf.galenic_group) \
					&& !/^In[jf]/.match(gg.de)
			}
			#if (candidates.size < sequences.size)
				model += candidates
			#end
		}
		State::Admin::PatinfoDeprivedSequences.new(@session, model)
	end
	def patinfo_stats
		State::Admin::PatinfoStats.new(@session,[])
	end
	def user_navigation
		[
			State::Admin::Logout,
		]
	end
	def sponsor
		model = @session.app.sponsor
		State::Admin::Sponsor.new(@session, model)
	end
	def substances
		model = @session.substances
		State::Substances::Substances.new(@session, model)
	end
	def effective_substances
		model = @session.substances.select { |sub| 
			sub.is_effective_form?
		}
		State::Substances::EffectiveSubstances.new(@session, model)
	end
	def zones
		[:drugs, :interactions, :substances, :companies, :doctors, :hospitals, :user, :admin]
	end
end
		end
	end
end
