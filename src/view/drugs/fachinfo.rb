#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Fachinfo -- oddb.org -- 27.03.2011 -- yasaka@ywesee.com
# ODDB::View::Drugs::Fachinfo -- oddb.org -- 25.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::Fachinfo -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

require 'flickraw'
require 'thread'
require 'view/drugs/privatetemplate'
require 'view/chapter'
require 'view/printtemplate'
require 'view/additional_information'
require 'view/changelog'

module ODDB
	module View
		module Drugs
class Fachinfo2001; end
class FiChapterChooserLink < HtmlGrid::Link
	def init
		@document = @model.send(@session.language)
		if(@document.respond_to?(:amzv))
			@value = @lookandfeel.lookup("fi_#{@name.to_s}_amzv")
		end
		@value ||= @lookandfeel.lookup("fi_" << @name.to_s)
		@attributes['title'] = if(@document.respond_to?(@name) \
			&& (chapter = @document.send(@name)))
			title = chapter.heading
			if(title.empty? && (section = chapter.sections.first))
				section.subheading
			else
				title
			end
		else
			@lookandfeel.lookup(@name)
		end
		args = [
			:reg, @model.registrations.first.iksnr,
			:chapter, @name,
		]
		unless(@session.user_input(:chapter) == @name.to_s)
			if(@model.pointer.skeleton == [:create])
				self.href = @lookandfeel.event_url(:self, {:chapter => @name})
			else
				self.href = @lookandfeel._event_url(:fachinfo, args)
			end
		end
	end
end
class FiChapterChooser < HtmlGrid::Composite
	include View::AdditionalInformation
	include View::Print
	XWIDTH = 8
	COLSPAN_MAP = {
		[2,0]	=>	XWIDTH - 3,
	}
	COMPONENTS = {
		[0,0]	=>	:full_text,
		[1,0]	=>	:ddd,
		#[2,0]	=>	:print,
	}
	COMPONENT_CSS_MAP = {
		[0,0,2]	=>	'chapter-tab',
		[2,0]		=>	'chapter-tab bold',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'chapter-tab',
		[2,0]		=>	'chapter-tab bold',
		[XWIDTH-1,0]		=>	'chapter-tab bold',
	}
	def init
		xwidth = self::class::XWIDTH
		unless(@model.pointer.skeleton == [:create])
			if(@session.state.allowed?)
				components.store([2,0], :print_edit)
				components.store([xwidth-1,0], :changelog)
			else
				components.store([2,0], :print)
			end
		end
		document = @model.send(@session.language)
		names = display_names(document)
		xx = 0
		yy = 0
		xoffset = xwidth
		pos = [0,0]
		names.each { |name|
			next if(name == :amzv)
			if((xx % xwidth) == 0)
				yy += 1
				xoffset -= xwidth
			end
			pos = [xx + xoffset, yy]
			components.store(pos, name)
			css_map.store(pos, 'chapter-tab')
			component_css_map.store(pos, 'chapter-tab')
			symbol_map.store(name, View::Drugs::FiChapterChooserLink)
			xx += 1
		}
		colspan_map.store(pos, xwidth - pos.at(0))
		super
	end
	def changelog(model, session)
		View::Drugs::FiChapterChooserLink.new(:changelog, 
			model, session, self)
	end
	def ddd(model, session)
		if(atc = model.atc_class)			
			View::Drugs::FiChapterChooserLink.new(:ddd, 
				model, session, self)
		end
	end
	def display_names(document)
		document.chapter_names
	end
	def full_text(model, session)
		if(@model.pointer.skeleton == [:create])
			@lookandfeel.lookup(:fachinfo_all)
		else
			link = HtmlGrid::Link.new(:fachinfo_all, model, session, self)
			link.set_attribute('title', @lookandfeel.lookup(:fachinfo_all_title))
			unless(@session.user_input(:chapter).nil?)
				link.href = @lookandfeel._event_url(:fachinfo, {:reg => model.registrations.first.iksnr})
			end
			link
		end
	end
  def print(model, session=@session, key=:print)
    link = HtmlGrid::Link.new(key, model, session, self)
    link.set_attribute('title', @lookandfeel.lookup(:print_title))
    args = {
      :fachinfo  => model.registrations.first.iksnr,
    }
    link.href = @lookandfeel._event_url(:print, args)
    link
  end
end
class FachinfoInnerComposite < HtmlGrid::DivComposite
	COMPONENTS = {}
	DEFAULT_CLASS = View::Chapter
  CSS_STYLE_MAP = {
    0 => 'float:right;',
  }
	def init
		@model.chapter_names.each_with_index { |name, idx|
			components.store([0,idx], name)
		}
		super
    thumbs = []
    photos = _load_photos
    photos.each_with_index { |photo, idx|
      image_div = _image_div(photo)
      text_link = _text_link(photo)
      div = HtmlGrid::Div.new(model, @session, self)
      div.value = image_div.to_html(@session.cgi) +
                  text_link.to_html(@session.cgi)
      div.set_attribute('class', 'thumbnail')
      thumbs << div
    }
    @grid.unshift(thumbs)
	end
  private
  def _image_div(photo)
    image = HtmlGrid::Image.new(photo[:name], @model, @session, self)
    image.set_attribute('alt', photo[:name])
    image.set_attribute('src', photo[:src])
    link = HtmlGrid::Link.new(photo[:name], @model, @session, self)
    link.href = photo[:url]
    link.value = image
    div = HtmlGrid::Div.new(model, @session, self)
    div.value = link
    div
  end
  def _text_link(photo)
    link = HtmlGrid::Link.new(photo[:name], @model, @session, self)
    link.href = photo[:url]
    link.value = photo[:name]
    link
  end
  def _load_photos
    # Flickr Image Size
    # "Thumbnail" :  40 x 100
    # "Small"     :  97 x 240
    # "Small320"  : 240 X 320
    photos = []
    config = ODDB.config
    if config.flickr_api_key.empty? or
       config.flickr_shared_secret.empty?
      return photos
    end
    FlickRaw.api_key = config.flickr_api_key
    FlickRaw.shared_secret = config.flickr_shared_secret
    flickr_form = /^http(?:s*):\/\/(?:.*)\.flickr\.com\/photos\/(?:.[^\/]*)\/([0-9]*)(?:\/*)/
    registrations = @container.model.registrations
    threads = {}
    mutex = Mutex.new
    registrations.each do |reg|
      reg.packages.each do |pack|
        if pack.photo_link =~ flickr_form
          id = $1
          unless threads.keys.include?(id)
            threads[id] = Thread.new {
              begin
                sizes = flickr.photos.getSizes :photo_id => id
                sizes.each do |size|
                  if size.label == "Small"
                    photo = {
                      :name => pack.name_base,
                      :src  => size.source,
                      :url  => pack.photo_link
                    }
                    mutex.synchronize do
                      photos << photo
                    end
                    break
                  end
              end
              rescue FlickRaw::FailedResponse => e
              end
            }
          end
        end
      end
    end
    threads.values.each do |thread|
      thread.join
    end
    photos.sort_by do |photo|
      photo[:name]
    end
  end
end
=begin
class Fachinfo2001InnerComposite < FachinfoInnerComposite
	CHAPTERS = [
		:amzv,
		:composition,
		:galenic_form,
		:indications,
		:usage,
		:contra_indications,
		:restrictions,
		:interactions,
		:pregnancy,
		:driving_ability,
		:unwanted_effects,
		:overdose,
		:effects,
		:kinetic,
		:preclinic,
		:other_advice,
		:iksnrs,
		:registration_owner,
		:date,
	]
end
=end
class FachinfoPreviewComposite < HtmlGrid::Composite
	COLSPAN_MAP = {
		[0,1]	=> 2,
	}
	COMPONENTS = {
		[0,0]	=>	:fachinfo_name,
		[1,0]	=>	:company,
		[0,1] =>	View::Drugs::FachinfoInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th right',
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	def fachinfo_name(model, session)
		@lookandfeel.lookup(:fachinfo_name, model.name)
	end
end
class FachinfoPrintInnerComposite < FachinfoInnerComposite
	DEFAULT_CLASS = View::PrintChapter
end
class FachinfoPrintComposite < HtmlGrid::DivComposite #View::Drugs::FachinfoPreviewComposite
	include PrintComposite
	INNER_COMPOSITE = View::Drugs::FachinfoInnerComposite
	PRINT_TYPE = :print_type_fachinfo
	CSS_MAP = {
		0	=> 'print-type',
		1	=> 'print big',
		2	=> 'list right',
	}
end
class FachinfoComposite < View::Drugs::FachinfoPreviewComposite
	CHOOSER_CLASS = View::Drugs::FiChapterChooser
	COMPONENTS = {
		[0,0]	=>	:fachinfo_name,
		[1,0]	=>	:company_name,
		[0,1]	=>	:chapter_chooser,
		[0,2] =>  :document,
	}
	COLSPAN_MAP = {
		[0,1]	=>	2,
		[0,2]	=>	2,
	}
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th right',
		[0,2]	=> 'list',
	}	
	def chapter_chooser(model, session)
		if(klass = self.class.const_get(:CHOOSER_CLASS))
			klass.new(model, session, self)
		end
	end
	def chapter_view(chapter, document)
		View::Chapter.new(chapter, document, @session, self)
	end
	def document(model, session)
		document = model.send(session.language)
		chapter = @session.user_input(:chapter)
		if(chapter == 'ddd')
			View::Drugs::DDDTree.new(model.atc_class, session, self)
		elsif(chapter == 'changelog')
		  View::ChangeLog.new(model.change_log, session, self)
		elsif(chapter != nil)
			chapter_view(chapter, document)
		else
			View::Drugs::FachinfoInnerComposite.new(document, session, self)
		end
	end
	def fachinfo_name(model, session)
		model = model.send(@session.language)
		super(model, session)
	end
end
class Fachinfo < PrivateTemplate
	CONTENT = View::Drugs::FachinfoComposite
	SNAPBACK_EVENT = :result
end
class FachinfoPreview < PrivateTemplate
	CONTENT = View::Drugs::FachinfoPreviewComposite
end
class FachinfoPrint < View::PrintTemplate
	CONTENT = View::Drugs::FachinfoPrintComposite
end
class CompanyFachinfoPrintComposite < FachinfoPrintComposite
	INNER_COMPOSITE = View::Drugs::FachinfoPrintInnerComposite
end
class CompanyFachinfoPrint < FachinfoPrint
	CONTENT = View::Drugs::CompanyFachinfoPrintComposite
end
class EditFiChapterChooser < FiChapterChooser
	def display_names(document)
		document.chapters
	end
end
class RootFachinfoComposite < View::Drugs::FachinfoComposite
	CHOOSER_CLASS = EditFiChapterChooser
	def init
		unless(@model.company.invoiceable?)
			components.update({
				[0,2] => :invoiceability,
				[0,3] => :document,
			})
			css_map.store([0,3], 'list')
			colspan_map.store([0,3], 2)
		end
		super
	end
	def chapter_view(chapter, document)
		if(@model.company.invoiceable?)
			View::EditChapterForm.new(chapter, document, @session, self)
		elsif(@model.pointer.skeleton == [:create])
			# don't show anything
		else
			super
		end
	end
	def invoiceability(model, session=@session)
		PointerLink.new(:e_fi_not_invoiceable, model.company, @session, self)
	end
end
class RootFachinfo < PrivateTemplate
	CONTENT = View::Drugs::RootFachinfoComposite
	SNAPBACK_EVENT = :result
	DOJO_REQUIRE = [ 'dijit.Editor' ]#, 'ywesee.widget.SymbolPalette' ]
  #JAVASCRIPTS = ['dojo/Editor']
	DOJO_PARSE_WIDGETS = true
end
		end
	end
end
