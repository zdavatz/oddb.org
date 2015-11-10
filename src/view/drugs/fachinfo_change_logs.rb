#!/usr/bin/env ruby
# encoding: utf-8
require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/value'

module ODDB
  module View
    module Drugs
      class FachinfoDocumentChangelogItemComposite < HtmlGrid::Composite
        LEGACY_INTERFACE = false
        COMPONENTS = {
          [0,0, 1] => 'th_change_log',
          [0,0, 2] => '&nbsp',
          [0,0, 3] => :name,
          [0,0, 4] => '&nbsp',
          [0,0, 5] => :nr_chunks,
          [0,0, 6] => '&nbsp',
          [0,0, 7] => 'th_nr_chunks',
          [0,0, 8] => '&nbsp',
          [0,0, 9] => 'th_change_log_time',
          [0,0,10] => '&nbsp',
          [0,0,11] => :time,
          [0,1] => :diff,
        }
        CSS_MAP = {
          [0,0] => 'th',
        }
        CSS_CLASS = 'composite '
        COLSPAN_MAP = { [0,1] => 6 }

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
          @session.choosen_fachinfo_diff[0].name_base
        end
        def time(model)
          model.time.to_s
        end
      end
      class FachinfoDocumentChangelogItem < PrivateTemplate
        CONTENT = View::Drugs::FachinfoDocumentChangelogItemComposite
        SNAPBACK_EVENT = :result
      end

      class FachinfoDocumentChangelogListItem < HtmlGrid::Composite
        LEGACY_INTERFACE = false
        COMPONENTS = {
          [0,0] => :name,
          [1,0] => :nr_chunks,
          [2,0] => :time,
          }
        DEFAULT_CLASS = HtmlGrid::Value
        CSS_CLASS = 'composite'
        def nr_chunks(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          j = 0; model.diff.each_chunk{|x| j+= 1}
          j
        end
        def name(model)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          @session.choosen_fachinfo_diff[0].name_base
        end
      end
      class FachinfoDocumentChangelogList < HtmlGrid::List
        CSS_CLASS = 'composite'
        OMIT_HEADER = true
        COMPONENTS = {
          [0,0] => :list_item,
        }
        DEFAULT_CLASS = HtmlGrid::Value
        SORT_DEFAULT = false
        SORT_HEADER = false
        def list_item(model, session=@session, key=:change_log)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          link = HtmlGrid::Link.new(key, model, session, self)
          # http://oddb-ci2.dyndns.org/de/gcc/show/fachinfo/51193/diff/2015-10-27
          link.set_attribute('title', @lookandfeel.lookup(:change_log))
          link.value = FachinfoDocumentChangelogListItem.new(model, session, self)
          link.href = @lookandfeel._event_url(:show,
                                              [:fachinfo,
                                               @session.choosen_fachinfo_diff[0].iksnr,
                                               :diff,
                                               model.time.to_s
                                              ] )
          link
        end
      end
      class FachinfoDocumentChangelogsComposite < HtmlGrid::Composite
        LEGACY_INTERFACE = false
        CSS_CLASS = 'composite'
        COMPONENTS = {
          [0,0] => :heading,
          [0,1] =>  FachinfoDocumentChangelogList,
        }
        CSS_MAP = {
          [0,0] => 'th',
        }
        def initialize(model, session, container)
          # latest changes must come first!
          model.sort!{|x,y| y.time.to_s <=> x.time.to_s}
          super
        end
        def heading(model)
          title = @session.lookandfeel.lookup(:th_change_log_heading)
          return title unless @session.choosen_fachinfo_diff[0]
          info  = @session.choosen_fachinfo_diff[0]
          "#{title} #{info.iksnr} #{info.name_base}"
        end
      end
      class FachinfoDocumentChangelogs < View::PrivateTemplate
        SNAPBACK_EVENT = :result
        CONTENT = View::Drugs::FachinfoDocumentChangelogsComposite
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
