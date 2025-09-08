#!/usr/bin/env ruby

# ODDB::State::Drugs::Fachinfo -- oddb.org -- 05.07.2012 -- yasaka@ywesee.com
# ODDB::State::Drugs::Fachinfo -- oddb.org -- 01.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::Fachinfo -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

require "state/drugs/global"
require "view/drugs/change_logs"
require "delegate"

module ODDB
  module State
    module Drugs
      class DocumentChangelogs < State::Drugs::Global
        class DocumentChangelogsWrapper < SimpleDelegator
          attr_accessor :pointer_descr
        end

        def init
          @model = DocumentChangelogsWrapper.new(@model)
          title = if @session.choosen_info_diff.first.is_a?(ODDB::Registration)
            @session.lookandfeel.lookup(:th_change_log_heading_FI)
          else
            @session.lookandfeel.lookup(:th_change_log_heading_PI)
          end
          iksnr = @session.choosen_info_diff.first.iksnr
          name = @session.choosen_info_diff.first.name_base
          descr = "#{title}#{name} (#{@session.lookandfeel.lookup(:fi_iksnrs)} #{iksnr})"
          @model.pointer_descr = descr
        end
        VIEW = View::Drugs::DocumentChangelogs
        LIMITED = false
        FILTER_THRESHOLD = 10
      end

      class DocumentChangelogItem < State::Drugs::Global
        class DocumentChangelogItemWrapper < SimpleDelegator
          attr_accessor :pointer_descr
        end

        def init
          @model = DocumentChangelogItemWrapper.new(@model)
          # Diff vom 10.11.2015 (Swissmedic-Nr.65569)
          title = @session.lookandfeel.lookup(:th_change_log_1)
          iksnr = @session.choosen_info_diff.first.iksnr
          descr = "#{title}#{@model.time.strftime("%d.%m.%Y")} (#{@session.lookandfeel.lookup(:fi_iksnrs)} #{iksnr})"
          @model.pointer_descr = descr
        end
        LIMITED = false
        VIEW = View::Drugs::DocumentChangelogItem
      end
    end
  end
end
