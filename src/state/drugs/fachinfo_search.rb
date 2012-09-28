# encoding: utf-8
# ODDB::State::Drugs::FachinfoSearch  -- oddb.org -- 28.09.2012 -- yasaka@ywesee.com

require 'state/drugs/global'
require 'view/drugs/fachinfo_search'

module ODDB
  module State
    module Drugs
class FachinfoSearchDrug < Global
  VIEW = View::Drugs::FachinfoSearchDrugDiv
  VOLATILE = true
end
class FachinfoSearchCsvExport < State::Drugs::Global
  VIEW = View::Drugs::FachinfoSearchCsv
end
class FachinfoSearch < State::Drugs::Global
  DIRECT_EVENT = :fachinfo_search
  VIEW = View::Drugs::FachinfoSearch
  @@ean13_form = /^(7680)(\d{5})(\d{3})(\d)$/u
  def init
    if @session.event.to_sym == self.class::DIRECT_EVENT and
       drugs = @session.persistent_user_input(:drugs) # init
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
        @session.set_persistent_user_input(:drugs, drugs)
      end
    end
    FachinfoSearchDrug.new(@session, @model)
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
    FachinfoSearchDrug.new(@session, @model)
  end
  def export_csv
    @model = match_term
    if @model.empty?
      FachinfoSearch.new(@session, @model)
    else
      FachinfoSearchCsvExport.new(@session, @model)
    end
  end
  def search
    @model = match_term
    FachinfoSearch.new(@session, @model)
  end
  private
  def check_model
    ean13 = @session.user_input(:ean)
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
  def match_term
    hits = []
    if ean13s = @session.persistent_user_input(:drugs) and
       ean13s.is_a? Hash
      chapter = @session.user_input(:fachinfo_search_type).to_s.gsub(/^fi_/, '').intern
      term    = @session.user_input(:fachinfo_search_term)
      is_full = (@session.user_input(:fachinfo_search_full_text) == "1")
      ean13s.keys.each do |ean13|
        pac = package_for(ean13)
        doc = pac.fachinfo.description(@session.language)
        if doc.respond_to?(chapter)
          desc = doc.send(chapter).to_s
          if is_full and
             (term == @session.lookandfeel.lookup(:fachinfo_search_term) \
              or term.empty?)
            hits << {
              :ean13 => ean13,
              :text  => desc,
            }
          elsif match = desc.scan(/.*\n?.*#{term}.*\n?.*/i) and
                !match.empty?
            hits << {
              :ean13 => ean13,
              :text  => is_full ? desc : match.join("\n"),
            }
          end
        end
      end
    end
    hits
  end
end
    end
  end
end
