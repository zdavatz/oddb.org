#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'state/doctors/global'
require 'view/doctors/doctor'

module ODDB
	module State
		module Doctors
class Doctor < State::Doctors::Global
	VIEW = View::Doctors::Doctor
	LIMITED = false
end
class RootDoctor < Doctor
	VIEW = View::Doctors::RootDoctor
  def update
    mandatory = [:title, :name_first, :name]
    keys = mandatory + [:specialities, :capabilities, 
            :correspondence, :exam, :ean13, :email]
    input = user_input(keys, mandatory)
    unless(error?)
      @model = @session.app.update(@model.pointer, input)
    end
    self
  end
end
		end
	end
end
