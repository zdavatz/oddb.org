#!/usr/bin/env ruby
# View::User::SuggestPackage -- oddb -- 02.12.2005 -- hwyss@ywesee.com

require 'view/admin/incompletepackage'

module ODDB
	module View
		module User
class SuggestPackageInnerComposite < View::Admin::IncompletePackageInnerComposite
	COMPONENTS = {
		[0,0]	=>	:th_active_package,
		[0,1]	=>	:active_package,
	}
	CSS_MAP = {
		[0,0]	=>	"subheading",
	}
	def active_package(model, session=@session)
		_active_package(model)
	end
end
class SuggestPackageComposite < View::Admin::IncompletePackageComposite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::IncompletePackageForm,
		[0,2]	=>	:active_package,
	}
	def active_package(model, session=@session)
		if((reg = @session.app.registration(model.iksnr)) \
			&& (pack = reg.package(model.ikscd)))
			SuggestPackageInnerComposite.new(pack, @session, self)
		end
	end
end
class SuggestPackage < View::PrivateTemplate
	CONTENT = SuggestPackageComposite
	SNAPBACK_EVENT = :home_user
end
		end
	end
end
