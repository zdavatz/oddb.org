#!/usr/bin/env ruby
# IncompleteRegistration -- oddb -- 23.05.2003 -- hwyss@ywesee.com 

require 'model/activeagent'
require 'model/package'
require 'model/registration'
require 'model/sequence'

module ODDB
	class IncompleteRegistration < RegistrationCommon
		attr_accessor :errors, :iksnr
		SEQUENCE = IncompleteSequence
		def initialize
			super(nil)
			set_oid()
		end
		def init(app = nil)
			@pointer.append(@oid)
			super
		end
		def acceptable?
			 @iksnr && @company && @sequences.values.all? { |seq| 
				seq.acceptable?
			}
		end
		def accepted!(app)
			ptr = Persistence::Pointer.new([:registration, @iksnr])
			hash = {
				:company						=>	(@company.oid if @company), 
				:expiration_date		=>	@expiration_date, 
				:inactive_date			=>	@inactive_date,
				:registration_date	=>	@registration_date, 
				:revision_date			=>	@revision_date,
				:indication					=>	(@indication.pointer if @indication), 
				:generic_type				=>	@generic_type, 
				:export_flag				=>	@export_flag,
				:source							=>	@source,
			}.delete_if { |key, val| val.nil? }
			reg = app.update(ptr.creator, hash)
			@sequences.each_value { |seq|
				seq.accepted!(app, ptr)
			}
			app.delete(@pointer)
			reg
		end
		def pointer_descr
			super || '???????'
		end
		def sequence_names
			@sequences.values.collect { |seq| seq.name }.uniq.sort
		end
	end
end
