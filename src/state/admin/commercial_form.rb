#!/usr/bin/env ruby
# State::Admin::CommercialForm -- oddb.org -- 24.11.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/commercial_form'

module ODDB
  module State
    module Admin
class CommercialForm < Global
  VIEW = View::Admin::CommercialForm
  def delete
    if(@model.empty?)
      @session.app.delete(@model.pointer)
      State::Admin::CommercialForms.new(@session, galenic_group)
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
          create_error('e_duplicate_galenic_form', key, value))
      end
      inj.store(key, value)
      inj
    }
    if(syn_list = @session.user_input(:synonym_list))
      syns = syn_list.split(/\s*,\s*/)
      syns.each { |syn| 
        if(duplicate?(syn))
          @errors.store(:synonym_list, 
            create_error('e_duplicate_galenic_form', 
              :synonym_list, syn))
        end
      }
      input.store(:synonyms, syns)
    end
    input.store(:galenic_group, @session.user_input(:galenic_group))
    unless error?
      @model = @session.app.update(@model.pointer, input, unique_email)
    end
    self
  end
end
    end
  end
end
