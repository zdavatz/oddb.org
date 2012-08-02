#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Prescription  -- oddb.org -- 02.08.2012 -- yasaka@ywesee.com

require 'state/drugs/global'
require 'view/drugs/prescription'

module ODDB
  module State
    module Drugs
class AjaxDrugs < Global
  VOLATILE = true
  VIEW = View::Drugs::PrescriptionDrugsHeader
end
class Prescription < State::Drugs::Global
  DIRECT_EVENT = :prescription
  VIEW = View::Drugs::Prescription
  @@ean13_form = /^(7680)(\d{5})(\d{3})(\d)$/u
  def ajax_add_drug
    check_model
    if ean13 = @session.persistent_user_input(:ean13) and
       pack = package_for(ean13)
      drugs = @session.persistent_user_input(:drugs) || {}
      drugs[ean13] = pack unless drugs.has_key?(ean13)
      @session.set_persistent_user_input(:drugs, drugs)
    end
    AjaxDrugs.new(@session, @model)
  end
  def ajax_delete_drug
    check_model
    if ean13 = @session.persistent_user_input(:ean13)
      drugs = @session.persistent_user_input(:drugs) || {}
      drugs.delete(ean13)
      @session.set_persistent_user_input(:drugs, drugs)
    end
    AjaxDrugs.new(@session, @model)
  end
  private
  def check_model
    ean13 = @session.user_input(:ean13)
    unless ean13 and ean13.match(@@ean13_form)
      @errors.store :pointer, create_error(:e_state_expired, :pointer, nil)
    end
    if !allowed?
      @errors.store :pointer, create_error(:e_not_allowed, :pointer, nil)
    end
  end
  def package_for(ean13)
    if ean13.match(@@ean13_form)
      iksnr = $2
      ikscd = $3
      if reg = @session.app.registration(iksnr) and
         pack = reg.package(ikscd)
        pack
      end
    end
  end
end
class PrescriptionPrint < State::Drugs::Global
  VIEW = View::Drugs::PrescriptionPrint
  VOLATILE = true
end
    end
  end
end
