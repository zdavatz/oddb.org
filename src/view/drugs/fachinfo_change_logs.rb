#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Photo -- oddb.org -- 27.07.2012 -- yasaka@ywesee.com

require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/value'

module ODDB
  module View
    module Drugs
      class FachinfoDocumentChangelogItem < View::PublicTemplate
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
        CSS_CLASS = 'composite'
        COLSPAN_MAP = { [0,1] => 5, }

        DEFAULT_CLASS = HtmlGrid::Value
        def diff(model, session)
          return model.diff.to_s(:html)
        end
        def nr_chunks(model, session)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          j = 0; model.diff.each_chunk{|x| j+= 1}
          j
        end
        def name(model, session)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          @session.choosen_fachinfo_diff[0].name_base
        end
        def time(model, session)
          model.time.to_s
        end
      end
      class FachinfoDocumentChangelogList < HtmlGrid::List
        EMPTY_LIST_KEY = :choose_fachinfo_range
        COMPONENTS = {
          [0,0] => :name,
          [2,0] => :nr_chunks,
          [4,0] => :time,
          [6,0] => :change_log,
        }
        DEFAULT_CLASS = HtmlGrid::Value
        CSS_CLASS = 'composite'
        CSS_MAP = {
          [0,0] =>  'name list',
          [2,0] =>  'nr_chunkslist',
          [4,0] =>  'timelist',
          [6,0] =>  'change_log',
        }
        SORT_DEFAULT = false
        SORT_HEADER = false
        def nr_chunks(model, session)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          j = 0; model.diff.each_chunk{|x| j+= 1}
          j
        end
        def name(model, session)
          return unless model and @session.choosen_fachinfo_diff.size > 0
          @session.choosen_fachinfo_diff[0].name_base
        end
        def time(model, session)
          model.time.to_s
        end
        def change_log(model, session=@session, key=:change_log)
          return nil unless @session.choosen_fachinfo_diff.size > 0
          link = HtmlGrid::Link.new(key, model, session, self)
          # http://oddb-ci2.dyndns.org/de/gcc/show/fachinfo/51193/diff/2015-10-27
          link.set_attribute('title', @lookandfeel.lookup(:change_log))
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
        CSS_CLASS = 'composite'
        COMPONENTS = {
          [0,1]   =>  :change_log_list,
        }
        CSS_MAP = {
          [0,0] => 'change_log_list right',
        }
         def initialize(model, session, container)
          # latest changes must come first!
          model.sort!{|x,y| y.time.to_s <=> x.time.to_s}
          super
        end
        def change_log_list(model, session)
          FachinfoDocumentChangelogList.new(model, session, self)
        end
      end
      class FachinfoDocumentChangelogs < View::PublicTemplate
        include View::AdditionalInformation
        CONTENT = View::Drugs::FachinfoDocumentChangelogsComposite
         def initialize(model, session)
          super
        end
      end
      class EmptyResultForm < HtmlGrid::Form
        COMPONENTS = {
          [0,1]   =>  :title_none_found,
          [0,2]   =>  'e_empty_result',
        }
        CSS_MAP = {
          [0,0]     =>  'search',
          [0,1]     =>  'th',
        }
        CSS_CLASS = 'composite'
        def title_none_found(model, session)
          @lookandfeel.lookup(:title_none_found, 'xng')
        end
      end
    end
  end
end
