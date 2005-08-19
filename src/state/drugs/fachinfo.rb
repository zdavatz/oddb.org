#!/usr/bin/env ruby
# State::Drugs::Fachinfo -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/fachinfo'

require 'ext/chapterparse/src/parser'
require 'ext/chapterparse/src/writer'

module ODDB
	module State
		module Drugs
class Fachinfo < State::Drugs::Global
	VIEW = View::Drugs::Fachinfo
	VOLATILE = true
end
class FachinfoPreview < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPreview
	VOLATILE = true
end
class FachinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPrint
	VOLATILE = true
end
class RootFachinfo < State::Drugs::Global
	VIEW = View::Drugs::RootFachinfo
	#VOLATILE = true
	def	update
		keys = [:html_chapter, :chapter]
		input = user_input(keys, keys)
		html = input[:html_chapter]
		writer = ChapterParse::Writer.new
		formatter = HtmlFormatter.new(writer)
		parser = ChapterParse::Parser.new(formatter)
		parser.feed(html)
		lang = @session.language
		doc = @model.send(lang)
		name = input[:chapter]
		original = doc.send(name)
		pointer = @model.pointer + [lang] + [name]
		args = {
			:sections =>	writer.chapter.sections,
		}
		ODBA.transaction {
			@session.app.update(pointer, args)
			@session.app.update(@model.pointer, {})
		}
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
	def allowed?
		@session.user_equiv?(@model.registrations.first.company)
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
