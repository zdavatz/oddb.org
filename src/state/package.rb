#!/usr/bin/env ruby
# PackageState -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'state/global'
require 'view/package'

module ODDB
	class PackageState < GlobalState
		VIEW = RootPackageView
		def delete
			sequence = @model.parent(@session.app) 
			@session.app.delete(@model.pointer)
			SequenceState.new(@session, sequence)
		end
		def new_item
			item = Persistence::CreateItem.new(@model.pointer + [:sl_entry])
			item.carry(:limitation, false)
			SlEntryState.new(@session, item)
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
					@model.carry(:price_exfactory, Package.price_internal(@session.user_input(:price_exfactory)))
					@model.carry(:price_public, Package.price_internal(@session.user_input(:price_public)))
					return self
				end
				@model.append(ikscode)
			end
			keys = [
				:descr,
				:size, 
				:ikscat,
				:pretty_dose,
				:price_exfactory,
				:price_public,
			]
			#input = user_input(keys)
=begin
			input = [
				:size, 
				:ikscat,
				:price_exfactory,
				:price_public,
			].inject({}) { |inj, key|
				value = @session.user_input(key)
				if(value.is_a? RuntimeError)
					@errors.store(key, value)
				else
					inj.store(key, value)
				end
				inj
			}
=end
			@model = @session.app.update(@model.pointer, user_input(keys))
			self
		end
	end
	class CompanyPackageState < PackageState
		def init
			super
			unless(allowed?)
				@default_view = PackageView
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
		private
		def allowed?
			((seq = @model.sequence) && @session.user_equiv?(seq.company))
		end
	end
end
