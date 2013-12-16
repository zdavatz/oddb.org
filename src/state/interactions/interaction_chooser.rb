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
  def init
    if @session.event.to_sym == self.class::DIRECT_EVENT
      @session.set_persistent_user_input(:drugs, {})
    end
    # from centeredsearchform
    if ean13 = @session.user_input(:search_query)
      check_model
      unless error?
        pack = package_for(ean13.to_s)
        drugs = @session.persistent_user_input(:drugs) || {}
        drugs[ean13] = pack unless drugs.has_key?(ean13)
        @session.set_persistent_user_input(:drugs, drugs)
      end
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
        @session.set_persistent_user_input(:drugs, drugs)
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
        @session.set_persistent_user_input(:drugs, drugs)
      end
    end
    InteractionChooserDrug.new(@session, @model)
  end
  def delete_all
    unless error?
      @session.set_persistent_user_input(:drugs, {})
      @model = []
    end
    self.http_headers = {
      'Status'   => '303 See Other',
      'Location' => @session.lookandfeel._event_url(:interaction_chooser, [])
    }
    self
  end
  
  def show_interaction
    atc_codes = []
    iksnrs    = []
    if drugs = @session.persistent_user_input(:drugs)      
      drugs.values.each do |drug|
        iksnrs << drug.iksnr
        atc_codes << drug.atc_class.code.gsub(/[^A-Z0-9]/, '')
      end
    end
    unless atc_codes.empty?
      # http://matrix.epha.ch/#/56751,61537,39053,59256
      url = 'http://matrix.epha.ch/'
      arg = iksnrs.join(',')
      location = "#{url}##{arg}"
      # redirect
      self.http_headers = {
        'Status'   => '303 See Other',
        'Location' => location
      }
    end
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
