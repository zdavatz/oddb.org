#!/usr/bin/env ruby
# Comparison -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'delegate'

module ODDB
	class Comparison
		include Enumerable
		attr_reader :package, :comparables
		class PackageFacade < SimpleDelegator
			include Comparable
			def initialize(package, original)
				@original = original
				@package = package
				super(package)
			end
			def price_difference
				oprice = @original.price_public.to_f
				pprice = @package.price_public.to_f
				osize = @original.comparable_size.qty.to_f 
				psize = @package.comparable_size.qty.to_f
				unless ( (@original == @package) \
					|| (oprice <= 0) || (pprice <= 0) \
					|| (osize <= 0) || (psize <= 0))
					( (osize * pprice) / (psize * oprice) ) - 1.0
				end
			end
			def <=>(other)
				ppp = @package.price_public.to_i
				opp = other.price_public.to_i
				if([ppp, opp].any? { |pp| pp <= 0 } \
					&& (res = opp-ppp) != 0)
					return res
				end
				res = price_difference.to_f <=> other.price_difference.to_f 
				res = ppp <=> opp if res == 0
				res = @package.comparable_size <=> other.comparable_size if res == 0
				res = @package.name_base <=> other.name_base if res == 0
				res
			end
		end
		def initialize(package)
			@package = PackageFacade.new(package, package)
			@comparables = package.comparables.collect { |pack|
				PackageFacade.new(pack, package)	
			}.sort
			@comparables
		end
		def each
			yield @package 
			@comparables.each { |comp| yield comp }
		end
		def empty?
			@comparables.empty?
		end
		def atc_class
			@package.atc_class
		end
	end
end
