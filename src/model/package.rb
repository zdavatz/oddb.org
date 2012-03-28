#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Package -- oddb.org -- 02.03.2012 -- yasaka@ywesee.com
# ODDB::Package -- oddb.org -- 01.03.2012 -- mhatakeyama@ywesee.com
# ODDB::Package -- oddb.org -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/money'
require 'util/today'
require 'model/slentry'
require 'model/ean13'
require 'model/feedback_observer'
require 'model/part'

module ODDB
	class PackageCommon
		include Persistence
    @@ddd_galforms = /tabletten?/iu
    @@ddd_grmforms = /(?!mg\/ml)[mg|g|ml]/iu
    @@flickr_forms = /^http(?:s*):\/\/(?:.*)\.flickr\.com\/photos\/(?:.[^\/]*)\/([0-9]*)(?:\/*)/
		class << self
      include AccessorCheckMethod
			def price_internal(price, type=nil)
        unless(price.is_a?(Util::Money))
          price = Util::Money.new(price, type, 'CH')
        end
        price
			end
			def registration_data(*names)
				names.each { |name|
					define_method(name) { 
						if(@sequence && @sequence.respond_to?(:registration) && (reg = @sequence.registration))
							reg.send(name)
						end
					}
				}
			end
			def sequence_data(*names)
				names.each { |name|
					define_method(name) { 
						@sequence && @sequence.respond_to?(name) && @sequence.send(name)
					}
				}
			end
		end
		attr_reader :ikscd, :parts, :pharmacode
		attr_accessor :sequence, :ikscat, :generic_group, :sl_generic_type,
			:price_exfactory, :price_public, :pretty_dose, :market_date,
			:medwin_ikscd, :out_of_trade, :refdata_override, :deductible, :lppv,
      :disable, :swissmedic_source, :descr, :preview_with_market_date,
      :generic_group_factor, :photo_link, :disable_ddd_price, :ddd_dose,
			:sl_entry, :deductible_m, # for just-medical
      :bm_flag, :mail_order_prices
    check_accessor_list = {
      :sequence => "ODDB::Sequence",
      :ikscat => "String",
      :generic_group => "ODDB::GenericGroup",
      :sl_generic_type => "Symbol",
      :price_exfactory => "ODDB::Util::Money",
      :price_public => "ODDB::Util::Money",
      :pretty_dose => "ODDB::Dose",
      :market_date => "Date",
      :medwin_ikscd => "String",
      :out_of_trade => ["TrueClass","NilClass","FalseClass"],
      :refdata_override => ["TrueClass","NilClass","FalseClass"],
      :deductible => ["Symbol","String"],
      :lppv => ["TrueClass","NilClass","FalseClass"],
      :disable => ["TrueClass","NilClass","FalseClass"],
      :swissmedic_source => "Hash",
      :descr => "String",
      :preview_with_market_date => ["TrueClass","NilClass","FalseClass"],
      :generic_group_factor => ["NilClass,Float","Fixnum"],
      :photo_link => ["NilClass","String"],
      :disable_ddd_price => ["TrueClass","NilClass","FalseClass"],
      :ddd_dose => "ODDB::Dose",
      :sl_entry => "ODDB::SlEntry",
      :deductible_m => "String",
      :bm_flag => ["TrueClass","NilClass","FalseClass"],
      :mail_order_prices => "Array",
    }
    define_check_class_methods check_accessor_list
		alias :pointer_descr :ikscd
		registration_data :comarketing_with, :complementary_type, :expiration_date,
      :expired?, :export_flag, :fachinfo_active?, :generic_type,
      :inactive_date, :pdf_fachinfos, :registration_date, :revision_date,
      :patent, :patent_protected?, :vaccine, :parallel_import, :minifi,
      :source, :index_therapeuticus, :ith_swissmedic, :has_fachinfo?, :production_science, :renewal_flag,
      :renewal_flag_swissmedic
    sequence_data :atc_class, :basename, :company, :composition_text, :ddds,
      :fachinfo, :galenic_forms, :galenic_group, :has_patinfo?, :longevity,
      :iksnr, :indication, :name, :name_base, :patinfo, :pdf_patinfo,
      :registration, :route_of_administration, :sequence_date, :seqnr
    MailOrderPrice = Struct.new(:price, :url, :logo)
    class MailOrderPrice
      def <=>(other)
        self.price.to_f <=> other.price.to_f
      end
    end
		def initialize(ikscd)
			super()
			@ikscd = sprintf('%03d', ikscd.to_i)
      @parts = []
      @mail_order_prices = [] 
		end
    def add_mail_order_price(price, url, logo)
      @mail_order_prices ||= []
      @mail_order_prices << MailOrderPrice.new(price, url, logo)
      @mail_order_prices.odba_store
      odba_store
    end
    def update_mail_order_price(index, price, url, logo)
      if @mail_order_prices and  @mail_order_prices[index]
        @mail_order_prices[index] = MailOrderPrice.new(price, url, logo)
        @mail_order_prices.odba_store
      end
      odba_store
    end
    def delete_mail_order_price_at(index)
      @mail_order_prices.delete_at(index)
      @mail_order_prices.odba_store
      odba_store
    end
    def delete_all_mail_order_prices
      @mail_order_prices
      @mail_order_prices = []
      @mail_order_prices.odba_store
      odba_store
    end
		def active?
			!@disable && (@preview_with_market_date || @market_date.nil? \
                    || @market_date <= @@today)
		end
    def active_agents
      @parts.inject([]) { |acts, part| 
        if part.active_agents.is_a?(Array)
          acts.concat part.active_agents 
        else
          acts
        end
      }
    end
		def barcode
			if(key = ikskey)
				Ean13.new_unchecked('7680'+key).to_s
			end
		end
		def checkout
			checkout_helper([@generic_group], :remove_package)
      @parts.dup.each { |part|
        part.checkout
        part.odba_delete
      }
      @parts.odba_delete
			if(@sl_entry.respond_to?(:checkout))
				@sl_entry.checkout 
				@sl_entry.odba_delete
			end
      delete_all_mail_order_prices
		end
    def commercial_forms
      if @parts.is_a?(Array)
        @parts.collect { |part| part.commercial_form if part.respond_to?(:commercial_form)}.compact
      else
        []
      end
    end
		def company_name
			(cmp = company) && cmp.name
		end
    def compositions
      @parts.inject([]) { |comps, part| comps.push part.composition }.compact
    end
    def comparable?(bottom, top, pack)
      begin
        pack != self \
          && (other = pack.comparable_size) \
          && bottom < other \
          && top > other \
          && !pack.basename.nil?
      rescue RuntimeError => e
        false
      end
    end
    def comparables
      cs = comparable_size
      bottom = cs * 0.75
      top = cs * 1.25
      comparables = generic_group_comparables
      @sequence.comparables.each { |seq|
        comparables.concat seq.public_packages.select { |pack|
          comparable?(bottom, top, pack)
        }
      }
      comparables.concat @sequence.public_packages.select { |pack|
        comparable?(bottom, top, pack)
      }
      comparables.uniq
    end
    def comparable_size
      @parts.collect { |part| part.comparable_size }.inject{ |a, b| a + b } or raise RuntimeError
    rescue RuntimeError
      @parts.inject(Dose.new(0)) { |comp, part|
        ODDB::Dose.new(comp.qty + part.comparable_size.qty)
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
    def ddd
      if (atc = atc_class) and atc.respond_to?(:has_ddd?) and atc.has_ddd?
        atc.ddds['O']
      end
    end
		def ddd_price
			if(!@disable_ddd_price && (ddd = self.ddd) \
				&& (price = price_public) && (ddose = ddd.dose) && (mdose = dose) \
        && size = comparable_size)

        _ddd_price = 0.00
        factor = (longevity || 1).to_f
        if (grp = galenic_group) && grp.match(@@ddd_galforms) 
          if(mdose > (ddose * factor))
            _ddd_price = (price / size.to_f) / factor
          else
            _ddd_price = (price / size.to_f) \
              * (ddose.to_f * factor / mdose.want(ddose.unit).to_f) / factor
          end
        else
          # This is valid only for the following case, for example, mdose unit: mg/ml, size unit: ml
          # ddd.dose  (ddose): the amount of active_agent required for one day
          # self.dose (mdose): (usually) the amount of active_agent included in one unit of package
          # but in the case of mg/ml, mdose means not 'amount' but 'concentration'
          # size: total amount of package
          begin
            if size.to_s.match(@@ddd_grmforms)
              unless mdose.to_g == 0
                _ddd_price = (price / ((size / mdose.to_g).to_f / ddose.to_f)) / factor
              end
            else
              _ddd_price = (price / ((size * mdose).to_f / ddose.to_f)) / factor
            end
          rescue StandardError
          end
        end
        unless _ddd_price.to_s.match(/^0.*0$/u)
          _ddd_price
        end
			end
		rescue RuntimeError
		end

    def delete_part(oid)
      @parts.delete_if { |comp| comp.oid == oid }
    end
		def delete_sl_entry
			@sl_entry = nil
      @deductible = nil
      @sl_generic_type = nil
      reg = @sequence.registration
      unless reg.nil? || reg.packages.any? do |pac| pac.sl_entry end
        reg.generic_type = nil
        reg.odba_isolated_store
      end
			self.odba_isolated_store
			nil
		end
    def dose
      @ddd_dose || (@sequence.dose if @sequence)
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
    def generic_group_comparables(filters=[])
      if @generic_group \
        && !((go = data_origins['generic_group']) && filters.include?(go))
        @generic_group.packages - [self]
      else
        []
      end
    end
		def good_result?(query)
			query = query.to_s.downcase
			basename.to_s.downcase[0,query.length] == query
		end
    def has_generic?
      @generic_type == :original && !comparables.empty?
    end
    def flickr_photo_id
      if self.photo_link =~ @@flickr_forms
        $1
      else
        nil
      end
    end
    alias :has_flickr_photo? :flickr_photo_id
    def ikscd=(ikscd)
      if(/^[0-9]{3}$/u.match(ikscd))
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
			@sl_entry.limitation if @sl_entry.respond_to?(:limitation)
		end
		def limitation_text
			@sl_entry.limitation_text if @sl_entry.respond_to?(:limitation_text)
		end
		def most_precise_dose
			@pretty_dose || dose
		end
    def name_with_size
      [name_base, size].join(', ')
    end
		def narcotic?
      @bm_flag
		end
    def part(oid)
      @parts.find { |part| part.oid == oid }
    end
    def pharmacode= pcode
      @pharmacode = pcode ? pcode.to_i.to_s : nil
    end
    def preview?
      @preview_with_market_date && @market_date && @market_date > @@today
    end
		def public?
      active? && (@refdata_override || !@out_of_trade \
                  || registration.active?)
		end
    def size
      @parts.collect { |part| part.size if part.respond_to?(:size)}.compact.join(' + ')
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
			values.dup.each { |key, value|
				case key
				when :generic_group
					values[key] = value.resolve(app)
				when :price_public, :price_exfactory
					values[key] = Package.price_internal(value, key)
				when :pretty_dose, :ddd_dose
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
    include ODBA::Persistable ## include directly to get odba_index
    odba_index :pharmacode
    odba_index :name_with_size
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
    def has_price?
      prices.any? do |key, values| !values.empty? end
    end
    def has_price_history?
      prices.any? do |key, values| values.size > 1 end
    end
    def price(type, ord_or_time=0)
      candidates = (prices[type] ||= [])
      if(ord_or_time.is_a?(Time))
        candidates.find { |price| price.valid_from < ord_or_time }
      else
        candidates[ord_or_time.to_i]
      end
    end
    def price_exfactory(ord_or_time=0)
      price(:exfactory, ord_or_time)
    end
    def price_exfactory=(price)
      return price_exfactory if(price == price_exfactory)
      (prices[:exfactory] ||= []).unshift(price)
      price
    end
    def price_public(ord_or_time=0)
      price(:public, ord_or_time)
    end
    def price_public=(price)
      return price_public if(price == price_public)
      (prices[:public] ||= []).unshift(price)
      price
    end
    def prices
      @prices ||= {}
    end
	end
end
