#!/usr/bin/env ruby
# TestPackage -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/package'
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
	attr_accessor :active_packages, :registration
	def initialize
		@active_packages = []
	end
	def public_packages
		@active_packages
	end
	def iksnr
		'12345'
	end
end

module ODDB
	class TestPackage < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
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
		def test_active
			assert_equal(true, @package.active?)
			@package.out_of_trade = true
			assert_equal(true, @package.active?)
			@package.refdata_override = true
			assert_equal(true, @package.active?)
			@package.market_date = Date.today + 1
			assert_equal(false, @package.active?)
			@package.market_date = Date.today
			assert_equal(true, @package.active?)
		end
		def test_public
      inactive = flexmock 'registration'
      inactive.should_receive(:active?).and_return false
      @package.sequence.registration = inactive
			assert_equal(true, @package.public?)
			@package.out_of_trade = true
			assert_equal(false, @package.public?)
			@package.refdata_override = true
			assert_equal(true, @package.public?)
			@package.market_date = Date.today + 1
			assert_equal(false, @package.public?)
			@package.market_date = Date.today
			assert_equal(true, @package.public?)
		end
		def test_barcode
			assert_equal('7680123450123', @package.barcode)
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
				:price_exfactory=>	Util::Money.new(12.34),
				:price_public		=>	Util::Money.new(15)
			}
			app = StubPackageApp.new
			app.generic_groups = {'test'=>generic_group}
			expected = {
				:size						=>	'20 x 1,7 g',
				:descr					=>	nil,
				:ikscat					=>	'A',
				:generic_group	=>	generic_group,
				:price_exfactory=>	Util::Money.new(12.34),
				:price_public		=>	Util::Money.new(15)
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
      part = ODDB::Part.new
			part.size = '12 Tabletten'
      pack.parts.push part
			seq.active_packages = [pack]
			@package.sequence.comparables = [seq]
      part = ODDB::Part.new
			part.size = '15 Tabletten'
      @package.parts.push part
			assert_equal([pack], @package.comparables)
		end
		def test_comparables2
			seq = StubPackageSequence.new
			pack = ODDB::Package.new('98')
      part = ODDB::Part.new
			part.size = '12 Tabletten'
      pack.parts.push part
			seq.active_packages = [pack]
			@package.sequence.comparables = [seq]
      part = ODDB::Part.new
			part.size = '200 Tabletten'
      @package.parts.push part
			assert_equal([], @package.comparables)
		end
		def test_comparables3
			seq = StubPackageSequence.new
			seqpack = ODDB::Package.new('97')
      part = ODDB::Part.new
			part.size = '12 Tabletten'
      seqpack.parts.push part
			pack = ODDB::Package.new('98')
      part = ODDB::Part.new
			part.size = '12 Tabletten'
      pack.parts.push part
			seq.active_packages = [pack]
			@package.sequence.comparables = [seq]
			@package.sequence.active_packages = [seqpack, @package]
      part = ODDB::Part.new
			part.size = '15 Tabletten'
      @package.parts.push part
			assert_equal([pack, seqpack], @package.comparables)
		end
		def test_respond_to_name_base
			assert_respond_to(@package, :name_base)
		end
		def test_price_diff
			values = {:price_exfactory => 12.34}
			expected = {:price_exfactory => Util::Money.new(12.34)}
			assert_equal(expected, @package.diff(values))
			@package.price_exfactory = Util::Money.new(12.34)
			assert_equal({}, @package.diff(values))
			values = {:price_exfactory => "12.34"}
			assert_equal({}, @package.diff(values))
			values = {:price_exfactory => 43.21}
			expected = {:price_exfactory => Util::Money.new(43.21)}
			assert_equal(expected, @package.diff(values))
			## rounding errors:
			@package.price_exfactory = Util::Money.new(43.21)
			values = {:price_exfactory => 43.210000000000000000345}
			assert_equal({}, @package.diff(values))
			values = {:price_exfactory => 43.209999999999999999995}
			assert_equal({}, @package.diff(values))
		end
		def test_feedback
      fb1 = flexmock :oid => 12
      fb2 = flexmock :oid => 16
			@package.feedbacks.push fb1, fb2
			assert_equal(fb1, @package.feedback(12))
			assert_equal(fb2, @package.feedback('16'))
			assert_nil(@package.feedback(1))
		end
	end
end
