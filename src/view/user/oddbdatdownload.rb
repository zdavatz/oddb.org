#!/usr/bin/env ruby
# View::User::ODDBDatDownload -- oddb -- 18.08.2003 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/user/export'
require 'htmlgrid/link'
require 'plugin/oddbdat_export'

module ODDB
	module View
		module User
class OddbDatDownloadInnerComposite < HtmlGrid::Composite
	include View::User::Export
	COMPONENTS = {
		[0,0]		=>	:oddbdat_download_tar_gz,
		[0,1]		=>	:oddbdat_download_zip,
		[0,2]		=>	:s31x_tar_gz,
		[0,3]		=>	:s31x_zip,
	}
	CSS_MAP = {
		[0,1,1,3]	=>	'list',
	}
	EXPORT_FILE = 'oddbdat'
	def oddbdat_download_tar_gz(model, session)
		link_with_filesize("oddbdat.tar.gz")
	end
	def oddbdat_download_zip(model, session)
		link_with_filesize("oddbdat.zip")
	end
	def s31x_tar_gz(model, session)
		link_with_filesize("s31x.gz")
	end
	def s31x_zip(model, session)
		link_with_filesize("s31x.zip")
	end
end
		end
	end
end
