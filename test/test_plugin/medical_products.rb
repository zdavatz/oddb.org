#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'stub/odba'
require 'fileutils'
require 'flexmock'
require 'plugin/medical_products'
require 'model/text'
require 'model/atcclass'
require 'model/fachinfo'
require 'model/commercial_form'
require 'model/registration'

module ODDB
  module SequenceObserver
    def initialize
    end
    def select_one(param)
    end
  end
  class PseudoFachinfoDocument
    def descriptions
      { :de => FlexMock.new('descriptions') }
    end
  end
    class StubLog
      include ODDB::Persistence
      attr_accessor :report, :pointers, :recipients, :hash
      def notify(arg=nil)
      end
    end
    class StubPackage
      attr_accessor :commercial_forms
      def initialize
        puts "StubPackage addin CommercialForm"
        @commercial_mock = FlexMock.new(ODDB::CommercialForm)
        @commercial_forms = [@commercial_mock]
      end
    end
    class ODDB::Registration
     def initialize(iksnr)
        @pointer = FlexMock.new(Persistence::Pointer)
        @pointer.should_receive(:descriptions).and_return(@descriptions)
        @pointer.should_receive(:pointer).and_return(@pointer)
        @pointer.should_receive(:creator).and_return([])
        @pointer.should_receive(:+).and_return(@pointer)
      @iksnr = iksnr
      @sequences = {}
      end
    end
    class StubApp
      attr_writer :log_group
      attr_reader :pointer, :values, :model
      attr_accessor :last_date, :epha_interactions, :registrations
      def initialize
        @model = StubLog.new
        @epha_interactions = []
        @registrations = []
        @company_mock = FlexMock.new(ODDB::Company)
        @company_mock.should_receive(:pointer).and_return(@pointer)
        epha_mock = FlexMock.new(@epha_interactions)
        epha_mock = FlexMock.new(@epha_interactions)
        epha_mock.should_receive(:odba_store)
        product_mock = FlexMock.new(@registrations)
        product_mock.should_receive(:odba_store)
        @pointer_mock = FlexMock.new(Persistence::Pointer)
        @descriptions_mock = FlexMock.new('descriptions')
        @pointer_mock.should_receive(:descriptions).and_return(@descriptions_mock)
        @pointer_mock.should_receive(:pointer).and_return(@pointer_mock)
        @pointer_mock.should_receive(:notify).and_return([])
        @pointer_mock.should_receive(:+).and_return(@pointer_mock)
      end
      def commercial_form_by_name(name)
        if name.match(/Fertigspritze/i)
          @commercial_mock = FlexMock.new(ODDB::CommercialForm)
          @commercial_mock.should_receive(:pointer).and_return(@pointer_mock)
          return @commercial_mock
        else
          return nil
        end
      end
      def create_registration(name)
        @registration_stub = StubRegistration.new(name)
        @registrations << @registration_stub
        @registration_stub
      end
      def company_by_name(name, matchValue)
        @registration_stub
      end
      def registration(number)
        @registrations.first
      end
      def sequence(number)
        @sequence_mock
      end
      def create_fachinfo
        @fachinfo
      end
      def odba_store
      end
      def odba_isolated_store
      end
      def create_epha_interaction(atc_code_self, atc_code_other)
        epha_interaction = ODDB::EphaInteraction.new
        mock = FlexMock.new(epha_interaction)
        @epha_interactions ||= []
        @epha_interactions << mock
        mock.should_receive(:odba_store)
        epha_interaction
      end
      def delete_all_epha_interactions
      end
      def update(pointer, values, reason = nil)
        @pointer = pointer
        @values = values
        if reason and reason.to_s.match('medical_product')
          registrations.first.sequences.first[1].packages.first[1].parts << @commercial_mock
          return @commercial_mock
        end
        return @company_mock if reason and reason.to_s.match('company')
        if reason.to_s.match(/registration/)
          if @registrations.size == 0
            stub = Registration.new('dummy')
            @registrations << stub
          else stub = @registrations.first
          end
          return stub
        elsif reason and reason.to_s.eql?('text_info')
           return PseudoFachinfoDocument.new
        end
        return PseudoFachinfoDocument.new
        @pointer_mock
      end
      def log_group(key)
        @log_group
      end
      def create(pointer)
        @log_group
      end
      def recount
        'recount'
      end
    end

  class TestMedicalProductPlugin <MiniTest::Unit::TestCase
    unless defined?(@@datadir)
      @@datadir = File.expand_path '../../ext/fiparse/test/data/docx/', File.dirname(__FILE__)
      @@vardir = File.expand_path '../var', File.dirname(__FILE__)
    end
    include FlexMock::TestCase
    
    def setup
      assert(File.directory?(@@datadir), "Directory #{@@datadir} must exist")
      FileUtils.mkdir_p @@vardir
      ODDB.config.data_dir = @@vardir
      ODDB.config.log_dir = @@vardir
      @opts = {
        :lang  => 'de',
        :files => [ File.join(@@datadir, 'Sinovial_DE.docx') ],
      }
      @sequence = flexmock('sequence',
                           :packages => ['packages'],
                           :pointer => 'pointer',
                           :creator => 'creator')
      seq_ptr = flexmock('seq_ptr',
                          :pointer => 'seq_ptr.pointer')
      @pointer = flexmock('pointer',
                          :pointer => seq_ptr,
                          :packages => ['packages'])
      @sequence = flexmock('sequence',
                           :creator => @sequence)
      seq_ptr.should_receive(:+).with([:sequence, 0]).and_return(@sequence)
      @app = StubApp.new
    end # Fuer Problem mit fachinfo italic
    
    def teardown
      FileUtils.rm_rf @@vardir
      super # to clean up FlexMock
    end
    def test_update_medical_product_with_absolute_path
      fileName = File.join(@@datadir, 'Sinovial_DE.docx')
      assert(File.exists?(fileName), "File #{fileName} must exist")
      options = {:files => [ fileName ],  :lang => 'de' }
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_DE.docx')
      assert(@app.registrations.first.packages, 'packages must be available')
      skip('Niklaus does not want to waste time to mock correctly this situation')
      assert_equal('Fertigspritze', @app.registrations.first.packages.first.commercial_forms.first)
    end
    def test_update_medical_product_with_lang_and_relative
      fileName = 'Sinovial_DE.docx'
      options = {:files => [ fileName ],  :lang => 'de' }
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_DE.docx')
    end
    def test_update_medical_product_with_relative_wildcard
      options = {:files => [ '*.docx']}
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_DE.docx')
    end
    def test_update_medical_product_french
      options = {:files => [ '*.docx'], :lang => :fr}
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      res = @plugin.update()
      assert_equal(1, @app.registrations.size, 'We have 1 medical_product in Sinovial_FR.docx')
      assert(@app.registrations.first.packages, 'packages must be available')
      assert_equal(2, @app.registrations.first.packages.size, 'we must have exactly two packages')
      assert_equal(nil, @app.registrations.first.packages.first.commercial_forms.first)
    end
    def test_update_invalid_ean
      fileName = File.join('errors', 'invalid_ean13.docx')
      options = {:files => [ fileName ],  :lang => 'de' }
      @plugin = ODDB::MedicalProductPlugin.new(@app, options)
      assert_raises(SBSM::InvalidDataError) {@plugin.update()}
    end
  end
end 
