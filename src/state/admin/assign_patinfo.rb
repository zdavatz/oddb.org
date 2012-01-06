#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::AssignPatinfo -- oddb.org -- 06.01.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::AssignPatinfo -- oddb.org -- 19.10.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/assign_deprived_sequence'
require 'view/admin/assign_patinfo'

module ODDB
	module State
		module Admin
class AssignPatinfo < AssignDeprivedSequence
	VIEW = View::Admin::AssignPatinfo
	def assign
    input = @session.user_input(:pointer_list)
    pointers = input.values.map do |p_str|
      if match = p_str.match(/\:\!registration,(\d+)\!sequence,(\d+)\./)
        if reg = match.to_a[1] and seq = match.to_a[2] \
          and sequence = @session.app.registration(reg).sequence(seq)
            sequence.pointer
        end
      end
    end
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
      pointers.each { |pointer|
        @session.app.update(pointer, args, unique_email)
      }
		end
		self
	end
end
		end
	end
end
