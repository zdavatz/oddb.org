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
			'generika'	=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelGenerika,
			],
			'mymedi'=>	[
				LookandfeelMyMedi, 
			],
			'hirslanden' => [
				LookandfeelLanguages,
				LookandfeelHirslanden,
			],
			'just-medical'=>	[
				LookandfeelLanguages,
				LookandfeelExtern,
				LookandfeelJustMedical, 
			],
			'konsuminfo'=>	[
				LookandfeelLanguages,
				LookandfeelStandardResult,
				LookandfeelKonsumInfo, 
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
				LookandfeelStandardResult,
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
		}
	end
end
