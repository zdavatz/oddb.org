#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::Items -- oddb.org -- 28.08.2012 -- yasaka@ywesee.com
# ODDB::View::Migel::Items -- oddb.org -- 16.12.2011 -- mhatakeyama@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/additional_information'
require 'view/dataformat'
require 'view/pager'

module ODDB
  module View
    module Migel

class SubHeader < HtmlGrid::Composite
  include View::AdditionalInformation
  include View::DataFormat
  COMPONENTS = {
    [0,0,0] => :max_insure_value,
    [0,0,1] => :price,
    [0,0,2] => :qty_unit,
    [0,0,3] => ' MiGel Code: ',
    [0,0,4] => :migel_code,
    [1,0]   => :pages,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0] => 'subheading',
    [1,0] => 'subheading',
  }
  def max_insure_value(model = @model, session = @session)
    if session.language == 'de'
      'Höchstvergütungsbetrag: '
    else
      'Montants Maximaux: '
    end
  end
  def migel_code(model=@model, session=@session)
    link = HtmlGrid::Link.new(:to_s, @model, @session, self)
    code = model.migel_code.to_s.force_encoding('utf-8')
    key_value = {:migel_code => code}
    event = :migel_search
    link.href = @lookandfeel._event_url(event, key_value)
    link.value = code
    link
  end
  def pages(model, session=@session)
    if @session.cookie_set_or_get(:resultview) == "pages"
      pages = @session.state.pages
      event = ''
      args  = {}
      if migel_code = @session.user_input(:migel_code)
        event = :migel_search
        args.update({:migel_code => migel_code})
      else
        event = :search
        args.update({
          :search_query => @session.persistent_user_input(:search_query).gsub('/', '%2F'),
          :search_type  => @session.persistent_user_input(:search_type),
        })
      end

      # sort
      sortvalue = @session.user_input(:sortvalue) || @session.user_input(:reverse)
      sort_way = @session.user_input(:sortvalue) ? :sortvalue : :reverse
      if sortvalue
        args.update({sort_way => sortvalue})
      end

      View::Pager.new(pages, @session, self, event, args)
    end
  end
end

class SearchedList < HtmlGrid::List
  include View::AdditionalInformation
  include View::LookandfeelComponents
  SUBHEADER = ODDB::View::Migel::SubHeader
  COMPONENTS = {}
  CSS_CLASS = 'composite'
  CSS_HEAD_KEYMAP = {}
  CSS_KEYMAP = {
    :pharmacode           => 'list',
    :ean_code             => 'list',
    :article_name         => 'list bold',
    :size                 => 'list italic',
    :status               => 'list',
    :companyname          => 'list',
    :ppub                 => 'list',
    :google_search        => 'list',
    :twitter_share        => 'list',
    :notify               => 'list',
  }
  %w(pharmacode ean_code status ppub).each do |attr|
    define_method(attr) do |model, session|
      if model.respond_to?(attr) and model.send(attr)
        value = model.send(attr)
      else
        value = ''
      end
      value.to_s.force_encoding('utf-8')
    end
  end
  def init
    reorganize_components(:migel_item_list_components)
    super
  end
  def article_name(model = @model, session = @session)
    if model.article_name.respond_to?(session.language)
      name = model.article_name.send(session.language)
    else
      name = model.article_name
    end
    name.to_s.force_encoding('utf-8') if name
  end
  def companyname(model = @model, session = @session)
    if model.companyname.respond_to?(session.language)
      name = model.companyname.send(session.language)
    else
      name = model.companyname
    end
    name.to_s.force_encoding('utf-8') if name
  end
  def size(model = @model, session = @session)
    if model.size.respond_to?(session.language)
      size = model.size.send(session.language)
    else
      size = model.size
    end
    size.to_s.force_encoding('utf-8') if size
  end
  def compose_list(model = @model, offset=[0,0])
    # Grouping products with migel_code
    migel_code_group = {}
    model.each do |product|
      (migel_code_group[product.migel_code] ||= []) <<  product
    end
    # list up items
    migel_code_group.keys.sort.each do |migel_code|
      offset_length = migel_code_group[migel_code].length
      compose_subheader(migel_code_group[migel_code][0], offset)
      super(migel_code_group[migel_code], offset)
      offset[1] += offset_length
    end
  end
  def compose_subheader(item, offset, css='list atc')
    subheader = SubHeader.new(item, @session, self)
    @grid.add(subheader, *offset)
    @grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
    offset[1] += 1
  end
  def sort_link(header_key, matrix, component)
    link = HtmlGrid::Link.new(header_key, @model, @session, self)

    sortvalue = @session.user_input(:sortvalue) || @session.user_input(:reverse)
    sort_way = @session.user_input(:sortvalue) ? :sortvalue : :reverse
    sort_way = if sort_way == :sortvalue and component.to_s == sortvalue
                 :reverse
               else
                 :sortvalue
               end
    page = @session.user_input(:page)
    if search_query = @session.user_input(:search_query)
      args = [:zone, @session.zone, :search_query, @session.user_input(:search_query), sort_way, component.to_s]
      if page
        args.concat [:page, page+1]
      end
      link.href = @lookandfeel._event_url(@session.event, args)
    elsif @model.first
      args = [:migel_code, @model.first.migel_code.force_encoding('utf-8').gsub('.',''), sort_way, component.to_s]
      if page
        args.concat [:page, page+1]
      end
      link.href = @lookandfeel._event_url(:migel_search, args)
    end
    link
  end
end
class SearchedComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => SearchedList,
  }
  CSS_CLASS = 'composite'
end
class Items < View::PrivateTemplate
  JAVASCRIPTS = ['bit.ly']
  CONTENT = SearchedComposite
  SNAPBACK_EVENT = :result
end
    end
  end
end
