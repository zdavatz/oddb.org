#!/usr/bin/env ruby
# State::Admin::Indication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/mergeindication'
require 'view/admin/indication'

module ODDB
	module State
		module Admin
class Indication < State::Admin::Global
	VIEW = View::Admin::Indication
	def delete
		if(@model.registrations.empty? && @model.sequences.empty?)
			@session.app.delete(@model.pointer)
			indications() # from RootState
		else
			State::Admin::MergeIndication.new(@session, @model)
		end
	end
  def duplicate?(string)
    !(string.to_s.empty? \
      || [nil, @model].include?(@session.app.indication_by_text(string)))
  end
  def update
    languages = @session.lookandfeel.languages + ['lt']
    input = languages.inject({}) { |inj, key|
      sym = key.intern
      value = @session.user_input(sym)
      if duplicate?(value)
        @errors.store(sym,
                      create_error('e_duplicate_indication', key, value))
      end
      inj.store(key, value)
      inj
    }
    if(syn_list = @session.user_input(:synonym_list))
      syns = syn_list.split(/\s*\|\s*/u)
      syns.each { |syn|
        if(duplicate?(syn))
          @errors.store(:synonym_list,
            create_error('e_duplicate_indication',
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
