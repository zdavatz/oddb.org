#!/usr/bin/env ruby

# ODDB::View::Drugs::Patinfo -- oddb.org -- 17.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::Patinfo -- oddb.org -- 11.11.2003 -- rwaltert@ywesee.com

require "view/drugs/privatetemplate"
require "view/chapter"
require "view/printtemplate"
require "view/drugs/change_logs"
require "model/patinfo"

module ODDB
  module View
    module Drugs
      def self.get_args(model, session)
        reg = (m = /reg\/(\d+)/.match(session.request_path)) ? m[1] : nil
        seq = (m = /seq\/(\d+)/.match(session.request_path)) ? m[1] : nil
        ikscd = (m = /pack\/(\d+)/.match(session.request_path)) ? m[1] : nil
        if ikscd
          return [:reg, reg, :seq, seq, :pack, ikscd]
        elsif seq
          package = session.app.registration(reg).sequence(seq).packages.values.first
          return [:reg, reg, :seq, seq, :pack, package.ikscd]
        elsif reg
          package = session.app.registration(reg).packages.first
          return [:reg, reg, :seq, package.seqnr, :pack, package.ikscd]
        end
        args = if model.sequences.first
          [:reg, model.sequences.first.registration.iksnr]
        elsif session && (m = /reg\/(\d+)/.match(session.request_path))
          [:reg, m[1]]
        else
          []
        end
        if session && (m2 = /seq\/(\d+)/.match(session.request_path))
          args += [:seq, m2[1]]
        elsif model.sequences.first
          args += [:seq, model.sequences.first.seqnr]
        end
        if session && (m3 = /pack\/(\d+)/.match(session.request_path))
          args += [:pack, m3[1]]
        end
        args
      end

      class Patinfo2001; end

      class PiChapterChooserLink < HtmlGrid::Link
        def init
          @document = @model.send(@session.language)
          @value ||= @lookandfeel.lookup("pi_" << @name.to_s)
          @attributes["title"] = if @document.respond_to?(@name) \
            && (@document.send(@name).is_a? Text::Chapter)
            chapter = @document.send(@name)
            title = chapter.heading
            if title.empty? && (section = chapter.sections.first)
              section.subheading
            else
              title
            end
          else
            @lookandfeel.lookup(@name)
          end
          args = Drugs.get_args(model, @session)
          args += [:chapter, @name]
          unless @session.user_input(:chapter) == @name.to_s
            self.href = if @model.pointer.skeleton == [:create]
              @lookandfeel.event_url(:self, {chapter: @name})
            else
              @lookandfeel._event_url(:patinfo, args)
            end
          end
        end
      end

      class PiChapterChooser < HtmlGrid::Composite
        include View::Print
        XWIDTH = 8
        COMPONENTS = {
          [0, 0] => :full_text
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0, 2] => "chapter-tab",
          [2, 0] => "chapter-tab bold",
          [XWIDTH - 1, 0] => "chapter-tab bold"
        }
        def init
          xwidth = self.class::XWIDTH
          next_offset = 1
          @css_map = {[0, 0, 2] => "chapter-tab"}
          @component_css_map = {
            [0, 0, 2] => "chapter-tab",
            [1, 0]	=> "chapter-tab"
          }
          unless @model.pointer.skeleton == [:create]
            document = @model.send(@session.language)
            if !document.empty? && document.change_log.size > 0
              components.store([next_offset, 0], :change_log)
              @css_map.store([next_offset, 0], "chapter-tab")
              next_offset += 1
            end
            if @session.state.allowed?
              components.store([next_offset, 0], :print_edit)
            else
              components.store([next_offset, 0], :print)
            end
            @component_css_map.store([next_offset, 0], "chapter-tab bold")
            @css_map.store([next_offset, 0], "chapter-tab bold")
            next_offset += 1
            @components.store([next_offset, 0], "&nbsp;")
            colspan_map.store([next_offset, 0], XWIDTH - next_offset)
            @css_map.store([next_offset, 0], "chapter-tab bold")
          end
          names = display_names(document)
          xx = 0
          yy = 0
          xoffset = xwidth
          pos = [0, 0]
          names.each { |name|
            next unless document.send(name)
            next if (name == :amzv) or (name == :name)
            if (xx % xwidth) == 0
              yy += 1
              xoffset -= xwidth
            end
            pos = [xx + xoffset, yy]
            components.store(pos, name)
            css_map.store(pos, "chapter-tab")
            component_css_map.store(pos, "chapter-tab")
            symbol_map.store(name, View::Drugs::PiChapterChooserLink)
            xx += 1
          }
          colspan_map.store(pos, xwidth - pos.at(0))
          # Instead of using a larger colspan we add a non breaking space in the next cell and enlarge it to the right
          # This fixes a display problem with iOS, where the font size of the photo was too large
          colspan_map.delete(pos)
          new_pos = pos.clone
          new_pos[0] += 1
          css_map.store(new_pos, "chapter-tab")
          component_css_map.store(new_pos, "chapter-tab")
          @components.store(new_pos, "&nbsp;")
          colspan_map.store(new_pos, xwidth - new_pos.at(0))
          super
        end

        def change_log(model, session = @session, key = :change_log)
          if @model.description(@session.language).is_a?(ODDB::PatinfoDocument) &&
              @model.description(@session.language).change_log.size > 0
            link = HtmlGrid::Link.new(key, model, session, self)
            link.set_attribute("title", @lookandfeel.lookup(:change_log))
            args = Drugs.get_args(model, @session)
            args += [:diff]
            link.href = @lookandfeel._event_url([:show, :patinfo, args[1], args[3], args[5], :diff])
            link
          end
        end

        def display_names(document)
          if document&.empty?
            []
          else
            document.chapter_names
          end
        end

        def full_text(model, session)
          if @model.pointer.skeleton == [:create]
            @lookandfeel.lookup(:patinfo_all)
          else
            link = HtmlGrid::Link.new(:patinfo_all, model, session, self)
            link.set_attribute("title", @lookandfeel.lookup(:patinfo_all_title))
            unless @session.user_input(:chapter).nil?
              args = Drugs.get_args(model, @session)
              link.href = @lookandfeel._event_url(:patinfo, args)
            end
            link
          end
        end

        def print(model, session = @session, key = :print)
          if model.send(@session.language).is_a?(ODDB::PatinfoDocument)
            link = HtmlGrid::Link.new(key, model, session, self)
            link.set_attribute("title", @lookandfeel.lookup(:print_title))
            link.set_attribute("target", "_blank")
            args = Drugs.get_args(model, @session)
            args += [:patinfo, nil]
            link.href = @lookandfeel._event_url(:print, args)
            link
          end
        end
      end

      class PatinfoInnerComposite < HtmlGrid::DivComposite
        COMPONENTS = {}
        DEFAULT_CLASS = View::Chapter
        def init
          unless @model&.empty?
            @model.chapter_names.each_with_index { |name, idx|
              if @model.respond_to?(name) &&
                  (chapter = @model.send(name)) && !chapter.empty?
                components.store([0, idx], name)
              end
            }
          end
          super
        end
      end

      class PatinfoPreviewComposite < HtmlGrid::Composite
        COLSPAN_MAP = {
          [0, 1] => 2
        }
        COMPONENTS = {
          [0, 0] => :patinfo_name,
          [1, 0] => :company,
          [0, 1] => View::Drugs::PatinfoInnerComposite
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0] => "th",
          [1, 0] => "th right"
        }
        DEFAULT_CLASS = HtmlGrid::Value
        def patinfo_name(model, session)
          @lookandfeel.lookup(:patinfo_name, model.name) unless model&.empty?
        end
      end

      class PatinfoComposite < View::Drugs::PatinfoPreviewComposite
        CHOOSER_CLASS = View::Drugs::PiChapterChooser
        COMPONENTS = {
          [0, 0] => :patinfo_name,
          [1, 0] => :company_name,
          [0, 1] => :chapter_chooser,
          [0, 2] => :document
        }
        COLSPAN_MAP = {
          [0, 1] => 2,
          [0, 2] => 2
        }
        CSS_MAP = {
          [0, 0] => "th",
          [1, 0] => "th right",
          [0, 2] => "list article"
        }
        def chapter_chooser(model, session = @session)
          if (klass = self.class.const_get(:CHOOSER_CLASS))
            klass.new(model, session, self)
          end
        end

        def chapter_view(chapter, document)
          View::Chapter.new(chapter, document, @session, self)
        end

        def document(model, session)
          document = model.send(session.language)
          chapter = @session.user_input(:chapter)
          if !chapter.nil?
            chapter_view(chapter, document)
          else
            View::Drugs::PatinfoInnerComposite.new(document, session, self)
          end
        end

        def patinfo_name(model, session)
          model = model.send(@session.language)
          super
        end

        def javascripts(context)
          scripts = ""
          (@additional_javascripts || []).each do |script|
            args = {
              "type" => "text/javascript",
              "language" => "JavaScript",
              "async" => true
            }
            scripts << context.script(args) { script }
          end
          scripts
        end

        def to_html(context)
          javascripts(context).to_s << super
        end
      end

      class PatinfoPrintInnerComposite < PatinfoInnerComposite
        DEFAULT_CLASS = View::PrintChapter
      end

      class PatinfoPrintComposite < HtmlGrid::DivComposite
        include View::PrintComposite
        INNER_COMPOSITE = View::Drugs::PatinfoInnerComposite
        PRINT_TYPE = :print_type_patinfo
        CSS_MAP = {
          0 => "print-type",
          1 => "print big",
          2 => "list right"
        }
      end

      class Patinfo < PrivateTemplate
        CONTENT = View::Drugs::PatinfoComposite
        SNAPBACK_EVENT = :result
      end

      class PatinfoPreview < PrivateTemplate
        CONTENT = View::Drugs::PatinfoPreviewComposite
      end

      class PatinfoPrint < View::PrintTemplate
        CONTENT = View::Drugs::PatinfoPrintComposite
      end
    end
  end
end
