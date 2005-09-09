#!/usr/bin/env ruby
# State::Drugs::Fachinfo -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/fachinfo'
require 'delegate'
require 'ext/chapterparse/src/parser'
require 'ext/chapterparse/src/writer'

module ODDB
	module State
		module Drugs
class Fachinfo < State::Drugs::Global
	class FachinfoWrapper < DelegateClass(ODDB::Fachinfo)
		attr_accessor :pointer_descr
	end
	VIEW = View::Drugs::Fachinfo
	LIMITED = true
	def init
		@model = FachinfoWrapper.new(@model)
		descr = @session.lookandfeel.lookup(:fachinfo_descr, 
			@model.name_base)
		@model.pointer_descr = descr
	end
end
class FachinfoPreview < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPreview
	VOLATILE = true
end
class FachinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPrint
	VOLATILE = true
	LIMITED = true
end
class RootFachinfo < Fachinfo
	VIEW = View::Drugs::RootFachinfo
	def	update
		mandatory = [:html_chapter, :chapter]
		keys = mandatory + [:heading]
		input = user_input(keys, mandatory)
		unless(error?)
			html = input[:html_chapter]
			writer = ChapterParse::Writer.new
			formatter = HtmlFormatter.new(writer)
			parser = ChapterParse::Parser.new(formatter)
			parser.feed(html)
			lang = @session.language	
			doc = @model.send(lang)
			email = @session.user.unique_email
			name = input[:chapter]
			unless(doc.send(name))
				doc.send("#{name}=", Text::Chapter.new)
			end
			doc_pointer = @model.pointer + [lang] 
			pointer = doc_pointer + [name]
			args = {
				:heading	=>	input[:heading],
				:sections =>	writer.chapter.sections,
			}
			ODBA.transaction {
				@model.add_change_log_item(email, name, lang)
				@session.app.update(pointer, args)
				@session.app.update(doc_pointer, {})
				@session.app.update(@model.pointer, {})
			}
		end
		self
	end	
end
class CompanyFachinfo < RootFachinfo
  VIEW = View::Drugs::RootFachinfo
	def init
		super
		unless(allowed?)
			@default_view = View::Drugs::Fachinfo
		end
	end
	def update
		if(allowed?)
			super
		end
	end
end
		end
	end
end
