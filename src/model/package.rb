#!/usr/bin/env ruby

# ODDB::Package -- oddb.org -- 06.06.2013 -- yasaka@ywesee.com
# ODDB::Package -- oddb.org -- 01.03.2012 -- mhatakeyama@ywesee.com
# ODDB::Package -- oddb.org -- 25.02.2003 -- hwyss@ywesee.com

require "util/persistence"
require "util/money"
require "util/today"
require "model/slentry"
require "model/ean13"
require "model/feedback_observer"
require "model/patinfo"
require "model/sequence"
require "model/part"
require "ruby-units"

# add some units
RubyUnits::Unit.define("UI") do |bp|
  bp.definition = RubyUnits::Unit.new("1 each")
  bp.aliases = %w[UI U.I.]
  bp.kind = :counting
end

module ODDB
  class PackageCommon
    include Persistence
    @@ddd_galforms = /tablet?/iu
    @@ddd_grmforms = /(?!mg\/ml)[mg|l]/iu
    @@flickr_forms = /^http(?:s*):\/\/(?:.*)\.flickr\.com\/photos\/(?:.[^\/]*)\/([0-9]*)(?:\/*)/
    class << self
      include AccessorCheckMethod
      def price_internal(price, type = nil)
        unless price.is_a?(Util::Money)
          price = Util::Money.new(price, type, "CH")
        end
        price
      end

      def registration_data(*names)
        names.each { |name|
          define_method(name) {
            if @sequence && @sequence.respond_to?(:registration) && (reg = @sequence.registration)
              reg.send(name) if reg.respond_to?(name)
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
    Shortage_fields = [:shortage_state, :shortage_last_update, :shortage_delivery_date, :shortage_link]
    NoMarketing_fields = [:nodelivery_since, :nomarketing_date, :nomarketing_since, :nomarketing_link]
    attr_reader :ikscd, :parts, :pharmacode
    attr_accessor :sequence, :ikscat, :generic_group, :sl_generic_type,
      :price_exfactory, :price_public, :pretty_dose, :market_date,
      :medwin_ikscd, :out_of_trade, :refdata_override, :deductible, :lppv,
      :disable, :swissmedic_source, :descr, :preview_with_market_date,
      :generic_group_factor, :photo_link, :disable_photo_forwarding, :disable_ddd_price, :ddd_dose,
      :sl_entry, :deductible_m, # for just-medical
      :bm_flag, :mail_order_prices,
      :patinfo, :pdf_patinfo,
      # E.g. https://www.drugshortage.ch/detail_lieferengpass.aspx?ID=3056
      :shortage_state, :shortage_last_update, :shortage_delivery_date, :shortage_link,
      :nodelivery_since, :nomarketing_date, :nomarketing_since, :nomarketing_link
    check_accessor_list = {
      sequence: "ODDB::Sequence",
      ikscat: "String",
      generic_group: "ODDB::GenericGroup",
      sl_generic_type: "Symbol",
      price_exfactory: "ODDB::Util::Money",
      price_public: "ODDB::Util::Money",
      pretty_dose: "ODDB::Dose",
      market_date: "Date",
      medwin_ikscd: "String",
      out_of_trade: ["TrueClass", "NilClass", "FalseClass"],
      refdata_override: ["TrueClass", "NilClass", "FalseClass"],
      deductible: ["Symbol", "String"],
      lppv: ["TrueClass", "NilClass", "FalseClass"],
      disable: ["TrueClass", "NilClass", "FalseClass"],
      swissmedic_source: "Hash",
      descr: "String",
      preview_with_market_date: ["TrueClass", "NilClass", "FalseClass"],
      generic_group_factor: ["NilClass", "Float", "Fixnum"],
      photo_link: ["NilClass", "String"],
      disable_ddd_price: ["TrueClass", "NilClass", "FalseClass"],
      disable_photo_forwarding: ["TrueClass", "NilClass", "FalseClass"],
      ddd_dose: "ODDB::Dose",
      sl_entry: "ODDB::SlEntry",
      deductible_m: "String",
      bm_flag: ["TrueClass", "NilClass", "FalseClass"],
      mail_order_prices: "Array",
      pdf_patinfo: "String",
      shortage_link: "String",
      shortage_info: "String",
      shortage_state: "String",
      shortage_last_update: "Date",
      shortage_delivery_date: "String", # can be offen
      nomarketing_date: "Date",
      nomarketing_since: "Date",
      nodelivery_since: "Date"
    }
    define_check_class_methods check_accessor_list
    alias_method :pointer_descr, :ikscd
    registration_data :comarketing_with, :complementary_type, :expiration_date,
      :expired?, :export_flag, :fachinfo_active?, :generic_type,
      :inactive_date, :pdf_fachinfos, :registration_date, :revision_date,
      :patent, :patent_protected?, :vaccine, :parallel_import, :minifi,
      :source, :index_therapeuticus, :ith_swissmedic, :has_fachinfo?, :production_science, :renewal_flag,
      :renewal_flag_swissmedic
    sequence_data :atc_class, :basename, :company, :composition_text, :ddds,
      :fachinfo, :galenic_forms, :galenic_group, :longevity, :compositions,
      :iksnr, :indication, :name, :name_base,
      :registration, :route_of_administration, :sequence_date, :seqnr
    MailOrderPrice = Struct.new(:price, :url, :logo) # logo is empty (old struct)
    def patinfo # {sequence|package}
      # Since February 2016 we suport different patinfo inside the sequence, this happens in over 100 cases
      # eg. Tramal, IKSNR 43788
      result = @patinfo || (sequence && sequence.patinfo.is_a?(ODDB::Patinfo) && sequence.patinfo)
      if @patinfo
        # puts "patinfo is #{@patinfo.class}"
      elsif sequence && sequence.patinfo
        # puts "Package.patinfo OR #{self.sequence.patinfo.class}"
      else
        result = nil
      end
      result
    end

    def pdf_patinfo # {sequence|package}
      @pdf_patinfo || sequence.pdf_patinfo
    end

    def has_patinfo? # {sequence|package}
      return true if @patinfo
      (sequence && sequence.has_patinfo?) ||
        package_patinfo?
    end

    def package_patinfo?
      !@pdf_patinfo.nil? && !@pdf_patinfo.empty?
    end

    class MailOrderPrice
      def <=>(other)
        price.to_f <=> other.price.to_f
      end
    end

    def initialize(ikscd)
      super()
      @ikscd = sprintf("%03d", ikscd.to_i)
      @parts = []
      @mail_order_prices = []
    end

    def add_mail_order_price(price, url)
      @mail_order_prices ||= []
      @mail_order_prices << MailOrderPrice.new(price, url)
      @mail_order_prices.odba_store
      odba_store
    end

    def insert_mail_order_price(price, url)
      @mail_order_prices ||= []
      @mail_order_prices.unshift MailOrderPrice.new(price, url)
      @mail_order_prices.odba_store
      odba_store
    end

    def update_mail_order_price(index, price, url)
      if @mail_order_prices and @mail_order_prices[index]
        @mail_order_prices[index] = MailOrderPrice.new(price, url)
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
      if (key = ikskey)
        if ikskey.to_s.size == 10
          Ean13.new_unchecked("76" + key).to_s
        else
          Ean13.new_unchecked("7680" + key).to_s
        end
      end
    end

    def checkout
      checkout_helper([@generic_group], :remove_package)
      if @parts
        @parts.dup.each { |part|
          part.checkout
          part.odba_delete
        }
        @parts.odba_delete
      end
      if @sl_entry.respond_to?(:checkout)
        @sl_entry.checkout
        @sl_entry.odba_delete
      end
      delete_all_mail_order_prices
    end

    def commercial_forms
      if @parts.is_a?(Array)
        @parts.collect { |part| part.commercial_form if part.respond_to?(:commercial_form) }.compact
      else
        []
      end
    end

    def company_name
      company.name if company
    end

    def comparable?(bottom, top, pack)
      pack != self \
        && (other = pack.comparable_size) \
        && bottom < other \
        && top > other \
        && !pack.basename.nil?
    rescue RuntimeError
      false
    end

    def comparables
      cs = comparable_size
      bottom = cs * 0.75
      top = cs * 1.25
      comparables = generic_group_comparables
      begin
        @sequence.comparables.each { |seq|
          comparables.concat seq.public_packages.select { |pack|
            comparable?(bottom, top, pack)
          }
        }
        comparables.concat @sequence.public_packages.select { |pack|
          comparable?(bottom, top, pack)
        }
      rescue => e
        puts "comparables: Got error #{e} barcode #{barcode} #{name}"
      end
      comparables.uniq
    end

    def comparable_size
      @parts.collect { |part| part.comparable_size }.inject { |a, b| a + b } or raise RuntimeError
    rescue RuntimeError
      begin
        @parts.inject(Dose.new(0)) { |comp, part|
          ODDB::Dose.new(comp.qty + part.comparable_size.qty)
        }
      rescue
        nil
      end
    end

    def create_part
      part = Part.new
      part.package = self
      @parts = [] if @parts.nil? || !@parts.is_a?(Array)
      @parts.push part
      part
    end

    def create_sl_entry
      @sl_entry = SlEntry.new
    end

    def ddd
      if (atc = atc_class) and atc.respond_to?(:has_ddd?) and atc.has_ddd?
        if route_of_administration
          atc.ddds.keys.sort.each do |ddd_key|
            return atc.ddds[ddd_key] if ddd_key.eql?(route_of_administration)
            roa_2 = route_of_administration.sub("roa_", "")
            return atc.ddds[ddd_key] if ddd_key.eql?(roa_2) || ddd_key.eql?(roa_2[0]) || ddd_key[0].eql?(roa_2[0])
          end
        end
        atc.ddds["O"] || atc.ddds["OIndependent of strength"]
      end
    end

    def ddd_pflaster
      if (atc = atc_class) and atc.respond_to?(:has_ddd?) and atc.has_ddd?
        if atc.ddds["TDpatch refer to amount delivered per 24 hours"]
          atc.ddds["TDpatch refer to amount delivered per 24 hours"]
        elsif atc.ddds["TD"]
          atc.ddds["TD"]
        else
          atc.ddds.values.first
        end
      end
    end

    def quanty_to_unit(dose)
      s = dose.to_s.sub("U.I.", "UI").sub(" / ", "/")
      if m = /\d(\s?Mio\.?\s?U\.?)/.match(s)
        s.sub!(m[1], "MU")
      end
      if /\d+\s+IE$/.match?(s)
        s.sub!(/IE$/, "U")
      end
      Unit.new(s)
    rescue
      puts "#{pointer}: #{name} Could not convert #{dose}"
      nil
    end
    # some constant to simplify testing
    SHOW_PRICE_CALCULATION = false
    CUM_LIBERATION_REGEXP = /cum Liberatione ([\d\.]+\s*[µm]g\/\d*\s*h)$/i
    AD_GRANULATUM_REGEXP = /ad Granulatum[^\d]+([\d\.]+\s[mugl]+)$/i
    def ddd_price
      price, _, _ = ddd_price_calc_variant
      price
    end

    def ddd_price_calc_variant(currency = "CHF")
      _ddd_price = nil
      variant = -1
      calc = "no calculation done"
      if !@disable_ddd_price && (ddd = self.ddd) \
         && (price = price_public) && (price.amount > 0) && (ddose = ddd.dose) && (mdose = dose) \
       && size = comparable_size
        factor = (longevity || 1).to_f
        excipiens = if sequence.compositions.first
          sequence.compositions.collect { |c| c.excipiens && c.excipiens.to_s }.compact.first
        end
        puts "#{pointer} @@ddd_galforms #{@@ddd_galforms} galenic_group #{galenic_group} match #{(grp = galenic_group) && grp.match(@@ddd_galforms)} excipiens #{excipiens}" if SHOW_PRICE_CALCULATION
        u_mdose = quanty_to_unit(mdose)
        u_size = quanty_to_unit(size)
        if atc_class.ddds.keys.eql?(["OIndependent of strength"])
        else
          u_ddose = quanty_to_unit(ddose)
          u_adose = sequence.active_agents.first ? quanty_to_unit(sequence.active_agents.first.dose) : 0
          catch_ui = composition_text && / (\d+) U[.]?I[.]?/.match(composition_text)
          if u_mdose != u_adose
            puts "IKSRN #{iksnr} u_adose (dose of first active agent #{u_adose} != dose  of package #{u_mdose}" if SHOW_PRICE_CALCULATION
          end
        end
        if atc_class.ddds.keys.eql?(["OIndependent of strength"])
          variant = 50
          _ddd_price = price / parts.first.count / parts.first.multi
          calc = "#{price} /  #{parts.first.count} / #{parts.first.multi}"
        elsif catch_ui && u_ddose.compatible?(Unit.new("1 TU"))
          if /[\d.-]+ TU/.match?(ddose.to_s)
            variant = 41
            ddd_dose_tu = u_ddose.scalar * 1000
          elsif /[\d.-]+ MU/.match?(ddose.to_s)
            variant = 42
            ddd_dose_tu = u_ddose.scalar * 1000 * 1000 # MU = milllion unit
          elsif /([\d.-])+ U/.match?(ddose.to_s)
            variant = 43
            ddd_dose_tu = u_ddose.scalar
          else
            variant = 44
            calc = "Unable to match ddose #{ddose}"
            puts calc
            return nil, calc, 41
          end
          if dose.unit.index("/ml")
            variant += 10
            measure = Unit.new(parts.first.measure.to_s)
            pack_dose_u = ((u_mdose.base * measure.base)).scalar
          else
            pack_dose_u = catch_ui[1].to_i
          end
          _ddd_price = price / parts.first.count / parts.first.multi / (pack_dose_u / ddd_dose_tu)
          calc = "#{price} /  #{parts.first.count} / #{parts.first.multi} / ( #{pack_dose_u} / #{ddd_dose_tu})"
        elsif excipiens && (per_unit = /ad pulverem\s+pro\s*([\d.]+\s*[mg])/i.match(sequence.composition_text))
          variant = 32
          _ddd_price = (price / ((u_size.base / (u_ddose.base / u_mdose.base)) / Unit.new(per_unit[1].to_s).base))
          calc = "#{price} / ( ( #{u_size} / ( #{u_ddose} /  #{u_mdose} / #{Unit.new(per_unit[1].to_s)} ) )"
        elsif excipiens && /pro compresso$/i.match(excipiens) && sequence.active_agents.size > 1
          variant = 30
          u_mdose = Unit.new(sequence.active_agents.first.dose.to_s)
          _ddd_price = price * (u_ddose.base / (u_mdose * u_size).base)
          calc = "#{price} x ( #{u_ddose} / ( #{u_mdose} x #{u_size} )"
        elsif excipiens && /capsula/i.match(excipiens) && u_ddose && u_mdose && u_size
          variant = 31
          _ddd_price = price * (u_ddose.base / (u_mdose * u_size).base)
          calc = "#{price} x ( #{u_ddose} / ( #{u_mdose} x #{u_size} ))"
        elsif excipiens && (m = CUM_LIBERATION_REGEXP.match(excipiens.downcase))
          variant = 10
          # we cannot mix units 'h' and 'H', therefore we downcase the excipiens
          u_mdose = (Unit.new(m[1]) * Unit.new("24 h")) # per day
          u_ddose = Unit.new(ddd_pflaster.dose.to_s)
          _ddd_price = price / u_size / (u_ddose.base / u_mdose.base)
          calc = "#{price} / #{u_size} / (#{u_ddose} /  #{u_mdose})"
        elsif excipiens && (m = AD_GRANULATUM_REGEXP.match(excipiens.downcase))
          variant = 20
          u_mdose = Unit.new(mdose.to_s)
          u_pro = Unit.new(m[1])
          _ddd_price = price / (u_size.base * (u_mdose.base / u_pro.base) / u_ddose.base)
          calc = "#{price} / #{u_size} x (#{u_mdose.base / u_pro.base} / #{u_ddose})"
        elsif (grp = galenic_group.to_s) && grp.match(@@ddd_galforms)
          if fachinfo && fachinfo.descriptions["de"] && /Wochentablette|pro Woche/i.match(fachinfo.descriptions["de"].usage.to_s)
            variant = 15
            _ddd_price = price / (@parts.first.count * @parts.first.multi) / 7
            calc = "#{price} / ( #{@parts.first.count} x #{@parts.first.multi} ) / 7"
          elsif u_mdose && (u_mdose > (u_ddose * factor))
            if @parts.size != 1
              variant = 11
              _ddd_price = nil
            else
              variant = 13
              _ddd_price = price / @parts.first.count / factor
              calc = "#{price} / #{size} / #{factor}"
            end
          else
            variant = 14
            _ddd_price = price / (@parts.first.count * @parts.first.multi) * (ddose.to_f / mdose.want(ddose.unit).to_f) / factor
            calc = "#{price} / ( #{@parts.first.count} x #{@parts.first.multi} ) x ( #{ddose} / #{mdose} ) / #{factor}"
          end
        elsif size.to_s.match(@@ddd_grmforms)
          # This is valid only for the following case, for example, mdose unit: mg/ml, size unit: ml
          # ddd.dose  (ddose): the amount of active_agent required for one day
          # self.dose (mdose): (usually) the amount of active_agent included in one unit of package
          # but in the case of mg/ml, mdose means not 'amount' but 'concentration'
          # size: total amount of package
          puts "Test to_g #{mdose.to_g == 0} test via unit #{u_mdose.compatible?(Unit.new("1 g"))}" if SHOW_PRICE_CALCULATION
          unless mdose.to_g == 0
            # originally _ddd_price = (price / ((size / mdose.to_g).to_f / ddose.to_f)) / factor
            # ( 0.5 g / 40 mg/ml ) x ( 6.45 / 30 ml )
            # _ddd_price 3 0.43 = 6.45 / 30 ml / 40 mg/ml.to_g).to_f / 0.0005)) / 1.0
            # TODO: Adapt show text to this algorithm
            if u_ddose.compatible?(u_mdose * u_size)
              variant = 1
              _ddd_price = price * (u_ddose.base / (u_mdose * u_size).base)
              calc = "#{price} x #{u_ddose} / ( #{u_mdose} x #{u_size} )"
            elsif u_mdose.compatible?(u_ddose) && excipiens && (m = /\d+\s*\S*/.match(excipiens))
              exc_dose = quanty_to_unit(m[0].sub("Ml", "ml"))
              comparable_unit = quanty_to_unit(comparable_size.to_s)
              variant = 2
              _ddd_price = price / ((u_mdose / exc_dose).base / (u_ddose / comparable_unit).base)
              calc = "#{price} / ( #{u_ddose} / #{exc_dose} / ( #{u_ddose} / #{comparable_size}) )"
            elsif excipiens && /Ad\s+Solutionem$/i.match(excipiens)
              if u_mdose.compatible?(u_ddose)
                variant = 33
                _ddd_price = (price / (u_mdose.base / u_ddose.base))
                calc = "#{price} / (#{u_mdose} / #{u_ddose})"
              elsif u_mdose.compatible?(u_adose)
                variant = 34
                _ddd_price = price / (u_mdose.base / u_adose.base)
                calc = "#{price} / ( #{u_mdose} / #{u_adose} )"
              end
            end
          end
        else
          variant = 4
          _ddd_price = price / ((size * mdose).to_f / ddose.to_f) / factor
          calc = "#{price} / #{size} x #{mdose} / #{ddose} / #{factor}"
        end
        _ddd_price = nil if _ddd_price && _ddd_price.amount.to_i > 20000
        (_ddd_price.to_s =~ /^0\.0*$/u) ? nil : _ddd_price
        puts "#{pointer}: #{variant} #{calc}" if SHOW_PRICE_CALCULATION
        [_ddd_price, calc, variant]
      else
        [_ddd_price, "Disabled or invalid", -2]
      end
    rescue StandardError, NoMethodError, RuntimeError, ArgumentError => e
      puts "_ddd_price RuntimeError #{e} #{iksnr} pack #{ikscd} #{name} from \n#{e.backtrace[0..5].join("\n")}" if SHOW_PRICE_CALCULATION
      _ddd_price = nil
      [_ddd_price, e.to_s, variant]
    end

    def delete_part(oid)
      @parts.delete_if { |comp| comp.oid == oid }
    end

    def delete_sl_entry
      @sl_entry = nil
      @deductible = nil
      @sl_generic_type = nil
      reg = @sequence.registration
      unless reg.nil? || reg.packages.any? { |pac| pac.sl_entry }
        reg.generic_type = nil
        reg.odba_isolated_store
      end
      odba_isolated_store
      nil
    end

    def dose
      @ddd_dose || (@sequence.dose if @sequence)
    end

    def fix_pointers
      @pointer = @sequence.pointer + [:package, @ikscd]
      if (sl = @sl_entry)
        sl.pointer = @pointer + [:sl_entry]
        sl.odba_store
      end
      @parts.each { |part|
        part.fix_pointers
      }
      odba_store
    end

    def generic_group_comparables(filters = [])
      if @generic_group \
        && !((go = data_origins["generic_group"]) && filters.include?(go))
        @generic_group.packages - [self]
      else
        []
      end
    end

    def good_result?(query)
      query = query.to_s.downcase
      basename.to_s.downcase[0, query.length] == query
    end

    def has_generic?
      @generic_type == :original && !comparables.empty?
    end

    def flickr_photo_id
      if photo_link =~ @@flickr_forms
        $1
      end
    end
    alias_method :has_flickr_photo?, :flickr_photo_id
    def photo(image_size = "Thumbnail")
      # Flickr Image Size (max)
      # "Square"    :  75 x  75 px
      # "Thumbnail" : 100 x 100 px
      # "Small"     : 180 x 240 px
      # "Small320"  : 240 X 320 px
      image_size.capitalize!
      config = ODDB.config
      if config.flickr_api_key.empty? or
          config.flickr_shared_secret.empty?
        return nil
      end
      FlickRaw.api_key = config.flickr_api_key
      FlickRaw.shared_secret = config.flickr_shared_secret
      photo_hash = {}
      if id = flickr_photo_id
        begin
          sizes = flickr.photos.getSizes photo_id: id
          has_size = false
          fallback = nil
          src = nil
          sizes.each do |size|
            if size.label == image_size
              has_size = true
              src = size.source
            elsif size.label == "Thumbnail"
              fallback = size.source
            end
          end
          if !has_size and fallback
            src = fallback
          end
          if src
            photo_hash = {
              name: name_base,
              url: photo_link,
              link: !disable_photo_forwarding,
              src: src
            }
          end
        rescue FlickRaw::FailedResponse
        end
      end
      photo_hash
    end

    def ikscd=(ikscd)
      if /^[0-9]{3}$/u.match?(ikscd)
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
      if (nr = iksnr)
        (iksnr.size == 10) ? nr : nr + @ikscd
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
      [name_base, size].join(", ")
    end

    def name_with_size_company_name_and_ean13
      [name_with_size, company_name, barcode].join(", ")
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

    def ref_data_listed? # aka not @out_of_trade
      !@out_of_trade
    end

    def public?
      active? && (@refdata_override || !@out_of_trade \
                  || registration.active?)
    end

    def size
      unless @parts.nil?
        @parts.collect { |part| part.size if part.respond_to?(:size) }.compact.join(" + ")
      end
    end

    def substances
      active_agents.collect { |active| active.substance }.compact
    end

    def <=>(other)
      [basename, dose.to_f, comparable_size.to_f] <=>
        [other.basename, other.dose.to_f, other.comparable_size.to_f]
    end

    private

    def adjust_types(values, app = nil)
      values = values.dup
      values.dup.each { |key, value|
        unless value.nil?
          case key
          when :sl_generic_type
            if value.is_a? String
              values[key] = value.intern
            end
          when :generic_group
            values[key] = value.resolve(app)
          when :price_public, :price_exfactory
            values[key] = Package.price_internal(value, key)
          when :pretty_dose, :ddd_dose
            values[key] = if value.is_a? Dose
              value
            elsif value.is_a?(Array)
              Dose.new(*value)
            end
          end
        end
      }
      values
    end
  end

  class Package < PackageCommon
    ODBA_SERIALIZABLE = ["@prices", "@ancestors", "@swissmedic_source"]
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
      if @feedbacks
        @feedbacks.dup.each { |fb|
          fb.item = nil
          fb.odba_store
        }
        @feedbacks.odba_delete
      end
    end

    def generic_group=(generic_group)
      unless @generic_group.nil?
        @generic_group.remove_package(self)
      end
      unless generic_group.nil?
        generic_group.add_package(self)
      end
      @generic_group = generic_group
    end

    def has_price?
      prices.any? { |key, values| !values.empty? }
    end

    def has_price_history?
      prices.any? { |key, values| values.size > 1 }
    end

    def price(type, ord_or_time = 0)
      candidates = (prices[type] ||= [])
      if ord_or_time.is_a?(Time)
        candidates.find { |price| price.valid_from < ord_or_time }
      else
        candidates[ord_or_time.to_i]
      end
    end

    def price_exfactory(ord_or_time = 0)
      price(:exfactory, ord_or_time)
    end

    def price_exfactory=(price)
      return price_exfactory if price == price_exfactory
      (prices[:exfactory] ||= []).unshift(price)
    end

    def price_public(ord_or_time = 0)
      price(:public, ord_or_time)
    end

    def price_public=(price)
      return price_public if price == price_public
      (prices[:public] ||= []).unshift(price)
    end

    def prices
      @prices ||= {}
    end

    def update_nomarketing_list(new_nomarketing_info)
      # See https://www.swissmedic.ch/arzneimittel/00156/00221/00225/index.html?lang=dedownload=NHzLpZeg7t,lnp6I0NTU042l2Z6ln1acy4Zn4Z2qZpnO2Yuq2Z6gpJCDdX57e2ym162epYbg2c_JjKbNoKSn6A--
      # nomarketing_date: (Column A Datum der Meldung)
      # nomarketing_since: (Column F Nicht-Inverkehrbringen ab)
      # nodelivery_since: (Column G: Vertriebsunterbruch ab)
      raise "Mismatching GTIN #{barcode} #{new_nomarketing_info.gtin}" unless barcode.eql?(new_nomarketing_info.gtin)
      raise "nomarketing_since or nodelivery_since must not be nil" unless new_nomarketing_info.nomarketing_since || new_nomarketing_info.nodelivery_since
      @nomarketing_date = new_nomarketing_info.nomarketing_date
      @nomarketing_since = new_nomarketing_info.nomarketing_since
      @nodelivery_since = new_nomarketing_info.nodelivery_since
      odba_store
    end

    def no_longer_in_nomarketing_list
      NoMarketing_fields.each { |item| eval("@#{item} = nil") }
      odba_store
    end

    def update_shortage_list(new_shortage_info)
      raise "Mismatching GTIN #{barcode} #{new_shortage_info.gtin}" unless barcode.eql?(new_shortage_info.gtin)
      Shortage_fields.each { |item| eval "raise 'field #{item} may not be nil' unless new_shortage_info.#{item}" }
      @shortage_state = new_shortage_info.shortage_state
      @shortage_last_update = new_shortage_info.shortage_last_update
      @shortage_delivery_date = new_shortage_info.shortage_delivery_date
      @shortage_link = new_shortage_info.shortage_link
      odba_store
    end

    def no_longer_in_shortage_list
      Shortage_fields.each { |item| eval("@#{item} = nil") }
      odba_store
    end
  end
end
