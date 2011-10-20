#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::LookandfeelFactory -- oddb.org -- 20.10.2011 -- mhatakeyama@ywesee.com 
# ODDB::LookandfeelFactory -- oddb.org -- 24.10.2002 -- hwyss@ywesee.com 

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
      'desitin' => [
        LookandfeelDesitin,
      ],
			'generika'	=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelGenerika,
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
			'mymigel'=>	[
				LookandfeelMyMigel, 
			],
			'oekk'	=>	[
				LookandfeelOekk,
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
        LookandfeelLanguages,
        LookandfeelComplementaryType,
        LookandfeelAnthroposophy,
      ],
      'homeopathy' => [
        LookandfeelLanguages,
        LookandfeelComplementaryType,
        LookandfeelHomeopathy,
      ],
      'phyto-pharma' => [
        LookandfeelLanguages,
        LookandfeelComplementaryType,
        LookandfeelPhytoPharma,
      ],
		}
	end
end
