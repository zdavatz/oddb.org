#!/usr/bin/env ruby
# TestBsvPlugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/bsv'
require 'date'

module ODDB
	class BsvPlugin < Plugin
		class PackageDiffer
			attr_accessor :both, :bsv, :smj
		end
		attr_accessor :unknown_packages, :unknown_registrations
		attr_accessor :change_flags, :successful_updates, :updated_packages
		attr_accessor :package_diffs
		public :update_package, :update_registration, :update_sl
		public :report_format, :purge_sl_entries, :price_flag
	end
end

class TestBsvPlugin < Test::Unit::TestCase
	class StubApp
		attr_accessor :registrations, :updates, :packages, :deletions
		def initialize
			@deletions = []
			@updates = {}
		end
		def delete(pointer)
			@deletions.push(pointer)
		end
		def each_package(&block)
			@packages.each(&block)
		end
		def registration(iksnr)
			(@registrations ||={})[iksnr]
		end
		def update(pointer, values)
			@updates.store(pointer, values)
		end
	end
	class StubCell
		attr_accessor :value
		def initialize(value)
			@value = value
		end
		def to_s
			@value.to_s
		end
		def to_i
			@value.to_i
		end
		def date
			Date.today
		end
	end	
	class StubRegistration
		attr_accessor :packages
		def package(iksnr)
			(@packages ||={})[iksnr]
		end
		def each_package(&block)
			(@packages ||= {}).each_value(&block)
		end
	end
	class StubPackage
		attr_accessor :pointer, :sl_entry, :ikscd, :iksnr,
			:price_exfactory, :price_public
		def diff(hash)
			hash
		end
	end
	class StubSlEntry
		attr_accessor :pointer
	end

	def setup
		@url = 'http://www.galinfo.net/sl/BSV_per_2003.06.01.xls'
		@app = StubApp.new
		@plug = ODDB::BsvPlugin.new(@app)
	end
	def test_purge_sl_entries
		sl_entry1 = StubSlEntry.new
		sl_entry2 = StubSlEntry.new
		sl_entry1.pointer = 1
		sl_entry2.pointer = 2
		pack1 = StubPackage.new
		pack2 = StubPackage.new
		pack3 = StubPackage.new
		pack1.pointer = 11
		pack2.pointer = 12
		pack3.pointer = 13
		pack1.sl_entry = sl_entry1 
		pack3.sl_entry = sl_entry2
		@app.packages = [ pack1, pack2, pack3 ]
		@plug.updated_packages = [ pack3 ]	
		@plug.purge_sl_entries
		assert_equal([1], @app.deletions)
		expected = {
			11	=>	[:sl_entry_delete],
		}
		assert_equal(expected, @plug.change_flags)
	end
	def test_report_format
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.new(2003,6,18),
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		expected = [
			"Name:               Acupan Filmtabs 30 mg 20 Filmtabs 30 mg",
			"Company:            3M (Schweiz AG)",
			"Iksnr:              39437",
			"Ikscd:              031",
			"Ikscat:             B",
			"Generic-type:       ",
			"Price-exfactory:    5.39",
			"Price-public:       12.5",
			"Introduction-date:  2003-06-18",
			"Limitation:         false", 
			"Limitation-points:  0",
		]
		assert_equal(expected, @plug.report_format(row))
	end
	def test_report
		assert_nothing_raised { @plug.report }
	end
	def test_update_package1 # Unknown Package
		reg = StubRegistration.new
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		@plug.update_package(reg, row)
		assert_equal([row], @plug.unknown_packages)
		assert_equal(['39437'], @plug.package_diffs.keys)
		diff = @plug.package_diffs['39437']
		assert_instance_of(ODDB::BsvPlugin::PackageDiffer, diff)
		assert_equal(['031'], diff.bsv)
		assert_equal([], diff.both)
	end
	def test_update_package2 # Price changed
		reg = StubRegistration.new
		package = StubPackage.new
		package.sl_entry = StubSlEntry.new
		package.price_exfactory = 4.00
		pointer = ODDB::Persistence::Pointer.new
		package.pointer = pointer
		reg.packages = {
			'031'	=>	package
		}	
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		@plug.update_package(reg, row)
		expected = {
			:price_exfactory	=>	5.39,
			:price_public			=>	12.50,
		}
		assert_equal(expected, @app.updates[pointer])
		assert_equal({pointer => [:price_rise]}, @plug.change_flags)
		assert_equal([], @plug.unknown_packages)
		assert_equal(['39437'], @plug.package_diffs.keys)
		diff = @plug.package_diffs['39437']
		assert_instance_of(ODDB::BsvPlugin::PackageDiffer, diff)
		assert_equal([], diff.bsv)
		assert_equal(['031'], diff.both)
	end
	def test_update_package3 # only price_public
		reg = StubRegistration.new
		package = StubPackage.new
		package.sl_entry = StubSlEntry.new
		pointer = ODDB::Persistence::Pointer.new
		package.pointer = pointer
		reg.packages = {
			'031'	=>	package
		}	
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		assert_nothing_raised { @plug.update_package(reg, row) }
		expected = {
			:price_public			=>	12.50,
		}
		assert_equal(expected, @app.updates[pointer])
		assert_equal([], @plug.unknown_packages)
	end
	def test_update_package4 # no price information
		reg = StubRegistration.new
		package = StubPackage.new
		package.sl_entry = StubSlEntry.new
		pointer = ODDB::Persistence::Pointer.new
		package.pointer = pointer
		reg.packages = {
			'031'	=>	package
		}	
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
		}
		assert_nothing_raised { @plug.update_package(reg, row) }
		expected = {}
		assert_equal(expected, @app.updates[pointer])
		assert_equal({}, @plug.change_flags)
		assert_equal([], @plug.unknown_packages)
	end
	def test_update_package5 # no prior SL-Entry
		reg = StubRegistration.new
		package = StubPackage.new
		pointer = ODDB::Persistence::Pointer.new
		package.pointer = pointer
		reg.packages = {
			'031'	=>	package
		}	
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		assert_nothing_raised { @plug.update_package(reg, row) }
		expected = {
			:price_public			=>	12.50,
		}
		assert_equal(expected, @app.updates[pointer])
		assert_equal({pointer => [:sl_entry]}, @plug.change_flags)
		assert_equal([], @plug.unknown_packages)
	end
	def test_update_registration1
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		@plug.update_registration(row)
		assert_equal([row], @plug.unknown_registrations)
	end
	def test_update_registration2
		@app.registrations = {
			'39437'	=>	StubRegistration.new
		}
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		@plug.update_registration(row)
		pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
		assert_nil(@app.updates[pointer])
		assert_equal([], @plug.unknown_registrations)
	end
	def test_update_registration3
		@app.registrations = {
			'39437'	=>	StubRegistration.new
		}
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
			:generic_type				=>	:generic,
		}
		@plug.update_registration(row)
		pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
		hash = @app.updates.collect { |key, value|
			value if key==pointer
		}.compact.first
		assert_equal([], @plug.unknown_registrations)
		assert_equal({:generic_type => :generic}, hash)
	end
	def test_update_sl
		row = {
			:company						=>	'3M (Schweiz AG)',
			:iksnr							=>	'39437',
			:ikscd							=>	'031',
			:ikscat							=>	'B',
			:introduction_date	=>	Date.today,
			:name								=>	'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg',
			:price_exfactory		=>	5.39,
			:price_public				=>	12.50,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		pointer = ODDB::Persistence::Pointer.new()
		sl_pointer = pointer + :sl_entry
		creator = sl_pointer.creator
		expected = {
			:introduction_date	=>	Date.today,
			:limitation					=>	false,
			:limitation_points	=>	0,
		}
		@plug.update_sl(pointer, row)
		hash = @app.updates.collect { |key, value|
			value if key==creator
		}.compact.first
		assert_equal(expected, hash)
	end
	def test_price_flag
		assert_equal(:price_cut, @plug.price_flag(2,1,4,3))
		assert_equal(:price_rise, @plug.price_flag(1,2,4,3))
		assert_equal(:price_rise, @plug.price_flag(2,1,3,4))
		assert_equal(:price_rise, @plug.price_flag(1,2,3,4))
		assert_equal(:price_rise, @plug.price_flag(nil,2,3,4))
		assert_equal(:price_rise, @plug.price_flag(1,nil,3,4))
		assert_equal(:price_rise, @plug.price_flag(nil,nil,3,4))
		assert_equal(:price_cut, @plug.price_flag(nil,2,4,3))
		assert_equal(:price_cut, @plug.price_flag(1,nil,4,3))
		assert_equal(:price_cut, @plug.price_flag(nil,nil,4,3))
		assert_equal(:price_rise, @plug.price_flag(1,2,nil,4))
		assert_equal(:price_rise, @plug.price_flag(1,2,3,nil))
		assert_equal(:price_rise, @plug.price_flag(1,2,nil,nil))
		assert_equal(:price_cut, @plug.price_flag(2,1,nil,4))
		assert_equal(:price_cut, @plug.price_flag(2,1,3,nil))
		assert_equal(:price_cut, @plug.price_flag(2,1,nil,nil))
		assert_equal(:price_rise, @plug.price_flag(nil, nil, nil, nil))
	end
end
class TestPackageDiffer < Test::Unit::TestCase
	class StubRegistration
		attr_accessor :packages
		def each_package(&block)
			(@packages ||= {}).each_value(&block)
		end
	end
	def setup
		reg = StubRegistration.new
		row = {
			:name	=>	"Aspirin Cardio", 
			:iksnr =>	"12345",
		}
		@diff = ODDB::BsvPlugin::PackageDiffer.new(reg, row)
	end
	def test_add_both1
		@diff.add_both('007')
		assert_equal([], @diff.bsv)
		assert_equal([], @diff.smj)
		assert_equal(['007'], @diff.both)
		@diff.add_both('017')
		assert_equal([], @diff.bsv)
		assert_equal([], @diff.smj)
		assert_equal(['007', '017'], @diff.both)
		@diff.add_both('007')
		assert_equal([], @diff.bsv)
		assert_equal([], @diff.smj)
		assert_equal(['007', '017'], @diff.both)
	end
	def test_add_both2
		@diff.smj = ['001', '002']
		@diff.add_both('001')
		assert_equal(['001'], @diff.both)
		assert_equal(['002'], @diff.smj)
	end
	def test_add_bsv1
		@diff.add_bsv('007')
		assert_equal(['007'], @diff.bsv)
		assert_equal([], @diff.smj)
		assert_equal([], @diff.both)
	end
	def test_add_bsv2
		@diff.smj = ['001', '002']
		assert_raises(RuntimeError) {
			@diff.add_bsv('001')
		}
		assert_equal(['001', '002'], @diff.smj)
		assert_equal([], @diff.bsv)
	end
	def test_add_smj
		@diff.add_smj('007')
		assert_equal([], @diff.bsv)
		assert_equal(['007'], @diff.smj)
		assert_equal([], @diff.both)
		@diff.both = ['017']
		@diff.add_smj('017')
		assert_equal([], @diff.bsv)
		assert_equal(['007'], @diff.smj)
		assert_equal(['017'], @diff.both)
	end
	def test_empty
		assert_equal(true, @diff.empty?)
		@diff.both = ['001']
		assert_equal(true, @diff.empty?)
		@diff.smj = ['002']
		assert_equal(true, @diff.empty?)
		@diff.bsv = ['002']
		assert_equal(false, @diff.empty?)
		@diff.smj = []
		assert_equal(false, @diff.empty?)
	end
	def test_to_s
		@diff.bsv = ['002', '001', '003']
		@diff.smj = ['004']
		@diff.both = ['005', '007', '006', '008']
		expected = <<-EOS
Aspirin Cardio
12345     001       004       005       
          002                 006       
          003                 007       
                              008       
		EOS
		result = @diff.to_s
=begin
		expected.split('').each_with_index { |char, idx|
			assert_equal(char, result[idx,1], expected[0..idx])
		}
=end
		assert_equal(expected.chop, result)
	end
end
