#!/usr/bin/env ruby

# ODDB::LookandfeelFactory -- oddb.org -- 20.10.2011 -- mhatakeyama@ywesee.com
# ODDB::LookandfeelFactory -- oddb.org -- 24.10.2002 -- hwyss@ywesee.com

require "sbsm/lookandfeelfactory"
require "custom/lookandfeelbase"
require "custom/lookandfeelwrapper"

module ODDB
  class LookandfeelFactory < SBSM::LookandfeelFactory
    BASE = LookandfeelBase
    WRAPPERS = {
      "desitin" => [
        LookandfeelDesitin
      ],
      "generika"	=>	[
        LookandfeelLanguages,
        LookandfeelExtern,
        LookandfeelGenerika
      ],
      "just-medical" =>	[
        LookandfeelLanguages,
        LookandfeelJustMedical
      ],
      "mobile"	=>	[
        LookandfeelLanguages,
        LookandfeelMobile
      ],
      "oekk"	=>	[
        LookandfeelOekk
      ],
      "swissmedic"	=>	[
        LookandfeelSwissmedic
      ],
      "swissmedinfo" =>	[
        LookandfeelSwissMedInfo
      ],
      "anthroposophy" => [
        LookandfeelLanguages,
        LookandfeelComplementaryType,
        LookandfeelAnthroposophy
      ],
      "homeopathy" => [
        LookandfeelLanguages,
        LookandfeelComplementaryType,
        LookandfeelHomeopathy
      ],
      "phyto-pharma" => [
        LookandfeelLanguages,
        LookandfeelComplementaryType,
        LookandfeelPhytoPharma
      ]
    }
  end
end
