#!/usr/bin/env ruby
# LookandfeelFactory -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'sbsm/lookandfeelfactory'
require 'custom/lookandfeelbase'
require 'custom/lookandfeelwrapper'

module ODDB
	class LookandfeelFactory < SBSM::LookandfeelFactory
		BASE = LookandfeelBase
		WRAPPERS = {
			'atupri'=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelAtupri, 
			],
			'atupri-web'=>	[
				LookandfeelAtupriWeb, 
			],
			'just-medical'=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelJustMedical, 
			],
			'generika'	=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelGenerika,
			],
			'oekk'	=>	[
				LookandfeelExtern,
				LookandfeelOekk,
			],
			'provita'			=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelProvita, 
			],
			'santesuisse' =>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelSantesuisse, 
			],
			'swissmedic'	=>	[
				LookandfeelSwissmedic,
			],
		}
	end
end
