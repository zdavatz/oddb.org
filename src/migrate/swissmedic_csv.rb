#!/usr/bin/env ruby
# SwissmedicCsv -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))

require 'csv'
require 'util/oddbapp'
require 'util/persistence'

oddb = ODDB::App.new
oddb.init
oddb.takeSnapshot
file = File.expand_path('../../data/csv/swissmedic.csv', File.dirname(__FILE__))

galenic_group_pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1])
CSV.open(file, 'r', ?;) { |cvs_row|
	row = cvs_row.to_a
	#puts (row[3,1] + row[7,2] + row[11,2] + row[17,2]).join(';')

	company	= nil
	if(row[10])
		company = if(comp = oddb.company_by_name(row[10]))
			comp
		else
			company_pointer = ODDB::Persistence::Pointer.new(['company'])
			hash = {
				:name =>	row[10]
			}
			oddb.update(company_pointer.creator, hash)
		end
	end

	pointer = ODDB::Persistence::Pointer.new(['registration', row[0]])
	reg = pointer.resolve(oddb)
	unless(reg)
		reg = oddb.create(pointer)
	end
	values = {
		:registration_date	=>	row[20],
		:company						=>	company.oid,
	}
	diff = reg.diff(values, oddb)
	oddb.update(pointer, values) unless diff.empty?

	galform = nil
	if(row[15])
		galform = oddb.galenic_form(row[15])
		if(galform.nil?)
			galform_pointer = galenic_group_pointer + [:galenic_form]
			galform = oddb.create(galform_pointer)
			oddb.update(galform.pointer, {"de"=>row[15]})
		end
	end

	atc = nil
	if(row[19])
		atc_pointer = ODDB::Persistence::Pointer.new(['atc_class', row[19]])
		atc = oddb.create(atc_pointer)
	end

	sequence_pointer = pointer + ['sequence' , row[2]]
	sequence = sequence_pointer.resolve(oddb)
	unless(sequence)
		sequence = oddb.create(sequence_pointer)
	end
	values = {
		:name					=>	row[3],
		:atc_class		=>	row[19],
		:galenic_form	=>	row[15],
	}
	unit = row[7]
	unit = unit.split(' ').first unless unit.nil?
	values[:dose] = [row[6], unit] unless /Kombi/.match(row[7])
	diff = sequence.diff(values, oddb)
	oddb.update(sequence_pointer, values) unless diff.empty?
	
	package = nil
	unless(row[1].nil?)
		package_pointer = sequence_pointer + ['package', row[1]]
		package = package_pointer.resolve(oddb)
		unless(package)
			package = oddb.create(package_pointer)
		end
		ikscat = row[14]
		unless(/[ABCDE]|Sp/.match(ikscat.to_s))
			ikscat = row[8]
		end
		values = {
			:size		=>	row[11,2].join(' '),
			:descr	=>	row[13],
			:ikscat	=>	ikscat,
		}
		diff = package.diff(values, oddb)
		oddb.update(package_pointer, values) unless diff.empty?
	end

	substance = nil
	if(row[16])
		substance_pointer = ODDB::Persistence::Pointer.new(['substance', row[16]])
		substance = oddb.create(substance_pointer)

		agent = sequence.active_agent(row[16])
		unless(agent)
			active_agent_pointer = sequence_pointer + ['active_agent', row[16]]
			agent = oddb.create(active_agent_pointer)
			unit = row[18]
			unit = unit.split(' ').first unless unit.nil?
			values = {
				:dose	=>	[row[17], unit],
			}
			oddb.update(active_agent_pointer, values)
		end
	end
}
oddb.takeSnapshot
