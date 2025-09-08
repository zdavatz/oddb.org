#!/usr/bin/env ruby

# ODDB::View::Admin::TestPackage -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "htmlgrid/select"
require "htmlgrid/textarea"
require "htmlgrid/span"
require "htmlgrid/labeltext"
require "view/additional_information"
require "view/admin/package"
require "stub/cgi"

class TestCompositionSelect < Minitest::Test
  def setup
    @session = flexmock("session")
    @model = flexmock("model")
    @select = ODDB::View::Admin::CompositionSelect.new("name", @model, @session)
  end

  def test_selection
    composition = flexmock("composition")
    registration = flexmock("registration", compositions: [composition])
    flexmock(@model,
      composition: composition,
      registration: registration)
    flexmock(@session, language: "language")

    context = flexmock("context", option: "option")
    assert_equal(["option"], @select.selection(context))
  end

  def test_shorten
    expected = "c" * 57 + "..."
    assert_equal(expected, @select.shorten("c" * 70))
  end
end

class TestParts < Minitest::Test
  def setup
    @lookandfeel = flexmock("lookandfeel",
      lookup: "lookup",
      attributes: {},
      event_url: "event_url")
    @model = flexmock("model",
      multi: "multi",
      count: "count",
      commercial_form: "commercial_form",
      measure: "measure",
      pointer: "pointer",
      iksnr: "iksnr",
      seqnr: "seqnr",
      ikscd: "ikscd")
    state = flexmock("state", model: @model)
    @session = flexmock("session",
      lookandfeel: @lookandfeel,
      state: state)
    @parts = ODDB::View::Admin::Parts.new([@model], @session)
  end

  def test_input_text
    flexmock(@model, key: "key")
    keys = [:key]
    ODDB::View::Admin::Parts.input_text(*keys)
    assert_kind_of(HtmlGrid::Input, @parts.key(@model))
  end

  def test_delete
    parts = ODDB::View::Admin::Parts.new([@model, @model], @session)
    assert_kind_of(HtmlGrid::Link, parts.delete(@model))
  end
end

class TestPackageForm < Minitest::Test
  def setup
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    @lookandfeel = flexmock("lookandfeel",
      lookup: "lookup",
      enabled?: false,
      result_list_components: @result_list_components,
      format_date: "format_date",
      attributes: {},
      format_price: "format_price",
      _event_url: "_event_url")
    @session = flexmock("session",
      cgi: CGI.new,
      lookandfeel: @lookandfeel,
      error: "error",
      warning?: nil,
      error?: nil)
    sl_entry = flexmock("sl_entry", pointer: "pointer")
    package = flexmock("package",
      generic_group_factor: 2.5,
      ikskey: "ikskey")
    company = flexmock("company", invoiceable?: "invoiceable?")
    patent = flexmock("patent", certificate_number: "certificate_number", expiry_date: Date.new(2099, 12, 31))
    @model = flexmock("model",
      ikscat: "ikscat",
      lppv: "lppv",
      index_therapeuticus: "index_therapeuticus",
      production_science: "production_science",
      registration_date: "registration_date",
      sequence_date: "sequence_date",
      revision_date: "revision_date",
      expiration_date: "expiration_date",
      market_date: "market_date",
      preview?: "preview",
      patent: patent,
      result_list_components: @result_list_components,
      shortage_state: "shortage_state",
      shortage_link: "shortage_link",
      ith_swissmedic: "ith_swissmedic",
      out_of_trade: "out_of_trade",
      generic_group_factor: 1,
      sl_entry: sl_entry,
      package_patinfo?: false,
      deductible: "deductible",
      company: company,
      seqnr: "seqnr",
      ikscd: "ikscd",
      iksnr: "iksnr",
      ikscat: "ikscat",
      lppv: "lppv",
      sl_generic_type: "sl_generic_type",
      generic_group_comparables: [package])
    @form = ODDB::View::Admin::PackageForm.new(@model, @session)
  end

  def test_init
    assert_nil(@form.init)
  end

  def test_sl_entry
    flexmock(@model, sl_entry: nil)
    flexmock(@lookandfeel, event_url: nil)
    assert_kind_of(HtmlGrid::Link, @form.sl_entry(@model, @session))
  end

  def test_generic_group
    assert_kind_of(HtmlGrid::Textarea, @form.generic_group(@model, @session))
  end
end

class TestPackageComposite < Minitest::Test
  def setup
    @lookandfeel = flexmock("lookandfeel",
      disabled?: nil,
      enabled?: nil,
      attributes: {},
      lookup: "lookup")
    @app = flexmock("app")
    @session = flexmock("session",
      app: @app,
      lookandfeel: @lookandfeel,
      error: "error")
    parent = flexmock("parent", name: "name")
    @model = flexmock("model",
      parent: parent,
      size: "size",
      price_exfactory: "price_exfactory",
      price_public: "price_public")
    @composite = ODDB::View::Admin::PackageComposite.new(@model, @session)
  end

  def test_package_name
    expected = "name&nbsp;-&nbsp;size"
    assert_equal(expected, @composite.package_name(@model, @session))
  end

  def test_source
    flexmock(@model, swissmedic_source: {"swissmedic_source" => "x"})
    assert_kind_of(HtmlGrid::Value, @composite.source(@model, @session))
  end
end

class TestRootPackageComposite < Minitest::Test
  def setup
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    @lookandfeel = flexmock("lookandfeel",
      attributes: {},
      lookup: "lookup",
      format_price: "format_price",
      format_date: "format_date",
      enabled?: false,
      result_list_components: @result_list_components,
      event_url: "event_url",
      _event_url: "_event_url",
      base_url: "base_url")
    @app = flexmock("app")
    state = flexmock("state")
    @session = flexmock("session",
      app: @app,
      lookandfeel: @lookandfeel,
      error: "error",
      warning?: nil,
      cgi: CGI.new,
      error?: nil,
      state: state)
    parent = flexmock("parent", name: "name")
    package = flexmock("package",
      ikskey: "ikskey",
      generic_group_factor: 2.5)
    sl_entry = flexmock("sl_entry", pointer: "pointer")
    part = flexmock("part",
      multi: "multi",
      count: "count",
      measure: "measure",
      commercial_form: "commercial_form")
    company = flexmock("company", invoiceable?: "invoiceable?")
    @model = flexmock("model",
      production_science: "production_science",
      parent: parent,
      registration_date: "registration_date",
      sequence_date: "sequence_date",
      revision_date: "revision_date",
      expiration_date: "expiration_date",
      market_date: "market_date",
      preview?: false,
      patent: flexmock("patent", certificate_number: "certificate_number", expiry_date: Date.new(2099, 12, 31)),
      size: "size",
      out_of_trade: "out_of_trade",
      sl_entry: sl_entry,
      parts: [part],
      pointer: "pointer",
      generic_group_factor: 1,
      generic_group_comparables: [package],
      swissmedic_source: {"swissmedic_source" => "x"},
      index_therapeuticus: "index_therapeuticus",
      ith_swissmedic: "ith_swissmedic",
      shortage_state: "shortage_state",
      shortage_link: "shortage_link",
      iksnr: "iksnr",
      seqnr: "seqnr",
      ikscd: "ikscd",
      package_patinfo?: false,
      deductible: "deductible",
      company: company,
      ikscat: "ikscat",
      lppv: "lppv",
      sl_generic_type: "sl_generic_type")
    flexmock(state, model: @model)
    @composite = ODDB::View::Admin::RootPackageComposite.new(@model, @session)
  end

  def test_init
    expected = {
      "ACCEPT-CHARSET" => "UTF-8",
      "NAME" => "stdform",
      "METHOD" => "POST",
      "ACTION" => "base_url"
    }
    assert_equal(expected, @composite.init)
  end
end

class TestDeductiblePackageComposite < Minitest::Test
  def test_source
    @lookandfeel = flexmock("lookandfeel",
      attributes: {},
      disabled?: nil,
      enabled?: nil,
      lookup: "lookup",
      event_url: "event_url",
      base_url: "base_url")
    @app = flexmock("app")
    state = flexmock("state")
    @session = flexmock("session",
      app: @app,
      error: nil,
      state: state,
      lookandfeel: @lookandfeel)
    parent = flexmock("parent", name: "name")
    part = flexmock("part",
      multi: "multi",
      count: "count",
      measure: "measure",
      commercial_form: "commercial_form")
    @model = flexmock("model",
      parent: parent,
      size: "size",
      parts: [part],
      pointer: "pointer",
      sequence: "sequence",
      price_public: "price_public",
      price_exfactory: "price_exfactory",
      iksnr: "iksnr",
      seqnr: "seqnr",
      ikscd: "ikscd")
    flexmock(state, model: @model)
    @composite = ODDB::View::Admin::DeductiblePackageComposite.new(@model, @session)
    assert_kind_of(HtmlGrid::Value, @composite.source(@model, @session))
  end
end
