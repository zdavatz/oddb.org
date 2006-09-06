#!/usr/bin/env ruby
# OdbaExporter -- ODDB -- 09.12.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'tempfile'
require 'archive/tarsimple'
require 'zip/zip'
require 'models'
require 'model/analysis/group'
require 'model/migel/group'
require 'oddb_yaml'
require 'csv_exporter'
require 'oddbdat'
require 'generics_xls'
require 'competition_xls'
require 'odba'

module ODBA
	class Stub
		def to_yaml(*args)
			odba_instance.to_yaml(*args)
		end
	end
end
module ODDB
	module OdbaExporter
		def OdbaExporter.clear
begin
			Thread.new { 
				sleep 1
				DRb.thread.exit
			}
end
			nil
		end
		def OdbaExporter.compress(dir, name)
			FileUtils.mkdir_p(dir)
			Dir.chdir(dir)
			tmp_name = name + '.tmp'
			gz_name = tmp_name + '.gz'
			zip_name = tmp_name + '.zip'
			gzwriter = 	Zlib::GzipWriter.open(gz_name)
			zipwriter = Zip::ZipOutputStream.open(zip_name)
			zipwriter.put_next_entry(name)
			File.open(name, "r") { |fh|
				fh.each { |line|
					gzwriter << line
					zipwriter.puts(line)
				}
			}
			FileUtils.mv(gz_name, name + '.gz')
			FileUtils.mv(zip_name, name + '.zip')
			name
		ensure
			gzwriter.close if(gzwriter)
			zipwriter.close if(zipwriter)
		end
		def OdbaExporter.compress_many(dir, name, files)
			FileUtils.mkdir_p(dir)
			Dir.chdir(dir)
			tmp_name = name + '.tmp'
			tar_name = tmp_name + '.tar'
			gz_name = tar_name + '.gz'
			File.delete(gz_name) if(File.exist?(gz_name))
			tar_archive = Archive::Tar.new(tar_name)
			tar_archive.create_archive(files.join(" "))
			tar_archive.compress_archive
			FileUtils.mv(gz_name, name + '.tar.gz')

			zip_name = tmp_name + '.zip'
			File.delete(zip_name) if(File.exist?(zip_name))
			Zip::ZipOutputStream.open(zip_name) { |zos|
				files.each { |fname|
					zos.put_next_entry(fname)
					zos.puts File.read(fname)
				}
			}
			FileUtils.mv(zip_name, name + '.zip')
			name
		end
		def OdbaExporter.export_competition_xls(comp_id, dir, name, db_path=nil)
			safe_export(dir, name) { |fh|
				exporter = CompetitionXls.new(fh.path, db_path)
				company = ODBA.cache.fetch(comp_id)
				exporter.export_competition(company)
				exporter.close
			}
		end
		def OdbaExporter.export_doc_csv(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
				fh << <<-HEAD
ean13;exam;salutation;title;firstname;name;praxis;addresstype;address_name;lines;address;plz;city;canton;fon;fax;email;language;specialities
				HEAD
				odba_ids.each { |odba_id|
					item = ODBA.cache.fetch(odba_id, nil)
					CsvExporter.dump(CsvExporter::DOCTOR, item, fh)
					#ODBA.cache.clear
				}
			}
		end
		def OdbaExporter.export_generics_xls(dir, name)
			safe_export(dir, name) { |fh|
				exporter = GenericXls.new(fh.path)
				exporter.export_generics
				exporter.close
			}
		end
		def OdbaExporter.export_analysis_csv(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
			fh << <<-HEAD
groupcd;poscd;anonymouspos;analysis_description_de;analysis_description_fr;analysis_footnote_de;analysis_footnote_fr;analysis_taxnote_de;analysis_taxnote_fr;analysis_limitation_de;analysis_limitation_fr;analysis_list_title_de;analysis_list_title_fr;lab_areas;taxpoints;finding;analysis_permissions_de;analysis_permissions_fr
				HEAD
					odba_ids.each { |odba_id|
						item = ODBA.cache.fetch(odba_id, nil)
						CsvExporter.dump(CsvExporter::ANALYSIS, item, fh)	
					}
			}
		end
		def OdbaExporter.export_migel_csv(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
			fh << <<-HEAD
migel_code;group_code;group_de;group_fr;group_it;group_limitation_de;group_limitation_fr;group_limitation_it;subgroup_code;subgroup_de;subgroup_fr;subgroup_it;subgroup_limitation_de;subgroup_limitation_fr;subgroup_limitation_it;product_code;product_de;product_fr;product_it;accessory_code;accessory_de;accessory_fr;accessory_it;product_limitation_de;product_limitation_fr;product_limitation_it;price;unit_de;unite_fr;unite_it;limitation_flag;date
				HEAD
					odba_ids.each { |odba_id|
					item = ODBA.cache.fetch(odba_id, nil)
					CsvExporter.dump(CsvExporter::MIGEL, item, fh)
					#ODBA.cache.clear
				}
			}
		end
		def OdbaExporter.export_narcotics_csv(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
				odba_ids.each { |odba_id|
					item = ODBA.cache.fetch(odba_id, nil)
					CsvExporter.dump(CsvExporter::NARCOTIC, item, fh)
					#ODBA.cache.clear
				}
			}
		end
		def OdbaExporter.export_oddbdat(odba_ids, dir, klasses)
			FileUtils.mkdir_p(dir)
			files = klasses.collect { |klass| 
				table = klass.new
				file = Tempfile.new(table.filename, dir)
				[file, table]
			}
			if(odba_ids.nil?)
				files.each { |file, table|
					file.puts table.lines
				}
			else
				odba_ids.each { |odba_id|
					item = ODBA.cache.fetch(odba_id, nil)
					files.each { |file, table|
						file.puts table.lines(item)
					}
					#ODBA.cache.clear
				}
			end
			files.each { |file, table|
				path = File.join(dir, table.filename)
				FileUtils.mv(file.path, path)
			}
			files.collect { |file, table| table.filename }
		ensure
			if(files)
				files.each { |file, table| file.close! }
			end
		end
		def OdbaExporter.export_yaml(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
				odba_ids.each { |odba_id|
					YAML.dump(ODBA.cache.fetch(odba_id, nil), fh)
					fh.puts
					#ODBA.cache.clear
					$stdout.flush
				}
			}
		end
		def OdbaExporter.safe_export(dir, name, &block)
			FileUtils.mkdir_p(dir)
			Tempfile.open(name, dir) { |fh|
				block.call(fh)
				fh.flush
				newpath = File.join(dir, name)
				FileUtils.mv(fh.path, newpath)
				FileUtils.chmod(0644, newpath)
				compress(dir, name)
			}
			name
		end
	end
end
