#!/usr/bin/env ruby
# OdbaExporter -- ODDB -- 09.12.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'tempfile'
require 'archive/tarsimple'
require 'zip/zip'
require 'models'
require 'model/migel/group'
require 'oddb_yaml'
require 'csv_exporter'
require 'oddbdat'
require 'odba'

module ODDB
	module OdbaExporter
		def OdbaExporter.clear
			Thread.new { 
				sleep 1
				DRb.thread.exit
			}
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
			gzwriter.close unless gzwriter.nil?
			zipwriter.close unless zipwriter.nil?
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
		def OdbaExporter.export_doc_csv(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
				fh << <<-HEAD
ean13;exam;salutation;title;firstname;name;praxis;addresstype;address;location;canton;fons;faxs;email;language
				HEAD
				odba_ids.each { |odba_id|
					item = ODBA.cache_server.fetch(odba_id, nil)
					CsvExporter.dump(CsvExporter::DOCTOR, item, fh)
					ODBA.cache_server.clear
				}
			}
		end
		def OdbaExporter.export_migel_csv(odba_ids, dir, name)
			safe_export(dir, name) { |fh|
			fh << <<-HEAD
migel_code;group_code;group_de;group_fr;group_it;group_limitation_de;group_limitation_fr;group_limitation_it;subgroup_code;subgroup_de;subgroup_fr;subgroup_it;subgroup_limitation_de;subgroup_limitation_fr;subgroup_limitation_it;product_code;product_de;product_fr;product_it;accessory_code;accessory_de;accessory_fr;accessory_it;product_limitation_de;product_limitation_fr;product_limitation_it;price;unit_de;unite_fr;unite_it;limitation_flag;date
				HEAD
					odba_ids.each { |odba_id|
					item = ODBA.cache_server.fetch(odba_id, nil)
					CsvExporter.dump(CsvExporter::MIGEL, item, fh)
					ODBA.cache_server.clear
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
					item = ODBA.cache_server.fetch(odba_id, nil)
					files.each { |file, table|
						file.puts table.lines(item)
					}
					ODBA.cache_server.clear
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
					YAML.dump(ODBA.cache_server.fetch(odba_id, nil), fh)
					fh.puts
					ODBA.cache_server.clear
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
				compress(dir, name)
			}
			name
		end
	end
end
