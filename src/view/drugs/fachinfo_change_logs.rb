#!/usr/bin/env ruby
# encoding: utf-8
require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/value'

module ODDB
  module View
    module Drugs
      # --- display de/gcc/show/fachinfo/63171/diff/31.10.2015
      class FachinfoDocumentChangelogItemComposite < HtmlGrid::Composite
        LEGACY_INTERFACE = false
        COMPONENTS = {
          [0,0, 0] => :nr_chunks,
          [0,0, 1] => '&nbsp',
          [0,0, 2] => 'th_change_log',
          [0,0, 3] => '&nbsp',
          [0,0, 4] => :name,
          [0,1] => :diff,
        }
        CSS_MAP = {
          [0,0] => 'th',
        }
        CSS_CLASS = 'composite'
        COLSPAN_MAP = { [0,0] => 9,
                        [0,1] => 8,
                      }

        DEFAULT_CLASS = HtmlGrid::Value
        def diff(model)
          return model.diff.to_s(:html)
        end
        def nr_chunks(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          j = 0; model.diff.each_chunk{|x| j+= 1}
          j
        end
        def name(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          @session.choosen_fachinfo_diff.first.name_base
        end
        def time(model)
          model.time.strftime('%d.%m.%Y')
        end
      end
      class FachinfoDocumentChangelogItem < PrivateTemplate
        CONTENT = View::Drugs::FachinfoDocumentChangelogItemComposite
        SNAPBACK_EVENT = :change_log
        def backtracking(model, session=@session)
          fields = []
          fields << @lookandfeel.lookup(:th_pointer_descr)
          link = HtmlGrid::Link.new(:home, model, @session, self)
          link.css_class = "list"
          link.href  = @lookandfeel._event_url(:home, [])
          link.value = @lookandfeel.lookup(:home)
          fields << link
          fields << '&nbsp;-&nbsp;'

          #  /fachinfo/reg/65453
          link = HtmlGrid::Link.new(:home, model, @session, self)
          link.css_class = "list"
          link.href  = @lookandfeel._event_url(:fachinfo, [ :reg, @session.choosen_fachinfo_diff.first.iksnr ])
          link.value = @lookandfeel.lookup(:fachinfo_name0) + @session.choosen_fachinfo_diff.first.name_base
          fields << link

          fields << '&nbsp;-&nbsp;'
          #  /fachinfo/reg/65453
          link = HtmlGrid::Link.new(:home, model, @session, self)
          link.css_class = "list"
          # http://oddb-ci2.dyndns.org/de/gcc/show/fachinfo/65569/diff/10.11.2015
          link.href  = @lookandfeel._event_url(:home, [:fachinfo, :reg, @session.choosen_fachinfo_diff.first.iksnr, :diff])
          link.value = @lookandfeel.lookup(:change_log_backtracking)
          fields << link

          fields << '&nbsp;-&nbsp;'
          span = HtmlGrid::Span.new(model, session, self)
          span.value = model.time.strftime('%d.%m.%Y')
          span.set_attribute('class', 'list')
          fields << span
          fields
        end
      end

      # --- display de/gcc/show/fachinfo/63171/diff
      class FachinfoDocumentChangelogList < HtmlGrid::List
        LEGACY_INTERFACE = false
        CSS_CLASS = 'composite'
        COMPONENTS = {
          [0,0] => :trademark,
          [1,0] => :nr_chunks,
          [2,0] => :change_log_date,
        }
        SORT_DEFAULT = false
        SORT_HEADER = false
        def nr_chunks(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          nr = 0; model.diff.each_chunk{|x| nr+= 1}
          link = HtmlGrid::Link.new(:change_log, model, @session, self)
          link.href = get_link_href(model)
          link.value = nr
          link
        end
        def change_log_date(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          link = HtmlGrid::Link.new(:change_log, model, @session, self)
          link.href = get_link_href(model)
          link.value = model.time.strftime('%d.%m.%Y')
          link
        end
        def trademark(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          link = HtmlGrid::Link.new(:change_log, model, @session, self)
          link.href = get_link_href(model)
          link.value = @session.choosen_fachinfo_diff.first.name_base
          link
        end
        def get_link_href(model)
          @lookandfeel._event_url(:show,
                                              [:fachinfo,
                                               @session.choosen_fachinfo_diff.first.iksnr,
                                               :diff,
                                               model.time.strftime('%d.%m.%Y')
                                              ] )
        end
      end
      class FachinfoDocumentChangelogsComposite < HtmlGrid::Composite
        CSS_CLASS = 'composite'
        COMPONENTS = {
          [0,0] =>  FachinfoDocumentChangelogList,
        }
        def initialize(model, session, container)
          # latest changes must come first!
          model.sort!{|x,y| y.time.to_s <=> x.time.to_s}
          super
        end
      end
      class FachinfoDocumentChangelogs < View::PrivateTemplate
        SNAPBACK_EVENT = :result
        CONTENT = View::Drugs::FachinfoDocumentChangelogsComposite
        def initialize(model, session, container=nil)
          # latest changes must come first!
          super
        end
        def backtracking(model, session=@session)
          fields = []
          fields << @lookandfeel.lookup(:th_pointer_descr)
          link = HtmlGrid::Link.new(:home, model, @session, self)
          link.css_class = "list"
          link.href  = @lookandfeel._event_url(:home, [])
          link.value = @lookandfeel.lookup(:home)
          fields << link
          return fields unless  @session.choosen_fachinfo_diff.first

          fields << '&nbsp;-&nbsp;'
          #  /fachinfo/reg/65453
          link = HtmlGrid::Link.new(:home, model, @session, self)
          link.css_class = "list"
          link.href  = @lookandfeel._event_url(:fachinfo, [ :reg, @session.choosen_fachinfo_diff.first.iksnr ])
          link.value = @lookandfeel.lookup(:fachinfo_name0) + @session.choosen_fachinfo_diff.first.name_base
          fields << link

          fields << '&nbsp;-&nbsp;'
          span = HtmlGrid::Span.new(model, session, self)
          span.value = @lookandfeel.lookup(:change_log_backtracking)
          span.set_attribute('class', 'list')
          fields << span
          fields
        end
      end
      class EmptyResultForm < HtmlGrid::Form
        CSS_CLASS = 'composite'
        COMPONENTS = {
          [0,1]   =>  :title_none_found,
          [0,2]   =>  'e_empty_result',
        }
        CSS_MAP = {
          [0,0]     =>  'search',
          [0,1]     =>  'th',
        }
        def title_none_found(model, session)
          @lookandfeel.lookup(:title_none_found)
        end
      end
    end
  end
end