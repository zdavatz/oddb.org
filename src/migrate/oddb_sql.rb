#!/usr/bin/env ruby
# OddbSql -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))

require 'dbi'
require 'util/oddbapp'
require 'util/persistence'

oddb = ODDB::App.new
oddb.init
oddb.takeSnapshot

galenic_group_pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1])
generic_groups = {}
DBI.connect("dbi:mysql:nachahmer", "nachahmer", "ch5733") { |dbh|
	sql = '	select * 
					from MedicineView order by oddb_key, active_agent_pos'
	handle = dbh.execute(sql)
	handle.each { |row|

		company	= nil
		if(row['company'])
			if(company = oddb.company_by_name(row['company']))
			else
				company_pointer = ODDB::Persistence::Pointer.new(['company'])
				hash = {
					:name	=>	row['company']
				}
				company = oddb.update(company_pointer.creator, hash)
			end
		end

		iksnr = nil
		ikskey = nil
		if(row['iks_key'].length < 8)
			iksnr = row['iks_key']
		else
			iksnr =   row['iks_key'][0..-4]
			ikskey = row['iks_key'][-3..-1]
		end
		pointer = ODDB::Persistence::Pointer.new(['registration', iksnr])
		reg = pointer.resolve(oddb)
		unless(reg)
			reg = oddb.create(pointer)
		end
		values = {
			:company						=>	row['company'],
		}
		if(row['generic_code'].to_i == 20)
			values[:generic_type] = :original
		elsif(row['generic_code'].to_i == 10)
			values[:generic_type] = :generic
		end
		diff = reg.diff(values, oddb)
		oddb.update(pointer, values) unless diff.empty?

		galform = nil
		if(row['galenic_form'])
			galform = oddb.galenic_form(row['galenic_form'])
			if(galform.nil?)
				galform_pointer = galenic_group_pointer + [:galenic_form]
				galform = oddb.create(galform_pointer)
				oddb.update(galform.pointer, {"de"=>row['galenic_form']})
			end
		end

		atc = nil
		if(row['atc_class'])
			atc_pointer = ODDB::Persistence::Pointer.new(['atc_class', row['atc_class']])
			atc = oddb.create(atc_pointer)
		end

		sequence_pointer = nil
		begin
			sequence_pointer = reg.package(ikskey).sequence.pointer
		rescue StandardError
			#puts "unknown sequence " << row['iks_key']
			next_sequence = reg.sequences.keys.max.to_i.next
			sequence_pointer = reg.pointer + ['sequence', next_sequence]
		end
		sequence = sequence_pointer.resolve(oddb)
		unless(sequence)
			sequence = oddb.create(sequence_pointer)
		end
		values = {
			:name_base		=>	row['name_base'],
			:name_descr		=>	row['name_description'],
			:atc_class		=>	row['atc_class'],
			:galenic_form	=>	row['galenic_form'],
		}
		unit = row['dose_unit']
		unit = unit.split(' ').first unless unit.nil?
		values[:dose] = [row['dose'], unit] unless /Kombi/.match(row['dose_unit'])
		diff = sequence.diff(values, oddb)
		oddb.update(sequence_pointer, values) unless diff.empty?
		
		package = nil
		unless(ikskey.nil?)
			package_pointer = sequence_pointer + ['package', ikskey]
			package = package_pointer.resolve(oddb)
			unless(package)
				package = oddb.create(package_pointer)
			end
			values = {
				:size						=>	[row['package_size'], row['package_size_unit']].join(' '),
				:descr						=>	row['package_description'],
				:price_exfactory	=>	row['price_exfactory'],
				:price_public			=>	row['price_public'],
			}
			if(group_id = row['generic_group'].to_i > 0)
				group_pointer = ODDB::Persistence::Pointer.new(['generic_group', package_pointer])
				generic_groups[group_id] ||= oddb.create(group_pointer)
				values[:generic_group] = group_pointer
			end
			diff = package.diff(values, oddb)
			oddb.update(package_pointer, values) unless diff.empty?
		end

		substance = nil
		if(row['active_agent'])
			substance_pointer = ODDB::Persistence::Pointer.new(['substance', row['active_agent']])
			substance = oddb.create(substance_pointer)

			agent = sequence.active_agent(row['active_agent'])
			unless(agent)
				active_agent_pointer = sequence_pointer + ['active_agent', row['active_agent']]
				agent = oddb.create(active_agent_pointer)
				unit = row['active_agent_dose_unit']
				unit = unit.split(' ').first unless unit.nil?
				values = {
					:dose	=>	[row['active_agent_dose'], unit],
				}
				oddb.update(active_agent_pointer, values)
			end
		end
	}
	handle.finish
}
oddb.takeSnapshot
