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
  def handle_drug_changes(drugs, msg)
    path = @session.request_path
    @session.set_persistent_user_input(:drugs, drugs)
    uri = @session.lookandfeel._event_url(:rezept, [])
    first = true
    drugs.each{|ean, pack|
               if first
                 first = false
                 uri += pack.barcode
               else
                  uri += ",#{pack.barcode}"
               end
               }
  end
  def init
    ean13 = @session.user_input(:search_query)
    path = @session.request_path
    uri = @session.lookandfeel._event_url(:rezept, [])
    search_code = path.split('rezept/ean/')[1]
    drugs = {}
    if search_code
      items = search_code.split(',')
      items.each{
        |item|
        if item.kind_of?(String) and item.length == 13
          next unless item
          pack = package_for(item)
          next unless pack
          drugs[item] = pack
        end
      }
      handle_drug_changes(drugs, 'init')
    else
      @session.set_persistent_user_input(:drugs, {})
    end
    super
  end
  def delete_all
    unless error?
      handle_drug_changes({}, 'delete_all')
      @model = []
    end
    self.http_headers = {
      'Status'   => '303 See Other',
      'Location' => @session.lookandfeel._event_url(:home_interactions, [])
    }
    self
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
        handle_drug_changes(drugs, 'ajax_add_drug')
      end
    end
    AjaxDrug.new(@session, @model)
  end
  
  def ajax_delete_drug(ean13 = @session.user_input(:ean))
    check_model
    unless error?
      if ean13 and pack = package_for(ean13)
        drugs = @session.persistent_user_input(:drugs) || {}
        drugs.delete(ean13)
        return handle_drug_changes(drugs, 'ajax_delete_drug')
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
