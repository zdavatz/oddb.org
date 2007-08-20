#!/usr/bin/env ruby
# State::Admin::OrphanedPatinfo -- oddb -- 20.11.2003 -- rwaltert@ywesee.com

require 'view/admin/orphaned_patinfo'
require 'state/admin/patinfo_preview'
require 'state/admin/orphaned_patinfo_assign'

module ODDB
	module State
		module Admin
class OrphanedPatinfo < State::Admin::Global
	VIEW = View::Admin::OrphanedPatinfo
	def init
		super
		@model.meanings.compact!
	end
	def choice
		keys = [:meaning_index, :state_id]
		values = user_input(keys, keys)
		if(error?)
			self
		else
			meidx = values[:meaning_index].to_i
			languages = @model.meanings.at(meidx)
			lang = PointerHash.new(languages, @model.pointer)
			State::Admin::OrphanedPatinfoAssign.new(@session, lang)
		end
	end
	def delete_orphaned_patinfo
		@session.app.delete(@model.pointer)
		orphaned_patinfos
	end
	def preview 
		keys = [:index, :language_select]
		values = user_input(keys, keys)
		if(error?)
			self
		else
			idx = values[:index].to_i
			lang = values[:language_select]
			languages = @model.meanings.at(idx)
			State::Admin::PatinfoPreview.new(@session, languages[lang])
		end
	end
end
		end
	end
end
