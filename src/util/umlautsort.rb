#!/usr/bin/env ruby
# encoding: utf-8
# UmlautSort -- oddb -- 07.07.2003 -- mhuggler@ywesee.com

module ODDB
	module UmlautSort
    FILTER_PAIRS = [
      [/[ÅÁÂÀÃĄǍĂĀȦåáâàãąǎăāȧ]/u, 'a'], [/[Ḃḃ]/u, 'b'], [/[ÇĈČĆĊçĉčćċ]/u, 'c'],
      [/[ḐĐÐĎḊḑđðďḋ]/u, 'd'], [/[ËÉÊÈȨĘĚĔẼĒĖëéêèȩęěĕẽēė]/u, 'e'],
      [/[ÞḞþḟ]/u, 'f'], [/[ĢǦĞǴĜḠĠģǧğǵĝḡġ]/u, 'g'], [/[ȞĤḦḨḢȟĥḧḩḣ]/u, 'h'],
      [/[ÏÍÎÌĮǏĬĨİïíîìįǐĭĩı]/u, 'i'], [/[Ĵĵ]/u, 'j'], [/[ǨḰĶǩḱķ]/u, 'k'],
      [/[ŁĹĽĻłĺľļ]/u, 'l'], [/[ḾṀḿṁ]/u, 'm'], [/[ŇŃÑǸŅṄňńñǹņṅ]/u, 'n'],
      [/[ÓÔÒÕŌŎǪǑȮóôòõōŏøǫǒȯ]/u, 'o'], [/[ṔṖṕṗ]/u, 'p'], [/[ŘŔŖṘřŕŗṙ]/u, 'r'],
      [/[ŚŜŠŞṠśŝšşṡ]/u, 's'], [/[ŤŢṪťţṫ]/u, 't'],
      [/[ÚÛÙŲǗǓǙǛŨŬŮǕúûùųǘǔǚǜũŭůǖ]/u, 'u'], [/[Ṽṽ]/u, 'v'],
      [/[ẂŴẀẄẆẃŵẁẅẇ]/u, 'w'], [/[ẌẊẍẋ]/u, 'x'], [/[ŸẎỸỲŶÝȲÿẏỹỳŷýȳ]/u, 'y'],
      [/[ŽŹẐŻžźẑż]/u, 'z']
    ]
		def sort_model
			if(self::class::SORT_DEFAULT && (@session.event != :sort))
				@model = @model.sort_by { |item| 
					umlaut_filter(item.send(self::class::SORT_DEFAULT))
				} 
			end
		end
    def umlaut_filter(itm)
      if itm.kind_of? String
        itm = itm.downcase
        FILTER_PAIRS.each do |search, replace|
          itm.gsub! search, replace
        end
        itm
      else
        itm
      end
    end
	end
end
