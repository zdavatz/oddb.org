# encoding: utf-8
# ODDB::State::Ajax::Matches -- oddb.org -- 14.01.2013 -- yasaka@ywesee.com

require 'state/ajax/global'
require 'view/ajax/json'

module ODDB
  module State
    module Ajax
class Matches < Global
  VIEW = View::Ajax::Json
  def init
    @model = []
    index = @session.user_input(:index_name) || 'sequence_index_exact'
    if (term = @session.user_input(:search_query)) && term.is_a?(String)
      terms = ODBA.cache.index_matches(index, term.downcase)
      case index
      when 'oddb_package_name_with_size_company_name_and_ean13',
           'oddb_package_name_with_size_company_name_ean13_fi'
        terms.collect! do |term|
          str = (term.match(/^(.+),\s(\d{13})$/)||[])
          { :search_query => str[2], :drug => str[1] }
        end
      else
        terms.collect! do |term|
          { :search_query => term }
        end
      end
      @model.concat terms
    end
  end
end
    end
  end
end
