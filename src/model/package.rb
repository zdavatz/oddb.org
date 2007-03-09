#!/usr/bin/env ruby
# Package -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'rockit/rockit'
require 'util/persistence'
require 'model/dose'
require 'model/slentry'
require 'model/ean13'
require 'model/feedback_observer'

module ODDB
	module SizeParser
		unit_pattern = '(([kmucMG]?([glLJm]|mol|Bq)\b)(\/([mu]?[glL])\b)?)|((Mio\s)?U\.?I\.?)|(%( [mV]\/[mV])?)|(I\.E\.)|(Fl\.)'
		numeric_pattern = '\d+(\'\d+)*([.,]\d+)?'
		iso_pattern = "[a-zA-Z#{0xC0.chr}-#{0xFF.chr}()\-]+"
		@@parser = Parse.generate_parser <<-EOG
Grammar OddbSize
	Tokens
		DESCRIPTION	= /(?!#{unit_pattern}\s)#{iso_pattern}(\s+#{iso_pattern})*/
		NUMERIC			= /#{numeric_pattern}/
		SPACE				= /\s+/		[:Skip]
		UNIT				= /#{unit_pattern}/
	Productions
		Size			->	Multiple* Addition? Count? Measure? Scale? Dose? DESCRIPTION?
		Count			->	'je'? NUMERIC
		Multiple	->	NUMERIC UNIT? /[xXà]/
		Measure		->	NUMERIC UNIT UNIT?
		Addition	->	NUMERIC UNIT? '+'
		Scale			->	'/' NUMERIC? UNIT
		Dose			->	'(' NUMERIC UNIT ')'
		EOG
		def comparable_size
			ODDB::Dose.from_quanty(@comparable_size)
		end
		def comparables
=begin
			bottom = [
				@comparable_size / 2, 
				Dose.new(@comparable_size.value - 20, 
					@comparable_size.unit)
			].max
			top = [
				@comparable_size * 2, 
				Dose.new(@comparable_size.value + 20, 
					@comparable_size.unit)
			].min
=end
			bottom = @comparable_size * 0.75
			top = @comparable_size * 1.25
			@sequence.comparables.collect { |seq|
				seq.public_packages.select { |pack|
					comparable?(bottom, top, pack)
				}
			}.flatten + @sequence.public_packages.select { |pack|
				comparable?(bottom, top, pack)
			}
		end
		def comparable?(bottom, top, pack)
			begin
				pack != self \
					&& bottom < pack.comparable_size \
					&& top > pack.comparable_size
			rescue RuntimeError => e
				puts "Error: #{e} while comparing #{@pointer} to #{pack.pointer}"
				false
			end
		end
		def set_comparable_size!
			descr_multi = [@descr.to_f, 1].max
			multi = @multi || 1
			count = @count || 1
			addition = @addition || 0
			measure = @measure || Dose.new(1, nil)
			scale = @scale || Dose.new(1, nil)
			@comparable_size = descr_multi * multi * ((count + addition) \
				* measure) / scale
		end
		def size=(size)
			@size = size
			unless size.to_s.strip.empty?
				@addition, @multi, @count, @measure, @scale, @comform = parse_size(size) 
				set_comparable_size!
			end
		end
		def parse_size(size)
			multi, addition, count, measure, scale, dose, comform = nil
			begin
				ast = @@parser.parse(size)
				multi, addition, count, measure, scale, dose, comform = ast.flatten
				count = (count ? count[1].value.to_i : 1)
			rescue ParseException, AmbigousParseException => e
				puts '*'*60 
				puts size
				puts e.message
				puts e.backtrace[0,6]
				count = size.to_i
			end
			if(!dose.nil? && @sequence.dose.nil?)
				@sequence.dose = Dose.new(*(dose.childrens[1,2].collect { |c| c.value }))
			end
			[
				(addition ? addition.first.value.to_i : 0),
				dose_from_multi(multi),
				count,
				dose_from_measure(measure),
				dose_from_scale(scale),
				(comform.value if comform),
			]
		end
		def descr=(descr)
			@descr = descr
			set_comparable_size!
			@descr
		end
		def dose_from_measure(measure)
			values = measure ? measure.childrens[0,2].collect{ |c| c.value } : [1,nil]
			Dose.new(*values)
		end
		def dose_from_scale(scale)
			values = scale ? scale.childrens[1,2].collect{ |c| c.value } : [1,nil]
			Dose.new(*values)
		end
		def dose_from_multi(multi)
			unless(multi.nil?)
				multi.childrens.inject(Dose.new(1,nil)) { |inj, node| 
					unit = (node[1].value if node[1])
					dose = Dose.new(node[0].value, unit)
					inj *= dose
				}
			else
				Dose.new(1,nil)
			end
		end
	end
	class PackageCommon
		include Persistence
		include SizeParser
		class << self
			def price_internal(value)
				(value.to_f*100).round
			end
			def registration_data(*names)
				names.each { |name|
					define_method(name) { 
						if(@sequence && (reg = @sequence.registration))
							reg.send(name)
						end
					}
				}
			end
		end
		attr_reader :ikscd, :size, :count, :multi, :measure, :comform, :descr,
			:addition, :scale, :sl_entry, :narcotics
		attr_accessor :sequence, :ikscat, :generic_group, :sl_generic_type,
			:price_exfactory, :price_public, :pretty_dose, :pharmacode, :market_date,
			:medwin_ikscd, :out_of_trade, :refdata_override, :deductible, :lppv,
      :commercial_form, :disable,
			:deductible_m # for just-medical
		alias :pointer_descr :ikscd
		registration_data :comarketing_with, :complementary_type, :expiration_date,
			:expired?, :export_flag, :generic_type, :inactive_date, :pdf_fachinfos,
			:registration_date, :revision_date, :patent, :patent_protected?, :vaccine,
			:parallel_import
		def initialize(ikscd)
			super()
			@ikscd = sprintf('%03d', ikscd.to_i)
			@comparable_size = Dose.new(1,'')
			@narcotics = []
		end
		def active?
			!@disable && (@market_date.nil? || @market_date <= @@today)
		end
		def active_agents
			@sequence.active_agents
		end
		def add_narcotic(narc)
			unless(narc.nil? || @narcotics.include?(narc))
				@narcotics.push(narc)
				@narcotics.odba_isolated_store
				narc.add_package(self)
			end
			narc
		end
		def barcode
			if(key = ikskey)
				Ean13.new_unchecked('7680'+key).to_s
			end
		end
		def atc_class
			@sequence.atc_class
		end
		def basename
			@sequence.basename
		end
		def checkout
			checkout_helper([@generic_group], :remove_package)
			@narcotics.each { |narc| 
				narc.remove_package(self)
			} if @narcotics
			if(@sl_entry.respond_to?(:checkout))
				@sl_entry.checkout 
				@sl_entry.odba_delete
			end
		end
		def company
			@sequence.company
		end
		def company_name
			company.name
		end
		def create_sl_entry
			@sl_entry = SlEntry.new
		end
		def ddd_price
			if((atc = atc_class) && atc.has_ddd? && (ddd = atc.ddds['O']) \
				&& (grp = galenic_form.galenic_group) && grp.match(/tabletten/i) \
				&& (price = price_public) && (ddose = ddd.dose) && (mdose = dose))
				(ddose.to_f / mdose.want(ddose.unit).to_f) * (price.to_f / comparable_size.to_f)
			end
		rescue RuntimeError
		end
		def delete_sl_entry
			@sl_entry = nil
			self.odba_isolated_store
			nil
		end
		def dose
			@sequence.dose
		end
		def fachinfo
			@sequence.fachinfo
		end
		def good_result?(query)
			query = query.to_s.downcase
			basename.to_s.downcase[0,query.length] == query
		end
		def localized_name(language)
			@sequence.localized_name(language)
		end
		def galenic_form
			@sequence.galenic_form
		end
		def has_patinfo?
			@sequence.has_patinfo?
		end
		def ikskey
			if(nr = iksnr)
				nr + @ikscd
			end
		end
		def iksnr
			@sequence.iksnr if(@sequence.respond_to? :iksnr)
		end
		def indication
			@sequence.indication
		end
		def limitation
			@sl_entry.limitation unless @sl_entry.nil?
		end
		def limitation_text
			@sl_entry.limitation_text unless @sl_entry.nil?
		end
		def most_precise_dose
			@pretty_dose || dose
		end
		def name
			@sequence.name
		end
		def name_base
			@sequence.name_base
		end
		def narcotic?
			@narcotics.any? { |narc| narc.category == 'a' }
		end
		def patinfo
			@sequence.patinfo
		end
		def pdf_patinfo
			@sequence.pdf_patinfo
		end
		def public?
      active? && (@refdata_override || !@out_of_trade \
                  || registration.active?(@@today))
		end
		def registration
			@sequence.registration
		end
		def registration_data(key)
			if(@sequence && (reg = @sequence.registration))
				reg.send(key)
			end
		end
		def remove_narcotic(narc)
			if(res = @narcotics.delete(narc))
				@narcotics.odba_isolated_store
				narc.remove_package(self)
			end
			res
		end
		def substances
			active_agents.collect { |active| active.substance }.compact
		end
		def <=>(other)
			[self.basename, self.dose.to_f, self.comparable_size.to_f] <=> \
				[other.basename, other.dose.to_f, other.comparable_size.to_f]
		end
		private
		def adjust_types(values, app=nil)
			values = values.dup
			values.each { |key, value|
				case key
				when :generic_group, :commercial_form
					values[key] = value.resolve(app)
				when :price_public, :price_exfactory
					values[key] = Package.price_internal(value) 
				when :pretty_dose
					values[key] = if(value.is_a? Dose)
						value
					elsif(value.is_a?(Array))
						Dose.new(*value)
					end
				end unless(value.nil?)
			}
			values
		end
	end
	class Package < PackageCommon
		attr_accessor :medwin_ikscd
		include FeedbackObserver
		def initialize(ikscd)
			super
			@feedbacks = {}
		end
		def checkout
			super
			if(@feedbacks)
				@feedbacks.values.each { |fb| fb.odba_delete }
				@feedbacks.odba_delete
			end
		end
		def commercial_form=(commercial_form)
			unless(@commercial_form.nil?)
				@commercial_form.remove_package(self)
			end
			unless(commercial_form.nil?)
				commercial_form.add_package(self)
			end
			@commercial_form = commercial_form
		end
		def generic_group=(generic_group)
			unless(@generic_group.nil?)
				@generic_group.remove_package(self)
			end
			unless(generic_group.nil?)
				generic_group.add_package(self)
			end
			@generic_group = generic_group
		end
	end
	class IncompletePackage < PackageCommon
		def acceptable?
			@size && @ikscat
		end
		def accepted!(app, sequence_pointer)
			ptr = sequence_pointer + [:package, @ikscd]
			hash = {
				:size							=>	@size, 
				:ikscat						=>	@ikscat, 		
				:generic_group		=>	(@generic_group.pointer if @generic_group),
				:price_exfactory	=>	(@price_exfactory/100.0 if @price_exfactory),
				:price_public			=>	(@price_public/100.0 if @price_public), 
			}.delete_if { |key, val| val.nil? }
			app.update(ptr.creator, hash) 
		end
		def fill_blanks(sequence)
			[	:descr, :dose, :ikscat, :price_exfactory, :generic_group, 
				:size, :price_public ].select { |key|
				if(self.send(key).to_s.empty?)
					self.send("#{key}=", sequence.send(key))
				end
			}
		end
	end
end
