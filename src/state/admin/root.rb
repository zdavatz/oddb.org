#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::Root -- oddb.org -- 02.11.2011 -- mhatakeyama@ywesee.com 
# ODDB::State::Admin::Root -- oddb.org -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/admin/galenicgroups'
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
class CommercialForm < Global; end
class CommercialForms < Global; end
class GalenicForm < Global; end
class GalenicGroup < Global; end
class GalenicGroups < Global; end
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
class Indication < Global; end
module Root
	include State::Admin::User
  EVENT_MAP = {
    :users            =>  State::Admin::Entities, 
  }
	RESOLVE_STATES = {
		[ :address_suggestion ]				=>	State::Admin::AddressSuggestion,
		[ :atc_class ]								=>	State::Admin::AtcClass,
		[ :company ]									=>	State::Companies::RootCompany,
		[ :commercial_form ]	    		=>	State::Admin::CommercialForm,
    [ :doctor ]                   =>  State::Doctors::RootDoctor,
		[ :fachinfo ]									=>	State::Drugs::RootFachinfo,
		[ :galenic_group ]						=>	State::Admin::GalenicGroup,
		[ :galenic_group,
			:galenic_form ]							=>	State::Admin::GalenicForm,
		[ :select_seq ]								=>  State::Admin::AssignDeprivedSequence,
		[ :hospital ]									=>	State::Hospitals::RootHospital,
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
  def address_suggestion
    if (ean_or_oid = @session.user_input(:doctor) and (doctor = @session.search_doctor(ean_or_oid) || @session.search_doctors(ean_or_oid).first)) \
      or (ean = @session.user_input(:hospital) and hospital = @session.search_hospital(ean))
      if oid = @session.user_input(:oid) and model = @session.app.address_suggestion(oid) 
        State::Admin::AddressSuggestion.new(@session, model)
      end
    end
  end
  def commercial_form
    if oid = @session.user_input(:oid) and model = @session.app.commercial_form(oid)
      ODDB::State::Admin::CommercialForm.new(@session, model)
    end
  end
  def commercial_forms
    State::Admin::CommercialForms.new(@session, 
                                      ODDB::CommercialForm.odba_extent)
  end
  def company
    if (oid = @session.user_input(:oid) and model = @session.app.company(oid)) \
      or (ean = @session.user_input(:ean) and model = @session.search_companies(ean).sort_by{|c| c.oid.to_i}.last)
      State::Companies::RootCompany.new(@session, model)
    end
  end
  def doctor
    model = if ean = @session.user_input(:ean)
               @session.search_doctors(ean).first
             elsif oid = @session.user_input(:oid)
               @session.search_doctor(oid)
             end
    if model
      State::Doctors::RootDoctor.new(@session, model)
    end
  end
	def effective_substances
		model = @session.substances.select { |sub| 
			sub.is_effective_form?
		}
		State::Substances::EffectiveSubstances.new(@session, model)
	end
  def fipi_overview
    if (oid_or_ean = @session.user_input(:company) and (company = @session.app.company(oid_or_ean) || @session.search_companies(oid_or_ean).sort_by{|c| c.oid.to_i}.last)) \
        or ((pointer = @session.user_input(:pointer)) and (company = pointer.resolve(@session.app)))
      State::Companies::FiPiOverview.new(@session, company)
    end
  end
	def galenic_groups
		model = @session.app.galenic_groups.values
		State::Admin::GalenicGroups.new(@session, model)
	end
  def hospital
    if ean = @session.user_input(:ean) and model = @session.app.hospital(ean)
      State::Hospitals::RootHospital.new(@session, model)
    end
  end
  def indication
    if oid = @session.user_input(:oid) and model = @session.app.indication(oid)
      State::Admin::Indication.new(@session, model)
    end
  end
	def indications
		model = @session.app.indications
		State::Admin::Indications.new(@session, model)
	end
	def limited?
		false
	end
	def new_commercial_form
		pointer = Persistence::Pointer.new(:commercial_form)
    cform = Persistence::CreateItem.new(pointer)
    cform.carry :packages, []
		State::Admin::CommercialForm.new(@session, cform)
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
		item.carry(:sequences, [])
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
    item.carry :sequences, {}
    item.carry :packages, []
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
					&& !/^In[jf]/u.match(gg.de)
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
  def substance
    if oid = @session.user_input(:oid) and substance = @session.app.substance(oid)
      State::Substances::Substance.new(@session, substance)
    end
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
