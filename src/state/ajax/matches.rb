# encoding: utf-8
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
      terms = ODBA.cache.index_matches(index, term)
      terms.collect! do |term|
        { :search_query => term }
      end
      @model.concat terms
    end
  end
end
    end
  end
end
