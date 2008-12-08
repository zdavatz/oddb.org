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
				LookandfeelStandardResult,
				LookandfeelAtupri, 
			],
			'atupri-web'=>	[
				LookandfeelAtupriWeb, 
			],
			'carenaschweiz'=>	[
				LookandfeelLanguages,
				LookandfeelStandardResult,
				LookandfeelCarenaSchweiz, 
			],
			'galenos'			=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelStandardResult,
				LookandfeelGalenos, 
			],
			'generika'	=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelGenerika,
			],
			'hirslanden' => [
				LookandfeelLanguages,
				LookandfeelHirslanden,
			],
			'just-medical'=>	[
				LookandfeelLanguages,
				LookandfeelJustMedical, 
			],
			'konsuminfo'=>	[
				LookandfeelLanguages,
				LookandfeelStandardResult,
				LookandfeelKonsumInfo, 
			],
      'mobile'	=>	[
        LookandfeelLanguages,
        LookandfeelMobile,
      ],
			'mymedi'=>	[
				LookandfeelMyMedi, 
			],
			'oekk'	=>	[
				LookandfeelOekk,
			],
			'sympany'	=>	[
				LookandfeelExtern,
				LookandfeelStandardResult,
				LookandfeelSympany,
			],
			'provita'			=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelStandardResult,
				LookandfeelProvita, 
			],
			'santesuisse' =>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelStandardResult,
				LookandfeelSantesuisse, 
			],
			'swissmedic'	=>	[
				LookandfeelSwissmedic,
			],
			'swissmedinfo'=>	[
				LookandfeelSwissMedInfo, 
			],
      'anthroposophy' => [
        LookandfeelComplementaryType,
        LookandfeelAnthroposophy,
      ],
      'homeopathy' => [
        LookandfeelComplementaryType,
        LookandfeelHomeopathy,
      ],
      'phyto-pharma' => [
        LookandfeelComplementaryType,
        LookandfeelPhytoPharma,
      ],
		}
	end
end
