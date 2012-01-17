#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Interval -- oddb.org -- 17.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::Interval -- oddb.org -- 03.07.2003 -- hwyss@ywesee.com 

module ODDB
	module Interval
		PERSISTENT_RANGE = false
		RANGE_PATTERNS = {
			'a-d'			=>	'a-dÅÆÄÁÂÀÃĄǍĂĀȦḂÇĈČĆĊḐĐÐĎḊåæäáâàãąǎăāȧḃçĉčćċḑđðďḋ',
			'e-h'			=>	'e-hËÉÊÈȨĘĚĔẼĒĖÞḞĢǦĞǴĜḠĠȞĤḦḨḢëéêèȩęěĕẽēėþḟģǧğǵĝḡġȟĥḧḩḣ',
			'i-l'			=>	'i-lÏÍÎÌĮǏĬĨİĴǨḰĶŁĹĽĻïíîìįǐĭĩıĵǩḱķłĺľļ',
			'm-p'			=>	'm-pḾṀŇŃÑǸŅṄŒÖÓÔÒÕŌŎØǪǑȮṔṖḿṁňńñǹņṅœöóôòõōŏøǫǒȯṕṗ',
			'q-t'			=>	'q-tŘŔŖṘŚŜŠŞṠŤŢṪřŕŗṙśŝšşṡťţṫ',
			'u-z'			=>	'u-zÜÚÛÙŲǗǓǙǛŨŬŮǕṼẂŴẀẄẆẌẊŸẎỸỲŶÝȲŽŹẐŻüúûùųǘǔǚǜũŭůǖṽẃŵẁẅẇẍẋÿẏỹỳŷýȳžźẑż',
			'|unknown'=>	'|unknown',
		}
		FILTER_THRESHOLD = 30
		attr_reader :range
		def default_interval
			intervals.first || 'a-d'
		end
		def filter_interval
			if(@model.size > self::class::FILTER_THRESHOLD)
        ptrns = range_patterns
				@range = ptrns.fetch(user_range) {
					ptrns[default_interval]
				}
				pattern = if(@range=='|unknown')
					/^($|[^a-zÅÆÄÁÂÀÃĄǍĂĀȦḂÇĈČĆĊḐĐÐĎḊËÉÊÈȨĘĚĔẼĒĖÞḞĢǦĞǴĜḠĠȞĤḦḨḢÏÍÎÌĮǏĬĨİĴǨḰĶŁĹĽĻḾṀŇŃÑǸŅṄŒÖÓÔÒÕŌŎØǪǑȮṔṖŘŔŖṘŚŜŠŞṠŤŢṪÜÚÛÙŲǗǓǙǛŨŬŮǕṼẂŴẀẄẆẌẊŸẎỸỲŶÝȲŽŹẐŻåæäáâàãąǎăāȧḃçĉčćċḑđðďḋëéêèȩęěĕẽēėþḟģǧğǵĝḡġȟĥḧḩḣïíîìįǐĭĩıĵǩḱķłĺľļḿṁňńñǹņṅœöóôòõōŏøǫǒȯṕṗřŕŗṙśŝšşṡťţṫüúûùųǘǔǚǜũŭůǖṽẃŵẁẅẇẍẋÿẏỹỳŷýȳžźẑż])/ui
				elsif(@range)
					/^[#{@range}]/ui
				else
					/^$/u
				end

				@filter = Proc.new { |model|
					model.select { |item| 
						pattern.match(item.send(*symbol))
					}
				}
			end
		end
		def get_intervals
			@model.collect { |item| 
				range_patterns.collect { |range, pattern| 
          range if /^[#{pattern}]/iu.match(item.send(*symbol).force_encoding('utf-8'))
				}.compact.first || '|unknown'
			}.flatten.uniq.sort
		end
		def interval
			@interval ||= range_patterns.index(@range)
		end
		def intervals
			@intervals ||= get_intervals
		end
    def range_patterns
      self.class.const_get(:RANGE_PATTERNS)
    end
		def user_range
			range = if(self::class::PERSISTENT_RANGE)
				@session.persistent_user_input(:range)
			else
				@session.user_input(:range)
			end
			unless(intervals.include?(range))
				range = default_interval
			end
			range
		end
		def symbol
			:to_s
		end
	end
	module IndexedInterval
		include Interval
		RANGE_PATTERNS = ('a'..'z').to_a.push('0-9')
		def init
			super
			@model = []
			@filter = method(:filter)
		end
		def comparison_value(item)
			item.send(*symbol).to_s.downcase
		end
		def default_interval
		end
		def load_model
			if((tmp_rng = user_range) && tmp_rng != @range)
				@model.clear
				parts = @range = tmp_rng
				if(@range == '0-9')
					intervals
					parts = @numbers
				end
        if parts.is_a?(String)
          parts.each_char { |part|
            @model.concat(index_lookup(part).sort_by { |item| 
              comparison_value(item)
            })
          }
        else
          parts.each { |part|
            @model.concat(index_lookup(part).sort_by { |item| 
              comparison_value(item)
            })
          }
        end
			end
			@model
		end
		def filter(model)
			load_model
		end
		def interval
			@range
		end
		def index_lookup(query)
			ODBA.cache.retrieve_from_index(index_name, query)
		end
		def index_name
		end
		def intervals
			@intervals or begin
				values = ODBA.cache.index_keys(index_name, 1).delete_if { |key|
					key.empty? }
				@intervals, @numbers = values.partition { |char|
					/[a-z]/ui.match(char)
				}
				unless(@numbers.empty?)
					@intervals.push('0-9')
				end
				@intervals
        rescue KeyError
          []
			end
		end
	end
end
