#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Fachinfo -- oddb.org -- 14.05.2012 -- yasaka@ywesee.com
# ODDB::State::Drugs::Fachinfo -- oddb.org -- 01.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::Fachinfo -- oddb.org -- 17.09.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/fachinfo'
require 'view/chapter'
require 'delegate'
require 'model/fachinfo'
require 'model/shorten_path'
require 'ext/chapterparse/src/chaptparser'
require 'ext/chapterparse/src/writer'
require 'yaml'

module ODDB
	module State
		module Drugs
class Fachinfo < State::Drugs::Global
	class FachinfoWrapper < SimpleDelegator
		attr_accessor :pointer_descr
	end
	VIEW = View::Drugs::Fachinfo
	def init
		@fachinfo = @model
		@model = FachinfoWrapper.new(@fachinfo)
		descr = @session.lookandfeel.lookup(:fachinfo_descr, 
			@fachinfo.localized_name(@session.language))
		@model.pointer_descr = descr
	end
	def allowed?
		@session.allowed?('edit', @fachinfo.registrations.first)
	end
end
class FachinfoPreview < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPreview
	VOLATILE = true
end
class FachinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPrint
	VOLATILE = true
	def init
		if(allowed?)
			@default_view = ODDB::View::Drugs::CompanyFachinfoPrint
		end
		super
	end
end
class AjaxLinks < Global
  VOLATILE = true
  VIEW = View::Links
end
class RootFachinfo < Fachinfo
	VIEW = View::Drugs::RootFachinfo
  def init
    super
    if _has_editor_privilege?
      @default_view = View::Drugs::RootFachinfo
    else # only show
      @default_view = View::Drugs::Fachinfo
    end
  end
  def ajax_create_fachinfo_link
    check_model
    links = @model.links
    unless error?
      link = FachinfoLink.new
      links.unshift link # head
    end
    AjaxLinks.new @session, links
  end
  def ajax_delete_fachinfo_link
    check_model
    keys = [:fachinfo_index]
    input = user_input(keys, keys)
    links = @model.links
    name = :links
    unless error?
      index = input[:fachinfo_index].to_i
      unless links[index].nil? # saved link
        links[index] = nil
        links.compact!
        email = unique_email
        lang = @session.language
        pointer = @model.pointer + [name]
        @model.add_change_log_item(email, name, lang)
        @session.app.update(pointer, links, email)
        @session.app.update(@model.pointer, {:links => links}, email)
      end
    end
    AjaxLinks.new(@session, @model.links)
  end
  def check_model
    if !allowed? and !@model.respond_to?(:links)
      @errors.store :pointer, create_error(:e_not_allowed, :pointer, nil)
    end
  end
  def update
    input = user_input(:chapter)
    if input[:chapter] and !error?
      if(input[:chapter] == 'links')
        input.merge! user_input([:fi_link_name, :fi_link_url, :fi_link_created])
        _update_links(input) unless error?
      elsif(input[:chapter] == 'shorten_path')
        input.merge! user_input([:fi_path_shorten_path, :fi_path_origin_path, :fi_path_created])
        _update_path(input) unless error?
      else
        mandatory = [:html_chapter]
        keys = mandatory + [:heading]
        input.merge! user_input(keys, mandatory)
        _update_document(input) unless error?
      end
    end
    self
  end
  private
  def _has_editor_privilege?
    user = @session.user
    [
      'org.oddb.RootUser',
      'org.oddb.AdminUser'
    ].each do |priv|
      return true if user.allowed?('login', priv)
    end
    return false
  end
  def _update_document(input)
    html = input[:html_chapter]
    writer = ChapterParse::Writer.new
    formatter = HtmlFormatter.new(writer)
    parser = ChapterParse::Parser.new(formatter)
    parser.feed(html)
    lang = @session.language
    email = unique_email
    if(@fachinfo.is_a?(Persistence::CreateItem))
      registration = @fachinfo.registrations.first
      doc = @fachinfo.send(lang)
      @fachinfo = @session.app.update(@fachinfo.pointer, {lang => doc}, email)
      @model = FachinfoWrapper.new(@fachinfo)
      @model.add_change_log_item(email, 'created', lang)
      @session.app.update(registration.pointer,
                          {:fachinfo => @model.pointer}, email)
    end
    doc = @model.descriptions.fetch(lang.to_s) {
      doc = @model.send(lang).class.new()
      doc.name = @model.name_base
      @session.app.update(@model.pointer, {lang => doc}, email)
      doc
    }
    name = input[:chapter]
    unless(doc.send(name))
      doc.send("#{name}=", Text::Chapter.new)
    end
    doc_pointer = @model.pointer + [lang]
    pointer = doc_pointer + [name]
    args = {
      :heading  => input[:heading],
      :sections => writer.chapter.sections,
    }
    @model.add_change_log_item(email, name, lang)
    @session.app.update(pointer, args, email)
    @session.app.update(doc_pointer, {}, email)
    @session.app.update(@model.pointer, {}, email)
  end
  def _update_links(input)
    lang = @session.language
    name = input[:chapter]
    email = unique_email
    pointer = @model.pointer + [name]
    if input[:fi_link_name].is_a? Hash
      links = []
      input[:fi_link_name].keys.length.times do |idx|
        index = idx.to_s
        if !input[:fi_link_name][index].empty? and
           input[:fi_link_url][index] !~ /^http:\/\/$/
          link = FachinfoLink.new
          link.name = input[:fi_link_name][index]
          link.url  = input[:fi_link_url][index]
          if !input[:fi_link_created].nil? and input[:fi_link_created][index]
            link.created = input[:fi_link_created][index]
          end
          links << link
        end
      end
      @model.add_change_log_item(email, name, lang)
      @session.app.update(pointer, links, email)
      @session.app.update(@model.pointer, {:links => links}, email)
    end
  end
  def _update_path(input)
    shorten_path = sanitize_shorten_path(input[:fi_path_shorten_path])
    origin_path = input[:fi_path_origin_path]
    validate_shorten_path(shorten_path)
    unless error?
      ODBA.cache.transaction {
        paths = @session.app.shorten_paths
        if path = paths.select {|path| path.origin_path == origin_path}.first
          path.shorten_path = shorten_path
          path.origin_path = origin_path
          path.odba_isolated_store
        else
          path = ODDB::ShortenPath.new(shorten_path, origin_path)
          path.odba_isolated_store
          paths << path
          paths.odba_isolated_store
        end
      }
    end
  end
  def validate_shorten_path(shorten_path)
    paths = @session.app.shorten_paths
    trans_handler = ODDB::PROJECT_ROOT + '/etc/trans_handler.yml'
		static_paths = {}
    begin
      static_paths.update(YAML.load(File.read(trans_handler)))
    rescue StandardError => err
    end
    unless shorten_path.empty? # allow empty
      if (!static_paths.empty? and shortcut = static_paths['shortcut'][shorten_path]) or
         paths.select {|path| path.shorten_path == shorten_path}.first
        error = create_error(:e_path_already_exist, :fi_path_shorter_path, shorten_path)
        @errors.store(:fi_path_shorten_path, error)
      end
    end
  end
  def sanitize_shorten_path(shorten_path)
    shorten_path = shorten_path.gsub(/[^A-z0-9\-_]/u, '')
    if !shorten_path.empty? and shorten_path[0] != '/'
      shorten_path = '/' + shorten_path
    end
    shorten_path
  end
end
class CompanyFachinfo < RootFachinfo
  VIEW = View::Drugs::RootFachinfo
	def init
		super
		unless(allowed?)
			@default_view = ODDB::View::Drugs::Fachinfo
		end
	end
	def update
		if(allowed?)
			super
		end
	end
end
		end
	end
end
