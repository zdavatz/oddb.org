#!/usr/bin/env ruby

# ODDB::State::Pharmacies::PharmacyList -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Pharmacies::PharmacyList -- oddb.org -- 09.03.2005 -- jlang@ywesee.com

require "state/global_predefine"
require "state/pharmacies/pharmacy"
require "view/pharmacies/pharmacylist"
require "model/user"
require "util/interval"
require "sbsm/user"

module ODDB
  module State
    module Pharmacies
      class PharmacyList < State::Pharmacies::Global
        include Interval
        attr_reader :range
        DIRECT_EVENT = :pharmacylist
        VIEW = View::Pharmacies::Pharmacies
        LIMITED = true
        RANGE_PATTERNS = {
          "a-d"	=>	"a-dÅÆÄÁÂÀÃĄǍĂĀȦḂÇĈČĆĊḐĐÐĎḊåæäáâàãąǎăāȧḃçĉčćċḑđðďḋ",
          "e-h"	=>	"e-hËÉÊÈȨĘĚĔẼĒĖÞḞĢǦĞǴĜḠĠȞĤḦḨḢëéêèȩęěĕẽēėþḟģǧğǵĝḡġȟĥḧḩḣ",
          "i-l"	=>	"i-lÏÍÎÌĮǏĬĨİĴǨḰĶŁĹĽĻïíîìįǐĭĩıĵǩḱķłĺľļ",
          "m-p"	=>	"m-pḾṀŇŃÑǸŅṄŒÖÓÔÒÕŌŎØǪǑȮṔṖḿṁňńñǹņṅœöóôòõōŏøǫǒȯṕṗ",
          "q-t"	=>	"q-tŘŔŖṘŚŜŠŞṠŤŢṪřŕŗṙśŝšşṡťţṫ",
          "u-z"	=>	"u-zÜÚÛÙŲǗǓǙǛŨŬŮǕṼẂŴẀẄẆẌẊŸẎỸỲŶÝȲŽŹẐŻüúûùųǘǔǚǜũŭůǖṽẃŵẁẅẇẍẋÿẏỹỳŷýȳžźẑż",
          "unknown" =>	"unknown"
        }
        # REVERSE_MAP = ResultList::REVERSE_MAP
        def init
          if !@model.is_a?(Array) || @model.empty?
            @default_view = ODDB::View::Companies::EmptyResult
          end
          filter_interval
        end

        def symbol
          :name
        end
      end

      class PharmacyResult < PharmacyList
        DIRECT_EVENT = :result
        def init
          if @model.empty?
            @default_view = ODDB::View::Pharmacies::EmptyResult
          else
            super
          end
        end
      end
    end
  end
end
