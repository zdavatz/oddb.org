#!/usr/bin/env ruby
# encoding: utf-8
# OddbApp -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OddbApp -- oddb -- 18.11.2002 -- hwyss@ywesee.com 

require 'syck'
require 'yaml'
YAML::ENGINE.yamler = "syck"
require 'util/oddbapp'

class OddbPrevalence
	attr_accessor :registrations, :galenic_groups, :galenic_forms, :substances
	attr_accessor :indications, :atc_classes, :companies, :generic_groups, :doctors
	attr_accessor :incomplete_registrations, :log_groups
	attr_accessor :last_update, :doctors
	attr_accessor :last_medication_update
	attr_reader :sequence_index, :indication_index, :substance_index
	attr_reader :patinfos
	attr_writer :fachinfos, :orphaned_patinfos, :indices_therapeutici, :invoices, :minifis, :migel_groups, :orphaned_fachinfos, :patinfos, :registrations, :substances, :commercial_forms, :address_suggestions, :atc_classes, :users, :feedbacks, :narcotics, :analysis_groups, :slates, :hospitals, :sponsors
	attr_writer :substance_index, :soundex_substances
	#public :rebuild_indices
	def all_soundex_substances
		@soundex_substances
	end
end
module ODDB
	ODDB_VERSION = 'version'
	class App < SBSM::DRbServer
		remove_const :RUN_CLEANER
		remove_const :RUN_UPDATER
		RUN_CLEANER = false
		RUN_EXPORTER = false
		RUN_UPDATER = false
	end
  module Admin
    class Subsystem; end
  end
  class PowerUser; end
  class CompanyUser; end
  class RootUser
    def initialize
      @oid = 0
      @unique_email = 'test@oddb.org'
      @pass_hash = Digest::MD5::hexdigest('test')
      @pointer = Pointer.new([:user, 0])
    end
  end
  class Registration
    attr_writer :sequences
  end
  class Sequence
    attr_accessor :packages
  end
  module Persistence
    class Pointer
      public :directions
    end
  end
  class GalenicGroup
    attr_accessor :galenic_forms
    def GalenicGroup::reset_oids
      @oid = 0
    end
  end
end
module DRb
  class DRbObject
    def respond_to?(msg_id, *args)
      case msg_id
      when :_dump
        true
      when :marshal_dump
        false
      else
        true
    #                                method_missing(:respond_to?, msg_id)
      end
    end
  end
end

# some StubSequence

  class StubSequence
    attr_reader :name_base, :name_descr, :atc_class
    def initialize(name_base, atc_class)
      @name_base = name_base
      @atc_class = atc_class
    end
    def name
      @name_base
    end
  end
  class StubAtcClass
    attr_reader :code
    def initialize(halb)
      @code = halb
    end
  end
  class StubAtcClassFactory
    class << self
      def atc(code)
        (@atc ||= {}).fetch(code) {
          @atc.store(code, StubAtcClass.new(code))
        }
      end
    end
  end
  class StubRegistration
    attr_reader :iksnr, :block_result
    def initialize(key=nil)
      @iksnr = key
    end
    def active_package_count
      3
    end
    def replace(registration)
    end
    def sequences
      {
        :foo  =>  StubSequence.new('blah', StubAtcClassFactory.atc('1')),
        :bar  =>  StubSequence.new('blahdiblah', StubAtcClassFactory.atc('2')),
        :rob  =>  StubSequence.new('frohbus', nil),
      }
    end
    def atcless_sequences
      [
        StubSequence.new('no_atc', nil)
      ]
    end
    def each_package(&block)
      @block_result = block.call(@iksnr)
    end
  end
  class StubGalenicForm
    include ODDB::Language
    attr_reader :name
    def initialize(name)
      self.update_values({ 'de' => name })
      @name = name
    end
  end
  class StubGalenicGroup
    attr_writer :galenic_form
    attr_reader :block_result
    def each_galenic_form(&block)
      @block_result = block.call(@galenic_form)
    end
    def empty?
      @galenic_form.nil?
    end
    def get_galenic_form(description)
      @galenic_form
    end
  end
  class StubSubstance
    attr_reader :name
    def initialize(name, similar)
      @name = name
      @similar = similar
    end
    def <=>(other)
      @name.downcase <=> other.name.downcase
    end
  end
  class StubRegistration2
    attr_accessor :sequences, :pointer, :descriptions
    def initialize
      @descriptions = {}
    end
    def indication
      self
    end
  end
