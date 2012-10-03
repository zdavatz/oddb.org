# encoding: utf-8
# ODDB::View::Drugs::FachinfoSearch -- oddb.org -- 03.10.2012 -- yasaka@ywesee.com

require 'csv'
require 'cgi'
require 'htmlentities'
require 'view/drugs/privatetemplate'
require 'view/drugs/centeredsearchform'
require 'view/additional_information'
require 'view/searchbar'
require 'view/printtemplate'
require 'view/publictemplate'
require 'view/form'
require 'view/chapter'

module ODDB
  module View
    module Drugs
class FachinfoSearchDrugHeader < HtmlGrid::Composite
  include View::AdditionalInformation
  COMPONENTS = {
    [0,0] => :fachinfo,
    [1,0] => :drug,
    [2,0] => :delete,
  }
  CSS_MAP = {
    [0,0] => 'small',
    [1,0] => 'list',
    [2,0] => 'small',
  }
  def init
    @drugs = @session.persistent_user_input(:drugs)
    @index = (@drugs ? @drugs.length : 0).to_s
    super
  end
  def fachinfo(model, session=@session)
    if fi = super(model, session, 'square bold infos')
      fi.set_attribute('target', '_blank')
		  if chapter = @session.user_input(:fachinfo_search_type)	and # search result
         term    = @session.user_input(:fachinfo_search_term)
        reg = model.registration.iksnr
			  args = [
          :reg, reg,
          :chapter, chapter.gsub(/fi_/, ''),
          :highlight, term
        ]
			  fi.href = @lookandfeel._event_url(:fachinfo, args)
      end
      fi
    end
  end
  def drug(model, session=@session)
    div = HtmlGrid::Div.new(model, @session, self)
    div.set_attribute('class', 'drug')
    div.value = []
    if model
      div.value << model.name_with_size
      if price = model.price_public
        div.value << '&nbsp;-&nbsp;'
        div.value << price.to_s
      end
      if company = model.company_name
        div.value << '&nbsp;-&nbsp;'
        div.value << company
      end
    end
    div
  end
  def delete(model, session=@session)
    if @container.is_a? FachinfoSearchDrug and # hide at search result
       (@drugs and @drugs.length >= 1)
      link = HtmlGrid::Link.new(:minus, model, session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      args = [:ean, model.barcode] if model
      url = @session.lookandfeel.event_url(:ajax_delete_drug, args)
      link.onclick = "replace_element('drugs_#{model.barcode}', '#{url}');"
      link
    end
  end
end
class FachinfoSearchDrug < HtmlGrid::Composite
  COMPONENTS = {}
  CSS_MAP = {}
  CSS_CLASS = 'composite'
  def init
    if @model.is_a? ODDB::Package
      components.store([0,0], :drug)
      css_map.store([0,0], 'subheading')
      @attributes.store('id', 'drugs_' + @model.barcode)
    end
    super
  end
  def drug(model, session)
    View::Drugs::FachinfoSearchDrugHeader.new(model, session, self)
  end
end
class FachinfoSearchDrugDiv < HtmlGrid::Div
  def init
    super
    @value = []
    @drugs = @session.persistent_user_input(:drugs)
    if @drugs and !@drugs.empty?
      @drugs.values.each do |pac|
        @value << FachinfoSearchDrug.new(pac, @session, self)
      end
    end
  end
  def to_html(context)
    unless @value.empty?
      html = super
    else
      html = ''
    end
    div = HtmlGrid::Div.new(@model, @session, self)
    if @drugs and !@drugs.empty?
      delete_all_link = HtmlGrid::Link.new(:delete, @model, @session, self)
      delete_all_link.href  = @lookandfeel._event_url(:delete_all, [])
      delete_all_link.value = @lookandfeel.lookup(:fachinfo_search_delete_all)
      delete_all_link.css_class = 'list'
      div.value = delete_all_link
    end
    div.set_attribute('id', 'drugs')
    html << div.to_html(context)
    html
  end
end
class FachinfoSearchDrugSearchForm < HtmlGrid::Composite
  attr_reader :index_name
  FORM_METHOD = 'POST'
  COMPONENTS = {
    [0,0] => :searchbar,
    [0,1] => :chapter_type,
    [0,2] => :search_term,
    [1,2] => :full_text,
  }
  SYMBOL_MAP = {
    :searchbar => View::FachinfoSearchDrugSearchBar,
  }
  CSS_MAP = {
    [0,0] => 'searchbar',
    [0,1] => 'selection',
    [0,2] => 'list',
    [1,2] => 'list',
  }
  COLSPAN_MAP = {
    [0,0] => 2,
  }
  def init
    super
    self.onload = "document.getElementById('searchbar').focus();"
    @index_name = 'oddb_package_name_with_size_company_name_ean13_fi'
    @additional_javascripts = []
  end
  def chapter_type(model, session=@session)
		select = HtmlGrid::Select.new(:fachinfo_search_type, model, session, self)
		select.valid_values = [
      'fachinfo_search_type',
      'fi_usage', 'fi_interactions', 'fi_unwanted_effects'
    ]
		select.selected = @session.user_input(:fachinfo_search_type)
		select
	end
  def full_text(model, session=@session)
    checkbox = HtmlGrid::InputCheckbox.new(:fachinfo_search_full_text, model, session, self)
		[checkbox, "&nbsp;", @lookandfeel.lookup(:fachinfo_search_full_text)]
  end
  def search_term(model, session=@session)
    input = HtmlGrid::InputText.new(:fachinfo_search_term, model, session, self)
    value = @lookandfeel.lookup(:fachinfo_search_term)
    input.set_attribute('size', 30)
    input.set_attribute('onFocus', "if (this.value == '#{value}') { value = '' };")
    input.set_attribute('onBlur',  "if (this.value == '') { value = '#{value}' };")
    term = @session.user_input(:fachinfo_search_term)
    input.value = term ? term : value
    input
  end
  def javascripts(context)
    scripts = ''
    @additional_javascripts.each do |script|
      args = {
        'type'     => 'text/javascript',
        'language' => 'JavaScript',
      }
      scripts << context.script(args) do script end
    end
    scripts
  end
  def to_html(context)
    javascripts(context).to_s << super
  end
end
class FachinfoSearchForm < View::Form
  include HtmlGrid::InfoMessage
  COMPONENTS = {
    [0,0] => 'fachinfo_search_description',
    [0,1] => View::Drugs::FachinfoSearchDrugDiv,
    [0,2] => View::Drugs::FachinfoSearchDrugSearchForm,
    [0,3] => :buttons,
    [0,4] => '&nbsp;',
  }
  CSS_MAP = {
    [0,0] => 'th bold',
    [0,1] => '', # none
    [0,2] => 'list',
    [0,3] => 'inner-button',
    [0,4] => 'list',
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
  def buttons(model, session)
    [
      post_event_button(:search),
      '&nbsp;',
      '&nbsp;',
      post_event_button(:export_csv),
    ]
  end
  private
  def init
    super
    @form_properties.update({
      'id' => 'fachinfo_search_form',
    })
  end
end
class FachinfoSearchTermHitList < HtmlGrid::List
  COMPONENTS = {
    [0,0] => :drug,
    [0,1] => :text,
    [0,2] => '&nbsp;',
  }
  CSS_MAP = {
    [0,0] => 'subheading',
    [0,1] => 'list',
    [0,2] => 'list',
  }
  CSS_CLASS = 'composite'
  OFFSET_STEP  = [0,3] # vertical
  SORT_DEFAULT = false
  SORT_HEADER  = false
  OMIT_HEADER  = true
  BACKGROUND_SUFFIX = ''
  LEGACY_INTERFACE = false
  def drug(model, session=@session)
    drugs = @session.persistent_user_input(:drugs)
    if pac = drugs[model[:ean13]]
      FachinfoSearchDrugHeader.new(pac, session, self)
    end
  end
  def text(model, session=@session)
    div = HtmlGrid::Div.new(model, session, self)
    div.set_attribute('class', 'text')
    div.label = false
    text = model[:text]
    if text.is_a? FachinfoDocument and
       type = @session.user_input(:fachinfo_search_type)
      # full chapter
      chapter = type.gsub(/^fi_/, '').intern
      div.value = View::Chapter.new(chapter, text, @session, self)
    else
      term = @session.user_input(:fachinfo_search_term)
      text.gsub!(/#{term}/i, "<span class='highlight'>%s</span>" % term)
      div.value = text
    end
    div
  end
end
class FachinfoSearchComposite < HtmlGrid::Composite
  include AdditionalInformation
  COMPONENTS = {
    [0,0] => View::Drugs::FachinfoSearchForm,
    [0,1] => :search_result,
  }
  COMPONENT_CSS_MAP = {
    [0,0] => 'composite',
    [0,1] => '',
  }
  COLSPAN_MAP = {
    [0,0] => 12,
    [0,1] => 12,
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  def search_result(model, session=@session)
    if @model.is_a? Array
      FachinfoSearchTermHitList.new(model, session)
    else
      '&nbsp;'
    end
  end
end
class FachinfoSearch < View::PrivateTemplate
  CONTENT = View::Drugs::FachinfoSearchComposite
  SNAPBACK_EVENT = :home
  JAVASCRIPTS = ['admin']
  def init
    # warm up
    @session.app.registrations.length
    super
  end
  def backtracking(model, session=@session)
    fields = []
    fields << @lookandfeel.lookup(:th_pointer_descr)
    link = HtmlGrid::Link.new(:home, model, @session, self)
    link.css_class = "list"
    link.href  = @lookandfeel._event_url(:home, [])
    link.value = @lookandfeel.lookup(:home)
    fields << link
    fields << '&nbsp;-&nbsp;'
    span = HtmlGrid::Span.new(model, session, self)
    span.value = @lookandfeel.lookup(:fachinfo_search)
    span.set_attribute('class', 'bold')
    fields << span
    fields
  end
end
class FachinfoSearchCsv < HtmlGrid::Component
  COMPONENTS = [ # of package
    :barcode,
    :pharmacode,
    :name_with_size,
  ]
  def init
    super
    @coder = HTMLEntities.new
  end
  def http_headers
    name = 'FI_' +
           lookup(user_input(:type)) + '_' +
           user_input(:term) + '_' +
           Date.today.strftime("%d.%m.%Y")
    {
      'Content-Type'        => 'text/csv',
      'Content-Disposition' => "attachment;filename=#{name}.csv",
    }
  end
  def to_csv
    @lines = [
      [ # header
        'EAN-Code',
        'Pharmacode',
        'Name',
        'Search Term',
        'Search Match',
      ],
    ]
    drugs = @session.persistent_user_input(:drugs)
    @model.each do |model|
      if pac = drugs[model[:ean13]]
        if model[:text].is_a? FachinfoDocument
          chapter = @session.user_input(:fachinfo_search_type).to_s.gsub(/^fi_/, '').intern
          text = model[:text].send(chapter).to_s
        else
          text = model[:text]
        end
        @lines << [
          model[:ean13],
          pac.pharmacode,
          pac.name_with_size,
          user_input(:term),
          text,
        ]
      end
    end
    csv = ''
    @lines.collect do |line|
      csv << CSV.generate_line(line, {:col_sep => ';'})
    end
    csv
  end
  def to_html(context)
    to_csv
  end
  private
  def user_input(attr)
    key = "fachinfo_search_#{attr}".to_sym
    input = @session.user_input(key)
    input = @coder.decode(input).gsub(/[\.\s]/, '')
    input
  end
  def lookup(attr)
    key = attr.to_sym
    if value = @lookandfeel.lookup(key)
      @coder.decode(value)
    end
  end
end
    end
  end
end
