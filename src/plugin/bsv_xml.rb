#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::BsvXmlPlugin -- oddb.org -- 03.04.2013 -- yasaka@ywesee.com
# ODDB::BsvXmlPlugin -- oddb.org -- 15.02.2012 -- mhatakeyama@ywesee.com
# ODDB::BsvXmlPlugin -- oddb.org -- 10.11.2008 -- hwyss@ywesee.com

require 'config'
require 'date'
require 'drb'
require 'fileutils'
require 'mechanize'
require 'model/dose'
require 'model/text'
require 'plugin/plugin'
require 'plugin/refdata'
require 'rexml/document'
require 'rexml/streamlistener'
require 'util/persistence'
require 'util/today'
require 'zip'
require 'plugin/swissindex'
require 'util/mail'

module ODDB
  class BsvXmlPlugin < Plugin
    RECIPIENTS     = ['oddb_bsv']
    BSV_RECIPIENTS = ['oddb_bsv_info']
    class Listener
      include REXML::StreamListener
      FORMATS = {
        'b' => :bold,
        'i' => :italic,
      }
      def initialize app, opts={}
        @app = app
        @change_flags = {}
        @opts = {}
      end
      def date txt
        unless txt.to_s.empty?
          parts = txt.split('.', 3).collect do |part| part.to_i end
          Date.new *parts.reverse
        end
      end
      def text text
        if @html
          @html << text.gsub(%r{<br\s*/?>}, "\n")
          @text = @html.gsub(%r{<[^>]+>}, '')
        end
      end
      def time txt
        unless txt.to_s.empty?
          parts = txt.split('.', 3).collect do |part| part.to_i end
          Time.local *parts.reverse
        end
      end
      def update_chapter chp, text, subheading=nil
        sec = chp.next_section
        if subheading
          sec.subheading << subheading.to_s << "\n"
        end
        #text.each do |line|
        text.each_line do |line|
          par = sec.next_paragraph
          line.scan /(<(\/)?([bi])>|[^<]+|<)/u do |match|
            if fmt = FORMATS[match[2]]
              if match[1]
                par.reduce_format fmt
              else
                par.augment_format fmt
              end
            else
              par << match[0]
            end
          end
        end
        chp.clean!
      end
    end
    class GenericsListener < Listener
      def tag_start name, attrs
        @text = ''
        @html = ''
      end
      def tag_end name
        case name
        when 'OrgGen'
          if @pointer && @original && @generic
            group = @app.create @pointer
            @app.update @original.pointer, {:generic_group => @pointer}, :bag
            @app.update @generic.pointer, {:generic_group => @pointer}, :bag
          end
          @pointer, @original, @generic = nil
        end
        @html, @text = nil
      end
    end
    class ItCodesListener < Listener
      def tag_start name, attrs
        case name
        when 'ItCode'
          code = attrs['Code'].to_s
          @pointer = Persistence::Pointer.new [:index_therapeuticus, code]
          @target_data = @data = {}
        when 'Limitations'
          @target_data = @lim_data = {}
        else
          @text = ''
          @html = ''
        end
      end
      def tag_end name
        case name
        when 'ItCode'
          @app.update @pointer.creator, @data, :bag
          unless @lim_data.empty?
            lim_ptr = @pointer + :limitation_text
            @lim_data.each_key do |key|
              if key.to_s.size == 2
                chp = Text::Chapter.new
                update_chapter chp, @lim_data[key]
                @lim_data[key] = chp
              end
            end
            @app.update lim_ptr.creator, @lim_data, :bag
          end
        when /Limitation([A-Z].+)/u, /Description(..)/u
          @target_data.store $~[1].downcase.to_sym, @text
        when 'ValidFromDate'
          @target_data.store :valid_from, date(@text)
        when 'Points'
          @target_data.store :limitation_points, @text.to_i
        end
        @text, @html = nil
      end
    end
    class PreparationsListener < Listener
      MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
      GENERIC_TYPES = { 'O' => :original, 'G' => :generic}
      attr_reader :change_flags,
                  :conflicted_registrations,
                  :missing_ikscodes, :missing_ikscodes_oot,
                  :unknown_packages, :unknown_registrations,
                  :unknown_packages_oot,
                  :created_sl_entries, :deleted_sl_entries,
                  :updated_sl_entries, :created_limitation_texts,
                  :deleted_limitation_texts, :updated_limitation_texts,
                  :duplicate_iksnrs
      attr_accessor :test_sequences if defined?(Minitest) #something we should avoid!!

      def initialize *args
        super
        @known_packages = {}
        @app.each_package do |pac|
          if pac.public? && pac.sl_entry
            @known_packages.store pac.pointer, {
              :name_base           => pac.name_base,
              :atc_class           => (atc = pac.atc_class) && atc.code,
              :swissmedic_no5_oddb => pac.iksnr,
              :swissmedic_no8_oddb => pac.ikskey,
            }
          end
        end
        @completed_registrations = {}
        @conflicted_registrations = []
        @duplicate_iksnrs = []
        @missing_ikscodes = []
        @missing_ikscodes_oot = []
        @unknown_packages = []
        @unknown_packages_oot = []
        @unknown_registrations = []
        @created_sl_entries = 0
        @created_limitation_texts = 0
        @deleted_sl_entries = 0
        @deleted_limitation_texts = 0
        @updated_sl_entries = 0
        @updated_limitation_texts = 0
        @origin = @@today.strftime "#{ODDB.config.url_bag_sl_zip} (%d.%m.%Y)"
        @visited_iksnrs = {}
      end
      def completed_registrations
        @completed_registrations.values
      end
      def erroneous_packages
        @known_packages.values.sort_by do |data| data[:name_base].to_s end
      end
      def flag_change pointer, key
        (@change_flags[pointer] ||= []).push key
      end
      def find_typo_registration iksnr, name
        names = name.collect do |key, name| name.downcase end
        (iksnr.length - 1).times do |idx|
          typo = iksnr.dup
          typo[idx,2] = typo[idx,2].reverse
          if reg = @app.registration(typo)
            rnames = reg.sequences.collect do |seqnr, seq|
              seq.name_base.downcase end
            return reg unless (names & rnames).empty?
          end
        end
        nil
      end
      def identify_sequence registration, name, substances
        if registration.nil?
          return nil
        end
        subs = substances.collect do |data|
          [data[:lt], ODDB::Dose.new(data[:dose], data[:unit])]
        end
        seqs = registration.sequences.values
        sequence = seqs.find do |seq|
          subs.size == seq.active_agents.size && subs.all? do |sub, dose|
            seq.active_agents.any? do |act| act.same_as?(sub) && act.dose == dose end
          end
        end
        sequence ||= seqs.find do |seq| seq.active_agents.empty? end
        if sequence.nil?
          seqnr = (registration.sequences.keys.max || '00').next
          ptr = registration.pointer + [:sequence, seqnr]
          sequence = @app.update ptr.creator, :name_base => name[:de]
        end
        if sequence.active_agents.empty?
          cptr = sequence.pointer + :composition
          comp = @app.create cptr
          subs.each do |name, dose|
            substance = @app.substance name
            unless substance
              sptr = Persistence::Pointer.new :substance
              substance = @app.update sptr.creator, :lt => name
            end
            pointer = comp.pointer + [:active_agent, name]
            agent = @app.update pointer.creator, :dose => dose,
                                                 :substance => substance.oid
          end
        end
        sequence
      end
      def add_bag_composition_to_sequence sequence, substances
        subs = substances.collect do |data|
          [data[:lt], ODDB::Dose.new(data[:dose], data[:unit])]
        end

        composition_pointer = sequence.pointer + :bag_composition
        comp = if (sequence.bag_compositions.nil? || sequence.bag_compositions.empty?) then @app.create composition_pointer else sequence.bag_compositions[0] end
        if !sequence.bag_compositions.empty?
          first_composition = sequence.bag_compositions[0]
          first_composition.active_agents.each do |agent|
            first_composition.delete_active_agent(agent)
            agent.odba_delete
            first_composition.odba_store
          end
        end

        subs.each do |name, dose|
          substance = @app.substance name
          unless substance
            sptr = Persistence::Pointer.new :substance
            substance = @app.update sptr.creator, :lt => name
          end
          pointer = comp.pointer + [:active_agent, name]
          agent = @app.update pointer.creator, :dose => dose,
                                               :substance => substance.oid
        end
      end
      def load_ikskey pcode
        return if pcode.to_s.empty?
        ODDB::RefdataPlugin.new(@app).load_ikskey(pcode)
      end
      def tag_start name, attrs
        case name
        when 'IntegrationDate'
          @parsing_prices = false
        when 'Pack'
          @parsing_prices = true
          @price_change_code = nil
          @price_amount = nil
          @valid_from = nil
          @ikscd = nil
          @data = @pac_data.dup
          @report = @report_data.dup.update(@data).update(@reg_data).update(@seq_data)
          @report.delete(:sl_generic_type)
          @out_of_trade = false
          if @registration
            @report.store :swissmedic_no5_oddb, @registration.iksnr
            unless ['00000', @registration.iksnr].include?(@iksnr)
              @conflicted_registrations.push @report
            end
          end
          @sl_data = { :limitation_points => nil, :limitation => nil }
          @lim_data = {}
        when 'Preparation'
          @descriptions = {}
          @reg_data = {}
          @seq_data = {}
          @pac_data = {}
          @sl_entries = {}
          @lim_texts = {}
          @name = {}
          @report_data = {}
          @deferred_packages = []
          @substances = []
          @sequence = nil
        when 'LastPriceChange' # just ignore it
        when 'ExFactoryPrice'
          @valid_from = nil
          @price_change_code = nil
          @price = nil
          @price_exfactory = Util::Money.new(0, :exfactory, 'CH')
          @price_exfactory.origin = @origin
          @price_exfactory.authority = :sl
          @price_type = :exfactory
        when 'PublicPrice'
          @valid_from = nil
          @price_change_code = nil
          @price = nil
          @price_type = :public
          @price_public = Util::Money.new(0, :public, 'CH')
          @price_public.origin = @origin
          @price_public.authority = :sl
        when 'Limitation'
          @in_limitation = true
        when 'ItCode'
          @itcode = attrs['Code']
          @reg_data.store :index_therapeuticus, @itcode
          @it_descriptions = {}
        when 'Substance'
          @substance = {}
        else
          @text = ''
          @html = ''
        end
      rescue StandardError => e
        e.message << "\n@report: " << @report.inspect
        raise
      end
      def tag_end name
        already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
        @seq_data ||= {}
        case name
        when 'Prices'
          @parsing_prices = false
        when 'Pack'
          fix_flags_with_rss_logic
          if @pack.nil? && @completed_registrations[@iksnr] && !@out_of_trade
            @deferred_packages.push({
              :ikscd    => @ikscd,
              :sequence => @seq_data,
              :package  => @data,
              :sl_entry => @sl_data,
              :lim_text => @lim_data,
              :size     => @size,
            })
          elsif @pack && !@duplicate_iksnr
            ## don't take the Swissmedic-Category unless it's missing in the DB
            @data.delete :ikscat if @pack.ikscat
            if  @pack.price_exfactory.nil? || !@price_exfactory.amount.to_s.eql?(@pack.price_exfactory.amount.to_s) || !@price_change_code.eql?(@pack.price_exfactory.mutation_code)
              LogFile.debug "tag_end_set price_exfactory #{@price_exfactory} for @pack.price_exfactor '#{@pack.price_exfactory}' #{@pack.price_exfactory&.mutation_code} now #{@price_change_code}"
              @pack.price_exfactory = @price_exfactory
              @pack.price_exfactory.mutation_code = @price_exfactory.mutation_code
              @pack.price_exfactory.valid_from = @price_exfactory.valid_from
              @data.store :price_exfactory, @price_exfactory
            end if @price_exfactory
            if @pack.price_public.nil? || !@price_public.amount.to_s.eql?(@pack.price_public.amount.to_s) || !@price_change_code.eql?(@pack.price_public.mutation_code)
              LogFile.debug "tag_end price_public #{@price_public} for @pack.price_exfactor '#{@pack.price_public}' #{@pack.price_public&.mutation_code} now #{@price_change_code}"
              @pack.price_public = @price_public
              @pack.price_public.valid_from = @price_public.valid_from
              @pack.price_public.mutation_code = @price_public.mutation_code
              @data.store :price_public, @price_public
            end if @price_public
            @app.update @pack.pointer, @data, :bag
            @sl_entries.store @pack.pointer, @sl_data
            @lim_texts.store @pack.pointer, @lim_data
          end
          if !@pack.nil?
            @sequence = @pack.sequence
            @pack.odba_store
          end
          @pack, @sl_data, @lim_data, @out_of_trade, @ikscd, @data, @size, @price_public, @price_exfactory = nil
        when 'Preparation'
          seq = @sequence || identify_sequence(@registration, @name, @substances)
          @test_sequences ||= []
          @test_sequences << seq if defined?(Minitest) #something we should avoid!!
          if !@deferred_packages.empty? && seq
            @deferred_packages.each do |info|
              ptr = seq.pointer + [:package, info[:ikscd]]
              @app.update seq.pointer, info[:sequence]
              unless seq.package(info[:ikscd])
                seq.create_package(info[:ikscd])
              end
              @app.update ptr.creator, info[:package]
              pptr = ptr + [:part]
              size = info[:size].sub(/(^| )[^\d.,]+(?= )/, '')
              @app.update pptr.creator, :size => size,
                                        :composition => seq.compositions.first
              @sl_entries.store ptr, info[:sl_entry]
              @lim_texts.store ptr, info[:lim_text]
            end
          end
          if !seq.nil?
            add_bag_composition_to_sequence seq, @substances
          end
          @sl_entries.each do |pac_ptr, sl_data|
            begin
              pac = pac_ptr.resolve @app
              @known_packages.delete pac_ptr
              next if pac.nil?
              unless pac.is_a?(ODDB::Package)
              else
                pointer = pac_ptr + :sl_entry
                if sl_data.empty?
                  if pac.sl_entry
                    @deleted_sl_entries += 1
                    @app.delete pointer
                  end
                else
                  if pac.sl_entry
                    @updated_sl_entries += 1
                  else
                    @created_sl_entries += 1
                  end
                  if (lim_data = @lim_texts[pac_ptr]) && !lim_data.empty?
                    sl_data.store :limitation, true
                  end
                  @app.update pointer.creator, sl_data, :bag
                end
              end
            rescue ODBA::OdbaError, ODDB::Persistence::InvalidPathError, NoMethodError => error
              # skip
            end
          end
          @lim_texts.each do |pac_ptr, lim_data|
            begin
               pac = pac_ptr.resolve @app
               next if pac.nil?
               unless pac.is_a?(ODDB::Package)
               else
                sl_entry = pac.sl_entry
                next if sl_entry.nil?
                sl_ptr = sl_entry.pointer
                sl_ptr ||= pac.pointer + [:sl_entry]
                txt_ptr = sl_ptr + :limitation_text
                # 2021.03.16 Niklaus has no idea, why I have to freeze it here
                # but without a freeze the @app.update fails miserably
                if lim_data.nil? || lim_data.empty?
                  if sl_entry.limitation_text
                    @deleted_limitation_texts += 1
                    @app.delete txt_ptr
                  end
                else
                  if sl_entry.limitation_text
                    @updated_limitation_texts += 1
                  else
                    @created_limitation_texts += 1
                  end
                  # In order to refresh limitation text old objects in ODBA cache
                  # before updating. Otherwise, the link between sl_entry and
                  # limitation_text may not produced even if there are both objects
                  # in ODBA cache.
                  begin
                    if sl_entry.limitation_text || txt_ptr.resolve(@app)
                      @app.delete txt_ptr
                    end
                  rescue ODDB::Persistence::UninitializedPathError,
                        ODDB::Persistence::InvalidPathError => error
                    # skip
                  end
                txt_ptr = sl_ptr + :limitation_text
                # 2021.03.16 Niklaus has no idea, why I have to redefine it here
                # but without redefining the @app.update fails miserably
                  @app.update txt_ptr.creator, lim_data, :bag
                end
              end
            rescue TypeError, ODBA::OdbaError, ODDB::Persistence::InvalidPathError, NoMethodError => error
              # skip
            end
          end
          if @registration
            @app.update @registration.pointer, @reg_data, :bag
          else
            @unknown_registrations.push @report_data
          end
          @iksnr, @registration, @sl_entries, @lim_texts, @duplicate_iksnr,
            @atc_code, @deferred_packages, @substances, @sequence = nil
        when 'AtcCode'
          @atc_code = @text
        when 'SwissmedicNo5'
          @iksnr = "%05i" % @text.to_i
          @report_data.store :swissmedic_no5_bag, @iksnr
          atc, name = visited = @visited_iksnrs[@iksnr]
          if @iksnr == '00000'
            # ignore, is reported independently
          elsif visited.nil? || @atc_code == atc \
            || atc.to_s.empty? || @atc_code.to_s.empty? \
            || name == @name
            @registration = @app.registration(@iksnr)
            @visited_iksnrs.store @iksnr, [@atc_code, @name]
          elsif @registration = find_typo_registration(@iksnr, @name)
            @report_data.store :swissmedic_no5_bag,
              sprintf("%s (auto-corrected to %s)", @iksnr,
                      @iksnr = @registration.iksnr)
            @duplicate_iksnrs.push @report_data
          else
            @duplicate_iksnr = true
            @report_data.store :swissmedic_no5_bag,
              sprintf("%s (belongs to %s)", @iksnr, name && name[:de])
            @duplicate_iksnrs.push @report_data
          end
          if @registration && @registration.packages.empty?
            @completed_registrations.store @iksnr, @report_data
          end
        when 'SwissmedicNo8'
          @report.store :swissmedic_no8_bag, @text
          unless @registration
            @registration = @app.registration("%05i" % @text[0..-4].to_i)
          end
          if @registration
            @ikscd = '%03i' % @text[-3,3].to_i
            @pack ||= @app.package_by_ikskey(@text)
            @out_of_trade = @pack.out_of_trade if @pack
            if !@pack.nil? && @pack.pointer.nil?
              @pack.fix_pointers
            end
          end

          if @text.strip.empty?
            if @out_of_trade
              @missing_ikscodes_oot.push @report
            else
              @missing_ikscodes.push @report
            end
          end
        when 'SwissmedicCategory'
          @data.store :ikscat, @text
        when 'OrgGenCode'
          gtype = GENERIC_TYPES[@text]
          unless (registration = @app.registration(@iksnr) and registration.keep_generic_type)
            @reg_data.store(:generic_type, (gtype || :unknown))
          end
          @pac_data.store :sl_generic_type, gtype
        when /FlagSB/
          @pac_data.store :deductible, @text == 'Y' ? :deductible_o : :deductible_g
        when 'FlagNarcosis'
          @data.store :narcotic, @text == 'Y'
        when 'BagDossierNo'
          @sl_data.store :bsv_dossier, @text if @sl_data
        when 'LastPriceChange' # just ignore
        when 'Prices'
          @parsing_prices = true
        when 'ExFactoryPrice'
          @price_exfactory = Util::Money.new(@price_amount, @price_type, 'CH')
          @price_exfactory.origin = @origin
          @price_exfactory.authority = :sl
          @price_exfactory.mutation_code = @price_change_code
          @price_exfactory.valid_from = @valid_from
          if @price_exfactory > 0
            @data.store :"price_#{@price_type}", @price_exfactory
          end
        when 'PublicPrice'
          @price_public = Util::Money.new(@price_amount, @price_type, 'CH')
          @price_public.origin = @origin
          @price_public.authority = :sl
          @price_public.mutation_code = @price_change_code
          @price_public.valid_from = @valid_from
          if @price_public > 0
            @data.store :"price_#{@price_type}", @price_public
          end
        when 'Price'
          @price_amount = @text
        when 'ValidFromDate'
          @valid_from = time(@text) # for prices
          if @sl_entries
            @sl_entries.each_value do |sl_data|
              sl_data.store :valid_from, date(@text)
            end
          end
        when 'ValidThruDate'
          if @sl_entries
            @sl_entries.each_value do |sl_data|
              sl_data.store :valid_until, date(@text)
            end
          end
        when 'StatusTypeCodeSl'
          # When looking Preparations.xml we find
          # <StatusTypeCodeSl>0</StatusTypeCodeSl>  <StatusTypeDescriptionSl>Initialzustand
          # <StatusTypeCodeSl>2</StatusTypeCodeSl>  <StatusTypeDescriptionSl>Neuaufnahme
          # <StatusTypeCodeSl>5</StatusTypeCodeSl>  <StatusTypeDescriptionSl>Ausserordentliche Preiserhöhung
          # <StatusTypeCodeSl>8</StatusTypeCodeSl>  <StatusTypeDescriptionSl>Preissenkung
          if @sl_data
            @sl_data.store :status, @text
            active = false
            flag = nil
            case @text
            when '2', '6'
              if @pack && !@pack.sl_entry
                flag_change @pack.pointer, :sl_entry
              end
              active = true
            when '3', '7'
              if @pack && @pack.sl_entry
                flag_change @pack.pointer, :sl_entry_delete
              end
            when '9', '10'
              #  9: inactive
              # 10: pending
            else
              active = true
            end
            if active && !@out_of_trade
              if @registration && @pack.nil?
                @report.store :swissmedic_no5_oddb, @registration.iksnr
                @unknown_packages.push @report
              end
            elsif @registration && @pack.nil?
              @report.store :swissmedic_no5_oddb, @registration.iksnr
              @unknown_packages_oot.push @report
            end
          end
        when 'IntegrationDate'
          @sl_data.store :introduction_date, date(@text) if @sl_data
        when 'PriceChangeTypeCode'
          @price_change_code = @text
        when 'Limitation'
          @in_limitation = false
        when 'LimitationType'
          # ignore
        when /^Limitation([A-Z].+)$/u
          @sl_data.store $~[1].downcase.to_sym, @text if @sl_data
        when /^Name(..)$/u
          key = $~[1].downcase.to_sym
          @name[key] = @text
          @report_data.store(:name_base, @text) if key == :de
        when 'DescriptionLa'
          @substance.store :lt, @text
        when 'Quantity'
          @substance.store :dose, @text.to_f
        when 'QuantityUnit'
          @substance.store :unit, @text
        when 'Substance'
          @substances.push @substance
          @substance = nil
        when /^Description(..)$/u
          key = $~[1].downcase.to_sym
          if @in_limitation
            if @lim_data # we are within a Package
              chp = Text::Chapter.new
              update_chapter chp, @html
              @lim_data.store key, chp
            else
              @lim_texts.each_value do |text_data|
                chp = text_data[key] ||= Text::Chapter.new
                subheading = if @it_descriptions
                               [@itcode, @it_descriptions[key]].compact.join(': ')
                             else
                               @name[key]
                             end
                update_chapter chp, @html, subheading
              end
            end
          elsif @it_descriptions
            @it_descriptions[key] = @text
          elsif @data
            @size ||= @text
          else
            @descriptions[key] ||= @text
            @report_data[:name_descr] ||= @text if key == :de
          end
        when 'Points'
          if @sl_data
            value = @text.to_i
            @sl_data.store :limitation_points, value
            @sl_data.store :limitation, value > 0
          end
        when 'ItCode'
          @itcode = nil
          @it_descriptions = nil
        when 'Preparations'
          @known_packages.each do |pointer, data|
            @deleted_sl_entries += 1
            flag_change pointer, :sl_entry_delete
            sl_ptr = pointer + :sl_entry
            begin
              @app.delete sl_ptr
            rescue  ODBA::OdbaError => error
              LogFile.debug "Preparations unable to delete pointer #{pointer} data #{data}"
            end
          end
        end
        @text, @html = nil
      rescue ODBA::OdbaError => error
        # Sometimes there would be an ODBAError, if we are not catching it,
        # the whole import job would stop. Zeno said it's safe to ignore the errors,
        # I am not so sure. Things with ODBA are so uncertain.
        # Ref https://github.com/zdavatz/oddb.org/issues/169
        warn "Error in tag_end #{error}"
      rescue StandardError => e
        e.message << "\n@report: " << @report.inspect
        raise
      ensure
        GC.enable unless already_disabled
      end

      def fix_flags_with_rss_logic
        # There's a bug where the XML source is incorrect with some flags,
        # the RSS looks ok but the generated xls isn't.
        # https://github.com/zdavatz/oddb.org/issues/154
        # To workaround that, we are using the logic from the RSS plugin.
        # https://github.com/zdavatz/oddb.org/blob/94e2d1a8f009168d7236a896f57760a6ba4502f7/src/plugin/rss.rb#L209-L224
        today = Date.today
        cutoff = (today << 1) + 1
        first = Time.local(cutoff.year, cutoff.month, cutoff.day)
        last = Time.local(today.year, today.month, today.day)
        range = first..last
        if (current = @price) && range.cover?(current.valid_from) && !@pack.nil?
          previous = @pack.price_public
          if previous.nil?
            if current.authority == :sl
              flag_change @pack.pointer, :sl_entry
            end
          elsif [:sl, :lppv, :bag].include?(@pack.data_origin(:price_public))
            if previous > current
              flag_change @pack.pointer, :price_cut
            elsif current > previous
              flag_change @pack.pointer, :price_rise
            end
          end
        end
      end
    end
    attr_reader :preparations_listener
    def initialize *args
      @latest = File.join ARCHIVE_PATH, 'xml', 'XMLPublications-latest.zip'
      super
    end
    def update

      LogFile.append('oddb/debug', " bsv_xml: getting BsvXmlPlugin.update", Time.now)

      target_url = ODDB.config.url_bag_sl_zip
      save_dir = File.join ARCHIVE_PATH, 'xml'
      file_name = "XMLPublications.zip"

      LogFile.append('oddb/debug', " bsv_xml: target_url = " + target_url.to_s, Time.now)
      LogFile.append('oddb/debug', " bsv_xml: save_dir   = " + save_dir.to_s, Time.now)

      path = download_file(target_url, save_dir, file_name)
      LogFile.append('oddb/debug', " bsv_xml: path = " + path.inspect.to_s, Time.now)
      #if(path = download_file(target_url, save_dir, file_name))
      if(path)
        _update path
      end
      path
    end
    def _update path=@latest
      Zip::File.foreach(path) do |entry|
        case entry.name
        when 'Preparations.xml'
          LogFile.append('oddb/debug', " bsv_xml: update_preparations", Time.now)
          entry.get_input_stream do |io| send('update_preparations', io) end
        when 'ItCodes.xml'
          LogFile.append('oddb/debug', " bsv_xml: update_it_codes", Time.now)
          entry.get_input_stream do |io| send('update_it_codes', io) end
        else
          LogFile.append('oddb/debug', " bsv_xml: Skipping entry.name = " + entry.name.to_s, Time.now)
        end
      end
    end
    def download_file(target_url, save_dir, file_name)
      LogFile.append('oddb/debug', " bsv_xml: getting download_file", Time.now)

      FileUtils.mkdir_p save_dir   # if there is it already, do nothing

      target_file = Mechanize.new.get(target_url)
      save_file = File.join save_dir,
               Date.today.strftime(file_name.gsub(/\./,"-%Y.%m.%d."))
      latest_file = File.join save_dir,
               Date.today.strftime(file_name.gsub(/\./,"-latest."))

      LogFile.append('oddb/debug', " bsv_xml: save_file   = " + save_file.to_s, Time.now)
      LogFile.append('oddb/debug', " bsv_xml: latest_file = " + latest_file.to_s, Time.now)

      # FileUtils.compare_file cannot compare tempfile
      target_file.save_as save_file
      LogFile.append('oddb/debug', " bsv_xml: File.exist?(#{latest_file}) = " + File.exist?(latest_file).inspect.to_s, Time.now)
      if(File.exist?(latest_file))
        LogFile.append('oddb/debug', " bsv_xml: FileUtils.compare_file(#{save_file} #{File.size(save_file)} bytes with #{latest_file} #{File.size(latest_file)} bytes) = " + FileUtils.compare_file(save_file, latest_file).inspect.to_s, Time.now)
      end

      # check and compare the latest file and save
      if(File.exist?(latest_file) && FileUtils.compare_file(save_file, latest_file))
        FileUtils.rm_f(save_file, verbose: true)
        return nil
      else
        FileUtils.cp(save_file, latest_file, verbose: true)
        return save_file
      end
    rescue EOFError
      retries ||= 10
      if retries > 0
        retries -= 1
        sleep 10 - retries
        retry
      else
        if File.exist? save_file
          File.unlink save_file
        end
        raise
      end
    end
    def save_attached_files(file_name, report)
      if file_name and report
        log_dir = File.expand_path("doc/sl_errors/#{Time.now.year}/#{"%02d" % Time.now.month.to_i}", ODDB::PROJECT_ROOT)
        log_file = File.join(log_dir, file_name)
        FileUtils.mkdir_p(log_dir)
        open(log_file, "w") do |out|
          out.print report
        end
      end
    end
    def log_info
      body = report << "\n\n"
      info = super
      parts = [
        [ :duplicate_iksnrs,
          'Duplicate Registrations in SL %d.%m.%Y',
          <<-EOS
Zwei oder mehr "Preparations" haben den selben 5-stelligen Swissmedic-Code
          EOS
        ],
        [ :completed_registrations,
          'Package-Data was completed from SL',
          <<-EOS
die Packungsinformation wurde aus den BAG-XML Daten übernommen weil von Seiten
der Swissmedic zur Zeit keine Packungsinformationen zur Verfügung stehen.
Limitation (falls vorhanden) und weitere Packungs-Infos wurden ebenfalls
übernommen.
          EOS
        ],
        [ :conflicted_registrations,
          'SMeX/SL-Differences (Registrations) %d.%m.%Y',
          'SL hat anderen 5-Stelligen Swissmedic-Code als SMeX' ],
        [ :missing_ikscodes,
          'Missing Swissmedic-Codes in SL %d.%m.%Y',
          'SL hat keinen 8-Stelligen Swissmedic-Code' ],
        [ :missing_ikscodes_oot,
          'Missing Swissmedic-Codes in SL (out of trade) %d.%m.%Y',
          <<-EOS
SL hat keinen 8-Stelligen Swissmedic-Code,
Produkt ist laut RefData ausser Handel
          EOS
        ],
        [ :unknown_packages,
          'Unknown Packages in SL %d.%m.%Y',
          <<-EOS
es gibt im SMeX keine Zeile mit diesem 8-stelligen Swissmedic-Code, und
wir konnten auch keine Automatisierte Zuweisung vornehmen, wir wissen
aber anhand des Pharmacodes, dass die Packung in MedWin vorkommt.
          EOS
        ],
        [ :unknown_packages_oot,
          'Unknown Packages in SL (out of trade) %d.%m.%Y',
          <<-EOS
es gibt im SMeX keine Zeile mit diesem 8-stelligen Swissmedic-Code, und
in MedWin kein Resultat mit dem entsprechenden Pharmacode
          EOS
        ],
      ].collect do |collection, fmt, explain|
        values = @preparations_listener.send(collection).collect do |data|
          report_format data
        end.sort
        name = @@today.strftime fmt
        header = report_format_header(name, values.size)
        body << header << "\n"
        report = [
          header,
          explain,
          values.join("\n\n"),
        ].join("\n")
        ['text/plain', name.gsub(/[\s()\/-]/u, '_') << '.txt', report]
      end
      parts.compact!
      ## combine the last two attachments
      _, _, unknown_pacs = parts.pop
      _, _, unknown_regs = parts.pop
      unknown = unknown_regs << "\n\n" << unknown_pacs
      name = @@today.strftime('Unknown_Products_in_SL_%d.%m.%Y.txt')
      parts.push ['text/plain', name, unknown]
      ## Add bag_xml_swissindex_pharmacode_error.log (error packages from swissindex server)
      sl_errors_dir = File.expand_path("doc/sl_errors/#{Time.now.year}/#{"%02d" % Time.now.month.to_i}", ODDB::PROJECT_ROOT)
      error_file = File.join(sl_errors_dir, 'bag_xml_swissindex_pharmacode_error.log')
      if File.exist?(error_file)
        report = File.read(error_file)
        parts.push ['text/plain', @@today.strftime('Error_Packages_%d.%m.%Y.txt'), report]
      end
      ## Add some general statistics to the body
      packages = @app.packages
      oots, its = packages.partition do |pac| pac.out_of_trade end
      exps, rest = its.partition do |pac| pac.expired? end
      body << <<-EOP
Packungen in der ODDB Total: #{packages.size}
- ausser Handel: #{oots.size}
- inaktive Registration: #{exps.size}
- noch nicht auf MedWin: #{rest.size}
      EOP

      parts.each do |part|
        save_attached_files(part[1], part[2])
        LogFile.append('oddb/debug', " bsv_xml: attached file #{part[1]} is saved", Time.now)
      end
      info.update(:parts => parts, :report => body)
      info
    end
    def log_info_bsv
      body = report_bsv << "\n\n"
      info = { :recipients => recipients.concat(BSV_RECIPIENTS)}
      parts = [
        [ :missing_ikscodes,
          'Missing Swissmedic-Codes in SL %d.%m.%Y',
           'SL hat keinen 8-Stelligen Swissmedic-Code' ],
        [ :missing_ikscodes_oot,
          'Missing Swissmedic-Codes in SL (out of trade) %d.%m.%Y',
          <<-EOS
SL hat keinen 8-Stelligen Swissmedic-Code,
Produkt ist laut RefData ausser Handel
          EOS
        ],
        [ :unknown_packages,
          'Unknown Packages in SL %d.%m.%Y',
          <<-EOS
es gibt im SMeX keine Zeile mit diesem 8-stelligen Swissmedic-Code, und
wir konnten auch keine Automatisierte Zuweisung vornehmen, wir wissen
aber anhand des Pharmacodes, dass die Packung in MedWin vorkommt.
          EOS
        ],
        [ :unknown_registrations,
          'Unknown Registrations in SL %d.%m.%Y',
          'es gibt im SMeX keine Zeile mit diesem 5-stelligen Swissmedic-Code' ],
        [ :unknown_packages_oot,
          'Unknown Packages in SL (out of trade) %d.%m.%Y',
          <<-EOS
es gibt im SMeX keine Zeile mit diesem 8-stelligen Swissmedic-Code, und
in MedWin kein Resultat mit dem entsprechenden Pharmacode
          EOS
        ],
        [ :duplicate_iksnrs,
          'Duplicate Registrations in SL %d.%m.%Y',
          <<-EOS
Zwei oder mehr "Preparations" haben den selben 5-stelligen Swissmedic-Code
          EOS
        ],
      ].collect do |collection, fmt, explain|
        values = @preparations_listener.send(collection).collect do |data|
          report_format data
        end.sort
        name = @@today.strftime fmt
        header = report_format_header(name, values.size)
        body << header << "\n"
        report = [
          header,
          explain,
          values.join("\n\n"),
        ].join("\n")
        file_name = name.gsub(/[\s()\/-]/u, '_') << '.txt'
        save_attached_files(file_name, report)
        LogFile.append('oddb/debug', " bsv_xml: attached file #{file_name} is saved", Time.now)
        ['text/plain', file_name, report]
      end
      info.update(:parts => parts, :report => body)
      info
    end
    def report
      [ 'Created SL-Entries', 'Updated SL-Entries', 'Deleted SL-Entries',
        'Created Limitation-Texts', 'Updated Limitation-Texts',
        'Deleted Limitation-Texts'
      ].collect do |title|
        method = title.downcase.gsub(/[ -]/u, '_')
        report_format_header title, @preparations_listener.send(method)
      end.join("\n")
    end
    def report_bsv
      numbers = [
        :conflicted_registrations, :missing_ikscodes, :missing_ikscodes_oot,
        :unknown_packages,  :unknown_registrations, :unknown_packages_oot,
        :duplicate_iksnrs ].collect do |key|
        @preparations_listener.send(key).size
      end
      sprintf <<-EOS, *numbers
#{Util.get_mailing_list_anrede(BSV_RECIPIENTS).join("\n")}

Am #{@@today.strftime('%d.%m.%Y')} haben wir Ihren aktuellen SL-Export (XML)
wieder überprüft. Dabei ist uns folgendes aufgefallen:

1. Bei %i Produkten hat die SL einen anderen 5-Stelligen Swissmedic-Code als
Swissmedic Excel.

2. Bei %i Produkten hat die SL keinen 8-Stelligen Swissmedic-Code. Ev.
befinden sich dort auch Produkte darunter, welche nicht bei der Swissmedic
registriert werden müssen. Es hat aber sicherlich auch Produkte darunter,
welche einen Swissmedic-Code haben sollten.

3. Bei %i Produkten hat die SL keinen 8-Stelligen Swissmedic-Code, die
Produkte sind laut RefData ausser Handel. Der Swissmedic Code sollte in der SL
gemäss SR 830.1, Art. 24, Abs. 1 trotzdem korrekt vorhanden sein. Die
Krankenkasse muss bis 5 Jahre in der Vergangenheit abrechnen können.

4. Bei %i Produkten gibt es im Swissmedic-Excel keine Zeile mit diesem
8-stelligen Swissmedic-Code, die Packung kommt aber bei Refdata.ch vor.

5. Bei %i Produkten gibt es im Swissmedic-Excel keine Zeile mit diesem
5-stelligen Swissmedic-Code. Die Produkte sind aber sicherlich bei der
Swissmedic registriert.

6. Bei %i Produkten gibt es im Swissmedic-Excel keine Zeile mit diesem
8-stelligen Swissmedic-Code. Die Produkte sind wohl ausser Handel aber sicher
noch bei der Swissmedic registriert. Der Swissmedic Code sollte in der SL
gemäss SR 830.1, Art. 24, Abs. 1 trotzdem korrekt vorhanden sein.

7. %i 5-stellige Swissmedic-Nummern kommen im BAG-XML-Export doppelt vor.
Siehe auch Attachment: #{@@today.strftime('Duplicate_Registrations_in_SL_%d.%m.%Y.txt')}

Um die obigen Beobachtungen kontrollieren zu können, speichern Sie bitte die
Attachments auf Ihrem Schreibtisch.

Sie können die Attachments mit dem Windows-Editor öffnen. Sie finden den
Windows-Editor unter: Startmenu > Programme > Editor

Starten Sie den Editor und gehen Sie dann auf: Datei > Öffnen

Wählen sie obige Attachments von Ihrem Schreibtisch aus und schon können Sie
die Attachments anschauen.

Danke für Ihr Feedback.

Mit freundlichen Grüssen
Zeno Davatz
+41 43 540 05 50


Attachments:
      EOS
    end
    def report_format_header name, size
      sprintf "%-58s%5i", name, size
    end
    def report_format hash
      [
        :name_base,
        :name_descr,
        :atc_class,
        :generic_type,
        :deductible,
        :swissmedic_no5_oddb,
        :swissmedic_no8_oddb,
        :swissmedic_no5_bag,
        :swissmedic_no8_bag,
      ].collect do |key|
        label = key.to_s.capitalize.gsub('_', '-') << ':'
        sprintf "%-20s %s", label, hash[key]
      end.join("\n")
    end
    def update_generics io
      listener = GenericsListener.new @app
      REXML::Document.parse_stream io, listener
    end
    def update_g_l__diff__s_b io
      # do nothing by masa 20110704
    end
    def update_it_codes io
      listener = ItCodesListener.new @app
      as_utf_8 = StringIO.new(io.read.force_encoding('utf-8'))
      REXML::Document.parse_stream as_utf_8, listener
    end
    def update_preparations io, opts={}
      @preparations_listener = PreparationsListener.new @app, opts
      as_utf_8 = StringIO.new(io.read.force_encoding('utf-8'))
      REXML::Document.parse_stream as_utf_8, @preparations_listener
      @change_flags = @preparations_listener.change_flags
    end
  end
end


