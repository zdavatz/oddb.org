#!/usr/bin/env ruby

# View::Drugs::RegisterDownload -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require "htmlgrid/errormessage"
require "htmlgrid/select"
require "view/resulttemplate"
require "view/paypal/invoice"
require "view/datadeclaration"
require "view/form"
require "view/user/autofill"

module ODDB
  module View
    module Drugs
      class RegisterDownloadForm < Form
        include View::User::AutoFill
        include HtmlGrid::ErrorMessage
        COMPONENTS = {
          [0, 0]	=>	:email,
          [0, 1]	=>	:salutation,
          [0, 2]	=>	:name_last,
          [0, 3]	=>	:name_first,
          [1, 4] =>	:submit
        }
        CSS_CLASS = "component"
        HTML_ATTRIBUTES = {
          "style"	=>	"width:30%"
        }
        EVENT = :checkout
        LABELS = true
        CSS_MAP = {
          [0, 0, 4, 5]	=>	"list"
        }
        COMPONENT_CSS_MAP = {
          [1, 0, 3, 4]	=>	"standard"
        }
        SYMBOL_MAP = {
          pass: HtmlGrid::Pass,
          set_pass_2: HtmlGrid::Pass,
          salutation: HtmlGrid::Select
        }
        def init
          unless @session.logged_in?
            hash_insert_row(components, [0, 1], :pass)
            components.store([3, 1], :set_pass_2)
            css_map.store([0, 11, 4], "list")
            component_css_map.store([1, 10], "standard")
          end
          super
          if @session.error?
            error = RuntimeError.new("e_need_all_input")
            __message(error, "processingerror")
          end
        end

        def hidden_fields(context)
          hidden = super
          [:search_query, :search_type].each { |key|
            hidden << context.hidden(key.to_s, @session.state.send(key))
          }
          hidden
        end

        def submit(model, session = @session)
          super(model, session, :checkout_paypal)
        end
      end
    end
  end
end
