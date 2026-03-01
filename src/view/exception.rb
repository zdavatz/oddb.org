#!/usr/bin/env ruby

# View::Exception -- oddb -- 12.03.2003 -- andy@jetnet.ch

require "view/publictemplate"
require "htmlgrid/form"
require "htmlgrid/span"
require "htmlgrid/text"
require "view/searchbar"

module ODDB
  module View
    class ExceptionComposite < HtmlGrid::Form
      COMPONENTS = {
        [0, 0, 0]	=>	:search_query,
        [0, 0, 1]	=>	:submit,
        [0, 1]	=>	:exception_header,
        [0, 2]	=>	:exception
      }
      CSS_CLASS = "composite"
      CSS_MAP = {
        [0, 0]	=>	"search",
        [0, 1]	=>	"th",
        [0, 2]	=>	"error"
      }
      EVENT = :search
      SYMBOL_MAP = {
        search_query: SearchBar,
        exception_header: HtmlGrid::Text
      }
      def exception(model, session)
        if model.is_a?(SBSM::InvalidDataError)
          HtmlGrid::Text.new(model.message, model, session, self)
        else
          span = HtmlGrid::Span.new(model, session, self)
          span.instance_variable_set(:@value, model.message.to_s)
          span
        end
      end
    end

    class Exception < View::PublicTemplate
      CONTENT = View::ExceptionComposite
    end
  end
end
