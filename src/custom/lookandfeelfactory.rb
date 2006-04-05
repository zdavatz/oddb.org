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
			'generika'	=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelGenerika,
			],
			'gerimedi'=>	[
				LookandfeelGeriMedi, 
			],
			'just-medical'=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelJustMedical, 
			],
			'medical-tribune' => [
				LookandfeelExtern,
				LookandfeelMedicalTribune,
			],
			'medical-tribune1' => [
				LookandfeelMedicalTribune1,
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
