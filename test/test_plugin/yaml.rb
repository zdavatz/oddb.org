#!/usr/bin/env ruby

# ODDB::TestYamlExporter -- oddb.org -- 22.11.2012 -- yasaka@ywesee.com
# ODDB::TestYamlExporter -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestYamlExporter -- oddb.org -- 02.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "plugin/yaml"
require "util/today"
require "util/logfile"

module ODDB
  @@today = Date.new(2014, 7, 8)
  class TestYamlExporter < Minitest::Test
    def stderr_null
      require "tempfile"
      $stderr = Tempfile.open("stderr")
      yield
      $stderr.close
      $stderr = STDERR
    end

    def replace_constant(constant, temp)
      stderr_null do
        eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end

    def setup
      @app = flexmock("app")
      @server = flexmock("server", export_yaml: "export_yaml")
      @plugin = ODDB::YamlExporter.new(@app)
    end

    def test_export_array
      array = ["item"]
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_array("name", array))
      end
    end

    def test_export_obj
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_obj("name", "obj"))
      end
    end

    def test_export
      flexmock(@app, companies: {"key" => "companies"})
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export)
      end
    end

    def test_export_atc_classes
      atc = flexmock("atc", code: "code")
      flexmock(@app, atc_classes: {"key" => atc})
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_atc_classes)
      end
    end

    def test_export_doctors
      flexmock(@app, doctors: {"key" => "doctors"})
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_doctors)
      end
    end

    def test_export_galenic_forms
      flexmock(@app, galenic_forms: {"key" => "galenic_forms"})
      skip "Don't know how to stub each_galenic_form"
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_galenic_forms)
      end
    end

    def test_export_galenic_groups
      flexmock(@app, galenic_groups: {"key" => "galenic_groups"})
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_galenic_groups)
      end
    end

    def test_export_prices
      package = flexmock("package", prices: {"key" => "price"})
      flexmock(@app, packages: [package])
      replace_constant("ODDB::YamlExporter::EXPORT_SERVER", @server) do
        assert_equal("export_yaml", @plugin.export_prices)
      end
    end
  end
end # ODDB
