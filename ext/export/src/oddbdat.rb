#!/usr/bin/env ruby
# OddbDat -- oddb -- 09.12.2004 -- hwyss@ywesee.com

module ODDB
	module OdbaExporter
		class Table
			CRLF = "\r\n"
			def filename
				self::class::FILENAME
			end
		end
		class AcTable <	Table
			FILENAME = 's01x'
			def lines(package)
				[AcLine.new(package)]
			end
		end
		class AccompTable < Table
			FILENAME = 's19x'
			def lines(package)
				[AccompLine.new(package)]
			end
		end
		class AcLimTable < Table
			FILENAME = 's09x'
			def lines(package)
				lines = []
				unless((sl = package.sl_entry).nil?)
					if(lim = sl.limitation_text)
						chap = lim.descriptions.values.first
						chap.paragraphs.each_with_index { |par, idx|
							pack = package.oid
							line = idx 
							lim = (pack.to_s + sprintf('%03i', line).to_s).to_i
							lines << AcLimLine.new(pack, line, lim)
						}
					end
				end
				lines
			end
		end
		class AcmedTable < Table
			FILENAME = 's02x'
			def lines(package)
				[AcmedLine.new(package)]
			end
		end
		class AcnamTable < Table
			FILENAME = 's03x'
			def lines(package)
				[AcnamLine.new(package)]
			end
		end
		class AcOddbTable < Table
			FILENAME = 's99x'
			def lines(package)
				[AcOddbLine.new(package)]
			end
		end
		class AcpricealgTable < Table
			FILENAME = 's07x'
			def lines(package)
				[
					AcpricealgPublicLine.new(package),
					AcpricealgExfactoryLine.new(package),
				]
			end
		end
		class AcscTable < Table
			FILENAME = 's41x'
			def lines(package)
				lines = []
				package.substances.each_with_index { |substance, idx|
					lines.push(AcscLine.new(package, substance, idx))
				}
				lines
			end
		end
		class LimitationTable < Table
			FILENAME = 's16x'
			def lines(package)
				lines = []
				unless((sl = package.sl_entry).nil?)
					if(lim = sl.limitation_text)
						chap = lim.descriptions.values.first
						chap.paragraphs.each_with_index { |par, idx|
							pack = package.oid
							line = idx 
							lim = (pack.to_s + sprintf('%03i', line).to_s).to_i
							lines << LimitationLine.new(lim)
						}
					end
				end
				lines
			end
		end
		class LimTxtTable < Table
			FILENAME = 's10x'
			def lines(package)
				lines = []
				unless((sl = package.sl_entry).nil?)
					if(lim = sl.limitation_text)
						lim.descriptions.each { |lang, value|
							value.paragraphs.each_with_index { |par, idx|
								language = lang[0,1].upcase
								lim = (package.oid.to_s + sprintf('%03i', idx).to_s).to_i
								txt = par.text
								lines << LimTxtLine.new(lim, language, txt)
							}
						}
					end
				end
				lines
			end
		end
		class EanTable < Table
			FILENAME = 's06x'
			def lines(package)
				[EanLine.new(package)]
			end
		end
		class MCMTable < Table
			FILENAME = 's31x'
			def lines(fi)
				lines = []
				fi.descriptions.each { |lang, doc|
					line = 1
					doc.each_chapter { |chap|
						text = format_line(chap)
						while(text.size > 220)
							pos = text.rindex(' ', 220)
							if(pos.nil?)
								pos = text.rindex('<P>', 220)-1
							end
							txt = text.slice!(0..pos)
							lines << MCMLine.new(fi.oid, line, lang, txt)
							line = line.next
						end
						lines << MCMLine.new(fi.oid, line, lang, text)
						line = line.next
					}	
				}
				lines
			end
			def format_line(chapter)
				string = String.new
				unless((head = chapter.heading).empty?)
					string << '<BI>' << head.to_s << '<E><P>'
				end
				chapter.sections.each { |sec|
					unless((subhead = sec.subheading).empty?)
						subhead = subhead.gsub(/\n/, "<P>")
						string << '<I>' << subhead.to_s << '<E>'
					end
					sec.paragraphs.each { |par|
						unless(par.is_a?(ODDB::Text::ImageLink))
							par.formats.each { |format|
								start_tag = ""
								end_tag = ""
								if(format.italic?)
									start_tag = "<I>"
									end_tag = "<E>"
								elsif(format.bold?)
									start_tag = "<B>"
									end_tag = "<E>"
								end
								string << start_tag << par.text[format.range] << end_tag << "<P>"
							}
							if(par.preformatted?)
								string.gsub!(/ /, '_')
								string.gsub!(/\n/, "<P>")
							end
						end
					}
				}
				string.gsub(/\n/, ' ')
			end
		end
		class CodesTable < Table
			FILENAME = 's11x'
			def lines(item)
				case item
				when AtcClass
					atclines(item)
				when GalenicForm
					gallines(item)
				end
			end
			def atclines(atcclass)
				[AtcLine.new(atcclass)]
			end
			def gallines(galform)
				[GalenicFormLine.new(galform)]
			end
		end
		class ScTable < Table
			FILENAME = 's40x'
			def lines(substance)
				[ScLine.new(nil, substance)]
			end
		end
		class CompTable < Table
			FILENAME = 's12x'
			def lines(company)
				[CompLine.new(company)]
			end
		end
		class Readme < Table
			FILENAME = 'README'
			def lines
				<<-EOS
	oddbdat.tar.gz und oddbdat.zip enthalten die täglich aktualisierten Artikelstammdaten der ODDB. Die Daten werden von ywesee in das OddbDat-Format umgewandelt und allen gewünschten Systemlieferanten von Schweizer Spitälern zur Verfügung gestellt.

	Feedback bitte an zdavatz@ywesee.com

	-AC (Tabelle 1) - ODDB-Code
	-ACMED (Tabelle 2) - Weitere Produktinformationen
	-ACNAM (Tabelle 3) - Sprachen
	-ACBARCODE (Tabelle 6) - EAN-Artikelcode
	-ACPRICEALG (Tabelle 7) - Preise
	-ACLIM (Tabelle 9) - Limitationen
	-LIMTXT (Tabelle 10) - Limitationstexte
	-CODES (Tabelle 11) - Codebeschreibungen (ATC-Beschreibung, Galenische Form)
	-COMP (Tabelle 12) - Hersteller
	-LIMITATION (Tabelle 16) - Limitationen der SL
	-ACCOMP (Tabelle 19) - Verbindungstabelle zwischen AC und COMP
	-SC (Tabelle 40) - Substanzen
	-ACSC (Tabelle 41) - Verbindungstabelle zwischen AC und SC
	-ACODDB (Tabelle 99) - Verbindungstabelle zwischen ODDB-ID und Pharmacode

	Folgende Tabelle mit den Fachinformationen steht wegen ihrer Grösse separat als tar.gz- oder zip-Download zur Verfügung.

	-MCM (Tabelle 31)	- Fachinformationen

	Die Daten werden als oddbdat.tar.gz und oddbdat.zip auf unserem Server bereitgestellt - Vorzugsweise benutzen Sie einen der folgenden direkten Links.

	Ganze Packages (ohne Fachinformationen):
	http://www.oddb.org/resources/downloads/oddbdat.tar.gz
	http://www.oddb.org/resources/downloads/oddbdat.zip

	Nur Fachinformationen (sehr grosse Dateien):
	http://www.oddb.org/resources/downloads/s31x.tar.gz
	http://www.oddb.org/resources/downloads/s31x.zip


				EOS
			end
		end
		class Line
			def initialize(*args)
				@date = Date.today.strftime("%Y%m%d%H%M%S")
				@structure = structure
			end
			def content(structure)
				return [] if structure.nil?
				fields = Array.new(self::class::LENGTH)
				structure.each_pair { |place, field|
					# schlüssel in structure entsprechen der OddbDat-Doku
					fields[place-1] = field 
				}
				fields
			end
			def empty?
				@structure.nil?
			end
			def structure
			end
			def to_s
				content(@structure).join('|').gsub("\000", "")
			end	
		end
		class PackageLine < Line
			def initialize(package, *args)
				@package = package
				super
			end
		end
		class SubstanceLine < PackageLine
			def initialize(package, substance, *args)
				@substance = substance
				super
			end
		end
		class AcLine < PackageLine
			LENGTH = 55
			def structure
				{
					1		=>	'01',
					2		=>	@date,
					3		=>	'1',
					4		=>	@package.oid,
					5		=>	'4',
					7		=>	ikskey,
					14	=>	@package.ikscat,
					# @package hat immer eine registration, da
					# Registration::create_package die Verknüpfung erstellt
					20	=>	generic_code(@package.registration),
					22	=>	iks_date(@package.registration),
					29	=>	(@package.sl_entry) ? '3' : nil,
					39	=>	inscode,
					40	=>	limitation,
					41	=>	limitation_points,
				}
			end
			def generic_code(registration)
				if registration.generic_type == :generic
					'Y'
				end
			end	
			def iks_date(registration)
				if(date = registration.registration_date)
					date.strftime("%Y%m%d")
				end
			end
			def ikskey
				ikskey = @package.iksnr.dup
				ikskey << @package.ikscd
				ikskey
			end
			def inscode
				if @package.sl_entry
					'1'
				end
			end
			def limitation
				if((sl = @package.sl_entry) && (sl.limitation))
					'Y'
				end
			end
			def limitation_points
				if(sl = @package.sl_entry)
					sl.limitation_points
				end
			end
		end
		class AccompLine < PackageLine
			LENGTH = 8
			def structure
				if(comp = @package.registration.company)
					{
						1		=>	'19',
						2		=>	@date,
						3		=>	@package.oid,
						4		=>	comp.oid,
						5		=>	'H',
						6		=>	'4',
					}
				end
			end
		end
		class AcLimLine < PackageLine
			LENGTH = 8
			def initialize(package_oid, line_oid, lim_oid)
				@package_oid = package_oid
				@line_oid = line_oid
				@lim_oid = lim_oid
				super
			end
			def structure
				{
					1		=>	'09',
					2		=>	@date,
					3		=>	@package_oid,
					4		=>	@lim_oid,
					5		=>	@line_oid,
					6		=>	'4',
				}
			end
		end
		class AcnamLine < PackageLine
			LENGTH = 26
			def structure
				seq = @package.sequence
				galform = if(gf = seq.galenic_form)
					gf.to_s
				end
				conc, unit = if(dose = seq.dose)
					[dose.qty, dose.unit]
				end
				measure, munit = if(ms = @package.measure)
					[ms.qty, ms.unit]
				end	
				qty, qty_unit = if(munit && !munit.empty?)
					[measure, munit]
				else
					[@package.count, @package.comform]
				end	
				{
					1		=>	'03',
					2		=>	@date,
					3		=>	'1',
					4		=>	@package.oid,
					5		=>	'D',
					6		=>	'4',
					7		=>	seq.name,
					8		=>	seq.name_base,
					9		=>	seq.name_descr,
					11	=>	galform,
					12	=>	conc,
					13	=>	unit,
					16	=>	@package.multi,
					17	=>	@package.comform,
					18	=>	qty,
					19	=>	qty_unit,
				}
			end
		end
		class AcmedLine	< PackageLine
			LENGTH = 27
			def structure
				atccd = if(atc = @package.sequence.atc_class)
					atc.code
				end
				gfid = if(galform = @package.galenic_form)
					galform.oid
				end
				fioid = if(fachinfo = @package.fachinfo)
					fachinfo.oid
				end	
				atc = @package.sequence.atc_class
				{
					1		=>	'02',
					2		=>	@date,
					3		=>	'1',
					4		=>	@package.oid,
					5		=>	'4',
					7		=>	fioid,
					10	=>	atccd,
					12	=>	gfid,
				}
			end
		end
		class AcOddbLine < PackageLine
			LENGTH = 2 
			def structure
				{
					1		=>	@package.oid,
					2		=>	@package.pharmacode,
				}
			end
		end
		class AcpricealgPublicLine	< PackageLine
			LENGTH = 9
			def structure
				if(ppub = @package.price_public)
					{
						1		=>	'07',
						2		=>	@date,
						3		=>	@package.oid,
						4		=>	price_public_type,
						5		=>	'4',
						6		=>	sprintf('%2.2f', ppub / 100.0),
					}
				end
			end
			def price_public_type
				if @package.sl_entry
					'PSL2'
				else
					'PPUB'
				end
			end
		end
		class AcpricealgExfactoryLine	< PackageLine
			LENGTH = 9
			def structure
				if(pexf = @package.price_exfactory)
					{
						1		=>	'07',
						2		=>	@date,
						3		=>	@package.oid,
						4		=>	'PSL1',
						5		=>	'4',
						6		=>	sprintf('%2.2f', pexf / 100.0),
					}
				end
			end
		end
		class AcscLine < SubstanceLine
			LENGTH = 10
			def initialize(package, substance, count)
				@count = count
				super
			end	
			def structure
				return if @substance.nil?
				qty, unit = if(dose = @package.dose)
					[dose.qty, dose.unit]
				end
				{
					1		=>	'41',
					2		=>	@date,
					3		=>	@package.oid,
					4		=>	@count,
					5		=>	'4',
					6		=>	@substance.oid,
					7		=>	qty,
					8		=>	unit,
					9		=>	'W',
				}
			end
		end
		class AtcLine	< Line
			LENGTH = 9
			def initialize(atcclass)
				@atcclass = atcclass
				super
			end
			def structure
				return if @atcclass.nil?
				{
					1		=>	'11',
					2		=>	@date,
					3		=>	'8',
					4		=>	@atcclass.code,
					5		=>	'D',
					6		=>	'4',
					7		=>	@atcclass.description,
				}
			end
		end
		class CompLine < Line
			LENGTH = 19
			def initialize(company)
				@company = company
				super
			end
			def structure
				{
					1		=>	'12',
					2		=>	@date,
					3		=>	@company.oid,
					4		=>	'4',
					5		=>	@company.ean13,
					7		=>	@company.name,
					8		=>	@company.address,
					9		=>	'CH',
					10	=>	@company.plz,
					11	=>	@company.location,
					13	=>	@company.phone,
					15	=>	@company.fax,
					16	=>	@company.address_email,
					17	=>	@company.url,
				}
			end
		end
		class EanLine < PackageLine
			LENGTH = 8
			def structure
				{
					1		=>	'06',
					2		=>	@date,
					3		=>	@package.oid,
					4		=>	'E13',
					5		=>	barcode,
					6		=>	'4',
				}
			end
			def barcode
				@package.barcode
			end
		end
		class GalenicFormLine	< Line
			LENGTH = 9
			def initialize(galenic_form)
				@galenic_form = galenic_form
				super
			end
			def structure
				{
					1		=>	'11',
					2		=>	@date,
					3		=>	'5',
					4		=>	@galenic_form.oid,
					5		=>	'D',
					6		=>	'4',
					7		=>	@galenic_form.to_s,
				}
			end
		end
		class ScLine < SubstanceLine
			LENGTH = 8
			def structure
				{
					1		=>	'40',
					2		=>	@date,
					3		=>	@substance.oid,
					4		=>	'L',
					5		=>	'4',
					6		=>	@substance,
				}
			end
		end
		class LimitationLine < PackageLine
			LENGTH = 10
			def initialize(lim_oid)
				@lim_oid = lim_oid
				super
			end
			def structure
				{
					1		=>	'16',
					2		=>	@date,
					3		=>	@lim_oid,
					5		=>	'4',
					6		=>	'COM',
				}
			end
		end
		class LimTxtLine < Line
			LENGTH = 8
			def initialize(lim_oid, language, txt)
				@lim_oid = lim_oid
				@language = language
				@txt = txt
				super
			end
			def structure
				{	
					1	=>	'10',
					2	=>	@date,
					3	=>	@lim_oid,
					4	=>	@language,
					5	=>	'4',
					6	=>	@txt,
				}
			end
		end
		class MCMLine < Line
			LENGTH = 7
			def initialize(fi_oid, line_nr, language, text)
				@fi_oid = fi_oid
				@line_nr = line_nr
				@language = language
				@text = text
				super
			end
			def structure
				{
					1	=>	'31',
					2	=>	@date,
					3	=>	@fi_oid,
					4	=>	@language.to_s[0,1].upcase,
					5	=>	@line_nr,
					6	=>	'4',
					7	=>	@text,
				}
			end
		end
	end
end
