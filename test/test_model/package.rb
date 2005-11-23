#!/usr/bin/env ruby
# TestPackage -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/package'
require 'mock'
require 'odba'
require 'flexmock'

module ODDB
	class Package
		public :adjust_types
	end
end

class StubPackageApp
	attr_writer :generic_groups
	attr_reader :pointer, :values
	def initialize
		@generic_groups = {}
	end
	def generic_group(key)
		@generic_groups[key]
	end
	def update(pointer, values)
		@pointer, @values = pointer, values
	end
end
class StubPackageGenericGroup
	attr_reader :package, :removed
	def add_package(package)
		@package = package
	end
	def remove_package(package)
		@removed = true
	end
end
class StubPackageSequence
	attr_accessor :dose
	attr_accessor :comparables
	attr_accessor :packages
	def initialize
		@packages = {}
	end
	def iksnr
		'12345'
	end
end

module ODDB
	class TestPackage < Test::Unit::TestCase
		def setup
			ODBA.storage = Mock.new
			ODBA.storage.__next(:next_id) {
				1
			}
			ODBA.storage.__next(:next_id) {
				2
			}
			ODBA.storage.__next(:next_id) {
				3
			}
			@package = ODDB::Package.new('12')
			@package.sequence = StubPackageSequence.new
		end
		def teardown
			ODBA.storage = nil
		end
		def test_initialize
			assert_equal('012', @package.ikscd)
			assert_not_nil(@package.oid)
		end
		def test_barcode
			assert_equal('7680123450123', @package.barcode)
		end
		def test_size_writer_12_Tabletten
			@package.size = '12 Tabletten'
			assert_equal('12 Tabletten', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(12, @package.count)
			assert_equal(ODDB::Dose.new(1,nil), @package.measure)
			assert_equal('Tabletten', @package.comform)
			assert_equal(ODDB::Dose.new(12, nil), @package.comparable_size)
			assert_instance_of(ODDB::Dose, @package.comparable_size)
		end
		def test_size_writer_40_g
			@package.size = '40 g'
			assert_equal('40 g', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(40, @package.measure.qty)
			assert_equal('g', @package.measure.unit.to_s)
			assert_equal(nil, @package.comform)
			assert_equal(ODDB::Dose.new(40, 'g'), @package.comparable_size)
		end
		def test_size_writer_multiple
			@package.size = '1 x 10 mL Flacon(s)'
			assert_equal('1 x 10 mL Flacon(s)', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(10, @package.measure.qty)
			assert_equal('ml', @package.measure.unit.to_s)
			assert_equal('Flacon(s)', @package.comform)
			assert_equal(ODDB::Dose.new(10, 'ml'), @package.comparable_size)
		end
		def test_size_writer_komma
			@package.size = '20 x 1,7 g'
			assert_equal('20 x 1,7 g', @package.size)
			assert_equal(20, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(1.7, @package.measure.qty)
			assert_equal('g', @package.measure.unit.to_s)
			assert_equal(nil, @package.comform)
			assert_equal(ODDB::Dose.new(34, 'g'), @package.comparable_size)
		end
		def test_size_writer_divider
			@package.size = '1 x 10 mg / 10 mL'
			assert_equal('1 x 10 mg / 10 mL', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(10, @package.measure.qty)
			assert_equal('mg', @package.measure.unit.to_s)
			assert_equal(10, @package.scale.qty)
			assert_equal('ml', @package.scale.unit.to_s)
			assert_equal(nil, @package.comform)
			assert_equal(ODDB::Dose.new(1, 'mg/ml'), @package.comparable_size)
		end
		def test_size_writer_addition_multiplication
			@package.size = '5 x 1 + 1 Ampulle(n)'
			assert_equal('5 x 1 + 1 Ampulle(n)', @package.size)
			assert_equal(5, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(1, @package.addition)
			assert_equal(ODDB::Dose.new(1, ''), @package.measure)
			assert_equal('Ampulle(n)', @package.comform)
			assert_equal(ODDB::Dose.new(10, ''), @package.comparable_size)
		end
		def test_size_writer_dose
			@package.size = '3 x 2 ml (40mg) Ampulle(n)'
			assert_equal('3 x 2 ml (40mg) Ampulle(n)', @package.size)
			assert_equal(3, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(0, @package.addition)
			assert_equal(2, @package.measure.qty)
			assert_equal('ml', @package.measure.unit.to_s)
			assert_equal(40, @package.dose.qty)
			assert_equal('mg', @package.dose.unit.to_s)
			assert_equal('Ampulle(n)', @package.comform)
			assert_equal(ODDB::Dose.new(6, 'ml'), @package.comparable_size)
		end
		def test_size_writer_MBq
			@package.size = '74 MBq/1.0 mL'
			assert_equal('74 MBq/1.0 mL', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(0, @package.addition)
			assert_equal(74, @package.measure.qty)
			assert_equal('MBq', @package.measure.unit.to_s)
			assert_equal(1, @package.scale.qty)
			assert_equal('ml', @package.scale.unit.to_s)
			assert_equal(ODDB::Dose.new(74, 'MBq/ml'), @package.comparable_size)
		end
		def test_size_writer_ml_ml
			@package.size = '20 ml ml'
			assert_equal('20 ml ml', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(0, @package.addition)
			assert_equal(20, @package.measure.qty)
			assert_equal('ml', @package.measure.unit.to_s)
			assert_nil(@package.comform)
			assert_equal(ODDB::Dose.new(20, 'ml'), @package.comparable_size)
		end
		def test_size_writer_GBq
			@package.size = '10 GBq'
			assert_equal('10 GBq', @package.size)
			assert_equal(1, @package.multi)
			assert_equal(1, @package.count)
			assert_equal(0, @package.addition)
			assert_equal(10, @package.measure.qty)
			assert_equal('GBq', @package.measure.unit.to_s)
			assert_equal(ODDB::Dose.new(10, 'GBq'), @package.comparable_size)
		end
		def test_descr_writer
			@package.size = '100 Tabletten'
			@package.descr = '5 Packungen à'
			assert_equal(Dose.new(500, nil), @package.comparable_size)
		end
		def test_generic_group
			assert_respond_to(@package, :generic_group)
		end
		def test_generic_group_writer
			generic_group = StubPackageGenericGroup.new
			assert_nil(generic_group.package)
			@package.generic_group = generic_group
			assert_equal(@package, generic_group.package)
			assert_nil(generic_group.removed)
			@package.generic_group = nil
			assert_equal(true, generic_group.removed)
			package = ODDB::IncompletePackage.new(7)
			package.generic_group = generic_group
			assert_not_equal(package, generic_group.package)
		end
		def test_adjust_types
			generic_group = StubPackageGenericGroup.new
			pointer = ODDB::Persistence::Pointer.new(['generic_group', 'test'])
			values = {
				:size						=>	'20 x 1,7 g',
				:descr					=>	nil,
				:ikscat					=>	'A',
				:generic_group	=>	pointer,
				:price_exfactory=>	'12.34',
				:price_public		=>	'15'
			}
			app = StubPackageApp.new
			app.generic_groups = {'test'=>generic_group}
			expected = {
				:size						=>	'20 x 1,7 g',
				:descr					=>	nil,
				:ikscat					=>	'A',
				:generic_group	=>	generic_group,
				:price_exfactory=>	1234,
				:price_public		=>	1500,
			}
			assert_equal(expected, @package.adjust_types(values, app))
		end
		def test_create_sl_entry
			assert_nil(@package.sl_entry)
			@package.create_sl_entry
			assert_equal(ODDB::SlEntry, @package.sl_entry.class)
		end
		def test_iksnr
			assert_respond_to(@package, :iksnr)
			assert_equal('12345', @package.iksnr)
		end
		def test_ikskey
			result = @package.ikskey()
			assert_equal('12345012', result)	
		end
		def test_comparables1
			seq = StubPackageSequence.new
			pack = ODDB::Package.new('98')
			pack.size = '12 Tabletten'
			seq.packages = {'98' => pack}
			@package.sequence.comparables = [seq]
			@package.size = '20 Tabletten'
			assert_equal([pack], @package.comparables)
		end
		def test_comparables2
			seq = StubPackageSequence.new
			pack = ODDB::Package.new('98')
			pack.size = '12 Tabletten'
			seq.packages = {'02' => pack}
			@package.sequence.comparables = [seq]
			@package.size = '200 Tabletten'
			assert_equal([], @package.comparables)
		end
		def test_comparables3
			seq = StubPackageSequence.new
			seqpack = ODDB::Package.new('97')
			seqpack.size = '12 Tabletten'
			pack = ODDB::Package.new('98')
			pack.size = '12 Tabletten'
			seq.packages = {'98' => pack}
			@package.sequence.comparables = [seq]
			@package.sequence.packages = {
				'97'	=>	seqpack,
				'96'	=>	@package,
			}
			@package.size = '20 Tabletten'
			assert_equal([pack, seqpack], @package.comparables)
		end
		def test_respond_to_name_base
			assert_respond_to(@package, :name_base)
		end
		def test_price_diff
			values = {:price_exfactory => 12.34}
			expected = {:price_exfactory => 1234}
			assert_equal(expected, @package.diff(values))
			@package.price_exfactory = 1234
			assert_equal({}, @package.diff(values))
			values = {:price_exfactory => "12.34"}
			assert_equal({}, @package.diff(values))
			values = {:price_exfactory => 43.21}
			expected = {:price_exfactory => 4321}
			assert_equal(expected, @package.diff(values))
			## rounding errors:
			@package.price_exfactory = 4321
			values = {:price_exfactory => 43.210000000000000000345}
			assert_equal({}, @package.diff(values))
			values = {:price_exfactory => 43.209999999999999999995}
			assert_equal({}, @package.diff(values))
		end
		def test_feedback
			feedbacks = {
				12	=>	'foo',
				16	=>	'bar',
			}
			@package.instance_variable_set('@feedbacks', feedbacks)
			assert_equal('foo', @package.feedback(12))
			assert_equal('bar', @package.feedback('16'))
			assert_nil(@package.feedback(1))
		end
		def test_create_feedback
			feedback = @package.create_feedback
			assert_instance_of(ODDB::Feedback, feedback)
			assert_equal({feedback.oid => feedback}, @package.feedbacks)
			assert_not_nil(feedback.oid)
			oid = feedback.oid
			assert_equal(feedback, @package.feedback(oid))
		end
	end
	class TestIncompletePackage < Test::Unit::TestCase
		def setup
			ODBA.storage = Mock.new
			ODBA.storage.__next(:next_id) {
				1
			}
			@pack = ODDB::IncompletePackage.new(12)
			@pack.size = '12 x 34 mg'
			@pack.ikscat = 'A'
			@pack.price_public = 1234
		end
		def teardown
			ODBA.storage = nil
		end
		def test_accepted
			app = StubPackageApp.new
			ptr = ODDB::Persistence::Pointer.new
			@pack.accepted!(app, ptr)
			pointer = ptr + [:package, '012']
			assert_equal(pointer.creator, app.pointer)
			expected = {
				:size					=>	'12 x 34 mg',
				:ikscat				=>	'A',
				:price_public	=>	12.34,
			}
			assert_equal(expected, app.values)
		end
	end
end
