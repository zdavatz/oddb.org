#!/usr/bin/env ruby
# Benchmark -- oddb -- 03.03.2003 -- andy@jetnet.ch

require 'benchmark'

ITERATIONS = 1000000

Benchmark.bmbm { |bm|
	bm.item('downcases') {
		ITERATIONS.times { 
			'Aspirin'.downcase.index('Aspirin'.downcase) 
	
		}
	}
	bm.item('regexp') {
		ITERATIONS.times {
			/Aspirin/i.match('Aspirin')
		}
	}
}
