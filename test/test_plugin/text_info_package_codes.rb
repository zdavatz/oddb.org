#!/usr/bin/env ruby

# Which package gets which of several Patinfos comes from the 8-digit
# identifiers in the AIPS download (iksnr + ikscd), not from the hand-kept
# etc/barcode_to_text_info.yml any more (11.11.2026).

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "stub/odba"
require "minitest/autorun"
require "flexmock/minitest"
require "stub/oddbapp"
require "plugin/text_info"
require "util/workdir"

class TestTextInfoPackageCodes < Minitest::Test
  CHUNK = <<~XML
    <MedicinalDocumentsBundle>
      <Date>2026-09-08T07:59:04</Date>
      <Domain>Human</Domain>
      <Type>PIL</Type>
      <RegulatedAuthorization>
        <Identifier>70455001</Identifier>
        <Identifier>70455003</Identifier>
        <Identifier>61686</Identifier>
      </RegulatedAuthorization>
      <Holder><Identifier>7601001396685</Identifier><Name>Mepha Pharma AG</Name></Holder>
      <Language>de</Language>
      <AttachedDocument>
        <Language>de</Language>
        <Description>Fexo-Mepha Allergie 180 mg Filmtabletten</Description>
        <Period><Start>2026-08-01T00:00:00</Start></Period>
        <DocumentReference><ContentType>text/html</ContentType><Url>https://files.refdata.ch/x-de.html</Url></DocumentReference>
      </AttachedDocument>
  XML

  def setup
    @plugin = ODDB::TextInfoPlugin.new(flexmock("app"), {})
    @plugin.instance_variable_set(:@iksnr_lang_type, {})
    @plugin.instance_variable_set(:@iksnrs_from_aips, [])
    @plugin.instance_variable_set(:@details_dir, File.join(ODDB::WORK_DIR, "details"))
  end

  def test_the_package_codes_are_kept_per_registration
    infos = @plugin.handle_chunk(CHUNK)
    assert_equal(%w[70455 61686], infos.collect(&:iksnr))
    assert_equal({"70455" => %w[001 003]}, infos.first.package_codes)
    # a 5-digit identifier covers the whole registration: no codes for it
    assert_nil(infos.last.package_codes["61686"])
  end

  def multi_pi_plugin(codes)
    packages = %w[001 002 003].collect { |cd| flexmock("pack #{cd}", ikscd: cd, seqnr: "01") }
    reg = flexmock("reg", packages: packages)
    app = flexmock("app", registration: reg)
    plugin = ODDB::TextInfoPlugin.new(app, {})
    meta = ODDB::SwissmedicMetaInfo.new
    meta.iksnr = "70455"; meta.type = "pi"; meta.lang = "de"; meta.authNrs = ["70455"]
    meta.title = "Fexo-Mepha"; meta.package_codes = codes
    plugin.instance_variable_set(:@iksnrs_meta_info, {%w[70455 pi de] => [meta, meta.clone]})
    plugin.instance_variable_set(:@updated_pis, [])
    stored = []
    flexmock(plugin).should_receive(:store_package_patinfo).and_return { |pack, _lang, _pi| stored << pack.ikscd; true }
    flexmock(plugin).should_receive(:update_html_cache_file)
    [plugin, meta, stored]
  end

  def test_with_several_patinfos_a_package_gets_the_one_that_names_it
    plugin, meta, stored = multi_pi_plugin({"70455" => %w[001 003]})
    plugin.send(:update_patinfo_lang, meta, flexmock("pi"))
    assert_equal(%w[001 003], stored)
    assert_empty(plugin.instance_variable_get(:@unassigned_packages))
  end

  def test_without_codes_nothing_is_stored_and_the_packages_are_reported
    plugin, meta, stored = multi_pi_plugin({})
    plugin.send(:update_patinfo_lang, meta, flexmock("pi"))
    assert_empty(stored)
    assert_equal(3, plugin.instance_variable_get(:@unassigned_packages).size)
  end
end
