#!/usr/bin/env ruby
# State::Admin::Entities -- oddb.org -- 08.06.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/entities'

module ODDB
  module State
    module Admin
class Entities < Global
  DIRECT_EVENT = :users
  VIEW = View::Admin::Entities
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
  def init
    super
    @model = @session.user.entities.collect { |entity|
      Wrapper.new(entity)
    }
  end
end
    end
  end
end
