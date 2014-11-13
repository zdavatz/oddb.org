#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::HC_providers::HC_providerList -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::HC_providers::HC_providerList -- oddb.org -- 09.03.2005 -- jlang@ywesee.com

require 'state/global_predefine'
require 'state/hc_providers/hc_provider'
require 'view/hc_providers/hc_providerlist'
require 'model/hc_provider'
require 'model/user'
require 'util/interval'
require 'sbsm/user'

module ODDB
	module State
		module HC_providers
class HC_providerList < State::HC_providers::Global
	include Interval
	attr_reader :range
	DIRECT_EVENT = :hc_providerlist
	VIEW = View::HC_providers::HC_providers
	LIMITED = true
  RANGE_PATTERNS = {
    'a-d'			=>	'a-dÅÆÄÁÂÀÃĄǍĂĀȦḂÇĈČĆĊḐĐÐĎḊåæäáâàãąǎăāȧḃçĉčćċḑđðďḋ',
    'e-h'			=>	'e-hËÉÊÈȨĘĚĔẼĒĖÞḞĢǦĞǴĜḠĠȞĤḦḨḢëéêèȩęěĕẽēėþḟģǧğǵĝḡġȟĥḧḩḣ',
    'i-l'			=>	'i-lÏÍÎÌĮǏĬĨİĴǨḰĶŁĹĽĻïíîìįǐĭĩıĵǩḱķłĺľļ',
    'm-p'			=>	'm-pḾṀŇŃÑǸŅṄŒÖÓÔÒÕŌŎØǪǑȮṔṖḿṁňńñǹņṅœöóôòõōŏøǫǒȯṕṗ',
    'q-t'			=>	'q-tŘŔŖṘŚŜŠŞṠŤŢṪřŕŗṙśŝšşṡťţṫ',
    'u-z'			=>	'u-zÜÚÛÙŲǗǓǙǛŨŬŮǕṼẂŴẀẄẆẌẊŸẎỸỲŶÝȲŽŹẐŻüúûùųǘǔǚǜũŭůǖṽẃŵẁẅẇẍẋÿẏỹỳŷýȳžźẑż',
    'unknown'=>	'unknown',
  }
	#REVERSE_MAP = ResultList::REVERSE_MAP
	def init
		if(!@model.is_a?(Array) || @model.empty?)
			@default_view = ODDB::View::Companies::EmptyResult
		end
		filter_interval
	end
	def symbol
		:name
	end
end
class HC_providerResult < HC_providerList
	DIRECT_EVENT = :result
	def init
		if(@model.empty?)
			@default_view = ODDB::View::HC_providers::EmptyResult
		else
			super
		end
	end
end
		end
	end
end
