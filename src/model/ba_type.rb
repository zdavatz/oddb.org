#!/usr/bin/env ruby
# encoding: utf-8
# Business area for companies
require 'sbsm/validator'

module ODDB
	class BA_type
		include Enumerable
		BA_hospital =  'ba_hospital'
		BA_pharma =  'ba_pharma'
		BA_public_pharmacy =  'ba_public_pharmacy'
		BA_hospital_pharmacy =  'ba_hospital_pharmacy'
		BA_research_institute =  'ba_research_institute'
		BA_insurance =  'ba_insurance'
		BA_doctor =  'ba_doctor'
		BA_health =  'ba_health'
		BA_info =  'ba_info'
   def each
     yield nil
     yield BA_hospital
     yield BA_pharma
     yield BA_public_pharmacy
     yield BA_hospital_pharmacy
     yield BA_research_institute
     yield BA_insurance
     yield BA_doctor
     yield BA_health
     yield BA_info
   end
  end
end
