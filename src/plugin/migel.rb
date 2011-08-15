#!/usr/bin/env ruby
# ODDB::MiGeLPlugin -- oddb.org -- 15.08.2011 -- mhatakeyama@ywesee.com
# ODDB::MiGeLPlugin -- oddb.org -- 30.08.2005 -- hwyss@ywesee.com

require 'util/persistence'
require 'plugin/plugin'
require 'model/text'
require 'csv'
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
			date = date.to_s.split(".")
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
      lines = CSV.read(path)
			#CSVParser.parse_with_file(path).each { |row|
      lines.shift
      lines.each { |row|
				id = row.at(13).to_s.split('.')
				if(id.empty?)
					id = row.at(4).to_s.split('.')
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
				language  => row.at(2).to_s, 
			}
			group = @app.update(pointer.creator, hash, :migel)
			text = row.at(3).to_s
			text.tr!("\v", " ")
			text.strip!
			unless(text.empty?)
				desc_ptr = pointer + [:limitation_text]
				@app.update(desc_ptr.creator, {language => text}, :migel)
			end
			group
		end
		def update_subgroup(id, group, row, language)
			sgcd = id.at(1)
			pointer = group.pointer + [:subgroup, sgcd]
			hash = {
				:code => sgcd,
				language => row.at(6).to_s,
			}
			subgroup = @app.update(pointer.creator, hash, :migel)
			text = row.at(7).to_s
			unless(text.empty?)
				lim_ptr = pointer + [:limitation_text]
				@app.update(lim_ptr.creator, {language => text}, :migel)
			end
			subgroup
		end	
		def update_product(id,  subgroup, row, language)
			productcd = id[2,3].join(".")
			pointer = subgroup.pointer + [:product, productcd]
			name = row.at(12).to_s
			product_text = row.at(15).gsub(/[ \t]+/u, " ")
			product_text.tr!("\v", "\n")
			limitation = ''
			if(idx = product_text.index(/Limitation|Limitazione/u))
				limitation = product_text.slice!(idx..-1).strip
			end
			if(name.to_s.strip.empty?)
				name = product_text.slice!(/^[^\n]+/u)
			end
			product_text.strip!
			type = SALE_TYPES[id.at(4)]
			price = ((row.at(18).to_s[/\d[\d.]*/u].to_f) * 100).round
			date = date_object(row.at(20))
			lim_flag = row.at(14)
			hash = {
				language => name,
				:limitation => (lim_flag == 'L'),
				:price => price,
				:type => type,
				:date => date,
			}
			qty = row.at(16).to_i
			if(qty > 0)
				hash.store(:qty, qty)
			end
			product = @app.update(pointer.creator, hash, :migel) 
			unless(product_text.empty?)
				pt_ptr = pointer + [:product_text]
				@app.update(pt_ptr.creator, {language => product_text}, 
									 :migel)
			end
			if(id[3] != "00")
				1.upto(3) { |num|
					prodcd =  [id[2], '00', num].join('.')
					if(prod = subgroup.product(prodcd))
						product.add_product(prod)
					end
				}
			end
			unless(limitation.empty?)
				lim_ptr = pointer + [:limitation_text]
				@app.update(lim_ptr.creator, {language => limitation},
									 :migel)
			end
			unit = row.at(17).to_s
			unless(unit.empty?)
				uni_ptr = pointer + [:unit]
				@app.update(uni_ptr.creator, {language => unit}, :migel)
			end
			product
		end
    def estimate_time(start_time, total, count)
      estimate = (Time.now - start_time) * total / count
      log = count.to_s + " / " + total.to_s + "\t"
      em   = estimate/60
      eh   = em/60
      rest = estimate - (Time.now - start_time)
      rm   = rest/60
      rh   = rm/60
      log << "Estimate total: "
      if eh > 1.0
        log << "%.2f" % eh + " [h]"
      else
        log << "%.2f" % em + " [m]"
      end
      log << " It will be done in: "
      if rh > 1.0
        log << "%.2f" % rh + " [h]\n"
      else
        log << "%.2f" % rm + " [m]\n"
      end
      log
    end
    def update_items_by_migel(time_estimate = false)
      total = @app.migel_count
      start_time = Time.now
      @app.migel_products.each_with_index do |product, count|
        migel_code = product.migel_code.split('.').to_s
        plugin = ODDB::SwissindexNonpharmaPlugin.new(@app)
        if table = plugin.search_migel_table(migel_code)
          table.each do |record|
            if record[:pharmacode]
              update_item(product, record)
            end
          end
        end
        p estimate_time(start_time, total, count + 1) if time_estimate
      end
    end
    def update_item(product, record)
      pointer = product.pointer + [:item, record[:pharmacode]]
      update_values = {
        :pharmacode   => record[:pharmacode],
        :ean_code     => record[:ean_code],
        :article_name => record[:article_name],
        :companyname  => record[:companyname],
        :ppha         => record[:ppha],
        :ppub         => record[:ppub],
        :factor       => record[:factor],
        :size         => record[:size],
        :status       => record[:status],
      }
      @app.update(pointer.creator, update_values, :migel)
    end
	end
end
