#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Prescription  -- oddb.org -- 15.08.2012 -- yasaka@ywesee.com

require 'state/drugs/global'
require 'view/drugs/prescription'

module ODDB
  module State
    module Drugs
class AjaxDrug < Global
  VIEW = View::Drugs::PrescriptionDrugDiv
  VOLATILE = true
end
class AjaxEmpty < Global # empty HTML
  VIEW = HtmlGrid::Component
  VOLATILE = true
end
class PrescriptionCsvExport < State::Drugs::Global
  VIEW = View::Drugs::PrescriptionCsv
end
class Prescription < State::Drugs::Global
  DIRECT_EVENT = :rezept
  VIEW = View::Drugs::Prescription
  @@ean13_form = /^(7680)(\d{5})(\d{3})(\d)$/u
  def init
    if @session.event.to_sym == self.class::DIRECT_EVENT
      @session.set_persistent_user_input(:drugs, {})
      if ean13 = @session.persistent_user_input(:ean)
        ean13.split(',').uniq.each{
          |ean|
          ajax_add_drug(ean)
        }
      end
    end
    super
  end
  def export_csv
    PrescriptionCsvExport.new(@session, @model)
  end
  def ajax_add_drug(ean13 = @session.user_input(:ean))
    check_model(ean13)
    unless error?
      if ean13 and pack = package_for(ean13)
        drugs = @session.persistent_user_input(:drugs) || {}
        drugs[ean13] = pack unless drugs.has_key?(ean13)
        @session.set_persistent_user_input(:drugs, drugs)
      end
    end
    AjaxDrug.new(@session, @model)
  end
  def ajax_delete_drug(ean13 = @session.user_input(:ean))
    check_model(ean13)
    unless error?
      if ean13
        drugs = @session.persistent_user_input(:drugs) || {}
        drugs.delete(ean13)
        @session.set_persistent_user_input(:drugs, drugs)
      end
    end
    AjaxEmpty.new(@session, @model)
  end
  private
  def check_model(ean13 = @session.user_input(:ean))
    unless ean13 and ean13.match(@@ean13_form)
      @errors.store :pointer, create_error(:e_state_expired, :pointer, nil)
    end
  end
  def package_for(ean13)
    if ean13.match(@@ean13_form) and
       pack = @session.app.package_by_ikskey($2 + $3)
      pack
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
