#!/usr/bin/env ruby
# View::Admin::Package -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/form'
require 'view/pointervalue'
require 'view/dataformat'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputcurrency'
require 'htmlgrid/inputdate'
require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'htmlgrid/link'
require 'htmlgrid/booleanvalue'

module ODDB
	module View
		module Admin
class PackageInnerComposite < HtmlGrid::Composite
	include DataFormat
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[2,1]		=>	:size,
		[0,2]		=>	:ikscat,
		[2,2]		=>	:sl_entry,
		[0,3]		=>	:price_exfactory,
		[2,3]		=>	:price_public,
	}
	CSS_MAP = {
		[0,0,4,4]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:sl_entry	=>	HtmlGrid::BooleanValue,
	}
end
class PackageForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[0,2]		=>	:pretty_dose,
		[2,2]		=>	:size,
		[0,3]		=>	:ikscat,
		[2,3]		=>	:sl_entry,
		[0,4]		=>	:price_exfactory,
		[2,4]		=>	:price_public,
		[0,5]		=>	:generic_group,
		[2,5]		=>	:market_date,
		[0,6]		=>	:deductible,
		[2,6]		=>	:lppv,
		[0,7]		=>	:out_of_trade,
		[1,8]		=>	:submit,
		[1,8,0]	=>	:delete_item,
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,6]	=>	'standard',
		[3,3]			=>	'list',
	}
	CSS_MAP = {
		[0,0,4,8]	=>	'list',
	}
	LABELS = true
	SYMBOL_MAP = {
		:deductible				=>	HtmlGrid::Select,
		:price_exfactory	=>	HtmlGrid::InputCurrency,
		:price_public			=>	HtmlGrid::InputCurrency,
		:iksnr						=>	HtmlGrid::Value,
		:market_date			=>	HtmlGrid::InputDate,
		:out_of_trade			=>	HtmlGrid::BooleanValue,
		:refdata_override	=>	HtmlGrid::InputCheckbox,
		:lppv							=>	HtmlGrid::Select,
	}
	def init
		if(@model.out_of_trade)
			components.store([2,6], :refdata_override)
		end
		super
		error_message()
	end
	def ikscd(model, session)
		klass = if(model.ikscd.nil?)
			HtmlGrid::InputText
		else
			HtmlGrid::Value
		end
		klass.new(:ikscd, model, session, self)
	end
	def delete_item(model, session)
		delete_item_warn(model, :w_delete_package)
	end
	def sl_entry(model, session)
		unless (model.is_a? Persistence::CreateItem)
			link = nil
			if (sl_entry = model.sl_entry)
				link = HtmlGrid::Link.new(:sl_modify, sl_entry, session, self)
				args = {'pointer' => sl_entry.pointer}
				link.href = @lookandfeel._event_url(:resolve, args)
				#PointerLink.new(:pointer_descr, sl_entry, session, self)
			else
				link = HtmlGrid::Link.new(:sl_create, sl_entry, session, self)
				link.href = @lookandfeel.event_url(:new_item)
			end
			link.label = true
			link.set_attribute('class', 'list')
			link
		end
	end
end
class DeductiblePackageForm < View::Admin::PackageInnerComposite
	include HtmlGrid::FormMethods
	include View::HiddenPointer
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	EVENT = :update
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[0,2]		=>	:pretty_dose,
		[2,2]		=>	:size,
		[0,3]		=>	:ikscat,
		[2,3]		=>	:sl_entry,
		[0,4]		=>	:price_exfactory,
		[2,4]		=>	:price_public,
		[0,5]		=>	:deductible_m,
		[1,6]		=>	:submit,
	}
	SYMBOL_MAP = {
		:deductible_m	=>	HtmlGrid::Select,
		:sl_entry			=>	HtmlGrid::BooleanValue,
	}
	CSS_MAP = {
		[0,0,4,7]	=>	'list',
	}
	LOOKANDFEEL_MAP = {
		:deductible_m	=>	:deductible,	
	}
end
class PackageComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::PackageInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def package_name(model, session)
		sequence = model.parent(session.app)
		[sequence.name, model.size].compact.join('&nbsp;-&nbsp;')
	end
end
class RootPackageComposite < View::Admin::PackageComposite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::PackageForm,
		[0,2]	=>	'th_source',
		[0,3]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'subheading',
	}
	def source(model, session)
		HtmlGrid::Value.new(:source, model.sequence, @session, self)
	end
end
class DeductiblePackageComposite < View::Admin::RootPackageComposite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::DeductiblePackageForm,
		[0,2]	=>	'th_source',
		[0,3]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'subheading',
	}
	def source(model, session)
		HtmlGrid::Value.new(:source, model.sequence, @session, self)
	end
end
class Package < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::PackageComposite
	SNAPBACK_EVENT = :result
end
class RootPackage < View::Admin::Package
	CONTENT = View::Admin::RootPackageComposite
end
class DeductiblePackage < View::Admin::Package
	CONTENT = View::Admin::DeductiblePackageComposite
end
		end
	end
end
