#!/usr/bin/env ruby
# TestGalenicGroup -- oddb -- 24.03.2003 -- mhuggler@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/galenicgroup'
require 'flexmock'

module ODDB
	class GalenicGroup
		attr_accessor :galenic_forms
	end
  class TestGalenicGroup < Test::Unit::TestCase
    class StubForm
      include ODDB::Persistence
      def has_description?(value)
        value == 'Tabletten'
      end
      def ==(other)
        self.class == other.class
      end
    end
    class StubApp
      include ODBA::Persistable
      def initialize
        @galenic_groups = {}
      end
      def create_galenic_group
        ODDB::GalenicGroup.new
      end
      def galenic_group(oid)
        @galenic_groups[oid]
      end
    end
    def setup
      ODBA.storage.reset_id
      @group = ODDB::GalenicGroup.new
      @group.pointer = ODDB::Persistence::Pointer.new([:galenic_group, 1])
    end
    def test_add
      form = StubForm.new
      @group.add(form)
      assert_equal({form.oid=>form}, @group.galenic_forms)
    end
    def test_empty
      assert_equal(true, @group.empty?)
      form = StubForm.new
      @group.galenic_forms = {form.oid=>form}
      assert_equal(false, @group.empty?)
    end
    def test_remove1
      form = StubForm.new
      @group.galenic_forms = {form.oid=>form}
      @group.remove(form)
      assert_equal({}, @group.galenic_forms)
    end
    def test_remove2
      form1 = StubForm.new
      form2 = StubForm.new
      @group.galenic_forms = {form1.oid=>form1, form2.oid=>form2}
      assert_equal(2, @group.galenic_forms.size)
      @group.remove(form1)
      assert_equal({form2.oid=>form2}, @group.galenic_forms)
    end
    def test_language_interface
      assert_respond_to(@group, :description)
    end
    def test_create
      pointer = ODDB::Persistence::Pointer.new([:galenic_group])
      app = StubApp.new
      galenic_group = pointer.issue_create(app)
      expected = ODDB::Persistence::Pointer.new([:galenic_group, galenic_group.oid])
      assert_equal(ODDB::GalenicGroup, galenic_group.class)
      assert_equal(expected, galenic_group.pointer)
    end
    def test_update
      values = {
        'de'	=>	'eine Beschreibung nach dem update',
      }
      @group.update_values(values)
      assert_equal('eine Beschreibung nach dem update', @group.description('de'))
    end
    def test_create_galenic_form
      @group.galenic_forms = {}
      @group.create_galenic_form
      assert_equal(ODDB::GalenicForm, @group.galenic_forms.values.first.class)
      assert_equal(@group.oid, @group.galenic_forms.values.first.galenic_group.oid)
    end
    def test_delete_galenic_form
      form = StubForm.new
      @group.galenic_forms = {1=>form}
    end
    def test_each_galenic_form
      form1 = StubForm.new
      form2 = StubForm.new
      @group.galenic_forms = { 2 => form1, 3 => form2}
      res = []
      @group.each_galenic_form do |form|
        res.push form.oid
      end
      assert_equal [2, 3], res.sort
    end
    def test_galenic_form
      form = StubForm.new
      @group.galenic_forms = {1=>form}
      assert_equal(form, @group.galenic_form(1))
      @group.delete_galenic_form 1
      assert_equal({}, @group.galenic_forms)
    end
    def test_get_galenic_form
      form = StubForm.new
      @group.galenic_forms = {1=>form}
      assert_equal(form, @group.get_galenic_form('Tabletten'))
    end
    def test_equal
      @group.instance_variable_set '@oid', 1
      assert_equal(false, @group == @group)
      group = ODDB::GalenicGroup.new
      assert_equal(true, group == group)
      assert_equal(false, group == @group)
      assert_equal(false, @group == group)
    end
  end
end
