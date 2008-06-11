#!/usr/bin/env ruby
# View::Admin::CommercialForm -- de.oddb.org -- 24.11.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/admin/sequence'

module ODDB
  module View
    module Admin
class ComformPackages < SequencePackages
  include RegistrationSequenceList
  COMPONENTS = {
    [0,0]	=>	:ikscd,
		[1,0]	=>	:name_base,
		[2,0]	=>	:galenic_form,
    [3,0]	=>	:most_precise_dose,
    [4,0]	=>	:size,
    [5,0]	=>	:out_of_trade,
  }
	CSS_HEAD_MAP = {
		[0,0]	=>	'subheading',
		[1,0]	=>	'subheading',
		[2,0]	=>	'subheading',
		[3,0]	=>	'subheading right',
		[4,0]	=>	'subheading right',
		[5,0]	=>	'subheading right',
	}
  CSS_MAP = {
    [0,0,3]	=>	'list',
    [3,0,3]	=>	'list right',
  }
	SORT_DEFAULT = :name_base
end
class CommercialFormForm < View::DescriptionForm
  COMPONENTS = {
    [2,0]  =>  :package_count,
  }
  CSS_MAP = {
    [3,0]  =>  'list right'
  }
  SYMBOL_MAP = {
    :package_count =>  HtmlGrid::Value,
  }
  def languages
    super + ['synonym_list']
  end
end
class CommercialFormComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => 'commercial_form',
    [0,1] => CommercialFormForm,
    [0,2] => :packages,
  }
  CSS_MAP = {
    [0,0] => 'th'
  }
  CSS_CLASS = 'composite'
  def packages(model, session=@session)
    ComformPackages.new(model.packages[0,30], @session, self)
  end
end
class CommercialForm < PrivateTemplate
  CONTENT = CommercialFormComposite
  SNAPBACK_EVENT = :commercial_forms
end
    end
  end
end
