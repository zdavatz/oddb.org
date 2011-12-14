#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::CommercialForm -- oddb.org -- 27.07.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::CommercialForm -- oddb.org -- 24.11.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/commercial_form'

module ODDB
  module State
    module Admin
class CommercialForm < Global
  VIEW = ODDB::View::Admin::CommercialForm
  def delete
    if(@model.empty?)
      @session.app.delete(@model.pointer)
			commercial_forms
    else
      State::Admin::MergeCommercialForm.new(@session, @model)
    end
  end
  def duplicate?(string)
    !(string.to_s.empty? \
      || [nil, @model].include?(ODDB::CommercialForm.find_by_name(string)))
  end
  def update
    languages = @session.lookandfeel.languages
    input = languages.inject({}) { |inj, key|
      sym = key.intern
      value = @session.user_input(sym)
      if(duplicate?(value))
        @errors.store(sym, 
          create_error('e_duplicate_commercial_form', key, value))
      end
      inj.store(key, value)
      inj
    }
    if(syn_list = @session.user_input(:synonym_list))
      syns = syn_list.split(/\s*,\s*/u)
      syns.each { |syn| 
        if(duplicate?(syn))
          @errors.store(:synonym_list, 
            create_error('e_duplicate_commercial_form', 
              :synonym_list, syn))
        end
      }
      input.store(:synonyms, syns)
    end
    unless error?
      @model = @session.app.update(@model.pointer, input, unique_email)
    end
    self
  end
end
    end
  end
end
