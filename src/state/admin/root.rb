#!/usr/bin/env ruby
# State::Admin::Root -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/admin/user'
require 'state/drugs/incompleteregistrations'
require 'state/drugs/galenicgroups'
require 'state/drugs/indications'
require 'state/admin/logout'
require 'state/admin/init'

module ODDB
	module State
		module Admin
class State::Drugs::ActiveAgent < State::Drugs::Global; end
class State::Drugs::AssignDeprivedSequence < State::Drugs::Global; end
class State::Drugs::AtcClass < State::Drugs::Global; end
class State::Companies::Company < State::Companies::Global; end
class State::Companies::UserCompany < State::Companies::Company; end
class State::Companies::RootCompany < State::Companies::UserCompany; end
class State::Drugs::GalenicForm < State::Drugs::Global; end
class State::Drugs::GalenicGroup < State::Drugs::Global; end
class State::Drugs::GalenicGroups < State::Drugs::Global; end
class State::Drugs::OrphanedFachinfos < State::Drugs::Global; end
class State::Drugs::OrphanedFachinfoAssign < State::Drugs::Global; end
class State::Drugs::OrphanedPatinfo < State::Drugs::Global; end
class State::Drugs::OrphanedPatinfos < State::Drugs::Global; end
class State::Drugs::Package < State::Drugs::Global; end
class State::Drugs::PatinfoDeprivedSequences < State::Drugs::Global; end
class State::Drugs::Registration < State::Drugs::Global; end
class State::Drugs::Sequence < State::Drugs::Global; end
class State::Drugs::SlEntry < State::Drugs::Global; end
class State::Admin::PatinfoStats < State::Admin::Global; end
class State::Admin::Sponsor < State::Admin::Global; end
class State::Substances::Substance < State::Substances::Global; end
class State::Substances::Substances < State::Substances::Global; end
class State::Drugs::IncompleteRegs < State::Drugs::Global; end
class State::Drugs::IncompleteReg < State::Drugs::Registration; end
class State::Drugs::IncompleteSequence < State::Drugs::Sequence; end
class State::Drugs::IncompletePackage < State::Drugs::Package; end
class State::Drugs::IncompleteActiveAgent < State::Drugs::ActiveAgent; end
class State::Drugs::Indication < State::Drugs::Global; end
class State::Drugs::Indication < State::Drugs::Global; end
module Root
	include State::Admin::User
	RESOLVE_STATES = {
		[ :atc_class ]								=>	State::Drugs::AtcClass,
		[ :company ]									=>	State::Companies::RootCompany,
		[ :galenic_group ]						=>	State::Drugs::GalenicGroup,
		[ :galenic_group,
			:galenic_form ]							=>	State::Drugs::GalenicForm,
			[ :select_seq ]									=>  State::Drugs::AssignDeprivedSequence,
		[ :incomplete_registration ]	=>	State::Drugs::IncompleteReg, 
		[ :incomplete_registration,
			:sequence ]									=>	State::Drugs::IncompleteSequence, 
		[ :incomplete_registration,
			:sequence, :package ]				=>	State::Drugs::IncompletePackage, 
		[ :incomplete_registration,
			:sequence, :active_agent ]	=>	State::Drugs::IncompleteActiveAgent, 
		[ :orphaned_fachinfo ]				=>	State::Drugs::OrphanedFachinfoAssign,
		[ :orphaned_patinfo ]					=>	State::Drugs::OrphanedPatinfo,
		[ :patinfo_deprived_sequences ] => State::Drugs::PatinfoDeprivedSequences,
		[ :registration ]							=>	State::Drugs::Registration,
		[ :registration, :sequence ]	=>	State::Drugs::Sequence,
		[ :registration,
			:sequence, :active_agent ]	=>	State::Drugs::ActiveAgent,
		[ :registration,
			:sequence, :package ]				=>	State::Drugs::Package,
		[ :registration, :sequence,
			:package, :sl_entry ]				=>	State::Drugs::SlEntry,
		[ :indication ]								=>	State::Drugs::Indication,
		[ :substance ]								=>	State::Substances::Substance,
	}	
	def galenic_groups
		model = @session.app.galenic_groups.values
		State::Drugs::GalenicGroups.new(@session, model)
	end
	def incomplete_registrations
		model = @session.app.incomplete_registrations
		State::Drugs::IncompleteRegs.new(@session, model)
	end
	def indications
		model = @session.app.indications
		State::Drugs::Indications.new(@session, model)
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
		State::Drugs::GalenicForm.new(@session, item)
	end
	def new_galenic_group
		pointer = Persistence::Pointer.new(:galenic_group)
		State::Drugs::GalenicGroup.new(@session, Persistence::CreateItem.new(pointer))
	end
	def new_indication
		pointer = Persistence::Pointer.new([:indication])
		item = Persistence::CreateItem.new(pointer)
		State::Drugs::Indication.new(@session, item)
	end
	def new_registration
		pointer = Persistence::Pointer.new(:registration)
		item = Persistence::CreateItem.new(pointer)
		if(@model.is_a?(Company))
			item.carry(:company, @model)
		end
		State::Drugs::Registration.new(@session, item)
	end
	def	orphaned_fachinfos
		model = @session.app.orphaned_fachinfos.values
		State::Drugs::OrphanedFachinfos.new(@session, model)
	end	
	def orphaned_patinfos
		model = @session.app.orphaned_patinfos.values
		State::Drugs::OrphanedPatinfos.new(@session, model)
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
		State::Drugs::PatinfoDeprivedSequences.new(@session, model)
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
		model = @session.app.substances
		State::Substances::Substances.new(@session, model)
	end
	def zones
	[:drugs, :interactions, :substances, :companies, :user, :admin]
	end
end
		end
	end
end
