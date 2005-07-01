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
	class BsvPlugin2 < Plugin
		class PackageDiffer
			attr_accessor :both, :bsv, :smj
		end
		ARCHIVE_PATH = File.expand_path('../data', File.dirname(__FILE__))
		public :balance_package
		public :bulletin
		public :database
		public :download_bulletin
		public :download_database
		public :handle_addition
		public :handle_augmentation
		public :handle_deletion
		public :handle_reduction
		public :load_database
		public :report_format
		attr_reader :ptable, :ikstable, :unknown_registrations, 
			:unknown_packages, :successful_updates
	end
=begin
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
=end
	class TestPackageDiffer < Test::Unit::TestCase
		class StubRegistration
			attr_accessor :iksnr, :name_base
			attr_accessor :packages
			def each_package(&block)
				(@packages ||= {}).each_value(&block)
			end
		end
		def setup
			reg = StubRegistration.new
			pac = BsvPlugin2::ParsedPackage.new
			pac.name = 'Aspirin Cardio'
			pac.iksnr = '12345'
			@diff = BsvPlugin2::PackageDiffer.new(reg, pac)
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
Iksnr       BAG         Swissmedic  Beide       
12345       001         004         005         
            002                     006         
            003                     007         
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
	class TestBsvMutationParser < Test::Unit::TestCase
		def setup
			src = File.read(File.expand_path('../data/txt/PR050401.txt',
				File.dirname(__FILE__)))
			@parser = BsvPlugin2::MutationParser.new(src)
		end
		def test_identify_parts
			additions = <<-EOS
Kapitel:01.01.30

		Durogesic Matrix 	JANSSEN-CILAG AG
+		(Fentanyl.)
		16734		5 Systeme 12,5 mcg/h Fr. 53.35 {31.38}		[53904068]		01.04.2005, A
 
Kapitel:01.06.00

		Limbitrol 		ICN PHARMACEUTICALS SWITZERLAND AG
		(Amitriptylin. HCl, Chlordiazepoxid.)
		18128		30 Caps. (12,5+5 mg) Fr. 12.75 {5.60}		[33354010]		01.04.2005, B
		18128		100 Caps. (12,5+5 mg) Fr. 36.20 {16.84}		[33354029]		01.04.2005, B
 
Kapitel:02.06.10

		Amlo eco 		ECOSOL AG
G		(Amlodipin.)
		18092		30 Compr. 5 mg Fr. 34.85 {15.70}		[56151002]		01.04.2005, B
		18092		100 Compr. 5 mg Fr. 66.90 {42.90}		[56151004]		01.04.2005, B
 
		Amlo eco 		ECOSOL AG
		(Amlodipin.)
G		18092		30 Compr. 10 mg Fr. 51.70 {30.00}		[56151006]		01.04.2005, B
		18092		100 Compr. 10 mg Fr. 112.95 {82.00}		[56151008]		01.04.2005, B

 
		Amlodipin Helvepharm 	HELVEPHARM AG
G		(Amlodipin.)
		18132		30 Compr. 5 mg Fr. 36.75 {17.30}		[56821002]		01.04.2005, B
		18132		100 Compr. 5 mg Fr. 89.95 {62.47}		[56821004]		01.04.2005, B
 
		Amlodipin Helvepharm 	HELVEPHARM AG
		(Amlodipin.)
G		18132		30 Compr. 10 mg Fr. 52.95 {31.05}		[56821006]		01.04.2005, B
		18132		100 Compr. 10 mg Fr. 149.70 {113.22}		[56821008]		01.04.2005, B

 
		Amlodipin-Mepha 	MEPHA PHARMA AG
		(Amlodipin.)
G		18133		30 Compr. 5 mg Fr. 39.90 {19.97}		[56991002]		01.04.2005, B
		18133		100 Compr. 5 mg Fr. 99.80 {70.84}		[56991004]		01.04.2005, B
 
		Amlodipin-Mepha 	MEPHA PHARMA AG
G		(Amlodipin.)
		18133		30 Compr. 10 mg Fr. 59.50 {36.61}		[56991008]		01.04.2005, B
		18133		100 Compr. 10 mg Fr. 171.40 {131.64}		[56991010]		01.04.2005, B
 

		Amlopin 		SPIRIG PHARMA AG
		(Amlodipin.)
G		18134		30 Compr. 5 mg Fr. 35.00 {15.81}		[57011002]		01.04.2005, B
		18134		100 Compr. 5 mg Fr. 66.50 {42.56}		[57011004]		01.04.2005, B
 
		Amlopin 		SPIRIG PHARMA AG
		(Amlodipin.)
G		18134		30 Compr. 10 mg Fr. 52.00 {30.24}		[57011006]		01.04.2005, B
		18134		100 Compr. 10 mg Fr. 112.50 {81.62}		[57011008]		01.04.2005, B


		Alzar			MEDIKA AG
		(Amlodipin.)
G		18091		30 Compr. 5 mg Fr. 29.95 {14.99}		[56822001]		01.04.2005, B
		18091		100 Compr. 5 mg Fr. 59.95 {37.00}		[56822003]		01.04.2005, B

		Alzar			MEDIKA AG
G		(Amlodipin.)
		18091		30 Compr. 10 mg Fr. 44.90 {24.20}		[56822005]		01.04.2005, B
		18091		100 Compr. 10 mg Fr. 89.90 {62.45}		[56822007]		01.04.2005, B

 
Kapitel:02.07.10

		Lisinopril HelvePharm 	HELVEPHARM AG
		(Lisinopril.)
G		18172		30 Compr. 5 mg Fr. 9.95 {4.99}			[56905002]		01.04.2005, B
		18172		100 Compr. 5 mg Fr. 28.95 {14.15}		[56905004]		01.04.2005, B
 
		Lisinopril HelvePharm 	HELVEPHARM AG
G		(Lisinopril.)
		18172		30 Compr. 10 mg Fr. 18.50 {8.76}		[56905006]		01.04.2005, B
		18172		100 Compr. 10 mg Fr. 41.50 {21.34}		[56905008]		01.04.2005, B

		Lisinopril HelvePharm 	HELVEPHARM AG
G		(Lisinopril.)
		18172		30 Compr. 20 mg Fr. 28.70 {13.95}		[56905010]		01.04.2005, B
		18172		100 Compr. 20 mg Fr. 64.90 {41.22}		[56905012]		01.04.2005, B
 
Kapitel:02.07.20

		Corpriretic 		G. STREULI & CO. AG
		(Lisinopril., Hydrochlorothiazid.)
G		18097		30 Compr. (10+12,5 mg) Fr. 29.70 {14.80}	[56902001]		01.04.2005, B
		18097		100 Compr. (10+12,5 mg) Fr. 65.75 {41.90}	[56902003]		01.04.2005, B
 
		Corpriretic 		G. STREULI & CO. AG
G		(Lisinopril., Hydrochlorothiazid.)
		18097		30 Compr. (20+12,5 mg) Fr. 39.70 {19.80}	[56902005]		01.04.2005, B
		18097		100 Compr. (20+12,5 mg) Fr. 82.35 {56.00}	[56902007]		01.04.2005, B
 
		Lisinopril HCT Helvepharm 		HELVEPHARM AG
G		(Lisinopril., Hydrochlorothiazid.)
		18136		30 Compr. (10+12,5 mg) Fr. 28.90 {14.11}	[56901002]		01.04.2005, B
		18136		100 Compr. (10+12,5 mg) Fr. 61.85 {38.62}	[56901004]		01.04.2005, B
 
		Lisinopril HCT Helvepharm 		HELVEPHARM AG
G		(Lisinopril., Hydrochlorothiazid.)
		18136		30 Compr. (20+12,5 mg) Fr. 38.40 {18.70}	[56901006]		01.04.2005, B
		18136		100 Compr. (20+12,5 mg) Fr. 79.90 {53.94}	[56901008]		01.04.2005, B
 
		Provas 		SCHWARZ PHARMA AG
		(Valsartan.)
		18174		28 Filmtabs 80 mg Fr. 58.40 {35.67}		[57305002]		01.04.2005, B
		18174		98 Filmtabs 80 mg Fr. 152.05 {115.20}		[57305004]		01.04.2005, B
 
		Provas 		SCHWARZ PHARMA AG
		(Valsartan.)
		18174		28 Filmtabs 160 mg Fr. 66.90 {42.88}		[57305006]		01.04.2005, B
		18174		98 Filmtabs 160 mg Fr. 194.80 {151.51}		[57305008]		01.04.2005, B
 
		Provas comp 	SCHWARZ PHARMA AG
		(Valsartan., Hydrochlorothiazid.)
		18175		28 Filmtabs (80+12,5 mg) Fr. 60.80 {37.71}	[57304001]		01.04.2005, B
		18175		98 Filmtabs (80+12,5 mg) Fr. 159.90 {121.88}	[57304003]		01.04.2005, B
 
		Provas comp 	SCHWARZ PHARMA AG
		(Valsartan., Hydrochlorothiazid.)
		18175		28 Filmtabs (160+12,5 mg) Fr. 69.10 {44.75}	[57304005]		01.04.2005, B
		18175		98 Filmtabs (160+12,5 mg) Fr. 200.65 {156.49}	[57304007]		01.04.2005, B
 
		Provas comp 	SCHWARZ PHARMA AG
		(Valsartan., Hydrochlorothiazid.)
		18175		28 Filmtabs maxx (160+25 mg) Fr. 69.10 {44.75}	[57304009]		01.04.2005, B
		18175		98 Filmtabs maxx (160+25 mg) Fr. 200.65 {156.49} [57304011]		01.04.2005, B
 
Kapitel:03.04.10

		Euphyllin N 		ALTANA PHARMA AG
		(Theophyllin.)
		 6771		5 Amp. i.v. 200 mg/10 ml Fr. 7.90 {3.29}	[18056038]		01.04.2005, B
 
Kapitel:04.08.13

	(L)	Colosan mite 		VIFOR SA
		(Sterculiae Gummi)
		13716		200 g Pulv. gran. 85% citron Fr. 12.35 {6.71}	[43319078]		01.04.2005, D
		13716		500 g Pulv. gran. 85% citron Fr. 28.25 {15.34}	[43319086]		01.04.2005, D
		13716		200 g Pulv. gran. 85% mocca Fr. 12.35 {6.71}	[43319108]		01.04.2005, D
		13716		500 g Pulv. gran. 85% mocca Fr. 28.25 {15.34}	[43319116]		01.04.2005, D

Limitatio: Gesamthaft zugelassen 2 Kleinpackungen oder 1 Grosspackung. Von dieser Beschränkung ist die Behandlung der 
Obstipation aufgrund von Opioidtherapie, von Parkinsontherapie sowie diejenige der Obstipation von Patienten, die Anti-
depressiva oder Neuroleptika unterstellt sind, ausgenommen. Im weiteren sind davon ausgenommen Para- und Tetraplegiker.

Prescription limitée au maximum à 2 petits emballages ou 1 grand emballage. Cette limitation ne s'applique pas à la 
prise en charge des cas de constipation résultant d'un traitement par des opioïdes ou par des antiparkinsoniens ou
encore à ceux consécutifs à la prise d'antidépresseurs ou de neuroleptiques. Cette limitation ne s'applique pas non
plus aux paraplégiques et aux tétraplégiques.

 
Kapitel:04.09.00

		Mesazin 		VIFOR SA
		(Mesalazin.)
		17975		50 Sach. Gran. 500 mg Fr. 53.65 {31.66}		[55951002]		01.04.2005, B
		17975		300 Sach. Gran. 500 mg Fr. 206.50 {161.47}	[55951004]		01.04.2005, B
 
		Mesazin 		VIFOR SA
		(Mesalazin.)
		17975		50 Sach. Gran. 1000 mg Fr. 90.95 {63.32}	[55951006]		01.04.2005, B
		17975		150 Sach. Gran. 1000 mg Fr. 206.50 {161.47}	[55951008]		01.04.2005, B
 
Kapitel:07.08.30

		Utrogestan 		VIFOR SA
		(Progesteron.)
		14470		15 Caps. 200 mg Fr. 20.35 {10.32}		[45351033]		01.04.2005, B
 
Kapitel:07.12.00

		Primesin 		SCHWARZ PHARMA AG
		(Fluvastatin.)
		18188		28 Caps. mite 20 mg Fr. 41.75 {21.56}		[57306001]		01.04.2005, B
		18188		98 Caps. mite 20 mg Fr. 99.55 {70.61}		[57306003]		01.04.2005, B
 
		Primesin 		SCHWARZ PHARMA AG
		(Fluvastatin.)
		18188		28 Caps. 40 mg Fr. 58.05 {35.39}		[57306005]		01.04.2005, B
		18188		98 Caps. 40 mg Fr. 152.70 {115.74}		[57306007]		01.04.2005, B
 
		Primesin 		SCHWARZ PHARMA AG
		(Fluvastatin.)
		18189		28 Compr. retard 80 mg Fr. 69.05 {44.72}	[57307002]		01.04.2005, B
		18189		98 Compr. retard 80 mg Fr. 200.35 {156.22}	[57307004]		01.04.2005, B
 
Kapitel:11.09.00

		Timo-Comod 		URSAPHARM SCHWEIZ GMBH
G		(Timololi maleas)
		18152		5 ml Guttae 0,25% Fr. 15.90 {6.56}		[55788009]		01.04.2005, B
		18152		2 x 5 ml Guttae 0,25% Fr. 27.30 {12.73}		[55788011]		01.04.2005, B
 
		Timo-Comod 		URSAPHARM SCHWEIZ GMBH
G		(Timololi maleas)
		18152		5 ml Guttae 0,5% Fr. 16.65 {7.18}		[55788013]		01.04.2005, B
		18152		2 x 5 ml Guttae 0,5% Fr. 28.70 {13.93}		[55788015]		01.04.2005, B
 
Kapitel:57.10.40

	(L)	Schmids Sportcrème 		OTC PHARMA AG
		(Dextrocamphora, Eucalypti aetheroleum, Gaultheriae aetherol., Rosmarini aetheroleum, Terebinthinae medicinalis aetheroleum, Arnicae Tct.)
		18154		100 g Crème (40+40+40+40+40+100 mg) Fr. 14.25 {7.74} [54210019]		01.04.2005, D

Limitatio: 4 x 100 g pro 3 Monate.
4 x 100 g par période de 3 mois.
			EOS
			deletions = <<-EOS
Kapitel:01.01.24

		Dorsilon 		DROSSAPHARM AG
		(Mephenoxalon., Paracetamol.)
		 9750		20 Compr. (200+450 mg) Fr. 11.20 {4.65}		[29088012]		1964, B
		 9750		100 Compr. (200+450 mg) Fr. 37.20 {17.66}	[29088020]		1964, B
 
		Dorsilon 		DROSSAPHARM AG
		(Mephenoxalon., Paracetamol.)
		10385		10 Supp. (200+600 mg) Fr. 9.15 {3.80}		[30848012]		1964, B
 
Kapitel:01.01.30

		Depronal retard 	PFIZER AG
		(Dextropropoxyphen. HCl)
		12086		15 Caps. 150 mg Fr. 16.25 {6.84}		[34306028]		1975, B
 
Kapitel:03.04.10

		Euphyllin 		ALTANA PHARMA AG
		(Aminophyllin.)
		 6771		5 Amp. i.v. 10 ml 24 mg/ml Fr. 7.90 {3.29}	[18056011]		1955, B
 
Kapitel:06.06.00

		Cyklokapron 		PFIZER AG
		(Acid. tranexamic.)
		11587		6 Amp. 5 ml 100 mg/ml Fr. 34.30 {15.23}		[33740018]		1972, B
 
Kapitel:10.05.20

		Nystacorton 		SPIRIG PHARMA AG
		(Prednisoloni acetas, Nystatin., Chlorhexidini HCl)
		14033		25 g Schaum (0,5%+100 000 E./u./g+0,5%) Fr. 18.20 {8.49} [44035014]		1982, B
 
Kapitel:12.02.60

		Coldistop 		RIDUPHARM
		(Retinol. palmitic., Tocopherol. acetic.)
		12579		10 ml Guttae (15 000 U.I.+20 mg/ml) Fr. 5.05 { } [38189018]		1977, D
			EOS
			reductions = <<-EOS
Fludara	SCHERING (Schweiz) AG	07.16.10
	5 Amp. 50 mg	1635551	16397	1332.70	1128.60	
 
Lisitril	ECOSOL AG	02.07.10
	100 Compr. 5 mg	2783816	18004	29.90		14.97	
	100 Compr. 10 mg2783880	18004	45.60		24.81	
	30 Compr. 20 mg	2783897	18004	28.00		13.34	
	100 Compr. 20 mg 2783905 18004	65.15		41.42	
 
Omeprazol Sandoz	Sandoz AG	04.99.00
	14 Caps. 10 mg	2672235	17916	29.90		14.96	
	28 Caps. 10 mg	2672241	17916	46.30		25.40	
	56 Caps. 10 mg	2672258	17916	82.40		56.06	
	7 Caps. 20 mg	2672270	17916	25.30		11.05	
	14 Caps. 20 mg	2672287	17916	34.05		15.00	
	28 Caps. 20 mg	2672293	17916	56.70		34.23	
	56 Caps. 20 mg	2672301	17916	109.00		78.65	
 
Prinil	MEPHA Pharma AG	02.07.10
	30 Compr. 5 mg	1361881	15581	9.95		4.99	
	28 Compr. 20 mg	1361869	15581	26.95		12.45	
	98 Compr. 20 mg	1361875	15581	64.20		40.60	
			EOS
			augmentations = <<-EOS
Advate	BAXTER AG	06.01.10
	1 Amp. 250 I.E.	2802152	18009	360.95		320.55	
	1 Amp. 500 I.E.	2802175	18009	651.90		610.30	
	1 Amp. 1000 I.E.2802117	18009	1263.00		1219.50	
	1 Amp. 1500 I.E.2802123	18009	1871.70		1828.20	
 
Benefix	BAXTER AG	06.01.10
	1 Amp. 250 I.E.	2802241	17063	374.20		333.80	
	1 Amp. 500 I.E.	2802258	17063	709.20		667.60	
	1 Amp. 1000 I.E. 2802235 17063	1377.70		1334.20	
 
Endobulin S/D	BAXTER AG	08.09.00
	1 Amp. 2,5 g	2477255	15548	207.80		162.25	
	1 Amp. 5 g	2477278	15548	399.00		324.50	
	1 Amp. 10 g	2477284	15548	782.55		649.00	
 
Faktor VII-Konzentrat S-TIM 4	BAXTER AG	06.01.10
	1 Vitr. 10 ml 500 I.E.	1968821	15944	507.95	467.35	
 
Feiba S-TIM 4	BAXTER AG	06.01.10
	1 Amp. 1000 E./u. 1982672 13547	1522.10		1478.60	
 
Gammagard S/D	BAXTER AG	08.09.00
	1 Amp. 2,5 g	1982778	16709	228.10		179.50	
	1 Amp. 5 g	1982784	16709	439.85		359.00	
	1 Amp. 10 g	1982790	16709	863.80		718.00	
 
Gen H-B Vax	Aventis Pasteur MSD AG	08.08.00
	1 Amp. pro adult. 10 mcg	1946972	16589	46.10	25.15	
	1 Amp. pro infant. 5 mcg	1946966	16589	42.80	22.35	
 
Gen H-B Vax Dialyse	Aventis Pasteur MSD AG	08.08.00
	1 Amp. 40 mcg	1379912	16590	50.10		28.54	
 
HB Vax Pro 10	Aventis Pasteur MSD AG	08.08.00
	1 Amp. pro adult. 10 mcg	2723688	17959	46.10	25.15	
 
HB Vax Pro 5	Aventis Pasteur MSD AG	08.08.00
	1 Amp. pro infant. 5 mcg	2847189	17958	42.80	22.35	
 
Hexavac	Aventis Pasteur MSD AG	08.08.00
	1 Amp. 0,5 ml	2343773	17650	90.55		62.77	
 
Human-Albumin 20%	BAXTER AG	06.01.10
	100 ml 20% salzarm 1874356	12398	109.35	69.20	
 
Immunate STIM Plus	BAXTER AG	06.01.10
	1 Amp. 250 I.E.	1874422	16468	298.75		258.35	
	1 Amp. 500 I.E.	1874439	16468	528.00		487.40	
	1 Amp. 1000 I.E. 1874416 16468	1016.40		974.80	
 
Immunine STIM Plus	BAXTER AG	06.01.10
	1 Amp. 600 I.E.	1874451	16141	525.60		485.00	
	1 Amp. 1200 I.E. 1874445 16141	1010.35		968.75	
 
M-M-R-Vax II	Aventis Pasteur MSD AG	08.08.00
	1 Amp. 0,5 ml	595039	16595	46.70		25.66	
 
Pentavac	Aventis Pasteur MSD AG	08.08.00
	1 Amp. 0.5 ml	2198911	17426	60.75		37.53	
 
Prothromplex Total S-TIM 4	BAXTER AG	06.01.10
	1 Amp. 200 E./u. 1968838	15453	172.25	131.95	
	1 Amp. 600 E./u. 1968844	15453	412.85	372.25	
 
Recombinate 	BAXTER AG	06.01.10
	1 Amp. 250 I.E.	2802904	16469	360.95		320.55	
	1 Amp. 500 I.E.	2802927	16469	651.90		610.30	
	1 Amp. 1000 I.E. 2802962 16469	1263.00		1219.50	
 
Revaxis	Aventis Pasteur MSD AG	08.08.00
	1 Amp. 0,5 ml	2343804	17608	35.75		16.39	
 
Tetravac	Aventis Pasteur MSD AG	08.08.00
	1 Amp. 0,5 ml	2198934	17427	45.10		24.29	
 
Vaccin Rabique Inactivé	Aventis Pasteur MSD AG	08.08.00
	1 Amp. à 1 Dose	723543	13613	75.95		50.42	
			EOS
			limitations = <<-EOS
Kapitel:07.16.10.

		Fludara			SCHERING (SCHWEIZ) AG
		(Fludarabin. phosphas.)	
	16397	5 Amp. 50 mg Fr. 1332.70 {1128.60}

Limitatio: Therapie der chronisch-lymphatischen Leukämie (CLL) vom B-Zell-Typ. Die Firstline-
Therapie mit FLUDARA sollte nur bei Patienten mit fortgeschrittener Erkrankung begonnen werden, d.h. im
Binet-Stadium B oder C, einhergehend mit krankheitsbedingten Symptomen oder Zeichen einer 
Krankheitsprogression.
Behandlung des niedrig malignen Non-Hodgkin-Lymphoms im Stadium 3 bis 4 bei Patienten, die 
auf eine Standardtherapie mit mindestens einer alkylierenden Substanz nicht angesprochen
haben oder bei denen die Krankheit während oder nach der Standardtherapie fortgeschritten ist.

Traitement de la leucémie lymphoïde chronique (LLC) à cellules B. Le traitement de première
intention avec FLUDARA ne doit être initié que chez des patients qui sont déjà à un stade avancé de la
maladie, c'est-à-dire aux stades B ou C de la classification de Binet, accompagné de symptômes liés
à la maladie ou de signes d'une progression de la maladie.
Traitement du lymphome non hodgkinien de faible malignité au stade 3 à 4, chez les patients qui n'ont
pas répondu au traitement standard par au moins une substance alkylante ou chez lesquels la maladie
a progressé pendant ou après le traitement standard.
			EOS
			@parser.identify_parts
=begin
			expected.split('').each_with_index { |char, idx|
				assert_equal(char, result[idx,1], expected[0..idx])
			}
=end
			assert_equal(additions.strip, @parser.src_additions)
			assert_equal(deletions.strip, @parser.src_deletions)
			assert_equal(reductions.strip, @parser.src_reductions)
			assert_equal(augmentations.strip, @parser.src_augmentations)
			assert_equal(limitations.strip, @parser.src_limitations)
		end
		def test_parse_line__1
			line = <<-EOS	
		16734		5 Systeme 12,5 mcg/h Fr. 53.35 {31.38}		[53904068]		01.04.2005, A
			EOS
			package = @parser.parse_line(line)
			assert_equal('16734', package.sl_dossier)
			assert_equal('53904', package.iksnr)
			assert_equal('068', package.ikscd)
			assert_equal(Date.new(2005, 4), package.introduction_date)
			assert_equal(53.35, package.price_public)
			assert_equal(31.38, package.price_exfactory)
		end
		def test_parse_line__2
			line = <<-EOS	
		12579		10 ml Guttae (15 000 U.I.+20 mg/ml) Fr. 5.05 { } [38189018]		1977, D
			EOS
			package = @parser.parse_line(line)
			assert_equal('12579', package.sl_dossier)
			assert_equal('38189', package.iksnr)
			assert_equal('018', package.ikscd)
			assert_equal(Date.new(1977), package.introduction_date)
			assert_equal(5.05, package.price_public)
			assert_equal(0.0, package.price_exfactory)
		end
		def test_parse_line__3
			line = <<-EOS
	100 Compr. 5 mg	2783816	18004	29.90		14.97	
			EOS
			pack = @parser.parse_line(line)
			assert_equal('18004', pack.sl_dossier)
			assert_equal('2783816', pack.pharmacode)
			assert_equal(29.90, pack.price_public)
			assert_equal(14.97, pack.price_exfactory)
		end
		def test_parse_line__4
			line = <<-EOS
	100 Compr. 10 mg2783880	18004	45.60		24.81	
			EOS
			pack = @parser.parse_line(line)
			assert_equal('18004', pack.sl_dossier)
			assert_equal('2783880', pack.pharmacode)
			assert_equal(45.60, pack.price_public)
			assert_equal(24.81, pack.price_exfactory)
		end
	end
	class TestBsvPlugin2 < Test::Unit::TestCase
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
		class StubRegistration
			attr_accessor :packages, :iksnr, :name_base
			def initialize(iksnr)
				@iksnr = iksnr
			end
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
		def setup
			@app = StubApp.new
			@month = Date.new(2005, 4)
			@plugin = BsvPlugin2.new(@app)
		end
		def test_bulletin
			assert_equal('PR050401.txt', @plugin.bulletin(@month))
		end
		def test_database
			assert_equal('BSV_per_2005.04.01.xls', @plugin.database(@month))
		end
		def test_download
			assert_raises(RuntimeError) {
				@plugin.download_database(Date.today >> 2) # next month
			}
			assert_raises(RuntimeError) {
				@plugin.download_bulletin(Date.today >> 2) # next month
			}
		end
		def test_load_database
			db_file = File.expand_path('../data/xls/BSV_per_2005.04.01.xls',
				File.dirname(__FILE__))
			@plugin.load_database(db_file)
			pack1 = @plugin.ptable['2591407']
			assert_equal('55725040', pack1.ikskey)
			pack2 = @plugin.ikstable['55725040']
			assert_equal('2591407', pack2.pharmacode)
			assert_equal(pack1, pack2)
			assert_equal(false, @plugin.ptable.include?(''))
			assert_equal(false, @plugin.ptable.include?('0'))
			assert_equal(false, @plugin.ikstable.include?(''))
			assert_equal(false, @plugin.ikstable.include?('0'))
		end
		def test_balance_package__1
			pack = BsvPlugin2::ParsedPackage.new
			pack.pharmacode = '12345'
			pack2 = BsvPlugin2::ParsedPackage.new
			pack2.ikskey = '54321012'
			@plugin.ptable.store('12345', pack2)
			@plugin.balance_package(pack)
			assert_equal('54321012', pack.ikskey)
			assert_equal('54321', pack.iksnr)
			assert_equal('012', pack.ikscd)
		end
		def test_balance_package__2
			pack = BsvPlugin2::ParsedPackage.new
			pack.ikskey = '54321012'
			pack2 = BsvPlugin2::ParsedPackage.new
			pack2.pharmacode = '12345'
			@plugin.ikstable.store('54321012', pack2)
			@plugin.balance_package(pack)
			assert_equal('12345', pack.pharmacode)
		end
		def test_handle_addition_1
			@app.registrations = { '12345' => 'Registration' }
			pack = BsvPlugin2::ParsedPackage.new
			@plugin.handle_addition(pack)
			assert_equal([pack], @plugin.unknown_registrations)
			assert_equal([], @plugin.unknown_packages)
			assert_equal({}, @plugin.change_flags)
		end
		def test_handle_addition_2
			reg = StubRegistration.new('39437')
			reg.name_base = 'foo'
			@app.registrations = {
				'39437'	=>	reg
			}
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.today
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			@plugin.handle_addition(pac)
			pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
			assert_equal({}, @app.updates)
			assert_equal([], @plugin.unknown_registrations)
			assert_equal([pac], @plugin.unknown_packages)
		end
		def test_handle_addition_3
			reg = StubRegistration.new('39437')
			reg.name_base = 'foo'
			@app.registrations = {
				'39437'	=>	reg
			}
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.today
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			pac.generic_type = :generic
			@plugin.handle_addition(pac)
			pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
			assert_equal(1, @app.updates.size)
			assert_equal([], @plugin.unknown_registrations)
			assert_equal([pac], @plugin.unknown_packages)
		end
		def test_handle_addition_4
			pack = StubPackage.new
			pack.pointer = Persistence::Pointer.new(:package)
			reg = StubRegistration.new('39437')
			reg.name_base = 'foo'
			reg.packages = { '031' => pack }
			@app.registrations = {
				'39437'	=>	reg
			}
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.today
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			pac.generic_type = :generic
			@plugin.handle_addition(pac)
			pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
			assert_equal(3, @app.updates.size)
			assert_equal([], @plugin.unknown_registrations)
			assert_equal([], @plugin.unknown_packages)
			assert_equal([pac], @plugin.successful_updates)
			assert_equal([[:sl_entry]], @plugin.change_flags.values)
		end
		def test_handle_deletion
			pack = StubPackage.new
			pack.pointer = Persistence::Pointer.new(:package)
			reg = StubRegistration.new('39437')
			reg.name_base = 'foo'
			reg.packages = { '031' => pack }
			@app.registrations = {
				'39437'	=>	reg
			}
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.today
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			pac.generic_type = :generic
			@plugin.handle_deletion(pac)
			pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
			assert_equal(1, @app.deletions.size)
			assert_equal(2, @app.updates.size)
			assert_equal([], @plugin.unknown_registrations)
			assert_equal([], @plugin.unknown_packages)
			assert_equal([pac], @plugin.successful_updates)
			assert_equal([[:sl_entry_delete]], @plugin.change_flags.values)
		end
		def test_handle_reduction
			pack = StubPackage.new
			pack.pointer = Persistence::Pointer.new(:package)
			reg = StubRegistration.new('39437')
			reg.name_base = 'foo'
			reg.packages = { '031' => pack }
			@app.registrations = {
				'39437'	=>	reg
			}
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.today
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			pac.generic_type = :generic
			@plugin.handle_reduction(pac)
			pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
			assert_equal(0, @app.deletions.size)
			assert_equal(3, @app.updates.size)
			assert_equal([], @plugin.unknown_registrations)
			assert_equal([], @plugin.unknown_packages)
			assert_equal([pac], @plugin.successful_updates)
			assert_equal([[:price_cut]], @plugin.change_flags.values)
		end
		def test_handle_augmentation
			pack = StubPackage.new
			pack.pointer = Persistence::Pointer.new(:package)
			reg = StubRegistration.new('39437')
			reg.name_base = 'foo'
			reg.packages = { '031' => pack }
			@app.registrations = {
				'39437'	=>	reg
			}
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.today
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			pac.generic_type = :generic
			@plugin.handle_augmentation(pac)
			pointer = ODDB::Persistence::Pointer.new([:registration, '39437'])
			assert_equal(0, @app.deletions.size)
			assert_equal(3, @app.updates.size)
			assert_equal([], @plugin.unknown_registrations)
			assert_equal([], @plugin.unknown_packages)
			assert_equal([pac], @plugin.successful_updates)
			assert_equal([[:price_rise]], @plugin.change_flags.values)
		end
		def test_report_format
			pac = BsvPlugin2::ParsedPackage.new
			pac.company = '3M (Schweiz AG)'
			pac.ikskey = '39437031'
			pac.introduction_date	 = Date.new(2003,6,18)
			pac.name = 'Acupan Filmtabs 30 mg 20 Filmtabs 30 mg'
			pac.price_exfactory	= 5.39
			pac.price_public = 12.50
			pac.limitation = false
			pac.limitation_points = 0
			pac.generic_type = :generic
			expected = [
				"Name:               Acupan Filmtabs 30 mg 20 Filmtabs 30 mg",
				"Company:            3M (Schweiz AG)",
				"Iksnr:              39437",
				"Ikscd:              031",
				"Generic-type:       generic",
				"Price-exfactory:    5.39",
				"Price-public:       12.5",
				"Introduction-date:  2003-06-18",
				"Limitation:         false", 
				"Limitation-points:  0",
			]
			assert_equal(expected, @plugin.report_format(pac))
		end
		def test_report
			assert_nothing_raised { @plugin.report }
		end
	end
	class TestParsedPackage < Test::Unit::TestCase
		def setup
			@package = BsvPlugin2::ParsedPackage.new
		end
		def test_ikskey_writer__0
			@package.ikskey = '12345123'
			assert_equal('12345123', @package.ikskey)
		end
		def test_ikskey_writer__1
			@package.ikskey = '123'
			assert_equal('00123000', @package.ikskey)
		end
	end
end
