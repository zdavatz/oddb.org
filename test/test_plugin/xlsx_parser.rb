#!/usr/bin/env ruby
$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "minitest/unit"
require "minitest/hooks/test"
require "util/util"
require "rubyXL"
require "xsv"
require "simple_xlsx_reader"
require "debug"

module ODDB
  class XlsxParserTest < Minitest::Test
    include Minitest::Hooks
    $idParser = 0

    def before_all
      super
      test_file = "Packungen-latest.xlsx"
      @test_xlsx = if File.exist?(test_file)
        test_file
      else
        "test/data/xls/Packungen-latest.xlsx"
      end
      @latest_name = @test_xlsx
      @packages = {}
      @veterinary_products = {}
      @target_keys = Util::COLUMNS_FEBRUARY_2019
      puts "XlsxParserTest: read_packages #{@latest_name} #{(File.size(@latest_name) / 1024).to_i} kB\n\n"
    end

    def print_result(parser_name, nrPackages, duration)
      start = ($idParser == 0) ? "." : ""
      $idParser = $idParser + 1
      puts "#{start}#{sprintf("%20s", parser_name)} read #{nrPackages} packages took #{sprintf("%7.3f", duration)} seconds"
      if (File.size(@latest_name) / 1024) > 500
        assert(nrPackages > 100)
      else
        assert(nrPackages > 5)
      end
    end

    def test_RubyXL_parser
      started = Time.now
      RubyXL::Parser.parse(@latest_name)[0][4..-1].each do |row|
        next unless row[@target_keys.keys.index(:iksnr)].value.to_i &&
          row[@target_keys.keys.index(:seqnr)].value.to_i &&
          row[@target_keys.keys.index(:production_science)].value.to_i
        next if row[@target_keys.keys.index(:production_science)] == "Tierarzneimittel"
        iksnr = "%05i" % row[@target_keys.keys.index(:iksnr)].value.to_i
        seqnr = "%03i" % row[@target_keys.keys.index(:seqnr)].value.to_i
        name_base = row[@target_keys.keys.index(:name_base)].value.to_s
        @packages[iksnr] = {iksnr: iksnr, seqnr: seqnr, name_base: name_base} # IKS_Package.new(iksnr, seqnr, name_base)
      end
      finished = Time.now
      print_result("RubyXL", @packages.size, finished - started)
    end

    def test_Xsv_parser
      started = Time.now
      sheet = Xsv.open(@latest_name).first
      @idx = 0
      begin
        sheet.each do |row|
          @idx += 1
          break if @idx > 10 && row.nil?
          next unless @idx > 4
          next unless row[@target_keys.keys.index(:iksnr)].to_i and
            row[@target_keys.keys.index(:seqnr)].to_i and
            row[@target_keys.keys.index(:production_science)].to_i
          next if row[@target_keys.keys.index(:production_science)] == "Tierarzneimittel"
          iksnr = "%05i" % row[@target_keys.keys.index(:iksnr)].to_i
          seqnr = "%03i" % row[@target_keys.keys.index(:seqnr)].to_i
          name_base = row[@target_keys.keys.index(:name_base)].to_s
          @packages[iksnr] = {iksnr: iksnr, seqnr: seqnr, name_base: name_base}
        end
      rescue
      end
      finished = Time.now
      print_result("Xsv", @packages.size, finished - started)
    end

    def test_SimpleXlsxReader
      started = Time.now
      rows = SimpleXlsxReader.open(@latest_name).sheets.first.rows
      @idx = 0
      begin
        rows.each do |row|
          @idx += 1
          break if @idx > 10 && row.nil?
          next unless @idx > 4
          next unless row[@target_keys.keys.index(:iksnr)].to_i and
            row[@target_keys.keys.index(:seqnr)].to_i and
            row[@target_keys.keys.index(:production_science)].to_i
          next if row[@target_keys.keys.index(:production_science)] == "Tierarzneimittel"
          iksnr = "%05i" % row[@target_keys.keys.index(:iksnr)].to_i
          seqnr = "%03i" % row[@target_keys.keys.index(:seqnr)].to_i
          name_base = row[@target_keys.keys.index(:name_base)].to_s
          @packages[iksnr] = {iksnr: iksnr, seqnr: seqnr, name_base: name_base}
        end
      rescue => err
        puts err
        0
      end
      finished = Time.now
      print_result("SimpleXlsxReader", @packages.size, finished - started)
    end
  end
end
