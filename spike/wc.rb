#!/usr/bin/env ruby
# wcspike -- oddb -- 05.12.2002 -- hwyss@ywesee.com 

path = ''
if ARGV.size == 1
	path = ARGV[0]
else
	path = __FILE__
end

require 'benchmark'

Benchmark.bm { |bm|
	bm.item("File.open{ read }") {
		f = File.open(path){|fh| fh.read}
		nl = f.count("\n")
		nw = f.tr_s("^\t\n\v\f\r ", "x").count("x")
		nc = f.size
		puts "    #{nl}    #{nw}    #{nc} #{ARGV[0]}"
	}
	bm.item("File.read") {
		f = File.read(path)
		nl = f.count("\n")
		nw = f.tr_s("^\t\n\v\f\r ", "x").count("x")
		nc = f.size
		puts "    #{nl}    #{nw}    #{nc} #{ARGV[0]}"
	}
	bm.item("File.open") {
		File.open(path) { |f|
			nl = f.count("\n")
			nw = f.tr_s("^\t\n\v\f\r ", "x").count("x")
			nc = f.size
			puts "    #{nl}    #{nw}    #{nc} #{ARGV[0]}"
		}
	}
}
