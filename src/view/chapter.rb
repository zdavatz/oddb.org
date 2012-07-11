#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Chapter -- oddb.org -- 11.07.2012 -- yasaka@ywesee.com
# ODDB::View::Chapter -- oddb.org -- 14.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Chapter -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/labeltext'
require 'htmlgrid/textarea'
require 'htmlgrid/dojotoolkit'
require 'htmlgrid/errormessage'
require 'view/form'
require 'model/fachinfo'

module ODDB
  module View
    module ChapterMethods
      PRE_STYLE = 'font-family: Courier New, monospace; font-size: 12px;'
      PAR_STYLE = 'padding-bottom: 4px; white-space: normal; line-height: 1.4em;'
      SUB_STYLE = 'font-style: italic' 
      TABLE_STYLE = 'border-collapse: collapse;'
      TD_STYLE = 'padding: 4px; vertical-align: top;'
      def formats(context, paragraph)
        res = ''
        if paragraph.is_a? String
          return context.span({ 'style' => self.class::PAR_STYLE }) { paragraph }
        end
        txt = u paragraph.text
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
            res << str.force_encoding('utf-8')
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
            begin
              res.gsub("\n", context.br.force_encoding('utf-8')) 
            rescue ArgumentError
              br = context.br.force_encoding('utf-8')
              res = res.encode("UTF-16BE", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
              res.gsub("\n", br) 
            end
          } << context.br.force_encoding('utf-8')

        end
      end
      def heading(context)
        if @value.respond_to?(:heading)
          context.h3 { self.escape(@value.heading) }
        end
      end
      def links(context, links)
        context.ul {
          fi_links = ''
          links.each do |fi_link|
            next if fi_link.url.empty? or fi_link.url =~ /^http:\/\/$/
            if fi_link.name.empty?
              fi_link.name = fi_link.url
            end
            link_attr = {:href => self.escape(fi_link.url), :target => '_blank'}
            fi_links << context.li {
              context.a(link_attr) {
                self.escape(fi_link.name)
              }
            }
          end
          fi_links
        } << context.br
      end
      def sections(context, sections)
        section_attr = { 'style' => @lookandfeel.section_style }
        subhead_attr = { 'style' => self.class::SUB_STYLE }
        sections.collect { |section|
          context.p(section_attr) { 
            head = context.span(subhead_attr) {
              self.escape(section.subheading) }
            begin
              /\n\s*$/u.match(section.subheading.force_encoding('utf-8'))
            rescue
              section.subheading = section.subheading.encode("UTF-16BE", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
            end
            if(/\n\s*$/u.match(section.subheading))
              head << context.br
            elsif(!section.subheading.strip.empty?)
              head << "&nbsp;"
            end
            head.force_encoding('utf-8')
            head << paragraphs(context, section.paragraphs)
          } 
        }.join
      end
      def paragraphs(context, paragraphs)
        attr = { 'style' => self.class::PAR_STYLE }
        paragraphs.collect { |paragraph|
          if(paragraph.is_a? Text::ImageLink)
            context.p(attr) { context.img(paragraph.attributes) }
          elsif(paragraph.is_a? Text::Table)
            table(context, paragraph)
          else
            formats(context, paragraph)
          end
        }.join
      end
      def table(context, table)
        context.table('class' => "chapter") {
          table.rows.collect { |row|
            context.tr {
              row.collect { |cell|
                if cell.is_a? Text::MultiCell
                  context.td('colspan' => cell.col_span) {
                    paragraphs(context, cell.contents)
                  }
                else
                  context.td('colspan' => cell.col_span) {
                    formats(context, cell)
                  }
                end
              }.join
            }
          }.join
        }
      end
    end
    class Chapter < HtmlGrid::Value
      include ChapterMethods
      def to_html(context)
        html = ''
        if @value
          if(@value.respond_to?(:heading) and !@value.heading.empty?)
            html << heading(context)
          end
          if @value.respond_to?(:sections)
            html << sections(context, @value.sections)
          end
          if @value.respond_to?(:links)
            html << links(context, @value.links)
          end
          if(hl = @session.user_input(:highlight))
            html.gsub!(hl, "<span class='highlight'>%s</span>" % hl)
          end
        end
        html
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
          'data-dojo-type' => 'dijit.Editor',
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
        [0,1,1]=>  :edit_chapter,
        [1,2]  =>  :submit,
      }
      LABELS = true
      LEGACY_INTERFACE = false
      SYMBOL_MAP = { }
      CSS_CLASS = 'composite tundra'
      CSS_MAP = {
        [0,0]  =>  'list',
        [0,1]  =>  'list top',
      }
      COMPONENT_CSS_MAP = {
        #[0,0,1]  =>  'standard',
      }
      def initialize(name, *args)
        @name = name
        super(*args)
      end
      def edit_chapter(model)
        editor = ChapterEditor.new(:html_chapter, model, @session, self)
        editor.value = model.send(@name)
        editor.label = true
        editor.css_id = "html-chapter"
        self.onsubmit = "this.html_chapter.value = dijit.byId('html-chapter').getValue();"
        editor
      end
      def heading(model)
        HtmlGrid::InputText.new(:heading, model.send(@name), 
          @session, self)
      end
      def hidden_fields(context)
        chapter = {'name' => 'chapter', 'value' => @name}
        html = {'name' => 'html_chapter', 'value' => ''}
        super << context.hidden(chapter) << context.hidden(html)
      end
    end
    class Links < HtmlGrid::List
      COMPONENTS = {
        [0,0] => :delete,
        [1,0] => :link_name,
        [2,0] => :link_url,
        [3,0] => :link_created,
      }
      OMIT_HEADER = true
      EMPTY_LIST = true
      CSS_CLASS = 'composite tundra'
      CSS_MAP = {
        [0,0] => 'list',
        [1,0] => 'list',
        [2,0] => 'list',
        [3,0] => 'list',
      }
      CSS_ID = 'links'
      SORT_DEFAULT = nil
      BACKGROUND_SUFFIX = ''
      DEFAULT_CLASS = HtmlGrid::InputText
      def compose_list(model, offset)
        if(@model.length < 2 or 
          (@model.last.name != '' and @model.last.url != ''))
          @grid.add(add(@model, @session), *offset)
          @grid.add_style('list', *offset)
        end
        x, y, = offset
        x += 1
        @grid.add('Link Name', x, y)
        @grid.add_style('list', x, y)
        x += 1
        @grid.add('Link', x, y)
        @grid.add_style('list', x, y)
        offset = resolve_offset(offset, self::class::OFFSET_STEP)
        offset = super(model, offset)
        offset
      end
      def add(model, session)
        link = HtmlGrid::Link.new(:plus, model, session, self)
        link.set_attribute('title', @lookandfeel.lookup(:create_part))
        link.css_class = 'create square'
        url = @session.lookandfeel.event_url(:ajax_create_fachinfo_link, [])
        link.onclick = "replace_element('#{css_id}', '#{url}');"
        link
      end
      def delete(model, session)
        link = HtmlGrid::Link.new(:minus, model, session, self)
        link.set_attribute('title', @lookandfeel.lookup(:delete))
        link.css_class = 'delete square'
        args = [:fachinfo_index, @list_index]
        url = @session.lookandfeel.event_url(:ajax_delete_fachinfo_link, args)
        link.onclick = "replace_element('#{css_id}', '#{url}');"
        link
      end
      def link_name(model, session)
        input = HtmlGrid::Input.new("fi_link_name[#{@list_index}]", model, session, self)
        input.set_attribute('title', 'Link Name')
        input.set_attribute('style', 'width:300px;')
        input.value = model.send(:name) if model
        input
      end
      def link_url(model, session)
        input = HtmlGrid::Input.new("fi_link_url[#{@list_index}]", model, session, self)
        input.set_attribute('title', 'Link')
        input.set_attribute('style', 'width:600px;')
        if model and !model.send(:url).nil?
          input.value = model.send(:url)
        else
          input.value = 'http://'
        end
        input
      end
      def link_created(model, session)
        input = HtmlGrid::Input.new("fi_link_created[#{@list_index}]", model, session, self)
        input.set_attribute('type', 'hidden')
          input.value = model.send(:created)
        input
      end
    end
    class Path < HtmlGrid::Composite
      COMPONENTS = {
        [0,0] => 'Short URL',
        [1,0] => 'Original URL',
        [0,1] => :shorten_path,
        [1,1] => :origin_path,
        [2,1] => :path_created,
      }
      CSS_CLASS = 'composite tundra'
      CSS_MAP = {
        [0,0] => 'list',
        [1,0] => 'list',
        [2,0] => 'list',
        [0,1] => 'list',
        [1,1] => 'list',
        [2,1] => 'list',
      }
      CSS_ID = 'paths'
      DEFAULT_CLASS = HtmlGrid::InputText
      def shorten_path(model, session)
        input = HtmlGrid::Input.new("fi_path_shorten_path", model, session, self)
        input.set_attribute('title', 'Path')
        input.set_attribute('style', 'width:300px;')
        input.value = model.send(:shorten_path)
        input
      end
      def origin_path(model, session)
        text = HtmlGrid::Value.new('origin_path', model, session)
        text.value = ' => ' + model.send(:origin_path)
        input = HtmlGrid::Input.new("fi_path_origin_path", model, session, self)
        input.set_attribute('type', 'hidden')
        input.value = model.send(:origin_path)
        [text, input]
      end
      def path_created(model, session)
        input = HtmlGrid::Input.new("fi_path_created", model, session, self)
        input.set_attribute('type', 'hidden')
        input.value = model.send(:created)
        input
      end
    end
    class EditLinkForm < Form
      LEGACY_INTERFACE = false
      COMPONENTS = {
        [0,0] => Links,
        [0,1] => :submit,
      }
      CSS_MAP = {
        [0,0] =>'list',
        [0,1] =>'list',
      }
      def initialize(model, session, container)
        if model.empty?
          model << FachinfoLink.new
        end
        super model, session, container
      end
      def hidden_fields(context)
        chapter = {'name' => 'chapter', 'value' => 'links'}
        super << context.hidden(chapter)
      end
    end
    class EditPathForm < Form
	    include HtmlGrid::ErrorMessage
      LEGACY_INTERFACE = false
      COMPONENTS = {
        [0,0] => Path,
        [0,1] => :submit,
      }
      CSS_MAP = {
        [0,0] =>'list',
        [0,1] =>'list',
      }
      def initialize(model, session, container)
        super model, session, container
      end
      def init
        super
        error_message
      end
      def hidden_fields(context)
        chapter = {'name' => 'chapter', 'value' => 'shorten_path'}
        super << context.hidden(chapter)
      end
    end
  end
end
