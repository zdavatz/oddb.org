#!/usr/bin/env ruby
# Migrate -- oddb -- 05.03.2003 -- andy@jetnet.ch

$: << File.dirname(__FILE__)

require 'benchmark'

Benchmark.bm { |bm|
	bm.item('swissmedic') { require 'swissmedic_csv.rb' }
	#bm.item('oddb') { require 'oddb_sql.rb' }
	bm.item('bsv') { require 'bsv_csv.rb' }
	bm.item('atc') { require 'atc_csv.rb' }
}
