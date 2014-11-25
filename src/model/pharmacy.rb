#!/usr/bin/env ruby
# encoding: utf-8

require 'util/persistence'
require 'model/address'
require 'model/user'
require 'model/ba_type'

module ODDB
  class Pharmacy
    include AddressObserver
    include UserObserver
    attr_accessor :name, :business_area,
      :addresses, :email, :ydim_id
    attr_reader :ean13
    alias :fullname :name
  alias :contact_email :email
    def initialize(ean13)
      @addresses = []
      @ean13 = ean13
    end
    def contact
      (addr = @addresses.first) && addr.name
    end
    def search_terms
      terms = [ @ean13, @name, @hc_typ, @email ]
      @addresses.each { |addr|
        terms += addr.search_terms
      }
      ODDB.search_terms(terms)
    end
    def search_text
      search_terms.join(' ')
    end
    def pointer_descr
      [@ean13, @name, @business_area].compact.join(' ')
    end
  end
end
