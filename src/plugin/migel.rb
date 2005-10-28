#!/usr/bin/env ruby
# MiGeLPlugin -- oddb -- 30.08.2005 -- hwyss@ywesee.com

require 'util/persistence'
require 'plugin/plugin'
require 'model/text'
require 'csvparser'
require 'iconv'
require 'date'

module ODDB
	class MiGeLPlugin < Plugin
		SALE_TYPES = {
			'1'	=> :purchase,
			'2' => :rent,
			'3'	=> :both,
		}
		def convert_charset(txt)
			txt = txt.gsub("\317", "oe")
			txt = txt.gsub("\320", "-")
			txt = txt.gsub("\324", " ")
			txt = txt.gsub("\325", "'")
			Iconv.iconv('latin1', 'mac', txt).first
		end
		def date_object(date)
			date = date.split(".")
			if(date.size == 3)
				Date.new(date.at(2).to_i, date.at(1).to_i, date.at(0).to_i)
			end
		end
		def update(path, language)
			CSVParser.parse_with_file(path).each { |row|
				id = row.at(8).split('.')
				id[-1]=id[-1][0,1]
				group = update_group(id, row, language)
				subgroup = update_subgroup(id, group, row, language)
				if(id.size > 2)
					update_product(id, subgroup, row, language)
				end
			}
		end
		def update_group(id, row, language)
			groupcd = id.at(0)
			pointer = Persistence::Pointer.new([:migel_group, groupcd])
			hash = {
				:code => groupcd,
				language  => convert_charset(row.at(1)), 
			}
			group = @app.update(pointer.creator, hash)
			text = convert_charset(row.at(2))
			text.tr!("\v", " ")
			text.strip!
			unless(text.empty?)
				desc_ptr = pointer + [:limitation_text]
				@app.update(desc_ptr.creator, {language => text})
			end
			group
		end
		def update_subgroup(id, group, row, language)
			sgcd = id.at(1)
			pointer = group.pointer + [:subgroup, sgcd]
			hash = {
				:code => sgcd,
				language => convert_charset(row.at(4))
			}
			subgroup = @app.update(pointer.creator, hash)
			text = convert_charset(row.at(5))
			unless(text.empty?)
				lim_ptr = pointer + [:limitation_text]
				@app.update(lim_ptr.creator, {language => text})
			end
			subgroup
		end	
		def update_product(id,  subgroup, row, language)
			productcd = id[2,3].join(".")
			pointer = subgroup.pointer + [:product, productcd]
			input = row.at(9).tr("\t", "")
			text = convert_charset(input)
			text.tr!("\v", "\n")
			limitation = ''
			if(idx = text.index("Limitation"))
				limitation = text[idx..-1].strip
				text = text[0...idx].strip
			else
				text.strip!
			end
			type = SALE_TYPES[id.at(4)]
			price = ((convert_charset(row.at(13)).to_f) * 100).round
			date = date_object(convert_charset(row.at(14)))
			lim_flag = convert_charset(row.at(10))
			hash = {
				language => text,
				:limitation => (lim_flag == 'L'),
				:price => price,
				:type => type,
				:date => date,
			}
			product = @app.update(pointer.creator, hash) 
			if(id[3] != "00")
				1.upto(3) { |num|
					prodcd =  [id[2], '00', num].join('.')
					if(prod = subgroup.product(prodcd))
						product.add_product(prod)
					end
				}
			end
			product_text = convert_charset(row.at(7))
			unless(product_text.empty?)
				pt_ptr = pointer + [:product_text]
				@app.update(pt_ptr.creator, {language => product_text})
			end
			unless(limitation.empty?)
				lim_ptr = pointer + [:limitation_text]
				@app.update(lim_ptr.creator, {language => limitation})
			end
			unless(row.at(12).empty?)
				uni_ptr = pointer + [:unit]
				@app.update(uni_ptr.creator,
					{language => convert_charset(row.at(12))})
			end
			product
		end
	end
end
