#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestPersistence -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::TestPersistence -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com 
# ODDB::TestPersistence -- oddb.org -- 26.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/persistence'
require 'date'
require 'stub/odba'
require 'flexmock'

module ODDB
	module Persistence
		class Pointer
			attr_reader :directions
		end
	end
	class StubPersistenceDiffable
		include ODDB::Persistence
		attr_accessor :foo, :bar, :baz, :zap, :date
		public :nil_if_empty
		class << self
			def reset_oid
				@oid = 0
			end
		end
		def adjust_types(values, app=nil)
			if(values.include?('date'))
				values['date'] = Date.parse(values['date'])
			end
			values
		end
	end
	class StubPersistenceUndiffable
		DISABLE_DIFF = true
	end
	class StubPersistenceNoOid
		include ODDB::Persistence
		def initialize
		end
	end
	class StubPointerBar
		include ODDB::Persistence
		attr_reader :bar, :values, :checkout_called
		attr_accessor :urks, :zaf
		def initialize(arg)
			@bar = arg
		end
		def update_values(values, origin=nil)
			super
			@values = values
		end
		def checkout
			@checkout_called = true
		end
	end
	class StubPointerFoo
		include ODBA::Persistable
		attr_reader :bar_deleted
		def initialize
			@shnup = {}
		end
		def bar(arg)
			@bar ||= StubPointerBar.new(arg.next)
		end
		def car(arg)
			nil
		end
		def create_shnup
			shnup = StubPersistenceDiffable.new
			@shnup.store(shnup.oid, shnup)
		end
		def create_car(arg)
			StubPointerBar.new(arg.reverse)
		end
		def delete_bar(arg)	
			@bar_deleted = arg
		end
		def shnup(arg)
			@shnup[arg]
		end
	end
	class StubPointerFap
		include ODDB::Persistence
		attr_accessor :fap
		def initialize(arg)
			@fap = arg
		end
	end
	class StubPointerApp
		def foo
			@foo ||= StubPointerFoo.new
		end
		def create(pointer)
			pointer.issue_create(self)
		end
		def update(pointer, values)
			pointer.issue_update(self, values)
		end
	end
	class StubPointerApp2
		include ODBA::Persistable
		def initialize
			@faps = {}
		end
		def foo
			@foo ||= StubPointerFoo.new
		end
		def fap(arg)
			@faps[arg]
		end
		def create(pointer)
			pointer.issue_create(self)
		end
		def create_fap(arg)
			@faps[arg] = StubPointerFap.new(arg)
		end
		def update(pointer, values)
			pointer.issue_update(self, values)
		end
	end
	class StubPersistenceOid
		include ODDB::Persistence
		class << self
			def reset_oid
				@oid = 0
			end
		end
	end
	class StubPersistenceOtherOid
		include ODDB::Persistence
		class << self
			def reset_oid
				@oid = 0
			end
		end
	end

	class TestPersistence < Test::Unit::TestCase
		def setup
			GC.start
			StubPersistenceDiffable.reset_oid
			@obj = StubPersistenceDiffable.new
			#@obj.set_oid
			@obj.foo = 'Foobar'
			@obj.bar = 'Foobar'
			@obj.baz = nil
			@obj.zap = 'Foobar'
		end
		def teardown
			GC.start
			ODBA.storage = nil
		end
		def test_diff
			values = {
				'foo'	=>	'Foobar',
				'bar'	=>	'Boofar',
				'baz'	=>	'Foobaz',
				'zap'	=>	nil,
				'date'=>	'01-02-2003',
			}
			expected = {
				'bar'	=>	'Boofar',
				'baz'	=>	'Foobaz',
				'zap'	=>	nil,
				'date'=>	Date.new(2003,02,01),
			}
			assert_equal(nil, @obj.undiffable?("foo"))
			assert_equal(expected, @obj.diff(values.dup))
			obj = StubPersistenceUndiffable.new
			assert_equal(true, @obj.undiffable?(obj))
			@obj.foo = obj
			expected = {
				'foo'	=>	'Foobar',
				'bar'	=>	'Boofar',
				'baz'	=>	'Foobaz',
				'zap'	=>	nil,
				'date'=>	Date.new(2003,02,01),
			}
			assert_equal(expected, @obj.diff(values))
		end
		def test_nil_if_empty
			assert_equal(nil, @obj.nil_if_empty(' '))
			assert_equal('foo', @obj.nil_if_empty('foo'))
		end
		def test_oid
			obj = StubPersistenceNoOid.new
			# no lazy initializing allowed, since there is no guarantee 
			# for such a value to end up in a snapshot...
			assert_nil(obj.oid)
		end
		def test_update_values
			values = {
				'bar'	=>	'Boofar',
				'baz'	=>	'Foobaz',
				'zap'	=>	nil,
			}
			@obj.update_values(values)
			assert_equal('Foobar', @obj.foo)
			assert_equal('Boofar', @obj.bar)
			assert_equal('Foobaz', @obj.baz)
			assert_equal(nil, @obj.zap)
		end
	end
	class TestPersistencePointer < Test::Unit::TestCase
		def setup
			ODBA.storage = ODBA::StorageStub.new
			ODBA.cache = ODBA::CacheStub.new
			@pointer = ODDB::Persistence::Pointer.new(:foo, [:bar, '12345'])
		end
		def teardown
			ODBA.storage = nil
			ODBA.cache = nil
		end
		def test_initialize
			expected = [
				[:foo],
				[:bar, '12345'],
			]
			assert_equal(expected, @pointer.directions)
		end
		def test_append
			pointer = ODDB::Persistence::Pointer.new(:foo, [:bar])
			pointer.append('12345')
			assert_equal(@pointer, pointer)
			pointer.append('12345')
			assert_equal(@pointer, pointer)
			pointer = ODDB::Persistence::Pointer.new
			assert_nothing_raised {
				pointer.append('12345')
			}
		end
		def test_equal
			pointer = ODDB::Persistence::Pointer.new(:foo, [:bar, '12345'])
			assert_equal(@pointer, pointer)
		end
		def test_plus
			pointer = @pointer + [:baz, '54321']
			expected = [
				[:foo],
				[:bar, '12345'],
				[:baz, '54321'],
			]
			assert_equal(expected, pointer.directions)
			pointer = @pointer + :baz
			expected = [
				[:foo],
				[:bar, '12345'],
				[:baz],
			]
			assert_equal(expected, pointer.directions)
		end
		def test_resolve
			obj = @pointer.resolve(StubPointerApp.new)
			assert_equal(StubPointerBar, obj.class)
			assert_equal('12346', obj.bar)
		end
		def test_fail_resolve1
			app = StubPointerApp2.new
			@pointer.directions[0] = [:fap, '9']
			assert_raises(ODDB::Persistence::UninitializedPathError) { @pointer.resolve(app) }
		end
		def test_fail_resolve2
			app = StubPointerApp2.new
			@pointer.directions[0] = [:frug, '9']
			assert_raises(ODDB::Persistence::InvalidPathError) { @pointer.resolve(app) }
		end
		def test_fail_resolve3
			app = StubPointerApp2.new
			@pointer.directions[1] = [:bar]
			assert_nothing_raised { @pointer.resolve(app) }
			assert_nil(@pointer.resolve(app))
		end
		def test_issue_create1
			app = StubPointerApp.new
			@pointer.directions[1] = [:car, '12345']
			new_obj = @pointer.issue_create(app)
			assert_equal(StubPointerBar, new_obj.class)
			assert_equal('54321', new_obj.bar)
			expected = [
				[:foo],
				[:car, '12345'],
			]
			assert_equal(expected, new_obj.pointer.directions)
		end
		def test_issue_create2
			pointer = ODDB::Persistence::Pointer.new([:fap, '12345'])
			app = StubPointerApp2.new
			new_obj = pointer.issue_create(app)
			assert_equal(StubPointerFap, new_obj.class)
			assert_equal(new_obj, pointer.issue_create(app))
		end
		def test_issue_delete
			app = StubPointerApp.new
			foo = app.foo
			@pointer.issue_delete(app)
			assert_equal("12345", foo.bar_deleted)
		end
		def test_issue_delete_checkout
			app = StubPointerApp.new
			bar = @pointer.resolve(app)
			@pointer.issue_delete(app)
			assert_equal(true, bar.checkout_called)
		end
    # No exist
		#def test_issue_delete_robust
		#	pointer = ODDB::Persistence::Pointer.new([:not_available], [:equally_unavailable])
		#	app = StubPointerApp.new
		#	assert_nothing_raised { 
		#		pointer.issue_delete(app)
		#	}
		#end
		def test_issue_update
			app = StubPointerApp2.new
			obj = @pointer.issue_create(app)
			assert_equal(nil, obj.values)
			values = {
				'zaf'	=>	'flop',
				'urks'=>	'bong',
			}
			@pointer.issue_update(app, values)
			assert_equal(values, obj.values)
		end
		def test_parent
			parent = @pointer.parent
			assert_equal(ODDB::Persistence::Pointer, parent.class)
			expected = [
				[:foo],
				[:bar, '12345'],
			]
			assert_equal(expected, @pointer.directions)
			expected = [
				[:foo],
			]
			assert_equal(expected, parent.directions)
		end
		def test_ancestors
			big_pointer = @pointer + [:zap, :frap]
			assert_equal(Array, big_pointer.ancestors.class)
			assert_equal(2, big_pointer.ancestors.size)
			expected = [
				[:foo],
			]
			assert_equal(expected, big_pointer.ancestors.first.directions)
			assert_equal(@pointer, big_pointer.ancestors.last)
		end
		def test_combined_creation_and_update
			app = StubPointerApp2.new
			@pointer.directions[1] = [:car, '12345']
			pointer = ODDB::Persistence::Pointer.new([:create, @pointer])
			values = {
				'zaf'	=>	'flop',
				'urks'=>	'bong',
			}
			new_obj = pointer.issue_update(app, values)
			assert_equal(StubPointerBar, new_obj.class)
			assert_equal(@pointer, new_obj.pointer)
			assert_equal(values, new_obj.values)
		end
		def test_to_s1
			assert_equal(':!foo!bar,12345.', @pointer.to_s)
		end
		def test_to_s2
			pointer = ODDB::Persistence::Pointer.new([:create, @pointer])
			assert_equal(':!create,:!foo!bar,12345..', pointer.to_s)
		end
		def test_to_s_escape
			pointer = ODDB::Persistence::Pointer.new([:test, 'a!b,c:d.e%f'])
			assert_equal(':!test,a%!b%,c%:d%.e%%f.', pointer.to_s)
		end
		def test_skeleton
			assert_equal([:foo,:bar], @pointer.skeleton)
		end
		def test_string_skeleton
			pointer = ODDB::Persistence::Pointer.new(['foo', 1, 2], ['bar'])
			assert_equal([:foo,:bar], pointer.skeleton)
		end
		def test_creator
			creator = ODDB::Persistence::Pointer.new([:create, @pointer])
			assert_equal(creator, @pointer.creator)
		end
		def test_marshal_dump
			assert_nothing_raised {
				Marshal.dump(@pointer)
			}
		end
		def test_hash_key
			hash = {}
			hash.store(Persistence::Pointer.new(:foo, [:bar, 1]), 'test')
			assert_equal('test', 
				hash[Persistence::Pointer.new(:foo, [:bar, 1])])
		end
		def test_to_yus_privilege
      pointer = Persistence::Pointer.new(:foo, [:bar, 1])
			assert_equal('org.oddb.model.!foo.!bar.1', pointer.to_yus_privilege)
      pointer = Persistence::Pointer.new([:foo, 'meep'], [:bar, 1])
			assert_equal('org.oddb.model.!foo.meep.!bar.1', pointer.to_yus_privilege)
		end
    def test_from_yus_privilege
      src = 'org.oddb.model.!foo.!bar.1'
      pointer = Persistence::Pointer.new(:foo, [:bar, 1])
      assert_equal(pointer, Persistence::Pointer.from_yus_privilege(src))
			src = 'org.oddb.model.!foo.meep.!bar.1'
      pointer = Persistence::Pointer.new([:foo, 'meep'], [:bar, 1])
      assert_equal(pointer, Persistence::Pointer.from_yus_privilege(src))
    end
	end
	class TestPersistenceCreateItem < Test::Unit::TestCase
		def setup
			@pointer = ODDB::Persistence::Pointer.new([:fap, "fap"])
			@item = ODDB::Persistence::CreateItem.new(@pointer)
		end
		def teardown
			ODBA.cache = nil
		end
		def test_carry
			@item.carry(:grok, "pak")
			assert_equal("pak", @item.grok)
			obj = Object.new
			@item.carry(:obj, obj)
			assert_equal(obj, @item.obj)
		end
		def test_create_pointer
			pointer = ODDB::Persistence::Pointer.new([:foo], [:car, 'rac'])
			item = ODDB::Persistence::CreateItem.new(pointer)
			app = StubPointerApp.new
			obj = app.update(item.pointer, {:urks => "moo"})
			assert_equal(StubPointerBar, obj.class)
			assert_equal('car', obj.bar)
			assert_equal('moo', obj.urks)
		end
		def test_create_oid_pointer
			pointer = ODDB::Persistence::Pointer.new([:foo], [:shnup])
			item = ODDB::Persistence::CreateItem.new(pointer)
			app = StubPointerApp.new
			obj = app.update(item.pointer, {:zap => "moo"})
			assert_equal(StubPersistenceDiffable, obj.class)
			assert_equal('moo', obj.zap)
		end
		def test_pointer
			expected = ODDB::Persistence::Pointer.new([:create, @pointer])
			assert_equal(expected, @item.pointer)
			app = StubPointerApp2.new
			obj = app.update(@item.pointer, {:fap => 'paf'})
			assert_equal(StubPointerFap, obj.class)
			assert_equal('paf', obj.fap)
		end
		def test_respond_to_anything
			message = :undefinded_method
			assert_nothing_raised { @item.send(message) }
			assert_equal(nil, @item.send(message))
		end
	end
end

module ODDB
  module Persistence
    class TestPointer < Test::Unit::TestCase
      include FlexMock::TestCase
      def test_to_csv
        pointer = ODDB::Persistence::Pointer.new(['key', 'value'])
        assert_equal('key,value', pointer.to_csv)
      end
    end
  end
end
