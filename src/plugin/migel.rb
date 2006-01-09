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
		def date_object(date)
			date = date.split(".")
			if(date.size == 3)
				Date.new(date.at(2).to_i, date.at(1).to_i, date.at(0).to_i)
			end
		end
		def prune_old_revisions
			@revision = Time.local(Time.now.year)
			@app.migel_groups.each_value { |grp|
				grp.subgroups.each_value { |sbg|
					sbg.products.each_value { |prd|
						if((lt = prd.limitation_text) && lt.revision < @revision)
							@app.delete(lt.pointer)
						end
						if((pt = prd.product_text) && pt.revision < @revision)
							@app.delete(pt.pointer)
						end
						if((ut = prd.unit) && ut.revision < @revision)
							@app.delete(ut.pointer)
						end
						if(prd.revision < @revision)
							@app.delete(prd.pointer)
						end
					}
					if((lt = sbg.limitation_text) && lt.revision < @revision)
						@app.delete(lt.pointer)
					end
					if(sbg.products.empty? && sbg.revision < @revision)
						@app.delete(sbg.pointer)
					end
				}
				if((lt = grp.limitation_text) && lt.revision < @revision)
					@app.delete(lt.pointer)
				end
				if(grp.subgroups.empty? && grp.revision < @revision)
					@app.delete(grp.pointer)
				end
			}
		end
		def update(path, language)
			CSVParser.parse_with_file(path).each { |row|
				id = row.at(13).split('.')
				if(id.empty?)
					id = row.at(4).split('.')
				else
					id[-1].replace(id[-1][0,1])
				end
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
				language  => row.at(2), 
			}
			group = @app.update(pointer.creator, hash)
			text = row.at(3)
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
				language => row.at(6),
			}
			subgroup = @app.update(pointer.creator, hash)
			text = row.at(7)
			unless(text.empty?)
				lim_ptr = pointer + [:limitation_text]
				@app.update(lim_ptr.creator, {language => text})
			end
			subgroup
		end	
		def update_product(id,  subgroup, row, language)
			productcd = id[2,3].join(".")
			pointer = subgroup.pointer + [:product, productcd]
			input = row.at(15).gsub(/[ \t]+/, " ")
			text = input
			text.tr!("\v", "\n")
			limitation = ''
			if(idx = text.index("Limitation"))
				limitation = text[idx..-1].strip
				text = text[0...idx].strip
			else
				text.strip!
			end
			type = SALE_TYPES[id.at(4)]
			price = ((row.at(18).to_f) * 100).round
			date = date_object(row.at(20))
			lim_flag = row.at(14)
			hash = {
				language => text,
				:limitation => (lim_flag == 'L'),
				:price => price,
				:type => type,
				:date => date,
			}
			qty = row.at(16).to_i
			if(qty > 0)
				hash.store(:qty, qty)
			end
			product = @app.update(pointer.creator, hash) 
			if(id[3] != "00")
				1.upto(3) { |num|
					prodcd =  [id[2], '00', num].join('.')
					if(prod = subgroup.product(prodcd))
						product.add_product(prod)
					end
				}
			end
			product_text = row.at(12)
			unless(product_text.empty?)
				pt_ptr = pointer + [:product_text]
				@app.update(pt_ptr.creator, {language => product_text})
			end
			unless(limitation.empty?)
				lim_ptr = pointer + [:limitation_text]
				@app.update(lim_ptr.creator, {language => limitation})
			end
			unit = row.at(17)
			unless(unit.empty?)
				uni_ptr = pointer + [:unit]
				@app.update(uni_ptr.creator, {language => unit})
			end
			product
		end
	end
end
