#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Prescription  -- oddb.org -- 25.07.2012 -- yasaka@ywesee.com

require 'state/drugs/global'
require 'view/drugs/prescription'

module ODDB
  module State
    module Drugs
class Prescription < State::Drugs::Global
  DIRECT_EVENT = :prescription
  VIEW = View::Drugs::Prescription
	VOLATILE = true
end
class PrescriptionPrint < State::Drugs::Global
	VIEW = View::Drugs::PrescriptionPrint
	VOLATILE = true
end
    end
  end
end

