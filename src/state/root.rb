#!/usr/bin/env ruby
# RootState -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/user'

module ODDB
	class ActiveAgentState < GlobalState; end
	class AssignDeprivedSequenceState < GlobalState; end
	class AtcClassState < GlobalState; end
	class CompanyState < GlobalState; end
	class UserCompanyState < CompanyState; end
	class RootCompanyState < UserCompanyState; end
	class GalenicFormState < GlobalState; end
	class GalenicGroupState < GlobalState; end
	class GalenicGroupsState < GlobalState; end
	class OrphanedFachinfosState < GlobalState; end
	class OrphanedFachinfoAssignState < GlobalState; end
	class OrphanedPatinfoState < GlobalState; end
	class OrphanedPatinfosState < GlobalState; end
	class PackageState < GlobalState; end
	class PatinfoDeprivedSequencesState < GlobalState; end
	class RegistrationState < GlobalState; end
	class SequenceState < GlobalState; end
	class SlEntryState < GlobalState; end
	class SponsorState < GlobalState; end
	class IncompleteRegsState < GlobalState; end
	class IncompleteRegState < RegistrationState; end
	class IncompleteSequenceState < SequenceState; end
	class IncompletePackageState < PackageState; end
	class IncompleteActiveAgentState < ActiveAgentState; end
	class IndicationsState < GlobalState; end
	class IndicationState < GlobalState; end
	module RootState
		include UserState
		RESOLVE_STATES = {
			[ :atc_class ]								=>	AtcClassState,
			[ :company ]									=>	RootCompanyState,
			[ :galenic_group ]						=>	GalenicGroupState,
			[ :galenic_group,
				:galenic_form ]							=>	GalenicFormState,
				[ :select_seq ]									=>  AssignDeprivedSequenceState,
			[ :incomplete_registration ]	=>	IncompleteRegState, 
			[ :incomplete_registration,
				:sequence ]									=>	IncompleteSequenceState, 
			[ :incomplete_registration,
				:sequence, :package ]				=>	IncompletePackageState, 
			[ :incomplete_registration,
				:sequence, :active_agent ]	=>	IncompleteActiveAgentState, 
			[ :orphaned_fachinfo ]				=>	OrphanedFachinfoAssignState,
			[ :orphaned_patinfo ]					=>	OrphanedPatinfoState,
			[ :patinfo_deprived_sequences ] => PatinfoDeprivedSequencesState,
			[ :registration ]							=>	RegistrationState,
			[ :registration, :sequence ]	=>	SequenceState,
			[ :registration,
				:sequence, :active_agent ]	=>	ActiveAgentState,
			[ :registration,
				:sequence, :package ]				=>	PackageState,
			[ :registration, :sequence,
				:package, :sl_entry ]				=>	SlEntryState,
				[ :indication ]							=>	IndicationState,
		}	
		def galenic_groups
			model = @session.app.galenic_groups.values
			GalenicGroupsState.new(@session, model)
		end
		def incomplete_registrations
			model = @session.app.incomplete_registrations
			IncompleteRegsState.new(@session, model)
		end
		def indications
			model = @session.app.indications
			IndicationsState.new(@session, model)
		end
		def new_company
			pointer = Persistence::Pointer.new(:company)
			RootCompanyState.new(@session, Persistence::CreateItem.new(pointer))
		end
		def new_galenic_form
			pointer = @session.user_input(:pointer)
			model = pointer.resolve(@session.app)
			item = Persistence::CreateItem.new(pointer + [:galenic_form])
			item.carry(:galenic_group, model)
			GalenicFormState.new(@session, item)
		end
		def new_galenic_group
			pointer = Persistence::Pointer.new(:galenic_group)
			GalenicGroupState.new(@session, Persistence::CreateItem.new(pointer))
		end
		def new_indication
			pointer = Persistence::Pointer.new([:indication])
			item = Persistence::CreateItem.new(pointer)
			IndicationState.new(@session, item)
		end
		def new_registration
			puts 'creating registration'
			pointer = Persistence::Pointer.new(:registration)
			item = Persistence::CreateItem.new(pointer)
			if(@model.is_a?(Company))
				item.carry(:company, @model)
			end
			RegistrationState.new(@session, item)
		end
		def	orphaned_fachinfos
			model = @session.app.orphaned_fachinfos.values
			OrphanedFachinfosState.new(@session, model)
		end	
		def orphaned_patinfos
			model = @session.app.orphaned_patinfos.values
			OrphanedPatinfosState.new(@session, model)
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
			PatinfoDeprivedSequencesState.new(@session, model)
		end
		def sponsor
			model = @session.app.sponsor
			SponsorState.new(@session, model)
		end
	end
end
