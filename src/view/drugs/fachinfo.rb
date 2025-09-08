#!/usr/bin/env ruby

# ODDB::View::Drugs::Fachinfo -- oddb.org -- 27.07.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::Fachinfo -- oddb.org -- 25.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::Fachinfo -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

# require 'mathn'
require "view/drugs/privatetemplate"
require "view/chapter"
require "view/printtemplate"
require "view/additional_information"
require "view/drugs/photo"
require "view/drugs/change_logs"
require "model/shorten_path"
require "ostruct"

module ODDB
  module View
    module Drugs
      class Fachinfo2001; end

      class FiChapterChooserImage < HtmlGrid::Image
        def init
          @document = @model.send(@session.language)
          unless @session.user_input(:chapter) == @name.to_s
            unless @model.pointer.skeleton == [:create]
              lnf = @lookandfeel.lookup(@name)
              set_attribute("src", "http://" + @session.server_name + "/resources/" + lnf)
            end
          end
        end
      end

      class FiChapterChooserLink < HtmlGrid::Link
        def init
          @document = @model.send(@session.language)
          if @document.respond_to?(:amzv)
            @value = @lookandfeel.lookup("fi_#{@name}_amzv")
          end
          @value ||= @lookandfeel.lookup("fi_" << @name.to_s)
          @attributes["title"] = if @document.respond_to?(@name) \
                                    && (chapter = @document.send(@name)) \
                                    && chapter.respond_to?(:heading)
            title = chapter.heading
            if title.empty? && (section = chapter.sections.first)
              section.subheading
            else
              title
            end
          else
            @lookandfeel.lookup(@name)
          end
          args = [
            :reg, @model.registrations.first.iksnr,
            :chapter, @name
          ]
          unless @session.user_input(:chapter) == @name.to_s
            self.href = if @model.pointer.skeleton == [:create]
              @lookandfeel.event_url(:self, {chapter: @name})
            else
              @lookandfeel._event_url(:fachinfo, args)
            end
          end
        end
      end

      class FiChapterChooser < HtmlGrid::Composite
        include View::AdditionalInformation
        include View::Print
        # we calculate the components dynamically as three items are optional depending on differenct conditions
        XWIDTH = 8
        CSS_CLASS = "composite"
        def init
          xwidth = self.class::XWIDTH
          @components = {}
          @component_css_map = {[0, 0, 2] => "chapter-tab"}
          @css_map = {[0, 0, 2] => "chapter-tab"}
          @components.store([0, 0], :full_text)
          next_offset = 1
          unless @lookandfeel.disabled?(:fi_link_to_ddd)
            @components.store([next_offset, 0], :ddd)
            next_offset += 1
          end
          document = @model.send(@session.language)
          if document.change_log.size > 0
            @components.store([next_offset, 0], :change_log)
            @css_map.store([next_offset, 0], "chapter-tab")
            next_offset += 1
          end
          @components.store([next_offset, 0], :print)
          @component_css_map.store([next_offset, 0], "chapter-tab bold")
          @css_map.store([next_offset, 0], "chapter-tab bold")
          next_offset += 1
          @components.store([next_offset, 0], "&nbsp;")
          colspan_map.store([next_offset, 0], XWIDTH - next_offset)
          @component_css_map.store([next_offset, 0], "chapter-tab bold")
          @css_map.store([next_offset, 0], "chapter-tab bold")
          names = display_names(document) - [:amzv]
          pos = [0, 0]
          xx = 0
          yy = 1
          names.each { |name|
            if xx >= xwidth
              yy += 1
              xx = 0
            end
            pos = [xx, yy]
            @components.store(pos, name)
            css_map.store(pos, "chapter-tab")
            component_css_map.store(pos, "chapter-tab")
            symbol_map.store(name, View::Drugs::FiChapterChooserLink)
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
          link = HtmlGrid::Link.new(key, model, session, self)
          link.set_attribute("title", @lookandfeel.lookup(:change_log))
          link.href = @lookandfeel._event_url(:show, [:fachinfo, model.registrations.first.iksnr, :diff])
          link
        end

        def ddd(model, session)
          if model.atc_class
            View::Drugs::FiChapterChooserLink.new(:ddd, model, session, self)
          end
        end

        def display_names(document)
          names = (document ? document.chapter_names : [])
          if @container.respond_to?(:photos) && @container.photos && !@container.photos.nil?
            names << :photos
          end
          if @container.respond_to?(:links) && @container.links && !@container.links.empty?
            names << :links
          end
          names
        end

        def full_text(model, session)
          if @model.pointer.skeleton == [:create]
            @lookandfeel.lookup(:fachinfo_all)
          else
            link = HtmlGrid::Link.new(:fachinfo_all, model, session, self)
            link.set_attribute("title", @lookandfeel.lookup(:fachinfo_all_title))
            unless @session.user_input(:chapter).nil?
              link.href = @lookandfeel._event_url(:fachinfo, {reg: model.registrations.first.iksnr})
            end
            link
          end
        end

        def print(model, session = @session, key = :print)
          link = HtmlGrid::Link.new(key, model, session, self)
          link.set_attribute("title", @lookandfeel.lookup(:print_title))
          link.set_attribute("target", "_blank")
          args = {
            fachinfo: model.registrations.first.iksnr
          }
          link.href = @lookandfeel._event_url(:print, args)
          link
        end
      end

      class FachinfoInnerComposite < HtmlGrid::DivComposite
        COMPONENTS = {}
        DEFAULT_CLASS = View::Chapter
        CSS_STYLE_MAP = {}
        def init
          if @model # document
            names = @model.chapter_names
            if @container.respond_to?(:links) and !@container.links.empty?
              names << :links
            end
            names.each_with_index { |name, idx|
              components.store([0, idx], name)
            }
          end
          # insert photos into head
          if @container.respond_to?(:photos) and !@container.photos.nil?
            @css_style_map = {
              0 => "float:right;"
            }
            super
            images = []
            css_class = @model.nil? ? "small" : "thumbnail"
            @container.photos.each_with_index { |photo, idx|
              image = PackagePhotoView.new(photo, @session, self)
              image.css_class = css_class
              images << image
            }
            @grid.unshift(images)
          else
            super
          end
        end

        def links(model)
          links = @container.links if @container.respond_to?(:links)
          if links # behave as link chapter
            # FIXME refactor in state
            chapter = OpenStruct.new({
              heading: "Links",
              links: links
            })
            model = OpenStruct.new(links: chapter)
            View::Chapter.new(:links, model, @session, self)
          end
        end
      end

      class FachinfoPreviewComposite < HtmlGrid::Composite
        COLSPAN_MAP = {
          [0, 1]	=> 2
        }
        COMPONENTS = {
          [0, 0]	=>	:fachinfo_name,
          [1, 0]	=>	:company,
          [0, 1] =>	View::Drugs::FachinfoInnerComposite
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0] => "th",
          [1, 0]	=> "th right"
        }
        DEFAULT_CLASS = HtmlGrid::Value
        def fachinfo_name(model, session)
          @lookandfeel.lookup(:fachinfo_name, model.name) if model
        end
      end

      class FachinfoPrintInnerComposite < FachinfoInnerComposite
        DEFAULT_CLASS = View::PrintChapter
      end

      class FachinfoPrintComposite < HtmlGrid::DivComposite # View::Drugs::FachinfoPreviewComposite
        attr_accessor :photos, :links
        include PrintComposite
        INNER_COMPOSITE = View::Drugs::FachinfoInnerComposite
        PRINT_TYPE = :print_type_fachinfo
        CSS_MAP = {
          0	=> "print-type",
          1	=> "print big",
          2	=> "list right"
        }
        def init
          @document = @model.send(@session.language)
          @links = @model.send(:links)
          @photos = @model.send(:photos, "thumbnail")
          super
        end
      end

      class FachinfoComposite < View::Drugs::FachinfoPreviewComposite
        attr_accessor :document, :photos, :links
        CHOOSER_CLASS = View::Drugs::FiChapterChooser
        COMPONENTS = {
          [0, 0] => :fachinfo_name,
          [1, 0] => :company_name,
          [0, 1] => :chapter_chooser,
          [0, 2] => :description
        }
        COLSPAN_MAP = {
          [0, 1]	=>	2,
          [0, 2]	=>	2
        }
        CSS_MAP = {
          [0, 0] => "th",
          [1, 0]	=> "th right",
          [0, 2] => "list article"
        }
        def init
          @document = @model.send(@session.language)
          @links = @model.send(:links)
          @photos = nil
          case @session.user_input(:chapter)
          when nil
            @photos = @model.send(:photos, "thumbnail")
          when "photos"
            @photos = @model.send(:photos, "small")
          else
            if @model.send(:has_photo?)
              @photos = true # link only
            end
          end
          super
        end

        def chapter_chooser(model, session)
          if (klass = self.class.const_get(:CHOOSER_CLASS))
            klass.new(model, session, self)
          end
        end

        def chapter_view(chapter)
          case chapter
          when "photos"
            @document = nil # no model
            View::Drugs::FachinfoInnerComposite.new(@document, @session, self)
          when "links"
            if @links # behave as link chapter
              # FIXME refactor in state
              chapter = OpenStruct.new({
                heading: "Links",
                links: @links
              })
              model = OpenStruct.new(links: chapter)
              View::Chapter.new(:links, model, @session, self)
            end
          else
            View::Chapter.new(chapter, @document, @session, self)
          end
        end

        def description(model, session)
          chapter = session.user_input(:chapter)
          if chapter == "ddd"
            View::Drugs::DDDTree.new(model.atc_class, session, self)
          elsif !chapter.nil?
            chapter_view(chapter)
          else
            # all
            View::Drugs::FachinfoInnerComposite.new(@document, session, self)
          end
        end

        def fachinfo_name(model, session)
          super(@document, session)
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
          all_names = document.chapters
          if @container.respond_to?(:photos) and !@container.send(:photos).nil?
            unless all_names.include?(:photos)
              all_names << :photos
            end
          else # remove from session
            all_names.delete(:photos)
          end
          unless all_names.include?(:links)
            all_names << :links
          end
          unless all_names.include?(:shorten_path)
            all_names << :shorten_path
          end
          all_names
        end
      end

      class RootFachinfoComposite < View::Drugs::FachinfoComposite
        def init
          unless @model.company.invoiceable?
            components.update({
              [0, 2] => :invoiceability,
              [0, 3] => :description
            })
            css_map.store([0, 3], "list")
            colspan_map.store([0, 3], 2)
          end
          super
        end

        def chapter_view(chapter)
          if @model.company.invoiceable?
            case chapter
            when "photos"
              super
            when "links"
              View::EditLinkForm.new(@model.send(:links), @session, self)
            end
          elsif @model.pointer.skeleton == [:create]
            # don't show anything
          else
            super
          end
        end

        def invoiceability(model, session = @session)
          PointerLink.new(:e_fi_not_invoiceable, model.company, @session, self)
        end
      end

      class RootFachinfo < PrivateTemplate
        CONTENT = View::Drugs::RootFachinfoComposite
        SNAPBACK_EVENT = :result
        JAVASCRIPTS = ["admin"]
      end
    end
  end
end
