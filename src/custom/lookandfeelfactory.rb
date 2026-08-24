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
      # "just-medical" retired in August 2026: just-medical.oddb.org no longer
      # resolves (NXDOMAIN), the path flavor saw no traffic at all, and the
      # partner's external stylesheet only answers from old.just-medical.ch.
      # Sessions asking for it now fall back to DEFAULT_FLAVOR ("gcc").
      # LookandfeelJustMedical and its theme are still in the tree, so putting
      # the entry back is all it takes to revive the flavor.
      # Unrelated to the med-drugs xls export, which mails
      # med-drugs@just-medical.com via the "ouwerkerk" list.
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
