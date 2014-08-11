# encoding: utf-8
# ODDB::State::Drugs::FachinfoSearch  -- oddb.org -- 03.10.2012 -- yasaka@ywesee.com

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
    $stdout.puts "FachinfoSearch #{@session.event.to_sym == self.class::DIRECT_EVENT} drugs #{@session.persistent_user_input(:drugs)}"
    super
  end
  def ajax_add_drug
    $stdout.puts "FachinfoSearch.ajax_add_drug #{@session.user_input(:ean)}"
    check_model
    FachinfoSearchDrug.new(@session, @model)
  end
  def ajax_delete_drug
    $stdout.puts "FachinfoSearch.ajax_delete_drug #{@session.user_input(:ean)}"
    check_model
    FachinfoSearchDrug.new(@session, @model)
  end
  def delete_all
    $stdout.puts "FachinfoSearch.delete_all request_path #{@session.request_path}"
    unless error?
      @model = []
    end
    self.http_headers = {
      'Status'   => '303 See Other',
      'Location' => @session.lookandfeel._event_url(:fachinfo_search, [])
    }
    self
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
    puts "fachinfo_search.match_term #{@session.request_path} drugsFromUrl: #{@session.drugsFromUrl}"
    hits = []
    if @session.drugsFromUrl
      chapter = @session.user_input(:fachinfo_search_type).to_s.gsub(/^fi_/, '').intern
      term    = @session.user_input(:fachinfo_search_term)
      is_full = (@session.user_input(:fachinfo_search_full_text) == "1")
      drugsFromUrl.each do |ean13, pac|
        $stdout.puts "match_term #{ean13} #{pac}"
        doc = pac.fachinfo.description(@session.language)
        if doc.respond_to?(chapter)
          desc = doc.send(chapter).to_s
          # hits[:text] contains FachinfoDocument or (matched) String
          if is_full and
             (term == @session.lookandfeel.lookup(:fachinfo_search_term) \
              or term.empty?)
            hits << {
              :ean13 => ean13,
              :text  => doc,
            }
          elsif match = desc.scan(/.*\n?.*#{term}.*\n?.*/i) and
                !match.empty?
            hits << {
              :ean13 => ean13,
              :text  => is_full ? doc : match.join("\n"),
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
