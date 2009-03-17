#!/usr/bin/env ruby
# State::Substances::Substances -- oddb -- 25.05.2004 -- mhuggler@ywesee.com

require 'state/substances/global'
require 'util/interval'
require 'view/substances/substances'

module ODDB
	module State
		module Substances
class Substances < State::Substances::Global
	include Interval
	VIEW = View::Substances::Substances
	DIRECT_EVENT = :substances
	RANGE_PATTERNS = {
		'a'			=>	'aÅÆÄÁÂÀÃĄǍĂĀȦåæäáâàãąǎăāȧ',
		'b'			=>	'bḂḃ',
		'c'			=>	'cÇĈČĆĊçĉčćċ',
		'd'			=>	'dḐĐÐĎḊḑđðďḋ',
		'e'			=>	'eËÉÊÈȨĘĚĔẼĒĖëéêèȩęěĕẽēė',
		'f'			=>	'fÞḞþḟ',
		'g'			=>	'gĢǦĞǴĜḠĠģǧğǵĝḡġ',
		'h'			=>	'hȞĤḦḨḢȟĥḧḩḣ',
		'i'			=>	'iÏÍÎÌĮǏĬĨİïíîìįǐĭĩı',
		'j'			=>	'jĴĵ',
		'k'			=>	'kǨḰĶǩḱķ',
		'l'			=>	'lŁĹĽĻłĺľļ',
		'm'			=>	'mḾṀḿṁ',
		'n'			=>	'nŇŃÑǸŅṄňńñǹņṅ',
		'o'			=>	'oŒÖÓÔÒÕŌŎØǪǑȮœöóôòõōŏøǫǒȯ',
		'p'			=>	'pṔṖṕṗ',
		'q'			=>	'q',
		'r'			=>	'rŘŔŖṘřŕŗṙ',
		's'			=>	'sŚŜŠŞṠśŝšşṡ',
		't'			=>	'tŤŢṪťţṫ',
		'u'			=>	'uÜÚÛÙŲǗǓǙǛŨŬŮǕüúûùųǘǔǚǜũŭůǖ',
		'v'			=>	'vṼṽ',
		'w'			=>	'wẂŴẀẄẆẃŵẁẅẇ',
		'x'			=>	'xẌẊẍẋ',
		'y'			=>	'yŸẎỸỲŶÝȲÿẏỹỳŷýȳ',
		'z'			=>	'zŽŹẐŻžźẑż',
		'|unknown'=>	'^a-zÅÆÄÁÂÀÃĄǍĂĀȦḂÇĈČĆĊḐĐÐĎḊËÉÊÈȨĘĚĔẼĒĖÞḞĢǦĞǴĜḠĠȞĤḦḨḢÏÍÎÌĮǏĬĨİĴǨḰĶŁĹĽĻḾṀŇŃÑǸŅṄŒÖÓÔÒÕŌŎØǪǑȮṔṖŘŔŖṘŚŜŠŞṠŤŢṪÜÚÛÙŲǗǓǙǛŨŬŮǕṼẂŴẀẄẆẌẊŸẎỸỲŶÝȲŽŹẐŻåæäáâàãąǎăāȧḃçĉčćċḑđðďḋëéêèȩęěĕẽēėþḟģǧğǵĝḡġȟĥḧḩḣïíîìįǐĭĩıĵǩḱķłĺľļḿṁňńñǹņṅœöóôòõōŏøǫǒȯṕṗřŕŗṙśŝšşṡťţṫüúûùųǘǔǚǜũŭůǖṽẃŵẁẅẇẍẋÿẏỹỳŷýȳžźẑż',
	}
	def init
		filter_interval
	end
	def default_interval
		intervals.first || 'a'
	end
end
class EffectiveSubstances < Substances
	DIRECT_EVENT = :effective_substances
end
		end
	end
end
