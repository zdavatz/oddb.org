#!/usr/bin/env ruby
# TestOddbDatExport -- oddb -- 23.06.2003 -- aschrafl@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'stub/oddbdat_export'
require 'model/text'
require 'date'
require 'util/language'
require 'fileutils'

module ODDB
	class OddbDatExport
		attr_reader :filenames, :singlefilenames
		attr_accessor :date
		class MCMLine
			attr_reader :text, :line_nr
		end
	end
end

class TestOddbDatExport < Test::Unit::TestCase
	class StubDose
		attr_accessor :qty, :unit
		def initialize
			@qty = 5
			@unit = 'kg'
		end
	end
	class StubGalenicForm
		attr_accessor :oid
		def initialize	
			@oid = 7
		end
		def to_s
			'This is the description of a galenic form'
		end
	end
	class StubAtcClass
		attr_accessor :code, :oid, :description
		def initialize
			@oid = '9'
			@code = 'ATC0273'
			@description = "\000T\000h\000i\000s\000 \000i\000s\000 \000a\000 \000d\000e\000s\000c\000r\000i\000p\000t\000i\000o\000n\000 o\000f\000 \000a\000 \000A\000t\000c\000C\000l\000a\000s\000s"
		end
	end		
	class StubSLEntry
		attr_accessor	:limitation, :limitation_points
		attr_accessor :limitation_text
		def initialize
			@limitation_text = nil
			@limitation_points = 5
		end
		def limitation_text
			@limitation_text 
		end
		def new_limtext(txt)
			@limitation_text = StubLimTxt.new(txt)
		end
	end
	class StubLimTxt
		attr_reader :oid, :descriptions
		def initialize(txt)
			@oid = 5
			chap_it = ODDB::Text::Chapter.new
			chap_fr = ODDB::Text::Chapter.new
			chap_de = ODDB::Text::Chapter.new
			['1','2','3'].each { |dig|
				it = chap_it.next_section.next_paragraph
				fr = chap_fr.next_section.next_paragraph
				de = chap_de.next_section.next_paragraph
				it << (txt+dig+'-it')
				fr << (txt+dig+'-fr')
				de << (txt+dig+'-de')
			}
			@descriptions = {
				'it'	=> chap_it, 
				'fr'	=> chap_fr,
				'de'	=> chap_de,
			}
		end
	end
	class StubCompany
		attr_accessor :ean13, :oid, :name, :address, :plz, :location, :phone, :fax, :address_email, :url
		def initialize
			@oid = 16
			@name = 'Ywesee'
			@address = 'Winterthurerstrasse 52'
			@plz = 8006
			@ean13 = '1234567891123'
			@location = 'Zuerich'
			@phone = '0041 1 350 85 85'
			@fax = '0041 1 350 85 86'
			@address_email = 'aschrafl@ywesee.com'
			@url = 'www.ywesee.com'
		end
	end
	class StubPackage
		attr_reader :oid, :iksnr, :ikscd, :ikscat, :ikskey
		attr_accessor :price_public, :price_exfactory, :substances
		attr_accessor :sl_entry, :dose, :registration, :sequence
		attr_accessor :multi, :galenic_form
		attr_accessor :measure, :count, :comform
		attr_accessor :fachinfo
		def initialize
			@oid = 3
			@iksnr = '007007'
			@ikscd = '747'
			@ikscat = 'A'
			@ikskey = '007007747'
		end	
		def barcode
			76800070077470
		end
		def pharmacode
			'12345'
		end
	end
	class StubSubstance
		attr_accessor :oid
		def initialize
			@oid = 41
		end
		def to_s
			'This is the description of a substance'
		end
	end
	class StubSequence
		attr_accessor :packages, :substances, :atc_class
		attr_accessor :galenic_form, :dose, :name, :name_base, :name_descr
	end
	class StubRegistration
		attr_reader :registration_date
		attr_accessor :generic_type, :company, :sequences, :iksnr,
									:fachinfo
		def initialize
			@registration_date = Time.now
		end
	end
	class StubODDBapp
		attr_accessor :registrations, :substances, :companies
		attr_accessor :atc_classes, :galenic_forms, :sequences
		attr_accessor :fachinfos
		def initialize
			@fachinfos = {}
		end
		def each_package
			@registrations.each_value { |registration|
				registration.sequences.each_value { |sequence|
					sequence.packages.each_value { |package|
						yield package
					}	
				}
			}
		end
		def each_atc_class(&block)
			@atc_classes.each_value(&block)
		end
		def each_galenic_form(&block)
			@galenic_forms.each(&block)
		end
	end	
	class StubFachinfo
		include ODDB::Language
		attr_accessor :oid
	end
	class StubFachinfoDocument
		attr_accessor :chapterone, :chaptertwo, :chapterthree
		attr_accessor :chapterfour, :chapterfive
		CHAPTERS = [
			:chapterone, :chaptertwo, :chapterthree, :chapterfour, 
			:chapterfive,
		]
		def initialize
			CHAPTERS.each_with_index { |chapter, idx|
				instance_eval("@#{chapter}=ODDB::Text::Chapter.new")
				instance_eval("@#{chapter}.heading = 'h-#{idx}'")
				instance_eval("sec = @#{chapter}.next_section")
				instance_eval("sec.subheading = 'sub-h-#{idx}'")
				instance_eval("par = sec.next_paragraph")
				instance_eval("par << 'text_'+#{idx}.to_s+'\n'+'end'")
				instance_eval("par.set_format(:italic)")
				instance_eval("par << 'italic'")
			}
			@chapterthree=ODDB::Text::Chapter.new
			par = @chapterthree.next_section.next_paragraph
			par << 'abcde '*35 << ' fghij'*5
			@chapterfour=ODDB::Text::Chapter.new
			par = @chapterfour.next_section.next_paragraph
			table = <<-EOS
----------------------------------------------------
Alter   Suspension   Kapseln   Suppositorien zu     
(Jahre) zu 10 mg/ml  zu        125 bzw. 500 mg      
        pro Tag      250 mg                         
----------------------------------------------------
 1/2    3\327 5 ml      -         2(-3)\327tgl. 1 \340 125 mg
 1-3    3\327 7,5 ml    -             3\327tgl. 1 \340 125 mg
 3-6    3\32710 ml      -             4\327tgl. 1 \340 125 mg
 6-9    3\32715 ml      -         1(-2)\327tgl. 1 \340 500 mg
 9-12   3\32720 ml      2(-3)\327                 
                     tgl. 1        2\327tgl. 1 \340 500 mg
12-14   3\32725 ml      3\327tgl. 1      3\327tgl. 1 \340 500 mg
----------------------------------------------------
			EOS
			@chapterfive=ODDB::Text::Chapter.new
			par = @chapterfive.next_section.next_paragraph
			par << table
			par.preformatted!
		end
		def each_chapter(&block)
			self::class::CHAPTERS.each { |chap|
				if(chapter = self.send(chap))
					block.call(chapter)
				end
			}
		end
	end
	class StubFachinfoDocument2001 < StubFachinfoDocument
		attr_accessor :chapterone, :chaptertwo, :chapterthree
		attr_accessor :chapterfour, :chapterfive, :chaptersix
		CHAPTERS = [
			:chapterone, :chaptertwo, :chapterthree, :chapterfour, 
			:chapterfive, :chaptersix,
		]
		def initialize
			CHAPTERS.each_with_index { |chapter, idx|
				instance_eval("@#{chapter}=ODDB::Text::Chapter.new")
				instance_eval("@#{chapter}.heading = 'h-#{idx}'")
				instance_eval("sec = @#{chapter}.next_section")
				instance_eval("sec.subheading = 'sub-h-#{idx}'")
				instance_eval("par = sec.next_paragraph")
				instance_eval("par << 'text_'+#{idx}.to_s")
				instance_eval("par.set_format(:italic)")
				instance_eval("par << 'italic'")
			}
		end
	end
	class StubFachinfoDoc
		attr_accessor :chapters
		def each_chapter(&block)
			@chapters.each(&block)
		end
	end

	def setup
		@app = StubODDBapp.new
		@plugin = ODDB::OddbDatExport.new(@app)
		@plugin.date = Time.gm(2003,"dec",15,11,11,11)
		@date = Date.today.strftime('%Y%m%d%H%M%S')
		@iksdate = Date.today.strftime("%Y%m%d")
		dir = ODDB::OddbDatExport.system_targetdir
		Dir.entries(dir) { |entry|
			file = File.expand_path(entry, dir)
			unless(File.ftype(file)=='directory')
				File.delete(file)
			end
		}
	end
	def test_scline
		package = StubPackage.new
		substance = StubSubstance.new
		scline = ODDB::OddbDatExport::ScLine.new(package, substance)
		expected = "40|#{@date}|41|L|4|This is the description of a substance||"
		assert_equal(expected, scline.to_s)
	end
	def test_galenicformline
		galform = StubGalenicForm.new
		galformline = ODDB::OddbDatExport::GalenicFormLine.new(galform)
		expected = "11|#{@date}|5|7|D|4|This is the description of a galenic form||"
		assert_equal(expected, galformline.to_s)
	end
	def test_compline
		company = StubCompany.new
		companyline = ODDB::OddbDatExport::CompLine.new(company)
		expected = "12|#{@date}|16|4|1234567891123||Ywesee|Winterthurerstrasse 52|CH|8006|Zuerich||0041 1 350 85 85||0041 1 350 85 86|aschrafl@ywesee.com|www.ywesee.com||"
		assert_equal(expected, companyline.to_s)
	end
	def test_atcline
		atcclass = StubAtcClass.new
		atcline = ODDB::OddbDatExport::AtcLine.new(atcclass)
		expected = "11|#{@date}|8|ATC0273|D|4|This is a description of a AtcClass||"
		assert_equal(expected, atcline.to_s)
	end
	def test_acscline
		package = StubPackage.new
		substance = StubSubstance.new
		dose = StubDose.new
		package.dose = dose
		acscline = ODDB::OddbDatExport::AcscLine.new(package, substance, 1)
		expected = "41|#{@date}|3|1|4|41|5|kg|W|"
		assert_equal(expected, acscline.to_s)
	end
	def test_acpricealgexfactoryline
		package = StubPackage.new
		acpricealgexfactoryline = ODDB::OddbDatExport::AcpricealgExfactoryLine.new(package)
		assert_equal('', acpricealgexfactoryline.to_s)
		package.price_exfactory = 342
		acpricealgexfactoryline = ODDB::OddbDatExport::AcpricealgExfactoryLine.new(package)
		expected = "07|#{@date}|3|PSL1|4|3.42|||"
		assert_equal(expected, acpricealgexfactoryline.to_s)
	end
	def test_acpricealgpublicline
		package = StubPackage.new
		acpricealgpublicline = ODDB::OddbDatExport::AcpricealgPublicLine.new(package)
		assert_equal('', acpricealgpublicline.to_s)
		package.price_public = 26
		acpricealgpublicline = ODDB::OddbDatExport::AcpricealgPublicLine.new(package)
		expected = "07|#{@date}|3|PPUB|4|0.26|||"
		assert_equal(expected, acpricealgpublicline.to_s)
		package.sl_entry = StubSLEntry.new
		acpricealgpublicline = ODDB::OddbDatExport::AcpricealgPublicLine.new(package)
		expected = "07|#{@date}|3|PSL2|4|0.26|||"
		assert_equal(expected, acpricealgpublicline.to_s)
	end
	def test_acmedline
		package = StubPackage.new
		sequence = StubSequence.new
		atcclass = StubAtcClass.new
		galenic_form = StubGalenicForm.new
		sequence.atc_class = atcclass
		package.sequence = sequence
		package.fachinfo = StubFachinfo.new
		package.fachinfo.oid = 3456 
		package.galenic_form = galenic_form
		acmedline = ODDB::OddbDatExport::AcmedLine.new(package)
		expected = "02|#{@date}|1|3|4||3456|||ATC0273||7|||||||||||||||"
		assert_equal(expected, acmedline.to_s)
	end
	def test_acmedline2
		package = StubPackage.new
		sequence = StubSequence.new
		package.sequence = sequence
		acmedline = ODDB::OddbDatExport::AcmedLine.new(package)
		expected = "02|#{@date}|1|3|4||||||||||||||||||||||"
		assert_equal(expected, acmedline.to_s)
	end
	def test_acnamline
		package = StubPackage.new
		sequence = StubSequence.new
		sequence.name = 'Il nomine della Rosa'
		sequence.name_base = 'Base Ball'
		sequence.name_descr = 'boring Sport'
		atcclass = StubAtcClass.new
		galenic_form = StubGalenicForm.new
		sequence.atc_class = atcclass
		sequence.galenic_form = galenic_form
		package.sequence = sequence
		acmedline = ODDB::OddbDatExport::AcnamLine.new(package)
		expected = "03|#{@date}|1|3|D|4|Il nomine della Rosa|Base Ball"
		expected += "|boring Sport||This is the description of a galenic form|||||||||||||||"
		assert_equal(expected, acmedline.to_s)
	end
	def test_accompline
		package = StubPackage.new
		company = StubCompany.new
		registration = StubRegistration.new
		registration.company = company
		package.registration = registration
		accompline = ODDB::OddbDatExport::AccompLine.new(package)
		expected = "19|#{@date}|3|16|H|4||"
		assert_equal(expected, accompline.to_s)
	end
	def test_generic_code
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		assert_equal(nil, acline.generic_code(registration))
		registration.generic_type = :generic
		assert_equal('Y', acline.generic_code(registration))
	end
	def test_http_filepath
		table = ODDB::OddbDatExport::AcTable.new(nil)
		assert_equal("/data/downloads/s01x", table.http_filepath)
	end
	def test_iks_date
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		assert_equal(@iksdate, acline.iks_date(registration))
	end
	def test_ikskey
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		assert_equal('007007747', acline.ikskey)
		assert_equal('007007', package.iksnr)
		assert_equal('747', package.ikscd)
	end
	def test_inscode
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		assert_equal(nil, acline.inscode)
		package.sl_entry = StubSLEntry.new
		assert_equal('1', acline.inscode)
	end
	def test_limitation
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		assert_equal(nil, acline.limitation)
		package.sl_entry = StubSLEntry.new
		assert_equal(nil, acline.limitation)
		package.sl_entry.limitation = true
		assert_equal('Y', acline.limitation)
	end
	def test_limitation_points
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		assert_equal(nil, acline.limitation_points)
		package.sl_entry = StubSLEntry.new
		assert_equal(5, acline.limitation_points)
	end
	def test_aclim
		package = StubPackage.new
		package.sl_entry = StubSLEntry.new
		package.sl_entry.new_limtext('test-txt-')
		table = ODDB::OddbDatExport::AcLimTable.new(@app)
		limtxtlines = table.lines(package)
		expected = "09|#{@date}|3|3002|2|4||"
		result = limtxtlines[2].to_s
		assert_equal(expected, result)
	end
	def test_limitation2
		package = StubPackage.new
		package.sl_entry = StubSLEntry.new
		package.sl_entry.new_limtext('test-txt-')
		table = ODDB::OddbDatExport::LimitationTable.new(@app)
		limtxtlines = table.lines(package)
		expected = "16|#{@date}|3001||4|COM||||"
		result = limtxtlines[1].to_s
		assert_equal(expected, result)
	end
	def test_limtxt
		package = StubPackage.new
		package.sl_entry = StubSLEntry.new
		package.sl_entry.new_limtext('test-txt-')
		table = ODDB::OddbDatExport::LimTxtTable.new(@app)
		limtxtlines = table.lines(package)
		expected = "10|#{@date}|3002|F|4|test-txt-3-fr||"
		assert_equal(expected, limtxtlines[8].to_s)
	end
	def test_mcm
		fi = StubFachinfo.new
		fi.descriptions[:de] = StubFachinfoDocument.new
		@app.fachinfos.store(1, fi)
		table = ODDB::OddbDatExport::MCMTable.new(@app)
		mcmlines = table.mcmline(fi)
		expected = "31|#{@date}|#{fi.oid}|D|2|4|<BI>h-1<E><P><I>sub-h-1<E>text_1 end<P><I>italic<E><P>"
		assert_equal(expected, mcmlines[1].to_s)
		result = mcmlines[4].text
		assert_equal("<P>", result)
		text_length = mcmlines[2].text.size
		assert_equal(216, text_length)
		assert_equal(4, mcmlines [3].line_nr)
		result = mcmlines[7].text
		expected = "<P>_6-9____3×15_ml______-_________1(-2)×tgl._1_à_500_mg<P>_9-12___3×20_ml______2(-3)×_________________<P>_____________________tgl._1________2×tgl._1_à_500_mg<P>12-14___3×25_ml______3×tgl._1______3×tgl._1_à_500_mg"
		assert_equal(expected, result)	
	end
	def test_mcm2
		date = Date.today.strftime("%Y%m%d%H%M%S")
		fi = StubFachinfo.new
		fi.descriptions[:de] = StubFachinfoDocument2001.new
		@app.fachinfos.store(1, fi)
		table = ODDB::OddbDatExport::MCMTable.new(@app)
		mcmlines = table.mcmline(fi)
		expected = "31|#{date}|#{fi.oid}|D|6|4|<BI>h-5<E><P><I>sub-h-5<E>text_5<P><I>italic<E><P>"
		assert_equal(expected, mcmlines[5].to_s)
	end
	def test_mcm3
		date = Date.today.strftime("%Y%m%d%H%M%S")
		fi = StubFachinfo.new
		fi.descriptions[:de] = StubFachinfoDocument2001.new
		@app.fachinfos.store(1, fi)
		table = ODDB::OddbDatExport::MCMTable.new(@app)
		mcmlines = table.mcmline(fi)
		expected = <<-EOS
31|#{date}|#{fi.oid}|D|1|4|<BI>h-0<E><P><I>sub-h-0<E>text_0<P><I>italic<E><P>
31|#{date}|#{fi.oid}|D|2|4|<BI>h-1<E><P><I>sub-h-1<E>text_1<P><I>italic<E><P>
31|#{date}|#{fi.oid}|D|3|4|<BI>h-2<E><P><I>sub-h-2<E>text_2<P><I>italic<E><P>
31|#{date}|#{fi.oid}|D|4|4|<BI>h-3<E><P><I>sub-h-3<E>text_3<P><I>italic<E><P>
31|#{date}|#{fi.oid}|D|5|4|<BI>h-4<E><P><I>sub-h-4<E>text_4<P><I>italic<E><P>
31|#{date}|#{fi.oid}|D|6|4|<BI>h-5<E><P><I>sub-h-5<E>text_5<P><I>italic<E><P>
		EOS
		assert_equal(expected.strip, mcmlines.join("\n"))
	end
	def test_mcm4
		date = Date.today.strftime("%Y%m%d%H%M%S")
		fi = StubFachinfo.new
		doc = StubFachinfoDoc.new
		chapter = ODDB::Text::Chapter.new
		chapter.heading = "heading"
		section = chapter.next_section
		section.subheading = "subheading"
		para = section.next_paragraph
		para << <<-EOS
Hunger. Stufe für Stufe schob sie sich die Treppe hinauf. Pizza Funghi Salami, Sternchen Salami gleich Blockwurst. Die Pilze hatten sechs Monate in einem Sarg aus Blech, abgeschattet vom Sonnenlicht, eingeschläfert in einer Sosse aus Essig, billigem Öl und verschiedenen Geschmacksverstärkern, geruht. Es war nur ein Augenblick, in dem sie die Welt erblickt hatten, dann verschwanden sie wieder in einem 450° heissen Ofen. Die Pizza ruhte auf ihrer rechten Hand, und in ihrer Linken hielt sie eine jener nichtssagenden Plastiktüten. Wie fast jeden Abend hatte sie noch das weisse Häubchen aus dem Krankenhaus auf dem Kopf. Das Fettgewebe ihrer Schenkel verspürte einen Heisshunger auf das müde Öl, das bei jedem Schritt sanft auf den Salamischeiben schaukelte. 
		EOS
		doc.chapters = [chapter]
		fi.descriptions[:de] = doc
		@app.fachinfos.store(1, fi)
		table = ODDB::OddbDatExport::MCMTable.new(@app)
		mcmlines = table.mcmline(fi)
		expected = <<-EOS
31|#{date}|#{fi.oid}|D|1|4|<BI>heading<E><P><I>subheading<E>Hunger. Stufe f\374r Stufe schob sie sich die Treppe hinauf. Pizza Funghi Salami, Sternchen Salami gleich Blockwurst. Die Pilze hatten sechs Monate in einem Sarg aus Blech, abgeschattet vom 
31|#{date}|#{fi.oid}|D|2|4|Sonnenlicht, eingeschl\344fert in einer Sosse aus Essig, billigem \326l und verschiedenen Geschmacksverst\344rkern, geruht. Es war nur ein Augenblick, in dem sie die Welt erblickt hatten, dann verschwanden sie wieder in einem 
31|#{date}|#{fi.oid}|D|3|4|450\260 heissen Ofen. Die Pizza ruhte auf ihrer rechten Hand, und in ihrer Linken hielt sie eine jener nichtssagenden Plastikt\374ten. Wie fast jeden Abend hatte sie noch das weisse H\344ubchen aus dem Krankenhaus auf dem Kopf. 
31|#{date}|#{fi.oid}|D|4|4|Das Fettgewebe ihrer Schenkel versp\374rte einen Heisshunger auf das m\374de \326l, das bei jedem Schritt sanft auf den Salamischeiben schaukelte.<P>
		EOS
		assert_equal(expected.strip, mcmlines.join("\n"))
	end
	def test_acline
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		acline = ODDB::OddbDatExport::AcLine.new(package)
		expected = "01|#{@date}|1|3|4||007007747|||||||A||||||||#{@iksdate}|||||||||||||||||||||||||||||||||"
		assert_equal(expected, acline.to_s)
	end
	def test_content
		line = ODDB::OddbDatExport::Line.new
		assert_equal(['nodata', nil, 'moredata', nil], line.content(line.structure))
	end
	def test_eanline
		package = StubPackage.new
		registration = StubRegistration.new
		package.registration = registration
		eanline = ODDB::OddbDatExport::EanLine.new(package)
		expected = "06|#{@date}|#{package.oid}|E13|76800070077470|4||"
		assert_equal(expected, eanline.to_s)
	end
	def test_export
		full_setup()
		@plugin.export
		dir = ODDB::OddbDatExport.system_targetdir
		{
			's01x'	=>	744,
			's02x'	=>	440,
			's03x'	=>	376,
			's06x'	=>	352,
			's07x'	=>	0,
			's11x'	=>	284,
			's12x'	=>	316,
			's19x'	=>	240,
			's40x'	=>	134,
			's41x'	=>	576,
			
		}.each_pair{ |name, size|
			file = File.expand_path(name, dir)
			assert(FileTest.exists?(file), "The file #{file} was not properly created")
			assert_equal(size, FileTest.size(file), "Wrong filesize for #{file}")
		}	
	end		
	def test_export2
		full_setup()
		@plugin.export
		assert_equal(15, @plugin.filenames.size)
		#<DocumedGag>
		#assert_equal(1, @plugin.singlefilenames.size)
		@plugin.date = Time.gm(2003,"dec",14,11,11,11)
		@plugin.export
		assert_equal(15, @plugin.filenames.size)
		assert_equal(0, @plugin.singlefilenames.size)
	end		
	def test_compress
		full_setup()
		@plugin.export
		@plugin.compress
		assert_equal(false, @plugin.filenames.include?("s31x"))
		dir = ODDB::OddbDatExport.system_targetdir
		name = File.expand_path("oddbdat.tar.gz", dir)
		assert(FileTest.exists?(name), "The file #{name} was not properly created")
		assert(File.size(name) > 500, "Filesize too small!")
		name = File.expand_path("oddbdat.zip", dir)
		assert(FileTest.exists?(name), "The file #{name} was not properly created")
		assert(File.size(name) > 1500, "Filesize too small!")
		name = File.expand_path("oddbdat.zip", dir)
	end
	def test_system_filepath
		table = ODDB::OddbDatExport::AcTable.new(nil)
		expected = File.expand_path('../data/downloads/s01x',
			File.dirname(__FILE__))
			puts expected
		assert_equal(expected, table.system_filepath)
	end
	def test_system_targetdir
		expected = File.expand_path('../data/downloads',
			File.dirname(__FILE__))
		assert_equal(expected, ODDB::OddbDatExport.system_targetdir)
	end
	def test_unix2pc
		table = ODDB::OddbDatExport::AcTable.new(nil)
		result = nil
		assert_nothing_raised {
			result = table.unix2pc("foo\256bar")
		}
		assert_equal("foobar", result)
	end
	def test_empty_atc
		line = ODDB::OddbDatExport::AtcLine.new(nil)
		assert_equal(true, line.empty?)
	end
	def full_setup
		package = StubPackage.new
		sequence = StubSequence.new
		registration = StubRegistration.new
		company = StubCompany.new
		galform = StubGalenicForm.new
		atcclass = StubAtcClass.new
		substance = StubSubstance.new
		dose = StubDose.new
		fachinfo = StubFachinfo.new
		fachinfo_doc = StubFachinfoDocument.new
		fachinfo.descriptions['de'] = fachinfo_doc
		registration.fachinfo = fachinfo
		package.dose = dose
		sequence.atc_class = atcclass
		package.sequence = sequence
		package.galenic_form = galform
		registration.company = company
		package.registration = registration
		package.substances = [
			substance,
			substance,
		]
		sequence.packages = {
			1 => package,
			2 => package,
		}
		registration.sequences = {
			1 => sequence,
			2 => sequence,
		}
		@app.registrations = {
			1 => registration,
			2 => registration,
		}
		@app.atc_classes = {
			1 => atcclass,
			2 => atcclass,
		}
		@app.galenic_forms = [
			galform,
			galform,
		]
		@app.substances = [
			substance,
			substance,
		]
		@app.companies = {
			1=>company,
			2=>company,
		}	
	end
end
