#!/usr/bin/env ruby
# View::Chapter -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/labeltext'
require 'htmlgrid/textarea'
require 'htmlgrid/dojotoolkit'
require 'view/form'

module ODDB
  module View
    module ChapterMethods
      PRE_STYLE = 'font-family: Courier New, monospace; font-size: 12px;'
      PAR_STYLE = 'padding-bottom: 4px; white-space: normal; line-height: 1.4em;'
      SUB_STYLE = 'font-style: italic' 
      def formats(context, paragraph)
        res = ''
        txt = paragraph.text
        paragraph.formats.each { |format|
          tag = :span
          style = [] 
          attrs = {}
          if(format.italic?)
            style << 'font-style:italic;'
          end
          if(format.bold?)
            style << 'font-weight:bold;'
          end
          if(format.superscript?)
            tag = :sup
            style << 'line-height: 0em;'
            if(paragraph.preformatted?)
              style << 'font-size: 12px;'
            end
          end
          if(format.subscript?)
            tag = :sub
            style << 'line-height: 0em'
          end
          escape_method = (format.symbol?) ? :escape_symbols : :escape
          str = self.send(escape_method, txt[format.range]) 
          if(style.empty? && tag == :span)
            res << str
          else
            attrs.store('style', style.join(' '))
            res << context.send(tag, attrs) { 
              str
            }
          end
        }
        if(paragraph.preformatted?)
          context.pre({ 'style' => self.class::PRE_STYLE }) { res }
        else
          ## this must be an inline element, to enable starting 
          ## paragraphs on the same line as the section-subheading
          context.span({ 'style' => self.class::PAR_STYLE }) { 
            res } << context.br
        end
      end
      def heading(context)
        context.h3 { self.escape(@value.heading) }
      end
      def sections(context, sections)
        section_attr = { 'style' => @lookandfeel.section_style }
        subhead_attr = { 'style' => self.class::SUB_STYLE }
        sections.collect { |section|
          context.p(section_attr) { 
            head = context.span(subhead_attr) {
              self.escape(section.subheading) }
            if(/\n\s*$/.match(section.subheading))  
              head << context.br
            elsif(!section.subheading.strip.empty?)
              head << "&nbsp;"
            end
            head << paragraphs(context, section.paragraphs)
          } 
        }.join
      end
      def paragraphs(context, paragraphs)
        attr = { 'style' => self.class::PAR_STYLE }
        paragraphs.collect { |paragraph|
          if(paragraph.is_a? Text::ImageLink)
            context.p(attr) { context.img(paragraph.attributes) }
          else
            formats(context, paragraph)
          end
        }.join
      end
    end
    class Chapter < HtmlGrid::Value
      include ChapterMethods
      def to_html(context)
        html = ''
        unless(@value.heading.empty?)
          html << heading(context)
        end
        html << sections(context, @value.sections)
      end
    end
    class PrintChapter < Chapter
      PAR_STYLE = 'padding-bottom: 4px; white-space: normal; line-height: 1.5em'
      SEC_STYLE = 'font-size: 13px; margin-top: 4px; line-height: 1.5em'
    end
    class ChapterEditor < HtmlGrid::Textarea
      include ChapterMethods
      def init
        super
        @attributes.update({
          'dojoType'    => 'Editor2',  
          'shareToolbar'=> 'true',
          'htmlEditing' => 'false',
          'useActiveX'  => 'false',
        })
      end
      def _to_html(context, value=@value)
        if(value)
          sections(context, value.sections)
        end
      end
    end
    class EditChapterForm < Form
      COMPONENTS = {
        [0,0]  =>  :heading,
        [1,1]    =>  :toolbar,
        [0,2,1]  =>  :edit_chapter,
        [1,3]  =>  :submit,
      }
      LABELS = true
      LEGACY_INTERFACE = false
      SYMBOL_MAP = { }
      CSS_CLASS = 'composite'
      CSS_MAP = {
        [0,0]  =>  'list',
        [0,2]  =>  'list top',
      }
      COMPONENT_CSS_MAP = {
        [0,0,1]  =>  'standard',
      }
      def initialize(name, *args)
        @name = name
        super(*args)
      end
      def edit_chapter(model)
        editor = ChapterEditor.new(:html_chapter, model, @session, self)
        editor.value = model.send(@name)
        editor.label = true
        editor
      end
      def heading(model)
        HtmlGrid::InputText.new(:heading, model.send(@name), 
          @session, self)
      end
      def hidden_fields(context)
        args = {'name' => 'chapter', 'value' => @name}
        super << context.hidden(args)
      end
      def toolbar(model)
        args = {
          "templatePath"  => @lookandfeel.resource_global(:javascript, 
                               'dojo/HtmlEditorToolbar.html'),
        }
        dojo_tag("Editor2Toolbar", args)
      end
    end
  end
end
