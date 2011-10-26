#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::GalenicGroups -- oddb.org -- 26.10.2011 -- mhatakeyama@jetnet.ch
# ODDB::View::Admin::GalenicGroups -- oddb.org -- 25.03.2003 -- andy@jetnet.ch

require 'view/drugs/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'

module ODDB
	module View
		module Admin
class GalenicGroupsList < View::DescriptionList
	COMPONENTS = {
		[0,0]	=>	:oid,
		[1,0]	=>	:description,
		[2,0]	=>	:de,
		[3,0]	=>	:en,
		[4,0]	=>	:fr,
	}
	CSS_MAP = {
		[0,0,5]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	EVENT = :new_galenic_group
	SYMBOL_MAP = {
		:description	=>	View::PointerLink,
		:oid					=>	View::PointerLink,
	}
  def oid(model, session)
    link = View::PointerLink.new(:oid, model, session)
    link.href = @lookandfeel._event_url(:galenic_group, {:oid => model.oid})
    link
  end
  def description(model, session)
    link = View::PointerLink.new(:description, model, session)
    link.href = @lookandfeel._event_url(:galenic_group, {:oid => model.oid})
    link
  end
end
class GalenicGroups < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::GalenicGroupsList
	SNAPBACK_EVENT = :galenic_groups
end
		end
	end
end
