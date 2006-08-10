#!/usr/bin/env ruby
# View::User::FachinfoPDFDownload -- oddb -- 20.09.2004 -- mhuggler@ywesee.com


module ODDB
	module View
		module User
class FachinfoPDFDownloadInnerComposite < HtmlGrid::Composite
	include View::User::Export
	COMPONENTS = {
		[0,0]		=>	:fachinfo_pdf_download,
	}
	CSS_MAP = {
		[0,0]	=>	'list',
	}
	EXPORT_FILE = 'fachinfo'
	def fachinfo_pdf_download(model, session)
		link_with_filesize("Fachinfos_Version_3.3.pdf")
	end
end
		end
	end
end
