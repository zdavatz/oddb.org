#!/usr/bin/env ruby

# ODDB::Sequence -- oddb.org -- 12.03.2013 -- yasaka@ywesee.com
# ODDB::Sequence -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Sequence -- oddb.org -- 24.02.2003 -- hwyss@ywesee.com

require "util/persistence"
require "util/logfile"
require "model/package"
require "model/dose"
require "model/division"
require "model/package"
require "model/composition"

module ODDB
  module Migel
    class Item
      # This is necessary because maybe some old migel item object remain somewhere in the cache
    end
  end

  class SequenceCommon
    include Persistence
    class << self
      include AccessorCheckMethod
      def registration_data(*names)
        names.each { |name|
          define_method(name) {
            @registration && @registration.respond_to?(name) && @registration.send(name)
          }
        }
      end
    end
    attr_reader :seqnr, :name_base, :name_descr, :packages,
      :compositions, :bag_compositions, :longevity
    attr_accessor :registration, :atc_class, :export_flag,
      :patinfo, :pdf_patinfo, :atc_request_time,
      :deactivate_patinfo, :sequence_date, :activate_patinfo,
      :division
    attr_writer :composition_text, :dose, :inactive_date
    check_accessor_list = {
      registration: "ODDB::Registration",
      atc_class: "ODDB::AtcClass",
      export_flag: ["NilClass", "FalseClass", "TrueClass"],
      patinfo: "ODDB::Patinfo",
      pdf_patinfo: "String",
      atc_request_time: "Time",
      deactivate_patinfo: ["NilClass", "Date"],
      sequence_date: ["NilClass", "Date", "DateTime"],
      activate_patinfo: ["NilClass", "Date"],
      composition_text: "String",
      dose: ["NilClass", "ODDB::Dose"],
      division: ["NilClass", "ODDB::Division"]
      # :inactive_date     => "Date",
    }
    define_check_class_methods check_accessor_list
    alias_method :pointer_descr, :seqnr
    registration_data :company, :company_name, :complementary_type, :expired?,
      :fachinfo, :fachinfo_active?, :generic_type, :has_fachinfo?, :iksnr,
      :minifi, :patent_protected?, :source
    def initialize(seqnr)
      @seqnr = sprintf("%02d", seqnr.to_i)
      @packages = {}
      @compositions = []
      @bag_compositions = []
    end

    def active_packages
      if active?
        @packages.values.select { |pac| pac.active? }
      else
        []
      end
    end

    def active_package_count(generic_type = nil)
      if active? && (generic_type.nil? || @registration.generic_type == generic_type)
        if @packages.is_a?(Hash)
          @packages.values.inject(0) { |count, pack|
            if pack.respond_to?(:active?) and pack.active?
              count += 1
            end
            count
          }
        end
      else
        0
      end
    end

    ## active_patinfo is used for invoicing. Returns path to a pdf file, if it
    #  is displayed online.
    def active_patinfo
      active? && patinfo_active? && @pdf_patinfo
    end

    def active?
      (!@inactive_date || (@inactive_date > @@two_years_ago)) \
        && @registration && @registration.is_a?(ODDB::Registration) && @registration.active?
      # && !violates_patent? # Zeno decided on March 9, 2017, that these sequences should appear
    end

    def active_agents
      check_compositions
      @compositions.inject([]) { |acts, comp|
        acts.concat comp.active_agents
      }
    end

    def inactive_agents
      check_compositions
      @compositions.inject([]) { |acts, comp|
        acts.concat comp.inactive_agents
      }
    end

    def basename
      nb = @name_base.to_s[/^.[^0-9]+/u]
      nb.force_encoding("utf-8") if nb
    end

    def checkout
      checkout_helper([@atc_class, @patinfo], :remove_sequence)
      @packages.each_value { |pac|
        pac.checkout
        pac.odba_delete
      }
      @packages.odba_delete
      @packages = {}
      @compositions.dup.each { |comp|
        comp.checkout
        comp.odba_delete
      }
      @compositions.odba_delete
      @compositions = []
    end

    def comparables(factor = 1.0)
      if @atc_class
        comps = factored_compositions(factor)
        @atc_class.sequences.select { |seq|
          comparable?(seq, factor, comps)
        }
      else
        []
      end
    end

    def comparable?(seq, factor = 1.0, comps = nil)
      comps ||= factored_compositions(factor)
      seq != self \
        && seq.active? \
        && seq.compositions.sort == comps
    end

    def compositions
      check_compositions
      @compositions
    end

    def composition(oid)
      @compositions.find { |comp| comp.oid == oid }
    end

    def bag_composition(oid)
      @bag_compositions.find { |comp| comp.oid == oid }
    end

    def create_composition
      comp = Composition.new
      comp.sequence = self
      @compositions.push comp
      comp
    end

    def create_bag_composition
      comp = Composition.new
      comp.sequence = self
      (@bag_compositions ||= []).push comp
      comp
    end

    def create_division
      div = Division.new
      div.add_sequence self
      @division = div
      div
    end

    def create_package(ikscd)
      ikscd = sprintf("%03d", ikscd.to_i)
      unless @packages.include?(ikscd)
        pkg = ODDB::Package.new(ikscd)
        pkg.sequence = self
        @packages.store(ikscd, pkg)
      end
      pkg
    end

    def delete_composition(oid)
      @compositions.delete_if { |comp| comp.oid == oid }
      @compositions.odba_isolated_store
    end

    def delete_bag_composition(oid)
      @bag_compositions.delete_if { |comp| comp.oid == oid }
      @bag_compositions.odba_isolated_store
    end

    def delete_package(ikscd)
      ikscd = sprintf("%03d", ikscd.to_i)
      if (pac = @packages.delete(ikscd))
        @packages.odba_isolated_store
        pac
      end
    end

    def dose # simulate the legacy attribute_reader for dose
      doses.inject { |a, b| a + b }
    rescue
    end

    def doses
      @compositions.inject([]) { |doses, comp|
        doses.concat comp.doses
      }
    end

    def each_package(&block)
      @packages.values.each(&block)
    end

    def factored_compositions(factor = 1.0)
      comps = @compositions.sort
      if factor != 1.0
        comps = comps.collect { |comp| comp * factor }
      end
      comps
    end

    def fix_pointers
      @pointer = @registration.pointer + [:sequence, @seqnr]
      @packages.each_value { |package|
        package.fix_pointers if package
      }
      @compositions.each { |comp|
        comp.fix_pointers
      }
      odba_store
    end

    def galenic_group
      groups = galenic_groups
      groups.first if groups.size == 1
    end

    def galenic_groups
      @compositions.collect { |comp| comp.galenic_group }.compact.uniq
    end

    def galenic_forms
      @compositions.collect { |comp|
        comp.galenic_form if comp.respond_to?(:galenic_form)
      }.compact.uniq
    end

    # Faengt Verweise ab, unter deren odba_id statt einer Patinfo ein
    # PatinfoDocument liegt - die odba_id-Kollision, Issue #280.
    #
    # Probieren, nicht fragen. Hier stand `@patinfo.respond_to?(:odba_instance)`
    # ungeschuetzt, und `respond_to?` ist eine der Methoden, die ein
    # ODBA::Stub aufloest: bei totem Ziel wirft es ODBA::OdbaError, und das
    # mitten in einem Reader, der bei jedem Seitenaufbau laeuft.
    #
    # Und die odba_id wird festgehalten, bevor der Verweis faellt. Sie ist
    # die einzige Spur in dieser Richtung. Was daran haengt, ist nicht nur
    # die Seite: die PI-Diffs laufen ueber
    # `reg.sequence(..).package(..).patinfo.<lang>.change_log`, also ueber
    # genau diesen Verweis - ohne ihn ist die change_log-History
    # unerreichbar, obwohl das Dokument sie noch traegt. Gemessen am
    # 20.11.2026 an 10 gestrandeten Sequenzen: 59160/01 haelt de=5 fr=5
    # it=5 Einträge, 62115/01 de=2 fr=1 it=2, 53929/02 de=3 fr=3 - alle
    # hinter einem 404. Die Gegenrichtung (`patinfo.sequences`) ueberlebt,
    # und jobs/repair_stranded_patinfos stellt den Verweis daraus her.
    def has_patinfo?
      broken = begin
        !@patinfo.nil? && !@patinfo.odba_instance.is_a?(ODDB::Patinfo)
      rescue => error
        LogFile.debug("Sequence #{iksnr}/#{seqnr}: @patinfo nicht aufloesbar, " \
                      "#{error.class}: #{error.message.to_s[0, 60]}")
        true
      end
      if broken
        lost = begin
          @patinfo.odba_id
        rescue
          nil
        end
        LogFile.debug("Sequence #{iksnr}/#{seqnr}: @patinfo #{lost.inspect} ist keine " \
                      "Patinfo, Verweis entfernt - Wiederherstellung ueber " \
                      "jobs/repair_stranded_patinfos")
        @patinfo = nil
        odba_store
        return false
      end
      ((!@patinfo.nil? and @patinfo.valid?) || !@pdf_patinfo.nil?) \
        && patinfo_active? \
        && company && !company.disable_patinfo
    end

    def has_public_packages?
      if @packages.is_a?(Hash)
        @packages.any? { |key, pac|
          pac.public?
        }
      end
    end

    def indication
      @indication || @registration.indication if @registration
    end

    def indication=(indication)
      @indication = replace_observer(@indication, indication)
    end

    def localized_name(language)
      name
    end

    def match(query)
      /#{query}/iu.match(@name_base)
    end

    def name
      @name_base.force_encoding("utf-8") if @name_base
      @name_descr.force_encoding("utf-8") if @name_descr
      [@name_base, @name_descr].compact.join(", ")
    end
    alias_method :to_s, :name
    def name=(name)
      self.name_base, self.name_descr = name.split(",", 2)
    end

    def name_base=(name_base)
      @name_base = nil_if_empty(name_base)
    end

    def name_descr=(name_descr)
      @name_descr = nil_if_empty(name_descr)
    end

    def out_of_trade
      @packages.all? { |key, pac|
        pac.out_of_trade
      }
    end

    def package(ikscd)
      unless ikscd.is_a?(SBSM::InvalidDataError)
        if @packages.is_a?(Hash)
          @packages[sprintf("%03d", ikscd.to_i)]
        end
      end
    end

    def package_count
      @packages.length
    end

    def patinfo_active?
      (@deactivate_patinfo.nil? || @deactivate_patinfo > @@today) \
        && (@activate_patinfo.nil? || @activate_patinfo <= @@today)
    end

    def public?
      !@export_flag && @registration.respond_to?(:public?) && @registration.public? && active?
    end

    def public_packages
      if public? and @packages.is_a?(Hash)
        @packages.values.select { |pac| pac.public? }
      else
        []
      end
    end

    def public_package_count(generic_type = nil)
      if public? && (generic_type.nil? \
        || @registration.generic_type == generic_type)
        count = 0
        if @packages.is_a?(Hash)
          @packages.values.each { |pack|
            if pack.respond_to?(:public?) and pack.public?
              count += 1
            end
          }
        end
        count
      else
        0
      end
    end

    def limitation_text
      if @packages.is_a?(Hash)
        @packages.each_value { |package|
          if (txt = package.limitation_text)
            return txt
          end
        }
      end
      nil
    end

    def limitation_text_count
      @packages.values.select { |package|
        package.limitation_text
      }.size
    end

    def longevity=(days)
      days = days.to_i
      @longevity = (days > 1) ? days : nil
    end

    def route_of_administration
      roas = @compositions.collect { |comp|
        comp.route_of_administration
      }.compact.uniq
      roas.first if roas.size == 1
    end

    def search_terms
      str = name
      # str = self.name.force_encoding('utf-8')
      ODDB.search_terms(str.split(/\s+/u).push(str))
    end

    def seqnr=(seqnr)
      ## FIXME: this is just a quick spaghetti-hack to get all data correct
      if /^[0-9]{2}$/u.match(seqnr) \
        && @registration.sequence(seqnr).nil?
        seqs = @registration.sequences
        seqs.delete(@seqnr)
        seqs.store(seqnr, self)
        seqs.odba_store
        @seqnr = seqnr
        fix_pointers
      end
    end

    def substances
      @compositions.inject([]) { |subs, comp|
        subs.concat comp.substances
      }.uniq
    end

    def substance_names
      substances.collect { |subst| subst.to_s }
    end

    def violates_patent?
      @atc_class && @registration.may_violate_patent?	\
        && @atc_class.sequences.any? { |seq|
             seq.patent_protected? && seq.company != @registration.company \
               && _violates_patent?(seq)
           }
    rescue
      false
    end

    def _violates_patent?(seq)
      other = seq.active_agents
      agents = active_agents
      other.size == agents.size or return false
      other = other.sort
      agents = agents.sort
      other.each_with_index { |oth, idx|
        agt = agents.at(idx)
        oth.substance == agt.substance or return false
        oth.chemical_substance == agt.chemical_substance or return false
      }
      true
    end

    private
    def check_compositions
      unless @compositions.instance_of?(Array)
        ODDB::LogFile.debug("Sequence #{odba_id} #{iksnr} has wrong class #{@compositions.class} for @compositions")
        @compositions = []
        odba_store
      end
      @compositions.delete_if{|x| !x.instance_of?(ODDB::Composition)}
    end

    def adjust_types(values, app = nil)
      values = values.dup
      values.dup.each { |key, value|
        if value.is_a?(Persistence::Pointer)
          values[key] = value.resolve(app)
        else
          case key
          when :atc_class
            values[key] = if (atc = app.atc_class(value))
              atc
            else
              @atc_class
            end
          when :dose
            values[key] = if value.is_a? Dose
              value
            elsif value.is_a?(Array)
              Dose.new(*value)
            end
          when :inactive_date, :sequence_date
            if value.is_a?(String)
              values.store(key, Date.parse(value.tr(".", "-")))
            end
          end
        end
      }
      values
    end
  end

  class Sequence < SequenceCommon
    attr_accessor :patinfo_shadow
    ACTIVE_AGENT = ActiveAgent
    ODBA_PREFETCH = true
    # Den alten Wert vor super festhalten, in allen drei Settern. super ist
    # der von define_check_class_methods erzeugte Setter und weist das Ivar
    # zu - danach sind target und value in replace_observer dasselbe Objekt,
    # also ruft es remove_sequence auf dem *neuen* Beobachter und der alte
    # erfaehrt nie, dass er die Sequenz abgeben soll. Er behaelt sie fuer
    # immer, und die Sequenz haengt in zwei Listen.
    #
    # Eingefuehrt von 719b266a (27.02.2012, "Check accessor classes of
    # Sequence"), das super(atc_class) und super(patinfo) ergaenzte, um den
    # neuen typpruefenden Setter zu benutzen. indication= zwei Methoden
    # weiter oben wurde nicht angefasst und ist deshalb das einzige der
    # vier, das stimmt - es ist die Vorlage.
    #
    # Gemessen am 20.11.2026: der WHO-Import repariert das seit Jahren jeden
    # Monat nach (23 / 24 / 15 Sequenzen in September / Oktober / November),
    # immer in denselben Klassen, weil jede ATC-Umbuchung im Monat einen
    # Eintrag zurueckliess.
    #
    # Auch der nil-Fall muss die alte Klasse benachrichtigen. Das frueher
    # hier stehende `unless atc_class.nil?` stammt aus der Zeit vor 2012, als
    # es kein super gab und eine nil-Zuweisung deshalb gar nichts tat. Mit
    # super loescht sie das Ivar sofort, und der Guard liess die alte Klasse
    # ungefragt - wer erst auf nil und dann auf B setzte, verlor A fuer
    # immer. replace_observer(previous, nil) ruft A.remove_sequence und gibt
    # nil zurueck, also genau das, was super schon gesetzt hat.
    #
    # AtcClass#checkout setzt die atc_class jeder Sequenz auf nil und wird
    # von nichts aufgerufen (geprueft 20.11.2026, src/ und jobs/) - die
    # Falle aus Package#checkout, wo ein odba_isolated_store das gerade
    # geloeschte Objekt wieder anlegt, greift hier also nicht.
    def atc_class=(atc_class)
      previous = @atc_class
      super
      @atc_class = replace_observer(previous, atc_class)
    end

    def patinfo=(patinfo)
      previous = @patinfo
      super
      @patinfo = replace_observer(previous, patinfo)
    end

    def division=(division)
      previous = @division
      super
      @division = replace_observer(previous, division)
    end

    def replace_observer(target, value)
      if target.respond_to?(:remove_sequence)
        target.remove_sequence(self)
      end
      if value.respond_to?(:add_sequence)
        value.add_sequence(self)
      end
      value
    end

    def composition_text
      @composition_text || @packages.collect { |cd, pac|
        (src = pac.swissmedic_source) && src[:composition]
      }.compact.first
      @composition_text.force_encoding("utf-8") if @composition_text
    end
  end
end
