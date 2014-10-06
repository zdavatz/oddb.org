#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::Download -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::User::Download -- oddb.org -- 29.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/download'
require 'view/user/auth_info'
require 'view/drugs/csv_result'

module ODDB
  module State
    module User
class Download < State::User::Global
  VOLATILE = true
  VIEW = View::User::Download
  attr_reader :filename
  def init
    # if the file is a bespoke export, query and stype should be set
    query = stype = nil
    if(@model.respond_to?(:data) && @model.data.is_a?(Hash))
      query = ODDB.search_term(@model.data[:search_query].to_s)
      stype = @model.data[:search_type]
    end
    if(query && stype)
      @model = _search_drugs(query.to_s.downcase.gsub(/\s+/u, ' '), stype)
      @model.search_query = query
      @model.search_type = stype
      @model.session = @session
      @default_view = ODDB::View::Drugs::CsvResult
    end
  end
end
    end
  end
end
