#!/usr/bin/env ruby
# View::Admin::IncompleteSequence -- oddb -- 20.06.2003 -- hwyss@ywesee.com 

require 'view/admin/sequence'
require 'view/privatetemplate'

module ODDB
	module View
		module Admin
class IncompleteSequenceInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:th_source,
		[1,0]	=>	:th_active_sequence,
		[0,1]	=>	:source,
		[1,1]	=>	:active_sequence,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	"subheading",
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SYMBOL_MAP = {
		:th_source	=>	HtmlGrid::Text,
		:th_active_sequence	=>	HtmlGrid::Text,
	}
	def active_sequence(model, session)
		if((reg = @session.app.registration(model.iksnr)) \
			&& (seq = reg.sequence(model.seqnr)))
			View::Admin::RootSequenceComposite.new(seq, session, self)
		end
	end
end
class IncompleteSequenceForm < View::Admin::SequenceForm
	EVENT = :update_incomplete
end
class IncompleteSequenceComposite < View::Admin::RootSequenceComposite
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	IncompleteSequenceForm,
		[0,2]	=>	:sequence_agents,
		[0,3]	=>	:sequence_packages,
		[0,4]	=>	View::Admin::IncompleteSequenceInnerComposite,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,4]	=>	'composite',
	}
end
class IncompleteSequence < View::PrivateTemplate
	SNAPBACK_EVENT = :incomplete_registrations
	CONTENT = View::Admin::IncompleteSequenceComposite
end
		end
	end
end
