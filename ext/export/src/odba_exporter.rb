#!/usr/bin/env ruby
# OdbaExporter -- ODDB -- 09.12.2004 -- hwyss@ywesee.com

require 'fileutils'
require 'tempfile'
require 'archive/tarsimple'
require 'zip/zip'
require 'models'
require 'oddb_yaml'
require 'oddbdat'
require 'odba'

module ODDB
	module OdbaExporter
		def compress(dir, name)
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
		def compress_many(dir, name, files)
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
		def export_yaml(odba_ids, dir, name)
			FileUtils.mkdir_p(dir)
			Tempfile.open(name, dir) { |fh|
				odba_ids.each { |odba_id|
					YAML.dump(ODBA.cache_server.fetch(odba_id, nil), fh)
					ODBA.cache_server.clear
				}
				newpath = File.join(dir, name)
				FileUtils.mv(fh.path, newpath)
				compress(dir, name)
			}
			name
		end
		def export_oddbdat(odba_ids, dir, klasses)
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
		def clear
			Thread.new { 
				sleep 1
				DRb.thread.exit
			}
			nil
		end
		module_function :compress
		module_function :compress_many
		module_function :export_oddbdat
		module_function :export_yaml
		module_function :clear
	end
end
