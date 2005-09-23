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
			chapter = Text::Chapter.new
			paragraph = chapter.next_section.next_paragraph
			chapter.heading = convert_charset(row.at(1))
			text = convert_charset(row.at(2))
			text.tr!("\v", " ")
			paragraph << text
			hash = {
				:code => groupcd,
				language  => chapter, 
			}
			@app.update(pointer.creator, hash)
		end
		def update_subgroup(id, group, row, language)
			sgcd = id.at(1)
			pointer = group.pointer + [:subgroup, sgcd]
			text = convert_charset(row.at(5))
			lim = "limitation_text_#{language}".to_sym
			hash = {
				:code => sgcd,
				language => convert_charset(row.at(4))
			}
			subgroup = @app.update(pointer.creator, hash)
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
			if(idx = text.index("\nLimitation"))
				limitation = text[idx.next..-1]
				text = text[0...idx]
			else
				text.strip!
			end
			if (id.at(4) == '3')
				type = :purchase
			elsif (id.at(4) == '2')
				type = :rent
			else
				type = :sell
			end
			price = (convert_charset(row.at(13)).to_i) * 100
			date = date_object(convert_charset(row.at(14)))
			hash = {
				language => text,
				:price => price,
				:type => type,
				:date => date,
			}
			if(id[3,1] != ["00"])
				prodcd = id[2,1] + ['00'] + id[4,1]
				prodcd = prodcd.join(".")
				prod = subgroup.pointer + [:product, prodcd]
				hash.store(:product, prod)
			end
			product = @app.update(pointer.creator, hash) 
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

