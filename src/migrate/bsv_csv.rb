#!/usr/bin/env ruby
# BsvCsv -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))

require 'csv'
require 'util/oddbapp'
require 'util/persistence'

oddb = ODDB::App.new
oddb.init
oddb.takeSnapshot
file = File.expand_path('../../data/csv/bsv.csv', File.dirname(__FILE__))

CSV.open(file, 'r', ?;) { |cvs_row|
	row = cvs_row.to_a

	package, pointer, iksnr, ikskey = nil
	unless(row[4].length < 7)
		iksnr = row[4][0..-4]
		ikskey = row[4][-3..-1]
		pointer = ODDB::Persistence::Pointer.new(['registration', iksnr], ['package', ikskey])
		begin
			package = pointer.resolve(oddb)
		rescue(ODDB::Persistence::UninitializedPathError)
			package = nil
			puts $!.message
		end
	end

	unless(package.nil?)
		values = {
			:price_exfactory	=>	row[8],
			:price_public			=>	row[9],
		}
		diff = package.diff(values, oddb)
		oddb.update(pointer, values) unless diff.empty?

		sl_pointer = pointer + 'sl_entry'
		sl_entry = oddb.create(sl_pointer)
		values = {
			:introduction_date	=>	row[6],
			:limitation					=>	row[10],
			:limitation_points	=>	row[11],
		}
		diff = sl_entry.diff(values, oddb)
		oddb.update(sl_pointer, values) unless diff.empty?
	end
}
oddb.takeSnapshot
