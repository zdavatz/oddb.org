#!/usr/bin/env ruby
# AtcCsv -- oddb -- 18.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))

require 'csv'
require 'util/oddbapp'
require 'util/persistence'

oddb = ODDB::App.new
oddb.init
oddb.takeSnapshot
file = File.expand_path('../../data/csv/atc_codes.csv', File.dirname(__FILE__))

CSV.open(file, 'r', ?;) { |cvs_row|
	row = cvs_row.to_a
	atc_pointer = ODDB::Persistence::Pointer.new(['atc_class', row[0]])
	atc = oddb.create(atc_pointer)

	values = {
		'de' => row[2],
	}
	oddb.update(atc_pointer, values)
}
oddb.takeSnapshot
