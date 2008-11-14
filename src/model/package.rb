#!/usr/bin/env ruby
# Package -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/money'
require 'model/slentry'
require 'model/ean13'
require 'model/feedback_observer'
require 'model/part'

module ODDB
	class PackageCommon
		include Persistence
    @@ddd_galforms = /tabletten/i
		class << self
			def price_internal(price, type=nil)
        unless(price.is_a?(Util::Money))
          price = Util::Money.new(price, type, 'CH')
        end
        price
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
			def sequence_data(*names)
				names.each { |name|
					define_method(name) { 
						@sequence && @sequence.send(name)
					}
				}
			end
		end
		attr_reader :ikscd,  :sl_entry, :narcotics, :parts
		attr_accessor :sequence, :ikscat, :generic_group, :sl_generic_type,
			:price_exfactory, :price_public, :pretty_dose, :pharmacode, :market_date,
			:medwin_ikscd, :out_of_trade, :refdata_override, :deductible, :lppv,
      :disable, :swissmedic_source, :descr, :preview_with_market_date
			:deductible_m # for just-medical
		alias :pointer_descr :ikscd
		registration_data :comarketing_with, :complementary_type, :expiration_date,
			:expired?, :export_flag, :generic_type, :inactive_date, :pdf_fachinfos,
			:registration_date, :revision_date, :patent, :patent_protected?, :vaccine,
			:parallel_import, :minifi, :source, :index_therapeuticus
    sequence_data :atc_class, :basename, :company, :ddds, :dose, 
      :fachinfo, :galenic_forms, :galenic_group, :has_patinfo?, :longevity,
      :iksnr, :indication, :name, :name_base, :patinfo, :pdf_patinfo,
      :registration, :route_of_administration
		def initialize(ikscd)
			super()
			@ikscd = sprintf('%03d', ikscd.to_i)
			@narcotics = []
      @parts = []
		end
		def active?
			!@disable && (@preview_with_market_date || @market_date.nil? \
                    || @market_date <= @@today)
		end
    def active_agents
      @parts.inject([]) { |acts, part| acts.concat part.active_agents }
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
		def checkout
			checkout_helper([@generic_group], :remove_package)
			@narcotics.each { |narc| 
				narc.remove_package(self)
			} if @narcotics
      @parts.dup.each { |part|
        part.checkout
        part.odba_delete
      }
      @parts.odba_delete
			if(@sl_entry.respond_to?(:checkout))
				@sl_entry.checkout 
				@sl_entry.odba_delete
			end
		end
    def commercial_forms
      @parts.collect { |part| part.commercial_form }
    end
		def company_name
			company.name
		end
    def compositions
      @parts.inject([]) { |comps, part| comps.push part.composition }.compact
    end
    def comparable?(bottom, top, pack)
      begin
        pack != self \
          && (other = pack.comparable_size) \
          && bottom < other \
          && top > other
      rescue RuntimeError => e
        false
      end
    end
    def comparables
      cs = comparable_size
      bottom = cs * 0.75
      top = cs * 1.25
      @sequence.comparables.collect { |seq|
        seq.public_packages.select { |pack|
          comparable?(bottom, top, pack)
        }
      }.flatten + @sequence.public_packages.select { |pack|
        comparable?(bottom, top, pack)
      }
    end
    def comparable_size
      ODDB::Dose.new @parts.collect { |part| 
        part.comparable_size }.inject { |a, b| a + b }
    rescue RuntimeError
      @parts.inject(Dose.new(0)) { |comp, part|
        ODDB::Dose.new(comp + part.comparable_size.qty)
      } rescue nil
    end
    def create_part
      part = Part.new
      part.package = self
      @parts.push part
      part
    end
		def create_sl_entry
			@sl_entry = SlEntry.new
		end
		def ddd_price
			if((atc = atc_class) && atc.has_ddd? && (ddd = atc.ddds['O']) \
				&& (grp = galenic_group) && grp.match(@@ddd_galforms) \
				&& (price = price_public) && (ddose = ddd.dose) && (mdose = dose))
        factor = (longevity || 1).to_f
        if(mdose > (ddose * factor))
          (price / comparable_size.to_f) / factor
        else
          (price / comparable_size.to_f) \
            * (ddose.to_f * factor / mdose.want(ddose.unit).to_f) / factor
        end
			end
		rescue RuntimeError
		end
    def delete_part(oid)
      @parts.delete_if { |comp| comp.oid == oid }
    end
		def delete_sl_entry
			@sl_entry = nil
			self.odba_isolated_store
			nil
		end
    def fix_pointers
      @pointer = @sequence.pointer + [:package, @ikscd]
      if(sl = @sl_entry)
        sl.pointer = @pointer + [:sl_entry]
        sl.odba_store
      end
      @parts.each { |part|
        part.fix_pointers
      }
      odba_store
    end
		def good_result?(query)
			query = query.to_s.downcase
			basename.to_s.downcase[0,query.length] == query
		end
    def has_generic?
      @generic_type == :original && !comparables.empty?
    end
    def ikscd=(ikscd)
      if(/^[0-9]{3}$/.match(ikscd))
        pacs = @sequence.packages
        pacs.delete(@ikscd)
        pacs.store(ikscd, self)
        pacs.odba_store
        @out_of_trade = false
        @ikscd = ikscd
        fix_pointers
      end
    end
		def localized_name(language)
			@sequence.localized_name(language)
		end
		def ikskey
			if(nr = iksnr)
				nr + @ikscd
			end
		end
		def limitation
			@sl_entry.limitation unless @sl_entry.nil?
		end
		def limitation_text
			@sl_entry.limitation_text unless @sl_entry.nil?
		end
    def _migrate_to_parts(app)
      unless @parts
        @parts = []
        ptr = @pointer + :part
        part = create_part
        part.pointer = ptr
        part.init app
        part.size = @size
        part.commercial_form = @commercial_form
        part.composition = @sequence.compositions.first
        %w{@size @addition @multi @count @measure @scale @comform
           @commercial_form}.each { |name|
          if instance_variable_get(name)
            remove_instance_variable name
          end
        }
        part.fix_pointers
        @parts.odba_store
        odba_store
      end
    end
		def most_precise_dose
			@pretty_dose || dose
		end
		def narcotic?
			@narcotics.any? { |narc| narc.category == 'a' }
		end
    def part(oid)
      @parts.find { |part| part.oid == oid }
    end
    def preview?
      @preview_with_market_date && @market_date && @market_date > @@today
    end
		def public?
      active? && (@refdata_override || !@out_of_trade \
                  || registration.active?)
		end
		def registration_data(key)
			if(reg = registration)
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
    def size
      @parts.collect { |part| part.size }.compact.join(' + ')
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
				when :generic_group
					values[key] = value.resolve(app)
				when :price_public, :price_exfactory
					values[key] = Package.price_internal(value, key)
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
    ODBA_SERIALIZABLE = [ '@prices', '@ancestors', '@swissmedic_source' ]
    include ODBA::Persistable
    odba_index :pharmacode
		attr_accessor :medwin_ikscd, :ancestors
		include FeedbackObserver
		def initialize(ikscd)
			super
			@feedbacks = []
		end
		def checkout
			super
			if(@feedbacks)
				@feedbacks.dup.each { |fb| fb.item = nil; fb.odba_store }
				@feedbacks.odba_delete
			end
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
    def price(type, ord_or_time=0)
      candidates = (prices[type] ||= [])
      if(ord_or_time.is_a?(Time))
        candidates.find { |price| price.valid_from < Time }
      else
        candidates[ord_or_time.to_i]
      end
    end
    def price_exfactory(ord_or_time=0)
      price(:exfactory, ord_or_time)
    end
    def price_exfactory=(price)
      return price_exfactory if(price_exfactory == price) 
      (prices[:exfactory] ||= []).unshift(price)
      price
    end
    def price_public(ord_or_time=0)
      price(:public, ord_or_time)
    end
    def price_public=(price)
      return price_public if(price_public == price) 
      (prices[:public] ||= []).unshift(price)
      price
    end
    def prices
      @prices ||= {}
    end
    def update_prices # migration, to be removed
      needs_save = false
      %w{public private}.each { |type|
        name = "@price_#{type}"
        if(price = instance_variable_get(name))
          needs_save = true
          money = Package.price_internal(price.to_f / 100.0, type)
          money.origin = data_origin(name[1..-1])
          money.valid_from = @revision
          self.send("price_#{type}=", money)
          remove_instance_variable(name)
        end
      }
      needs_save && odba_store
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
				:price_exfactory	=>	@price_exfactory,
				:price_public			=>	@price_public, 
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
