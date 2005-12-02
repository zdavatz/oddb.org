#!/usr/bin/env ruby
# View::Admin::IncompletePackage -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'view/admin/package'

module ODDB
	module View
		module Admin
class IncompletePackageInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:th_source,
		[1,0]	=>	:th_active_package,
		[0,1]	=>	:source,
		[1,1]	=>	:active_package,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	"subheading",
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SYMBOL_MAP = {
		:th_source	=>	HtmlGrid::Text,
		:th_active_package	=>	HtmlGrid::Text,
	}
	def active_package(model, session)
		if((reg = @session.app.registration(model.iksnr)) \
			&& (pack = reg.package(model.ikscd)))
			_active_package(pack)
		end
	end
	def _active_package(pack)
		View::Admin::PackageComposite.new(pack, @session, self)
	end
	def source(model, session)
		HtmlGrid::Value.new(:source, model.parent(session.app), session, self)	
	end
end
class IncompletePackageForm < View::Admin::PackageForm
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[0,2]		=>	:pretty_dose,
		[2,2]		=>	:size,
		[0,3]		=>	:ikscat,
		[0,4]		=>	:price_exfactory,
		[2,4]		=>	:price_public,
		[0,5]		=>	:generic_group,
		[1,6]		=>	:submit,
		[1,6,0]	=>	:delete_item,
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,6]	=>	'standard',
		[3,3]			=>	'list',
	}
	CSS_MAP = {
		[0,0,4,7]	=>	'list',
	}
	EVENT = :update_incomplete
end
class IncompletePackageComposite < View::Admin::PackageComposite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::IncompletePackageForm,
		[0,2]	=>	View::Admin::IncompletePackageInnerComposite,
	}
end
class IncompletePackage < View::PrivateTemplate
	CONTENT = View::Admin::IncompletePackageComposite
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
