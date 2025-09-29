#!/usr/bin/env ruby

# State::Drugs::Result -- oddb.org -- 24.02.2012 -- mhatakeyama@ywesee.com
# State::Drugs::Result -- oddb.org -- 03.03.2003 -- hwyss@ywesee.com

require "state/global_predefine"
require "state/page_facade"
require "view/drugs/result"
require "model/registration"
require "model/invoice"
require "state/admin/registration"
require "state/user/limit"

module ODDB
  module State
    module Drugs
      class Result < State::Drugs::Global
        SNAPBACK_EVENT = :result
        VIEW = View::Drugs::Result
        LIMITED = true
        ITEM_LIMIT = 100
        REVERSE_MAP = View::Drugs::ResultList::REVERSE_MAP
        attr_accessor :search_query, :search_type
        attr_reader :pages, :code2page
        include ResultStateSort
        def init
          @pages = []
          @model.session = @session
          @model.atc_classes.delete_if { |atc| atc.package_count == 0 }
          if /drug(_?)shortage/i.match(@session.persistent_user_input(:search_query)) && !@session.user_input(:sortvalue)
            @sortby = [:name_base]
            sort
          end
          if @model.respond_to?(:package_filters)
            @model.package_filters = get_search_filters
            @model.apply_filters(@session)
          end
          if @model.atc_classes.nil? || @model.atc_classes.empty?
            @default_view = ODDB::View::Drugs::EmptyResult
          elsif @model.overflow?
            @session.persistent_user_input(:search_query).to_s.downcase
            page = 0
            count = 0
            @code2page = {}
            @model.each { |atc|
              @code2page.store(atc.code, page)
              @pages[page] ||= State::PageFacade.new(page)
              @pages[page].push(atc)
              count += atc.package_count
              if count >= ITEM_LIMIT
                page += 1
                count = 0
              end
            }
            @session.set_cookie_input(:resultview, "pages")
            @filter = proc { |model|
              @session.set_cookie_input(:resultview, "pages")
              page()  # standard:disable all
            }
          end
        end

        def get_sortby!
          super
          if @sortby.first == :dsp
            sortvalue = [:most_precise_dose, :comparable_size, :price_public]
            if @sortby[1, 3] == sortvalue
              ## @sort_reverse has already been reset at this stage,
              ## correct it with dedicated instance variable
              @sort_reverse = @sort_reverse_dsp = !@sort_reverse_dsp
              @sortby.shift
            else
              @sort_reverse_dsp = @sort_reverse
              @sortby[0, 1] = sortvalue
            end
          end
          @sortby.uniq!
        end

        def limit_state
          model = if @search_type.eql?("st_sequence")
            @model
          else
            _search_drugs(@search_query, "st_sequence")
          end
          result = model.atc_classes.inject([]) { |mdl, atc|
            mdl += atc.active_packages  # standard:disable all
          }
          state = State::Drugs::ResultLimit.new(@session, result)
          state.package_count = @model.package_count
          state
        end

        def package_count
          @model.package_count
        end

        def page
          pge = nil
          if @session.event == :search
            ## reset page-input
            if @session.user_input(:page)
              pge = @session.user_input(:page)
            elsif (code = @session.user_input(:code))
              pge = @code2page[code]
            end
            @session.set_persistent_user_input(:page, pge)
          else
            pge = @session.persistent_user_input(:page)
          end
          page = @pages[pge || 0]
          page ||= @pages[0]
          page.model = @model
          page
        end

        def request_path
          if @request_path
            suffix = @session.lookandfeel.disabled?(:best_result) ? "" : "#best_result"
            @request_path + suffix
          end
        end

        def search
          query = @session.persistent_user_input(:search_query).to_s.downcase
          stype = @session.user_input(:search_type)
          if @search_type != stype || @search_query != query
            super
          else
            @request_path = @session.request_path
            self
          end
        end
      end
    end
  end
end
