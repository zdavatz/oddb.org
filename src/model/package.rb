#!/usr/bin/env ruby
# Package -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'rockit/rockit'
require 'util/persistence'
require 'model/dose'
require 'model/slentry'
require 'model/ean13'

module ODDB
	class PackageCommon
		include Persistence
		class << self
			def price_internal(value)
				(value.to_f*100).round
			end
		end
		attr_reader :ikscd, :size, :count, :multi, :measure, :comform
		attr_reader :addition, :scale, :sl_entry
		attr_accessor :descr, :sequence, :ikscat, :generic_group
		attr_accessor :price_exfactory, :price_public, :pretty_dose
		attr_accessor :pharmacode
		alias :pointer_descr :ikscd
		unit_pattern = '(([kmucMG]?([glLJm]|mol|Bq))(\/([mu]?[glL]))?)|((Mio\s)?U\.?I\.?)|(%( [mV]\/[mV])?)|(I\.E\.)|(Fl\.)'
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
		def initialize(ikscd)
			super()
			@ikscd = sprintf('%03d', ikscd.to_i)
			@comparable_size = Dose.new(1,'')
		end
		def active?
			@sequence.active?
		end
		def active_agents
			@sequence.active_agents
		end
		def barcode
			if(key = ikskey)
				Ean13.new_unchecked('7680'+key)
			end
		end
		def atc_class
			@sequence.atc_class
		end
		def checkout
			checkout_helper([@generic_group], :remove_package)
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
		def comparable_size
			ODDB::Dose.from_quanty(@comparable_size)
		end
		def comparables
			range = ([
				@comparable_size / 2, 
				Dose.new(@comparable_size.value - 20, 
					@comparable_size.unit)
			].max)..([
				@comparable_size * 2, 
				Dose.new(@comparable_size.value + 20, 
					@comparable_size.unit)
			].min)
			@sequence.comparables.collect { |seq|
				seq.packages.values.select { |pack|
					comparable?(range, pack)
				}
			}.flatten + @sequence.packages.values.select { |pack|
				comparable?(range, pack)
			}
		end
		def comparable?(range, pack)
			begin
				pack != self \
					&& range.include?(pack.comparable_size)
			rescue RuntimeError => e
				puts "Error: #{e} while comparing #{@pointer} to #{pack.pointer}"
				false
			end
		end
		def create_sl_entry
			@sl_entry = SlEntry.new
		end
		def delete_sl_entry
			@sl_entry = nil
		end
		def dose
			@sequence.dose
		end
		def fachinfo
			registration.fachinfo
		end
		def galenic_form
			@sequence.galenic_form
		end
		def generic_type
			registration.generic_type
		end
		def ikskey
			if(nr = iksnr)
				nr + @ikscd
			end
		end
		def iksnr
			@sequence.iksnr if(@sequence.respond_to? :iksnr)
		end
		def size=(size)
			@size = size
			unless size.to_s.strip.empty?
				@addition, @multi, @count, @measure, @scale, @comform = parse_size(size) 
				@comparable_size = @multi * ((@count + @addition) * @measure) / @scale
			end
		end
		def limitation_text
			@sl_entry.limitation_text
		end
		def most_precise_dose
			@pretty_dose || dose
		end
		def name_base
			@sequence.name_base
		end
		def patinfo
			@sequence.patinfo
		end
		def registration
			@sequence.registration
		end
		def registration_date
			@sequence.registration.registration_date
		end
		def substances
			active_agents.collect { |active| active.substance }.compact
		end
		private
		def adjust_types(values, app=nil)
			values = values.dup
			values.each { |key, value|
				case key
				when :generic_group
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
		def parse_size(size)
			multi, addition, count, measure, scale, dose, comform = nil
			begin
				ast = @@parser.parse(size)
				multi, addition, count, measure, scale, dose, comform = ast.flatten
			rescue ParseException => e
				puts '*'*60 
				puts size
				puts e.message
				puts e.backtrace
			end
			if(!dose.nil? && @sequence.dose.nil?)
				@sequence.dose = Dose.new(*(dose.childrens[1,2].collect { |c| c.value }))
			end
			[
				(addition ? addition.first.value.to_i : 0),
				dose_from_multi(multi),
				(count ? count[1].value.to_i : 1),
				dose_from_measure(measure),
				dose_from_scale(scale),
				(comform.value if comform),
			]
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
	class Package < PackageCommon
		ODBA_PREFETCH = true
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
	end
end
