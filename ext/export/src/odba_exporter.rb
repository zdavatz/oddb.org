#!/usr/bin/env ruby
# OdbaExporter -- ODDB -- 09.12.2004 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'fileutils'
require 'tempfile'
require 'archive/tarsimple'
require 'zip/zip'
require 'models'
require 'oddb_yaml'
require 'oddbdat'
require 'odba'
require 'util/oddbconfig'
require 'etc/db_connection'

module ODBA
	class CacheEntry
		remove_const :CLEAN_PREFETCHABLE
		CLEAN_PREFETCHABLE = true
		remove_const :RETIRE_TIME
		RETIRE_TIME = 150
		remove_const :DESTROY_TIME
		DESTROY_TIME =  300
	end
end
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
				files.each { |name|
					zos.put_next_entry(name)
					zos.puts File.read(name)
				}
			}
			FileUtils.mv(zip_name, name + '.zip')
		end
		def export_yaml(odba_ids, dir, name)
			FileUtils.mkdir_p(dir)
			Tempfile.open(name, dir) { |fh|
				odba_ids.each { |odba_id|
					fh.puts ODBA.cache_server.fetch(odba_id, nil).to_yaml
				}
				newpath = File.join(dir, name)
				FileUtils.mv(fh.path, newpath)
				compress(dir, name)
			}
			nil
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
		module_function :compress
		module_function :compress_many
		module_function :export_oddbdat
		module_function :export_yaml
	end
end

DRb.start_service(ODDB::EXPORT_URI, ODDB::OdbaExporter)

$0 = "Oddb (FiParse)"

DRb.thread.join
