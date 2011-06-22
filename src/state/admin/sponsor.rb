#!/usr/bin/env ruby
#	ODDB::State::Admin::Sponsor -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com
#	ODDB::State::Admin::Sponsor -- oddb.org -- 29.07.2003 -- mhuggler@ywesee.com

require 'state/admin/global'
require 'util/upload'
require 'view/admin/sponsor'

module ODDB
	module State
		module Admin
class Sponsor < State::Admin::Global
	DIRECT_EVENT = :sponsor	
	VIEW = ODDB::View::Admin::Sponsor	
	PATH = File.expand_path('../../../doc/resources/sponsor', 
		File.dirname(__FILE__))
	def update
		keys = [:sponsor_until, :emails, :company_name, :logo_file, :logo_fr, :urls ]
		input = user_input(keys)
		name = input[:company_name]
		values = {
			:sponsor_until	=>	input[:sponsor_until],
			:urls						=>	input[:urls],
      :emails         =>  input[:emails],
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
				@model = @session.app.update(@model.pointer, values, unique_email)
				if(logo_default = input[:logo_file])
					name = store_logo(logo_default, :default, 
						@model.logo_filenames[:default])
					@model.logo_filenames.store(:default, name)
				end
				if(logo_fr = input[:logo_fr])
					name = store_logo(logo_fr, :fr, @model.logo_filenames[:fr])
					@model.logo_filenames.store(:fr, name)
				end
				@model.odba_store
			rescue StandardError => e
				err = create_error(:e_exception, :logo_file, e.message)	
				@errors.store(:logo_file, err)
			end
		end
		self
	end
	def store_logo(io, key, oldname)
		if(oldname)
			old = File.expand_path(oldname, PATH)
			if(File.exist?(old))
				File.delete(old)
			end
		end
		filename = keyname(io, key)
		path = File.expand_path(filename, PATH)
		FileUtils.mkdir_p(PATH)
		File.open(path, 'wb') { |fh|
			fh << io.read
		}
		filename
	end
	def keyname(io, key)
		[@session.flavor, key, io.original_filename].join('_')
	end
end
		end
	end
end
