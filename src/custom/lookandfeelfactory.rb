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
				LookandfeelExtern,
				LookandfeelAtupri, 
			],
=begin
			'drouwerkerk'=>	[
				LookandfeelExtern,
				LookandfeelDrOuwerkerk, 
			],
=end
			'generika'	=>	[
				LookandfeelExtern,
				LookandfeelGenerika,
			],
=begin
			'innova'			=>	[
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelInnova, 
			],
=end
			'provita'			=>	[
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelProvita, 
			],
			'santesuisse' =>	[
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelSantesuisse, 
			],
=begin
			'schoenenberger' =>	[
				LookandfeelExtern,
				LookandfeelButtons, 
				LookandfeelSchoenenberger, 
			],
=end
		}
	end
end
