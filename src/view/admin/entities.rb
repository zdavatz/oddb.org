#!/usr/bin/env ruby
# View::Admin::Entities -- oddb -- 08.06.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'htmlgrid/list'

module ODDB
  module View
    module Admin
class EntityList < HtmlGrid::FormList
  EVENT = :new_user
  COMPONENTS = {
    [0,0] => :name,
    [1,0] => :affiliations,
    [2,0] => :name_first,
    [3,0] => :name_last,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0,4] =>  'list', 
  }
  DEFAULT_HEAD_CLASS = 'th'
  DEFAULT_CLASS = HtmlGrid::Value
  LEGACY_INTERFACE = false
  SORT_DEFAULT = :name
  LOOKANDFEEL_MAP = {
    :name => :email, 
  }
  def name(model)
    link = HtmlGrid::Link.new(:name, model, @session, self)
    link.href = @lookandfeel._event_url(:user, {:name => model.name})
    link.value = model.name
    link
  end
end
class InnerEntityList < EntityList
  DEFAULT_HEAD_CLASS = 'subheading'
  SORT_HEADER = false
end
class Entities < View::PrivateTemplate
  CONTENT = EntityList
  class Wrapper
    def Wrapper.delegators(*args)
      args.each { |key|
        define_method(key) { 
          @entity.send(key)
        }
      }
    end
    def Wrapper.preferences(*args)
      args.each { |key|
        define_method(key) { 
          @entity.send(:get_preference, key)
        }
      }
    end
    preferences :name_first, :name_last
    delegators :name
    def initialize(entity)
      @entity = entity
    end
    def affiliations
      @entity.affiliations.collect { |aff| aff.name }
    end
  end
	def Entities.wrap_all(entities)
		entities.collect { |entity|
			Wrapper.new(entity)
		}
	end
	def init
		@model = Entities.wrap_all(@model)
		super
	end
end
    end
  end
end
