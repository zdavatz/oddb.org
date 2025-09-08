#!/usr/bin/env ruby

# View::Drugs::TestPackage -- oddb -- 23.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/drugs/package"
require "htmlgrid/span"
require "model/index_therapeuticus"
require "sbsm/validator"
require "model/galenicgroup"
require "model/package"
require "state/drugs/compare"
require "stub/cgi"

module ODDB
  class Session
    DEFAULT_FLAVOR = "gcc" unless defined?(DEFAULT_FLAVOR)
  end
end

class StubContainer
  attr_accessor :additional_javascripts
end

class TestPackageInnerComposite < Minitest::Test
  def setup
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    @lookandfeel = flexmock("lookandfeel",
      format_date: "format_date",
      result_list_components: @result_list_components,
      lookup: "lookup",
      enabled?: nil,
      language: "language",
      disabled?: nil,
      attributes: {},
      _event_url: "_event_url")
    atc_class = flexmock("atc_class",
      description: "description",
      code: "code",
      has_ddd?: true,
      parent_code: "parent_code",
      pointer: "pointer")
    @app = flexmock("app", atc_class: atc_class)
    @session = flexmock("session",
      lookandfeel: @lookandfeel,
      error: "error",
      app: @app,
      language: "language",
      cgi: CGI.new,
      persistent_user_input: "persistent_user_input")
    @pointer = flexmock("pointer")
    patent = flexmock("patent", certificate_number: "certificate_number", expiry_date: Date.new(2099, 12, 31))
    @model = flexmock("model",
      ikscat: "ikscat",
      lppv: "lppv",
      preview?: "preview",
      patent: patent,
      result_list_components: @result_list_components,
      registration_date: "registration_date",
      sequence_date: "sequence_date",
      revision_date: "revision_date",
      market_date: "market_date",
      expiration_date: "expiration_date",
      narcotic?: nil,
      ddd_price: "ddd_price",
      production_science: "production_science",
      shortage_state: "shortage_state",
      shortage_link: "shortage_link",
      sl_entry: nil,
      atc_class: atc_class,
      parallel_import: "parallel_import",
      name: "name",
      name_base: "name_base",
      index_therapeuticus: "index_therapeuticus",
      ikskey: "ikskey",
      ith_swissmedic: "ith_swissmedic",
      price_exfactory: "price_exfactory",
      deductible: "deductible",
      price_public: "price_public",
      pointer: @pointer,
      sl_generic_type: "sl_generic_type")
    ith = flexmock("ith", language: "language")
    flexmock(ODDB::IndexTherapeuticus, find_by_code: ith)
    @container = flexmock("container", StubContainer.new)
    @container.should_receive(:additional_javascripts).and_return([])
    @composite = ODDB::View::Drugs::PackageInnerComposite.new(@model, @session, @container)
  end

  def test_init
    assert_equal({}, @composite.init)
  end

  def test_init__narcotic
    flexmock(@model, narcotic?: true)
    flexmock(@pointer, :+ => @pointer)
    assert_equal({}, @composite.init)
  end

  def test_init__feedback
    flexmock(@lookandfeel, enabled?: true)
    flexmock(@composite, hash_insert_row: "hash_insert_row")
    flexmock(@model,
      fachinfo_active?: nil,
      has_fachinfo?: nil,
      localized_name: "localized_name",
      has_patinfo?: nil)
    flexmock(@session, allowed?: nil)
    assert_equal({}, @composite.init)
  end

  def test_init__patinfos
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).never.with(:feedback).and_return(false)
      l.should_receive(:enabled?).never.with(:fachinfos).and_return(false)
      l.should_receive(:enabled?).never.with(:patinfos).and_return(true)
      l.should_receive(:enabled?).never.with(:popup_links, false)
      l.should_receive(:enabled?).never.with(:ddd_chart)
    end
    flexmock(@model, has_patinfo?: nil)
    flexmock(@composite, hash_insert_row: "hash_insert_row")
    assert_equal({}, @composite.init)
  end

  def test_init__sl_entry
    flexmock(@model,
      sl_entry: "sl_entry",
      limitation_text: "limitation_text")
    flexmock(@composite, hash_insert_row: "hash_insert_row")
    assert_equal({}, @composite.init)
  end

  def test_init__limitation_text
    @composite.instance_eval("components[[1,2,3]] = :limitation_text", __FILE__, __LINE__)
    limitation_text = flexmock("limitation_text", language: "language")
    flexmock(@model, limitation_text: limitation_text)
    assert_equal({}, @composite.init)
  end

  def test_introduction_date
    # before 2019.02.13 was assert_kind_of(HtmlGrid::DateValue, @composite.introduction_date(@model, @session))
    assert_nil(@composite.introduction_date(@model, @session))
  end
end

class TestODDBViewDrugsPackageComposite < Minitest::Test
  def setup
    dose = flexmock("dose", qty: "qty", unit: "unit")
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    @lookandfeel = flexmock("lookandfeel",
      result_list_components: @result_list_components,
      format_date: "format_date",
      enabled?: nil,
      language: "language",
      lookup: "lookup",
      disabled?: nil,
      attributes: {},
      _event_url: "_event_url").by_default
    atc_class = flexmock("atc_class",
      description: "description",
      code: "code",
      has_ddd?: true,
      parent_code: "parent_code",
      pointer: "pointer")
    @app = flexmock("app", atc_class: atc_class)
    @session = flexmock("session",
      lookandfeel: @lookandfeel,
      error: "error",
      app: @app,
      cgi: ::CGI.new,
      language: "language",
      state: "state",
      persistent_user_input: "persistent_user_input")
    substance = flexmock("substance", language: "language")
    galenic_form = flexmock("galenic_form", language: "language")
    parent = flexmock("parent", galenic_form: galenic_form)
    @active_agent = flexmock("active_agent",
      is_active_agent: true,
      oid: "oid",
      more_info: "more_info",
      chemical_substance: nil,
      substance: substance,
      dose: dose,
      parent: parent)
    @commercial_form = flexmock("commercial_form", language: "language")
    excipiens = flexmock("excipiens",
      more_info: "more_info",
      oid: "oid",
      is_active_agent: false,
      dose: dose,
      substance: substance,
      parent: parent)
    composition = flexmock("composition",
      label: "label",
      oid: "oid",
      excipiens: excipiens,
      active_agents: [@active_agent],
      corresp: "corresp",
      galenic_form: galenic_form,
      inactive_agents: [])
    part = flexmock("part",
      oid: "oid",
      multi: "multi",
      count: "count",
      measure: "measure",
      composition: composition,
      active_agents: [@active_agent],
      commercial_form: @commercial_form)
    sequence = flexmock("sequence",
      division: "division",
      iksnr: "iksnr",
      seqnr: "seqnr",
      compositions: [composition],
      bag_compositions: [])
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    patent = flexmock("patent", certificate_number: "certificate_number", expiry_date: Date.new(2099, 12, 31))
    @model = flexmock("model",
      ikscat: "ikscat",
      ikscd: "ikscd",
      lppv: "lppv",
      preview?: "preview",
      patent: patent,
      market_date: "market_date",
      result_list_components: @result_list_components,
      oid: "oid",
      name: "name",
      size: "size",
      narcotic?: nil,
      ddd_price: "ddd_price",
      sl_entry: nil,
      atc_class: atc_class,
      name_base: "name_base",
      iksnr: "iksnr",
      seqnr: "seqnr",
      ikskey: "ikskey",
      pointer: "pointer",
      parts: [part],
      registration_date: "registration_date",
      sequence_date: "sequence_date",
      revision_date: "revision_date",
      expiration_date: "expiration_date",
      swissmedic_source: {"swissmedic_source" => "x"},
      deductible: "deductible",
      price_exfactory: "price_exfactory",
      price_public: "price_public",
      ith_swissmedic: "ith_swissmedic",
      production_science: "production_science",
      shortage_state: "shortage_state",
      shortage_link: "shortage_link",
      parallel_import: "parallel_import",
      index_therapeuticus: "index_therapeuticus",
      sequence: sequence,
      sl_generic_type: "sl_generic_type")
    ith = flexmock("ith", language: "language")
    flexmock(ODDB::IndexTherapeuticus, find_by_code: ith)
    @container = flexmock("container", StubContainer.new)
    @container.should_receive(:additional_javascripts).and_return([])
    @composite = ODDB::View::Drugs::PackageComposite.new(@model, @session, @container)
  end

  def test_init
    assert_equal({}, @composite.init)
  end

  def test_to_html
    html = @composite.to_html(CGI.new)
    ["</TABLE>",
      "label_deductible_1",
      "division_divisable",
      "dissolvable"].each { |expression| assert_match(expression, html) }
  end

  def test_init__twitter_share
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:twitter_share).and_return(true)
      l.should_receive(:enabled?).once.with(:facebook_share, true).and_return(true)
      l.should_receive(:enabled?).with(:ajax).and_return(false)
      l.should_receive(:resource).and_return("resource")
      l.should_receive(:enabled?).at_least.once.with(:link_pubprice_to_price_comparison, false)
      l.should_receive(:enabled?).at_least.once.with(:show_ean13)
      l.should_receive(:enabled?).at_least.once.with(:feedback)
      l.should_receive(:enabled?).at_least.once.with(:fachinfos)
      l.should_receive(:enabled?).at_least.once.with(:patinfos)
      l.should_receive(:enabled?).never.with(:popup_links, false)
      l.should_receive(:enabled?).at_least.once.with(:ddd_chart)
    end
    indication = flexmock("indication", language: "language")
    flexmock(@model,
      commercial_forms: [@commercial_form],
      indication: indication)
    assert_equal({}, @composite.init)
  end

  def test_init__facebook_share
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).at_least.once.with(:show_ean13)
      l.should_receive(:enabled?).once.with(:twitter_share).and_return(false)
      l.should_receive(:enabled?).once.with(:facebook_share, true).and_return(true)
      l.should_receive(:enabled?).with(:ajax).and_return(false)
      l.should_receive(:enabled?).at_least.once.with(:link_pubprice_to_price_comparison, false)
      l.should_receive(:enabled?).at_least.once.with(:feedback)
      l.should_receive(:enabled?).at_least.once.with(:fachinfos)
      l.should_receive(:enabled?).at_least.once.with(:patinfos)
      l.should_receive(:enabled?).never.with(:popup_links, false)
      l.should_receive(:enabled?).at_least.once.with(:ddd_chart)
    end
    assert_equal({}, @composite.init)
  end

  def test_compositions
    composition = flexmock("composition", active_agents: [@active_agent], excipiens: "excipiens", corresp: "corresp")
    flexmock(@model, compositions: [composition])
    assert_kind_of(ODDB::View::Admin::Compositions, @composite.compositions(@model, @session))
  end
end

class TestPackage < Minitest::Test
  def setup
    dose = flexmock("dose", qty: "qty", unit: "unit")
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    lookandfeel = flexmock("lookandfeel",
      format_date: "format_date",
      result_list_components: @result_list_components,
      enabled?: nil,
      attributes: {},
      resource: "resource",
      lookup: "lookup",
      zones: ["zones"],
      disabled?: nil,
      direct_event: "direct_event",
      _event_url: "_event_url",
      language: "language",
      languages: "languages",
      base_url: "base_url",
      navigation: ["navigation"],
      resource_localized: "resource_localized",
      zone_navigation: ["zone_navigation"])
    user = flexmock("user", valid?: nil)
    sponsor = flexmock("sponsor", valid?: nil)
    snapback_model = flexmock("snapback_model", pointer: "pointer")
    state = flexmock("state",
      direct_event: "direct_event",
      snapback_model: snapback_model,
      zone: "zone")
    atc_class = flexmock("atc_class",
      description: "description",
      code: "code",
      has_ddd?: true,
      parent_code: "parent_code",
      pointer: "pointer")
    app = flexmock("app", atc_class: atc_class)
    @session = flexmock("session",
      cgi: CGI.new,
      lookandfeel: lookandfeel,
      user: user,
      sponsor: sponsor,
      state: state,
      allowed?: nil,
      error: "error",
      app: app,
      request_path: "request_path",
      language: "language",
      zone: "zone",
      persistent_user_input: "persistent_user_input",
      flavor: "flavor",
      event: "event",
      get_cookie_input: "get_cookie_input",
      request_method: "GET")
    commercial_form = flexmock("commercial_form", language: "language")
    substance = flexmock("substance", language: "language")
    galenic_form = flexmock("galenic_form", language: "language")
    parent = flexmock("parent", galenic_form: galenic_form)
    excipiens = flexmock("excipiens",
      more_info: "more_info",
      oid: "oid",
      is_active_agent: false,
      dose: dose,
      substance: substance,
      parent: parent)
    active_agent = flexmock("active_agent",
      more_info: "more_info",
      oid: "oid",
      is_active_agent: true,
      substance: substance,
      chemical_substance: nil,
      dose: dose,
      parent: parent)
    galenic_form = flexmock("galenic_form", language: "language")
    composition = flexmock("composition",
      label: "label",
      oid: "oid",
      excipiens: excipiens,
      corresp: "corresp",
      galenic_form: galenic_form,
      active_agents: [active_agent],
      inactive_agents: [])
    part = flexmock("part",
      oid: "oid",
      multi: "multi",
      count: "count",
      measure: "measure",
      active_agents: [active_agent],
      composition: composition,
      commercial_form: commercial_form)
    indication = flexmock("indication", language: "language")
    sequence = flexmock("sequence",
      division: "division",
      compositions: [composition],
      bag_compositions: [])
    @result_list_components = flexmock("result_list_components",
      has_value?: false)
    patent = flexmock("patent", certificate_number: "certificate_number", expiry_date: Date.new(2099, 12, 31))
    @model = flexmock("model",
      ikscat: "ikscat",
      lppv: "lppv",
      registration_date: "registration_date",
      sequence_date: "sequence_date",
      revision_date: "revision_date",
      expiration_date: "expiration_date",
      market_date: "market_date",
      preview?: "preview",
      patent: patent,
      result_list_components: @result_list_components,
      chemical_substance: nil,
      name: "name",
      size: "size",
      narcotic?: nil,
      ddd_price: "ddd_price",
      sl_entry: nil,
      atc_class: atc_class,
      name_base: "name_base",
      parts: [part],
      pointer: "pointer",
      indication: indication,
      ikskey: "ikskey",
      swissmedic_source: {"swissmedic_source" => "x"},
      deductible: "deductible",
      price_exfactory: "price_exfactory",
      price_public: "price_public",
      ith_swissmedic: "ith_swissmedic",
      production_science: "production_science",
      shortage_state: "shortage_state",
      shortage_link: "shortage_link",
      parallel_import: "parallel_import",
      commercial_forms: [commercial_form],
      index_therapeuticus: "index_therapeuticus",
      sequence: sequence,
      sl_generic_type: "sl_generic_type")
    ith = flexmock("ith", language: "language")
    flexmock(ODDB::IndexTherapeuticus, find_by_code: ith)
    @package = ODDB::View::Drugs::Package.new(@model, @session)
  end
  ODDB::View::Copyright::ODDB_VERSION = "oddb_version"
  def test_meta_tags
    context = flexmock("context", meta: "meta")
    assert_equal("metametametametametameta", @package.meta_tags(context))
  end
end
