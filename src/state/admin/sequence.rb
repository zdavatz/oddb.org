#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::Sequence -- oddb.org -- 06.06.2013 -- yasaka@ywesee.com
# ODDB::State::Admin::Sequence -- oddb.org -- 29.02.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::Sequence -- oddb.org -- 11.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/sequence'
require 'model/sequence'
require 'model/division'
require 'state/admin/package'
require 'state/admin/activeagent'
require 'state/admin/assign_deprived_sequence'
require 'state/admin/assign_patinfo'
require 'state/admin/assign_division'
require 'state/admin/patinfo_pdf'
require 'fileutils'
require 'util/mail'

module ODDB
	module State
		module Admin
module SequenceMethods
	include PatinfoPdfMethods
  def assign_patinfo
    if(@model.has_patinfo?)
      State::Admin::AssignPatinfo.new(@session, @model)
    else
      State::Admin::AssignDeprivedSequence.new(@session, @model)
    end
  end
  def assign_division
    State::Admin::AssignDivision.new(@session, @model)
  end
	def delete
		registration = @model.parent(@session.app) 
		if(klass = resolve_state(registration.pointer))
      @session.app.delete(@model.pointer)
			klass.new(@session, registration)
		end
	end
	def new_active_agent
		pointer = @session.user_input(:pointer)
		model = pointer.resolve(@session.app)
		aa_pointer = pointer + [:active_agent]
		item = Persistence::CreateItem.new(aa_pointer)
		item.carry(:iksnr, model.iksnr)
		item.carry(:name_base, model.name_base)
		item.carry(:sequence, model)
		if (klass=resolve_state(aa_pointer))
			klass.new(@session, item)
		else
			self
		end
	end
	def new_package
    model = if @model.is_a?(ODDB::Sequence)
               @model
            elsif iksnr = @session.persistent_user_input(:reg) and seqnr = @session.persistent_user_input(:seq)
               @session.app.registration(iksnr).sequence(seqnr)
            end
    if model
      pointer = model.pointer
      p_pointer = pointer + [:package]
      item = Persistence::CreateItem.new(p_pointer)
      item.carry(:iksnr, model.iksnr)
      item.carry(:name_base, model.name_base)
      item.carry(:sequence, model)
      item.carry(:parts, [])
      if (klass=resolve_state(p_pointer))
        klass.new(@session, item)
      else
        self
      end
    else
      self
    end
	end
	def update
		newstate = self
		if(@model.is_a? Persistence::CreateItem)
			seqnr = @session.user_input(:seqnr)
			error =	if(seqnr.is_a? RuntimeError)
				seqnr
			elsif(seqnr.empty?)
				create_error(:e_missing_seqnr, :seqnr, seqnr)
			elsif(@model.parent(@session.app).sequence(seqnr))
				create_error(:e_duplicate_seqnr, :seqnr, seqnr)
			end
			if error
				@errors.store(:seqnr, error)
				return newstate
			end
			@model.append(seqnr)
		end
    keys = [
      :composition_text,
      :dose,
      :export_flag,
      :name_base,
      :name_descr,
      :longevity,
      :substance,
      :galenic_form,
      :activate_patinfo,
      :deactivate_patinfo,
      :sequence_date,
      :division_divisable,
      :division_dissolvable,
      :division_crushable,
      :division_openable,
      :division_notes,
      :division_source,
    ]
		input = user_input(keys)
=begin
		galform = @session.user_input(:galenic_form)
		if(@session.app.galenic_form(galform))
			input.store(:galenic_form, galform)
		else
			err = create_error(:e_unknown_galenic_form, 
				:galenic_form, galform)
			@errors.store(:galenic_form, err)
		end
=end
		atc_input = self.user_input(:code, :code)
		atc_code = atc_input[:code]
		if(atc_code.nil?)
			# error already stored by user_input(:code, :code)
		elsif((descr = @session.user_input(:atc_descr)) \
			&& !descr.empty?)
			pointer = Persistence::Pointer.new([:atc_class, atc_code])
			values = {
				@session.language	=> descr,	
			}
			@session.app.update(pointer.creator, values, unique_email)
			input.store(:atc_class, atc_code)
		elsif(@session.app.atc_class(atc_code))
			input.store(:atc_class, atc_code)
		else
			@errors.store(:atc_class, create_error(:e_unknown_atc_class, :code, atc_code))
		end
    update_division input
		newstate = get_patinfo_input(input)
		if((company = @model.company) \
			&& (mail = user_input(:regulatory_email)) && !mail.empty?)
			@session.app.update(company.pointer, mail, unique_email)
		end
    @model = @session.app.update(@model.pointer, input, unique_email)
    update_compositions input
		newstate
	end
  def ajax_create_active_agent
    check_model
    keys = [:reg, :seq, :composition]
    input = user_input(keys, keys)
    agents = []
    if(!error? \
       && (composition = @model.compositions.at(input[:composition].to_i)))
      agents = composition.active_agents
    end
    AjaxActiveAgents.new(@session, agents.dup.push(nil))
  end
  def ajax_create_composition
    check_model
    comps = @model.compositions.dup
    if(!error?)
      comp = ODDB::Composition.new
      comp.active_agents.push nil
      comps.push comp
    end
    AjaxCompositions.new @session, comps
  end
  def ajax_delete_active_agent
    check_model
    keys = [:reg, :seq, :active_agent, :composition]
    input = user_input(keys, keys)
    agents = []
    if(!error? \
       && (composition = @model.compositions.at(input[:composition].to_i)))
      if(agent = composition.active_agents.at(input[:active_agent].to_i))
        @session.app.delete agent.pointer
        #composition.remove_active_agent(agent)
        #composition.save
      end
      agents = composition.active_agents
    end
    AjaxActiveAgents.new(@session, agents)
  end
  def ajax_delete_composition
    check_model
    keys = [:reg, :seq, :composition]
    input = user_input(keys, keys)
    agents = []
    if(!error? \
       && (composition = @model.compositions.at(input[:composition].to_i)))
      @session.app.delete composition.pointer
    end
    AjaxCompositions.new(@session, @model.compositions)
  end
  def check_model
    unless iksnr = @session.user_input(:reg) and seqnr = @session.user_input(:seq)\
      and reg = @session.app.registration(iksnr) and seq = reg.sequence(seqnr)\
      and @model.pointer == seq.pointer
      @errors.store :pointer, create_error(:e_state_expired, :pointer, nil)
    end
    if !allowed?
      @errors.store :pointer, create_error(:e_not_allowed, :pointer, nil)
    end
  end
  def update_division(input)
    if !input.empty? and input[:division_divisable]
      data = {}
      div = @model.division
      input.each_pair do |key, value|
        if key.to_s =~ /division_(\w*)/
          data[$1] = value
        end
      end
      ptr = div ? div.pointer : (@model.pointer + :division).creator
      if ptr
        div = @session.app.update ptr, data, unique_email
      end
    end
  end
  def update_compositions(input)
    saved = nil
    if(substances = input[:substance])
      substances.each { |cmp_idx, substances|
        doses = input[:dose][cmp_idx]
        galform = input[:galenic_form][cmp_idx]
        cmp_idx = cmp_idx.to_i
        comp = @model.compositions.at(cmp_idx)
        ptr = comp ? comp.pointer : (@model.pointer + :composition).creator
        comp = @session.app.update ptr, { :galenic_form => galform },
                                   unique_email
        substances.each { |sub_idx, sub|
          ## create missing substance on the fly
          unless @session.app.substance(sub)
            sptr = Persistence::Pointer.new(:substance)
            @session.app.update(sptr.creator, 'lt' => sub)
          end
          parts = doses[sub_idx]
          sub_idx = sub_idx.to_i
          agent = comp.active_agents.at(sub_idx)
          ptr = agent ? agent.pointer \
                      : (comp.pointer + [:active_agent, sub]).creator
          agent = @session.app.update ptr, { :dose => parts, :substance => sub },
                                      unique_email
          unless agent.substance
            key = :"substance[#{cmp_idx}][#{sub_idx}]"
            @errors.store key, create_error(:e_unknown_substance, key, sub)
          end
        }
      }
    end
    saved
  end
end
class AjaxActiveAgents < Global
  VOLATILE = true
  VIEW = View::Admin::RootActiveAgents
end
class AjaxCompositions < Global
  VOLATILE = true
  VIEW = View::Admin::RootCompositions
end
class Sequence < State::Admin::Global
	VIEW = View::Admin::RootSequence
	RECIPIENTS = []
	include SequenceMethods
	def atc_request
		if((company = @model.company) && (addr = company.regulatory_email))
			lookandfeel = @session.lookandfeel
			body = [
				lookandfeel.lookup(:atc_request_email),
				lookandfeel.lookup(:name) + ": " + @model.name_base,
				lookandfeel.lookup(:registration) + ": " + @model.iksnr,
				lookandfeel.lookup(:package) + ": " \
					+ @model.packages.keys.join(","),
				lookandfeel._event_url(:drug, [:reg, @model.iksnr, :seq, @model.seqnr]),
				nil,
				lookandfeel.lookup(:thanks_for_cooperation),
			].join("\n")
			Util.send_mail([addr], "#{@model.name_base} #{@model.iksnr}", body)
			@model.atc_request_time = Time.now
			@model.odba_isolated_store
		end
		self
	end
	private
	def store_slate
		time = Time.now
    store_slate_item(time, :annual_fee)
    store_slate_item(time, :processing)
	end
end
class CompanySequence < State::Admin::Sequence
	def init
		super
		unless(allowed?)
			@default_view = ODDB::View::Admin::Sequence 
		end
	end
	def delete
		if(allowed?)
			super
		end
	end
	def new_active_agent
		if(allowed?)
			super
		end
	end
	def new_package
		if(allowed?)
			super
		end
	end
	def update
		if(allowed?)
			super
		end
	end
	def store_slate
		store_slate_item(Time.now, :annual_fee)
	end
end
class ResellerSequence < Global
	include PatinfoPdfMethods
	VIEW = View::Admin::ResellerSequence
	def update
		input = {}
		newstate = get_patinfo_input(input)
    @model = @session.app.update(@model.pointer, input, unique_email)
		newstate
	end
end
		end
	end
end
