#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::InteractionChooser -- oddb.org -- 10.10.2012 -- yasaka@ywesee.com

require 'state/interactions/global'
require 'view/interactions/interaction_chooser'

module ODDB
  module State
    module Interactions

class InteractionChooserDrug < Global
  VIEW = View::Interactions::InteractionChooserDrugDiv
  VOLATILE = true
end

class InteractionChooser < State::Interactions::Global
  DIRECT_EVENT = :interaction_chooser
  VIEW = View::Interactions::InteractionChooser
  @@ean13_form = /^(7680)(\d{5})(\d{3})(\d)$/u

  def handle_drug_changes(drugs, msg)
    path = @session.request_path
    @session.set_persistent_user_input(:drugs, drugs)
    uri = @session.lookandfeel._event_url(:home_interactions, [])
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
    search_code = path.split('home_interactions/')[1]
    drugs = {}
    if search_code
      items = search_code.split(',')
      # new approach unified
      # http://oddb-ci2.dyndns.org/de/gcc/home_interactions/51795,C07AA05,7680583920112
      # Beispiel von Mepha. Losartan, Teva, Novaldex und Paroxetin
      #  http://matrix.epha.ch/#/56751,61537,39053,59256
      #  http://oddb-ci2.dyndns.org/de/gcc/home_interactions/56751,61537,39053,59256
      items.each{
        |item|
        if item.kind_of?(String) and item.length == 5 # it is an iksrn
          registration = @session.app.registration(item)
          pack = registration.packages.first
          next unless pack
          drugs[pack.barcode] = pack
        elsif item.kind_of?(String) and item.length == 7 # it is an ATC code
          next unless atc = @session.app.atc_class(item)
          next unless atc.packages.first and atc.packages.first.barcode
          drugs[atc.packages.first.barcode] = atc.packages.first
        elsif item.kind_of?(String) and item.length == 13 # it is an barcode/ean13
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
  def ajax_add_drug
    check_model
    unless error?
      if ean13 = @session.user_input(:ean).to_s and
        pack  = package_for(ean13)
        drugs = @session.persistent_user_input(:drugs) || {}
        drugs[ean13] = pack unless drugs.has_key?(ean13)
        return handle_drug_changes(drugs, 'ajax_add_drug')
      end
    end
    InteractionChooserDrug.new(@session, @model)
  end
  def ajax_delete_drug
    check_model
    unless error?
      if ean13 = @session.user_input(:ean).to_s
        drugs = @session.persistent_user_input(:drugs) || {}
        drugs.delete(ean13)
        return handle_drug_changes(drugs, 'ajax_delete_drug')
      end
    end
    InteractionChooserDrug.new(@session, @model)
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
  
  private
  def check_model
    ean13 = @session.user_input(:ean) ||
            @session.persistent_user_input(:search_query)
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
    end
  end
end
