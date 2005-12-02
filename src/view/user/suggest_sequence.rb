#!/usr/bin/env ruby
# View::User::SuggestSequence -- oddb -- 02.12.2005 -- hwyss@ywesee.com

require 'view/admin/incompletesequence'

module ODDB
	module View
		module User
class SuggestSequenceComposite < View::Admin::IncompleteSequenceComposite
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Admin::IncompleteSequenceForm,
		[0,2]	=>	:sequence_agents,
		[0,3]	=>	:sequence_packages,
		[0,4]	=>	View::Admin::IncompleteSequenceInnerComposite,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,4]	=>	'composite',
	}
	def sequence_agents(model, session=@session)
		if(model._acceptable?)
			super
		end
	end
	def sequence_packages(model, session=@session)
		if(model._acceptable?)
			super
		end
	end
end
class SuggestSequence < PrivateTemplate
	SNAPBACK_EVENT = :user_home
	CONTENT = View::User::SuggestSequenceComposite
end
		end
	end
end
