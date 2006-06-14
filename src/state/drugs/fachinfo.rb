#!/usr/bin/env ruby
# State::Drugs::Fachinfo -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/fachinfo'
require 'delegate'
require 'model/fachinfo'
require 'ext/chapterparse/src/parser'
require 'ext/chapterparse/src/writer'

module ODDB
	module State
		module Drugs
class Fachinfo < State::Drugs::Global
	class FachinfoWrapper < SimpleDelegator
		attr_accessor :pointer_descr
	end
	VIEW = View::Drugs::Fachinfo
	def init
		@fachinfo = @model
		@model = FachinfoWrapper.new(@fachinfo)
		descr = @session.lookandfeel.lookup(:fachinfo_descr, 
			@model.name_base)
		@model.pointer_descr = descr
	end
	def allowed?
		@session.user.allowed?(@fachinfo.registrations.first)
	end
end
class FachinfoPreview < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPreview
	VOLATILE = true
end
class FachinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPrint
	VOLATILE = true
	def init
		if(allowed?)
			@default_view = View::Drugs::CompanyFachinfoPrint
		end
		super
	end
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
			ODBA.transaction {
				lang = @session.language	
				email = unique_email
				if(@fachinfo.is_a?(Persistence::CreateItem))
					registration = @fachinfo.registrations.first
					doc = @fachinfo.send(lang)
					@fachinfo = @session.app.update(@fachinfo.pointer, {lang => doc}, email)
					@model = FachinfoWrapper.new(@fachinfo)
					@model.add_change_log_item(email, 'created', lang)
					@session.app.update(registration.pointer, 
															{:fachinfo => @model.pointer}, email)
				end
				doc = @model.descriptions.fetch(lang.to_s) {
					doc = @model.send(lang).class.new()
					doc.name = @model.name_base
					@session.app.update(@model.pointer, {lang => doc}, email)
					doc
				}
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
				@model.add_change_log_item(email, name, lang)
				@session.app.update(pointer, args, email)
				@session.app.update(doc_pointer, {}, email)
				@session.app.update(@model.pointer, {}, email)
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
