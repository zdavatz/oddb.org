#!/usr/bin/env ruby
#	State::Admin::Sponsor -- oddb -- 29.07.2003 -- mhuggler@ywesee.com

require 'state/admin/global'
require 'util/upload'
require 'view/admin/sponsor'

module ODDB
	module State
		module Admin
class Sponsor < State::Admin::Global
	DIRECT_EVENT = :sponsor	
	VIEW = View::Admin::Sponsor	
	def update
		keys = [:sponsor_until, :company_name, :logo_file]
		input = user_input(keys)#, keys)
		name = input[:company_name]
		values = {
			:sponsor_until	=>	input[:sponsor_until],
		}
		if(name.empty?)
			values.store(:company, nil)
		elsif(company = @session.app.company_by_name(name))
			values.store(:company, company.pointer)
		else
			err = create_error(:e_unknown_company, :company_name, name)
			@errors.store(:company_name, err)
		end
		unless error?
			begin
				if((logo = input[:logo_file]))
					values.store(:logo, Upload.new(logo))
				end
				@session.app.update(@model.pointer, values)
			rescue StandardError => e
				err = create_error(:e_exception, :logo_file, e.message)	
				@errors.store(:logo_file, err)
			end
		end
		self
	end
end
		end
	end
end
