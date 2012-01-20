#/usr/bin/env ruby
# encoding: utf-8
# ODDB::OddbDatExport -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::OddbDatExport -- oddb.org -- 23.06.2003 -- aschrafl@ywesee.com

require 'plugin/plugin'
require 'drb'
require 'util/oddbconfig'
require 'util/persistence'
require 'custom/lookandfeelbase'
require 'date'
require 'iconv'
require 'archive/tarsimple'
require 'zip/zip'
require 'fileutils'

module ODDB
	module OdbaExporter
		class AcTable; end
		class AccompTable; end
		class AcLimTable; end
		class AcmedTable; end
		class AcnamTable; end
		class AcOddbTable; end
		class AcpricealgTable; end
		class AcscTable; end
		class LimitationTable; end
		class LimTxtTable; end
		class MCMTable; end
		class CodesTable; end
		class EanTable; end
		class ScTable; end
		class CompTable; end
		class Readme; end
class OddbDatExport < ODDB::Plugin
	EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
	EXPORT_DIR = File.expand_path('../../data/downloads', 
		File.dirname(__FILE__))
	def initialize(app)
		@date = @@today 
		super
	end
	def export
		files = []

		# package tables
		package_tables = [
			AcTable, AccompTable, AcLimTable, AcmedTable, AcnamTable,
			AcOddbTable, AcpricealgTable, AcscTable, LimitationTable,
			LimTxtTable, EanTable
		]
		ids = []
        dose_missing_list = []
		@app.each_package { |pac| 
          ids.push(pac.odba_id) 
          if pac.parts.empty?
            dose_missing_list.push([pac.basename, pac.iksnr, pac.sequence.seqnr, pac.ikscd])
          end
        }

		files += EXPORT_SERVER.export_oddbdat(ids, EXPORT_DIR, package_tables)

		# codes table
		ids = @app.atc_classes.values.collect { |atc| atc.odba_id }
		@app.each_galenic_form { |galform| ids.push(galform.odba_id) }
		files += EXPORT_SERVER.export_oddbdat(ids, EXPORT_DIR, [CodesTable])

		# substances table
		ids = @app.substances.collect { |subs| subs.odba_id }
		files += EXPORT_SERVER.export_oddbdat(ids, EXPORT_DIR, [ScTable])

		# companies table
		ids = @app.companies.collect { |oid, comp| comp.odba_id }
		files += EXPORT_SERVER.export_oddbdat(ids, EXPORT_DIR, [CompTable])

		# readme
		files += EXPORT_SERVER.export_oddbdat(nil, EXPORT_DIR, [Readme])

		# compress
		EXPORT_SERVER.compress_many(EXPORT_DIR, 'oddbdat', files)

        # warning
        return dose_missing_list
	end
  def export_by_company_name(company_name)
    company_name.downcase!
    export_dir = File.join(EXPORT_DIR, company_name.gsub(/\s+/,'_'))
    FileUtils.mkdir_p export_dir
    @options = {:compression => 'zip'}
    @file_path = File.join(export_dir, 'oddbdat_' + company_name.gsub(/\s+/,'_'))
    @packages = 0

    files = []

    # package tables
    package_tables = [
      AcTable, AccompTable, AcLimTable, AcmedTable, AcnamTable,
      AcOddbTable, AcpricealgTable, AcscTable, LimitationTable,
      LimTxtTable, EanTable
    ]
    ids = []
    dose_missing_list = []
    @app.each_package do |pac| 
      if pac.company_name and pac.company_name.downcase =~ /#{company_name}/
        ids.push(pac.odba_id) 
        if pac.parts.empty?
          dose_missing_list.push([pac.basename, pac.iksnr, pac.sequence.seqnr, pac.ikscd])
        end
      end
    end

    @packages = ids.length
    files += EXPORT_SERVER.export_oddbdat(ids, export_dir, package_tables)

    # codes table
    ids = @app.atc_classes.values.select{|at| at.sequences.find{|seq| seq.company_name.downcase =~ /#{company_name}/ if seq.company_name}}.collect { |atc| atc.odba_id }
    @app.each_galenic_form { |galform| ids.push(galform.odba_id) }
    files += EXPORT_SERVER.export_oddbdat(ids, export_dir, [CodesTable])

    # substances table
    ids = @app.substances.values.select{|at| at.sequences.find{|seq| seq.company_name.downcase =~ /#{company_name}/ if seq.company_name}}.collect { |subs| subs.odba_id }
    files += EXPORT_SERVER.export_oddbdat(ids, export_dir, [ScTable])

    # companies table
    ids = @app.companies.values.select{|com| com.name.downcase =~ /#{company_name}/ if com.name}.collect { |comp| comp.odba_id }
    files += EXPORT_SERVER.export_oddbdat(ids, export_dir, [CompTable])

    # fachinfo table
    ids = @app.fachinfos.values.select{|fach| fach.company_name.downcase =~ /#{company_name}/ if fach.company_name}.collect { |fachinfo| fachinfo.odba_id }
    files += EXPORT_SERVER.export_oddbdat(ids, export_dir, [MCMTable])

    # readme
    files += EXPORT_SERVER.export_oddbdat(nil, export_dir, [Readme])

    # compress
    EXPORT_SERVER.compress_many(export_dir, "oddbdat_#{company_name}", files)

    # warning
    return dose_missing_list
	end
	def export_fachinfos
		# fachinfo table
		ids = @app.fachinfos.collect { |oid, fachinfo| fachinfo.odba_id }
		files = EXPORT_SERVER.export_oddbdat(ids, EXPORT_DIR, [MCMTable])
		EXPORT_SERVER.compress(EXPORT_DIR, files.first)
	end
  def log_info
    hash = super
    if @file_path
      if comp = @options[:compression]
        path = @file_path + "." << comp
        type = "application/#{comp}"
      end
      hash.store(:files, { path => type })
    end
    hash
  end
  def report
    if @file_path
      file_path = @file_path + "." + @options[:compression] if @options[:compression]
      [
        "Packages: #{@packages}",
        "File path: #{file_path}", 
      ].join("\n")
    else
      ''
    end
  end
end
	end
end
