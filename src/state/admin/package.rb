#!/usr/bin/env ruby
# State::Admin::Package -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/package'

module ODDB
	module State
		module Admin
module PackageMethods
	def delete
		sequence = @model.parent(@session.app) 
		if(klass = resolve_state(sequence.pointer))
			@session.app.delete(@model.pointer)
			klass.new(@session, sequence)
		end
	end
	def update
		if(@model.is_a? Persistence::CreateItem)
			ikscode = @session.user_input(:ikscd)
			error =	if(ikscode.is_a? RuntimeError)
				ikscode
			elsif(ikscode.empty?)
				create_error(:e_missing_ikscd, :ikscd, ikscode)
			elsif(@model.parent(@session.app).package(ikscode))
				create_error(:e_duplicate_ikscd, :ikscd, ikscode)
			end
			if error
				@errors.store(:ikscd, error)
				@model.carry(:price_exfactory, 
					ODDB::Package.price_internal(@session.user_input(:price_exfactory)))
				@model.carry(:price_public, 
					ODDB::Package.price_internal(@session.user_input(:price_public)))
				return self
			end
			@model.append(ikscode)
			@model = @session.app.create(@model.pointer)
		end
		keys = [
      :commercial_form,
			:deductible,
			:descr,
			:size, 
			:ikscat,
			:market_date,
			:pretty_dose,
			:price_exfactory,
			:price_public,
			:refdata_override,
			:lppv,
		]
		input = user_input(keys)
    if(name = input[:commercial_form])
      if(name.empty?)
        input.store(:commercial_form, nil)
      elsif(comform = ODDB::CommercialForm.find_by_name(name))
        input.store(:commercial_form, comform.pointer)
      else
        @errors.store(:commercial_form,
                      create_error(:e_unknown_comform,
                                   :commercial_form, name))
      end
    end
		unless(error?)
			ODBA.transaction {
				@model = @session.app.update(@model.pointer, input, unique_email)
			}
		end
		self
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
end
class CompanyPackage < State::Admin::Package
	def init
		super
		unless(allowed?)
			@default_view = View::Admin::Package
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
