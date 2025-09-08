#!/usr/bin/env ruby

# View::User::YamlExport -- oddb -- 05.09.2003 -- rwaltert@ywesee.com

require "view/publictemplate"
require "view/user/export"
require "htmlgrid/link"

module ODDB
  module View
    module User
      class YamlExportInnerComposite < HtmlGrid::Composite
        include View::User::Export
        COMPONENTS = {
          [0, 1]	=>	:yaml_export_gz,
          [0, 2]	=>	:yaml_export_zip
        }
        CSS_MAP = {
          [0, 1, 1, 6]	=>	"list"
        }
        EXPORT_FILE = "oddb.yaml"
        def yaml_export_gz(model, session)
          link_with_filesize("oddb.yaml.gz")
        end

        def yaml_export_zip(model, session)
          link_with_filesize("oddb.yaml.zip")
        end
      end
    end
  end
end
