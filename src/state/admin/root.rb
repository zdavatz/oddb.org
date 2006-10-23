#!/usr/bin/env ruby
# State::Admin::Root -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/admin/galenicgroups'
require 'state/admin/incompleteregistrations'
require 'state/admin/indications'
require 'state/admin/init'
require 'state/admin/logout'
require 'state/admin/patent'
require 'state/admin/user'
require 'state/admin/entities'
require 'state/doctors/doctor'
require 'state/drugs/fachinfo'
require 'state/hospitals/hospital'
require 'ostruct'

module ODDB
	module State
		module Companies
class Global < State::Global; end
class Company < Global; end
class UserCompany < Company; end
class RootCompany < UserCompany; end
		end
		module Substances
class Global < State::Global; end
class Substance < Global; end
class Substances < Global; end
class EffectiveSubstances < Substances; end
		end
		module Admin
class Global < State::Global; end
class ActiveAgent < Global; end
class Addresses < Global; end
class AddressSuggestion < Global; end
class AssignDeprivedSequence < Global; end
class AtcClass < Global; end
class GalenicForm < Global; end
class GalenicGroup < Global; end
class GalenicGroups < Global; end
class IncompleteRegs < Global; end
class OrphanedFachinfos < Global; end
class OrphanedFachinfoAssign < Global; end
class OrphanedPatinfo < Global; end
class OrphanedPatinfos < Global; end
class Package < Global; end
class PatinfoDeprivedSequences < Global; end
class Registration < Global; end
class Sequence < Global; end
class SlEntry < Global; end
class PatinfoStatsCommon < Global; end
class PatinfoStats < PatinfoStatsCommon; end
class Sponsor < Global; end
class SuggestReg < Registration; end
class IncompleteReg < Registration; end
class IncompleteSequence < Sequence; end
class IncompleteActiveAgent < ActiveAgent; end
class IncompletePackage < Package; end
class Indication < Global; end
module Root
	include State::Admin::User
  EVENT_MAP = {
    :users  =>  State::Admin::Entities, 
  }
	RESOLVE_STATES = {
		[ :address_suggestion ]				=>	State::Admin::AddressSuggestion,
		[ :atc_class ]								=>	State::Admin::AtcClass,
		[ :company ]									=>	State::Companies::RootCompany,
    [ :doctor ]                   =>  State::Doctors::RootDoctor,
		[ :fachinfo ]									=>	State::Drugs::RootFachinfo,
		[ :galenic_group ]						=>	State::Admin::GalenicGroup,
		[ :galenic_group,
			:galenic_form ]							=>	State::Admin::GalenicForm,
		[ :select_seq ]								=>  State::Admin::AssignDeprivedSequence,
		[ :hospital ]									=>	State::Hospitals::RootHospital,
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
		[ :registration, :patent ]		=>	State::Admin::Patent,
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
	def effective_substances
		model = @session.substances.select { |sub| 
			sub.is_effective_form?
		}
		State::Substances::EffectiveSubstances.new(@session, model)
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
	def new_fachinfo
		if((pointer = @session.user_input(:pointer)) \
				&& (registration = pointer.resolve(@session)))
			_new_fachinfo(registration)
		end
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
  def new_user
    pointer = Persistence::Pointer.new(:user)
    user = Persistence::CreateItem.new(pointer)
    case @model.odba_instance
    when ODDB::Company # and not: ODDB::State::Companies::Company
      aff = OpenStruct.new
      aff.name = 'CompanyUser'
      user.carry(:affiliations, [aff])
      user.carry(:association, @model.pointer.to_yus_privilege)
      user.carry(:name, @model.contact_email)
      if(fullname = @model.contact)
        first, last = fullname.split(' ', 2)
        user.carry(:name_first, first)
        user.carry(:name_last, last)
      end
    else
      user.carry(:affiliations, [])
    end
    State::Admin::Entity.new(@session, user)
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
	def sponsor
		pointer = Persistence::Pointer.new([:sponsor, @session.flavor])
		model = pointer.resolve(@session.app) || Persistence::CreateItem.new(pointer)
		State::Admin::Sponsor.new(@session, model)
	end
	def substances
		model = @session.substances
		State::Substances::Substances.new(@session, model)
	end
  def user
    name = @session.user_input(:name)
    user = @session.user.find_entity(name)
    State::Admin::Entity.new(@session, user)
  end
	def zones
		[:admin, :analysis, :doctors, :interactions, :drugs, :migel, :user, :hospitals, :substances, :companies]
	end
end
		end
	end
end
