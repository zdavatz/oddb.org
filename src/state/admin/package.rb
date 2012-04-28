#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::Package -- oddb.org -- 28.04.2012 -- yasaka@ywesee.com
# ODDB::State::Admin::Package -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::Package -- oddb.org -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/package'

module ODDB
	module State
		module Admin
class AjaxParts < Global
  VOLATILE = true
  VIEW = View::Admin::Parts
end
module PackageMethods
  def ajax_create_part
    check_model
    parts = @model.parts.dup
    if(!error?)
      part = Persistence::CreateItem.new(@model.pointer + :part)
      part.carry(:registration, @model.registration)
      parts.push part
    end
    AjaxParts.new @session, parts
  end
  def ajax_delete_part
    check_model
    keys = [:reg, :seq, :pack, :part]
    input = user_input(keys, keys)
    if(!error? \
       && (part = @model.parts[input[:part].to_i]))
      @session.app.delete part.pointer
    end
    AjaxParts.new(@session, @model.parts)
  end
  def check_model
    unless iksnr = @session.user_input(:reg) and seqnr = @session.user_input(:seq) and ikscd = @session.user_input(:pack)\
      and reg = @session.app.registration(iksnr) and seq = reg.sequence(seqnr) and pac = seq.package(ikscd)\
      and @model.pointer == pac.pointer
      @errors.store :pointer, create_error(:e_state_expired, :pointer, nil)
    end
    if !allowed?
      @errors.store :pointer, create_error(:e_not_allowed, :pointer, nil)
    end
  end
	def delete
		sequence = @model.parent(@session.app) 
		if(klass = resolve_state(sequence.pointer))
			@session.app.delete(@model.pointer)
			klass.new(@session, sequence)
		end
	end
	def update
    ikscode = @session.user_input(:ikscd)
    error =	if(ikscode.is_a? RuntimeError)
      ikscode
    elsif(ikscode.empty?)
      create_error(:e_missing_ikscd, :ikscd, ikscode)
    elsif((dup = @model.parent(@session.app).package(ikscode)) \
          && dup != @model)
      create_error(:e_duplicate_ikscd, :ikscd, ikscode)
    end
    if error
      @errors.store(:ikscd, error)
      if(@model.is_a? Persistence::CreateItem)
        @model.carry(:price_exfactory, 
          ODDB::Package.price_internal(@session.user_input(:price_exfactory), 
                                      :exfactory))
        @model.carry(:price_public, 
          ODDB::Package.price_internal(@session.user_input(:price_public),
                                      :public))
      end
      return self
    end
		if(@model.is_a? Persistence::CreateItem)
			@model.append(ikscode)
			@model = @session.app.create(@model.pointer)
		end
		keys = [
      :ddd_dose,
			:deductible,
			:descr,
      :disable,
      :disable_ddd_price,
			:ikscat,
			:market_date,
      :pharmacode,
			:pretty_dose,
      :preview_with_market_date,
			:price_exfactory,
			:price_public,
      :photo_link,
			:refdata_override,
			:lppv,
      :sl_generic_type,
		]
		input = user_input(keys)
    part_keys = [
      :multi,
      :count,
      :measure,
      :commercial_form,
      :composition,
    ]
    parts = user_input(part_keys)
    time = Time.now
    [:price_exfactory, :price_public].each { |key|
      if(input.include?(key))
        price = ODDB::Package.price_internal(input[key], key)
        price.origin = unique_email
        price.authority = :user
        price.valid_from = time
        input.store(key, price)
      end
    }
		unless(error?)
      if(ikscode != @model.ikscd)
        @model.ikscd = ikscode
      end
      @model = @session.app.update(@model.pointer, input, unique_email)
      update_parts(parts)
		end
		self
	end
  def update_parts(input)
    if(counts = input[:count])
      comforms = input[:commercial_form] || {}
      counts.each { |idx, count|
        part = @model.parts.at(idx.to_i)
        ptr = part ? part.pointer : (@model.pointer + :part).creator
        current = { :package => @model.pointer }
        [:multi, :count, :measure, :composition].each { |key|
          values = (input[key] ||= {})
          current.store(key, values[idx])
        }
        if(cidx = current[:composition])
          comp = @model.registration.compositions[cidx.to_i]
          current[:composition] = comp ? comp.pointer : nil
        end
        if(name = comforms[idx])
          if(name.empty?)
            current.store(:commercial_form, nil)
          elsif(comform = ODDB::CommercialForm.find_by_name(name))
            current.store(:commercial_form, comform.pointer)
          else
            @errors.store(:commercial_form,
                          create_error(:e_unknown_comform,
                                       :commercial_form, name))
          end
        end
        @session.app.update(ptr, current, unique_email)
      }
    end
  end
end
class Package < State::Admin::Global
	include PackageMethods
	VIEW = View::Admin::RootPackage
	def new_item
		item = Persistence::CreateItem.new(@model.pointer + [:sl_entry])
		item.carry(:limitation, false)
		State::Admin::SlEntry.new(@session, item)
	end
  def update
    super
    unless error?
      pointer = nil
      group = @session.user_input(:generic_group)
      unless group.empty?
        packages = []
        group.scan(/(\d{8})\s*(?:\(\s*([\d.]+)\s*x?\s*\))?/) do |ikskey, factor|
          packages.push [ @session.package_by_ikskey(ikskey),
                          (factor || 1).to_f ]
        end
        packages.push [@model, 1]
        group = @model.generic_group
        if group.nil?
          group = @session.create Persistence::Pointer.new([:generic_group, @model.pointer])
        end
        pointer = group.pointer
        add = packages - group.packages
        rem = group.packages - packages
        rem.each do |pac, factor|
          @session.app.update pac.pointer, { :generic_group => nil }, unique_email
        end
        add.each do |pac, factor|
          args = { :generic_group => pointer, :generic_group_factor => factor }
          @session.app.update pac.pointer, args, unique_email
        end
      end
      args = { :generic_group => pointer }
      @model = @session.app.update(@model.pointer, args, unique_email)
    end
    self
  end
end
class CompanyPackage < State::Admin::Package
	def init
		super
		unless(allowed?)
			@default_view = ODDB::View::Admin::Package
		end
	end
	def delete
		if(allowed?)
			super
		end
	end
	def new_item
		if(allowed?)
			super
		end
	end	
	def update
		if(allowed?)
			super
		end
	end
end
class DeductiblePackage < State::Admin::Global
	VIEW = View::Admin::DeductiblePackage
	def update
		keys = [:pointer, :deductible_m]
		input = user_input(keys, [:pointer])
		unless(error?)
			@session.app.update(input.delete(:pointer), input)
		end
		self
	end
end
		end
	end
end
