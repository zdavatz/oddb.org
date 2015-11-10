#!/usr/bin/env ruby
# encoding: utf-8
require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/value'

module ODDB
  module View
    module Drugs
      class FachinfoDocumentChangelogItem < View::PublicTemplate
        LEGACY_INTERFACE = false
        include View::AdditionalInformation
        COMPONENTS = {
          [0,0] => :name,
          [2,0] => :nr_chunks,
          [3,0] => :th_time,
          [4,0] => :time,
          [0,1] => :diff,
        }
        CSS_MAP = {
          [0,0] =>  'name list',
          [2,0] =>  'nr_chunks list',
          [4,0] =>  'time list',
          [0,1] =>  'diff',
        }
        CSS_CLASS = 'composite '

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
          title = @session.lookandfeel.lookup(:name_list)
          return title unless @session.choosen_fachinfo_diff[0]
          info  = @session.choosen_fachinfo_diff[0]
          "#{title} #{info.iksnr} #{info.name_base}"
        end
      end
      class FachinfoDocumentChangelogs < View::PublicTemplate
        CSS_CLASS = 'composite'
        SNAPBACK_EVENT = :result
        include View::AdditionalInformation
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
