#!/usr/bin/env ruby
# State::Admin::AssignPatinfo -- oddb -- 19.10.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/assign_deprived_sequence'
require 'view/admin/assign_patinfo'

module ODDB
	module State
		module Admin
class AssignPatinfo < AssignDeprivedSequence
	VIEW = View::Admin::AssignPatinfo
	def assign
		keys = [:pointers]
		input = user_input(keys, keys)
		pointers = input[:pointers]
		if(pointers \
			&& pointers.any? { |pointer| 
				!allowed?(pointer.resolve(@session))})
			@errors.store(:pointers, 
				create_error('e_not_allowed', :pointers, nil))
		end
		unless(error?)
			args = { :patinfo	=>	nil, :pdf_patinfo => nil }
			if(pat = @model.sequence.pdf_patinfo)
				args.store(:pdf_patinfo, pat)
			elsif(pat = @model.sequence.patinfo)
				args.store(:patinfo, pat.pointer)
			end
			ODBA.transaction { 
				pointers.each { |pointer|
					puts "updating #{pointer} with #{args.inspect}"
					@session.app.update(pointer, args)
				}
			}
		end
		self
	end
end
		end
	end
end
