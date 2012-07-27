#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Photo -- oddb.org -- 27.07.2012 -- yasaka@ywesee.com

require 'htmlgrid/div'
require 'htmlgrid/image'
require 'htmlgrid/link'
require 'htmlgrid/value'

module ODDB
	module View
		module Drugs
class PackagePhotoView < HtmlGrid::Div
  CSS_CLASS = ''
  def init
    super
    @value = []
    if model and model.has_key?(:src)
      @value << _image_div(model)
      @value << _text_link(model)
    end
  end
  private
  def _image_div(model)
    image = HtmlGrid::Image.new(model[:name], @model, @session, self)
    image.set_attribute('alt', model[:name])
    image.set_attribute('src', model[:src])
    div = HtmlGrid::Div.new(model, @session, self)
    unless model[:link]
      div.value = image
    else
      link = HtmlGrid::Link.new(model[:name], @model, @session, self)
      link.href = model[:url]
      link.value = image
      link.target = '_blank'
      div.value = link
    end
    div
  end
  def _text_link(model)
    unless model[:link]
      text = HtmlGrid::Value.new(model[:name], @model, @session, self)
      text.value = model[:name]
      text
    else
      link = HtmlGrid::Link.new(model[:name], @model, @session, self)
      link.href = model[:url]
      link.value = model[:name]
      link.target = '_blank'
      link
    end
  end
end
class PackagePhotoComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :name,
    [0,1] => :photo
  }
  CSS_MAP = {
    [0,0] => 'th',
    [0,1] => 'compose',
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  def photo(model, session=@session)
    if model.has_flickr_photo?
      image = View::Drugs::PackagePhotoView.new(model.photo('Small'), session, self)
      image.css_class = 'small'
      image
    end
  end
end
class Photo < PrivateTemplate
  CONTENT = View::Drugs::PackagePhotoComposite
  SNAPBACK_EVENT = :result
  def backtracking(model, session=@session)
    fields = []
    fields << @lookandfeel.lookup(:th_pointer_descr)
    link = HtmlGrid::Link.new(:result, model, @session, self)
    link.css_class = "list"
    query = @session.persistent_user_input(:search_query)
    if query and !query.is_a?(SBSM::InvalidDataError)
      args = [
        :zone, :drugs, :search_query, query.gsub('/', '%2F'), :search_type,
        @session.persistent_user_input(:search_type) || 'st_oddb',
      ]
      link.href = @lookandfeel._event_url(:search, args)
      link.value = @lookandfeel.lookup(:result)
    end
    fields << link
    fields << '&nbsp;-&nbsp;'
    span = HtmlGrid::Span.new(model, session, self)
    span.value = @lookandfeel.lookup(:photo_for) + model.name
    span.set_attribute('class', 'list')
    fields << span
    fields
  end
end
    end
  end
end
