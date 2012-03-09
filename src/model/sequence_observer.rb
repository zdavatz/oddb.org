#!/usr/bin/env ruby
# encoding: utf-8
# SequenceObserver -- oddb -- 28.11.2003 -- rwaltert@ywesee.com

module ODDB
	module SequenceObserver
		attr_reader :sequences
		def initialize
			@sequences = []
			super
		end
		def add_sequence(seq)
			unless(@sequences.include?(seq))
				@sequences.push(seq) 
				@sequences.odba_isolated_store
			end
			odba_isolated_store # rewrite indices
			seq
		end
		def article_codes
			codes = []
			@sequences.collect { |seq| 
				seq.each_package { |pac|
					cds = {
						:article_ean13 => pac.barcode.to_s,
					}
					if(pcode = pac.pharmacode)
						cds.store(:article_pcode, pcode)
					end
          if(psize = pac.size)
            cds.store(:article_size, psize)
          end
          if(pdose = pac.dose)
            cds.store(:article_dose, pdose.to_s)
          end
					codes.push(cds)
				}
			}
			codes
		end
		def remove_sequence(seq)
			## failsafe-code
			@sequences.delete_if { |s| s.odba_instance.nil? }
			##
			if(@sequences.delete(seq))
				@sequences.odba_isolated_store
			end
			odba_isolated_store # rewrite indices
			seq
		end
		def empty?
			@sequences.empty?
		end
	end
end
