#!/usr/bin/env ruby

# Business area for companies
require "sbsm/validator"

module ODDB
  class BA_type
    include Enumerable
    BA_cantonal_authority = "ba_cantonal_authority"
    BA_doctor = "ba_doctor"
    BA_health = "ba_health"
    BA_hospital = "ba_hospital"
    BA_hospital_pharmacy = "ba_hospital_pharmacy"
    BA_info = "ba_info"
    BA_insurance = "ba_insurance"
    BA_pharma = "ba_pharma"
    BA_public_pharmacy = "ba_public_pharmacy"
    BA_research_institute = "ba_research_institute"
    def self.collect
      BA_types
    end
  end

  BA_types = Set[
    nil,
    BA_type::BA_cantonal_authority,
    BA_type::BA_doctor,
    BA_type::BA_health,
    BA_type::BA_hospital,
    BA_type::BA_hospital_pharmacy,
    BA_type::BA_info,
    BA_type::BA_insurance,
    BA_type::BA_pharma,
    BA_type::BA_public_pharmacy,
    BA_type::BA_research_institute
  ]
end
