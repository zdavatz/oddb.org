#!/usr/bin/env ruby

# View::User::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require "view/centeredsearchform"
require	"view/language_chooser"

module ODDB
  module View
    module User
      class CenteredSearchForm < View::CenteredSearchForm
        COMPONENTS = {
          [0, 0]	=>	View::TabNavigation
        }
        EVENT = :search
      end

      class CenteredSearchComposite < View::CenteredSearchComposite
        COMPONENTS = {
          [0, 0]	=>	:language_chooser,
          [0, 1]	=>	View::User::CenteredSearchForm,
          [0, 2, 0]	=>	:download_export,
          [0, 2, 1]	=>	:divider,
          [0, 2, 2]	=>	:mediudate_link,
          [0, 3, 0]	=>	:database_size,
          [0, 3, 1]	=>	"database_size_text",
          [0, 3, 2]	=>	"comma_separator",
          [0, 3, 3]	=>	"database_last_updated_txt",
          [0, 3, 4]	=>	:database_last_updated,
          [0, 4]	=>	:generic_definition,
          [0, 5]	=>	:legal_note,
          [0, 6]	=>	:paypal
        }
        CSS_MAP = {
          [0, 0, 1, 10]	=>	"list center"
        }
        COMPONENT_CSS_MAP = {
          [0, 5]	=>	"legal-note"
        }
        def mediudate_link(model, session)
          link = HtmlGrid::Link.new(:mediupdate, model, session, self)
          link.href = @lookandfeel.lookup(:mediupdate_url)
          link.set_attribute("target", "_blank")
          link
        end

        def substance_count(model, session)
          @session.app.substance_count
        end
      end

      class GoogleAdSenseComposite < View::GoogleAdSenseComposite
        CONTENT = CenteredSearchComposite
        GOOGLE_CHANNEL = "4606893552"
      end
    end
  end
end
