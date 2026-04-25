#!/usr/bin/env ruby

# ODDB::BsvFhirPlugin -- oddb.org -- 2026
# FHIR NDJSON variant of BsvXmlPlugin
# Processes the BAG SL export in FHIR NDJSON format from
# https://epl.bag.admin.ch/static/fhir/foph-sl-export-*.ndjson
# and maps it to the same internal data structures as BsvXmlPlugin.

require "config"
require "date"
require "delegate"
require "drb"
require "fileutils"
require "json"
require "model/text"
require "net/http"
require "uri"
require "plugin/bsv_xml"
require "util/persistence"
require "util/today"
require "util/mail"
require "util/logfile"

module ODDB
  class BsvFhirPlugin < BsvXmlPlugin
    FHIR_BASE_URL = "https://epl.bag.admin.ch/static/fhir/".freeze
    FHIR_LANGUAGES = [:de, :fr, :it].freeze

    # FHIR code mappings to existing XML equivalents
    PRODUCT_TYPE_MAP = {
      "756001003001" => "G",  # Generic product     -> OrgGenCode "G"
      "756001003002" => "O",  # Originator product   -> OrgGenCode "O"
      "756001003003" => "O",  # Reference product    -> OrgGenCode "O"
      "756001003004" => "G",  # Biosimilar           -> OrgGenCode "G"
      "756001003005" => nil,  # Complementary med    -> no mapping
      "756001003009" => "G"   # Co-marketing         -> OrgGenCode "G"
    }.freeze

    SWISSMEDIC_CATEGORY_MAP = {
      "756005022001" => "A",  # Prescription single dispensation (A)
      "756005022003" => "B",  # Prescription (B)
      "756005022008" => "D"   # Dispensation after consultation (D)
    }.freeze

    # FHIR price change type codes -> XML PriceChangeTypeCode equivalents
    PRICE_CHANGE_TYPE_MAP = {
      "756002006001" => "ERP",    # External reference price
      "756002006003" => "FREIWI",  # Voluntary price reduction
      "756002006005" => "MWST",    # VAT-change
      "756002006006" => "NORMAL",  # Normal price mutation
      "756002006007" => "TUR3",    # Triennal review
      "756002006008" => "PATENT",  # Patent expiry
      "756002006009" => "PE",      # Price increase
      "756002006010" => "ERSTAUF", # First listing
      "756002006011" => "EINF_VM", # Introduction uniform wholesale margin
      "756002006012" => "VM"       # Wholesale margin
    }.freeze

    REIMBURSEMENT_STATUS_MAP = {
      "756001021001" => true  # Reimbursed
    }.freeze

    LISTING_STATUS_MAP = {
      "756001002001" => "0"  # Listed -> StatusTypeCodeSl "0" (Initialzustand/active)
    }.freeze

    LANGUAGE_MAP = {
      "de-CH" => :de,
      "fr-CH" => :fr,
      "it-CH" => :it
    }.freeze

    def initialize(*args)
      @latest = File.join(ODDB::WORK_DIR, "ndjson", "foph-sl-export-latest-de.ndjson")
      super
    end

    # Main entry point - called by Updater#update_bsv_fhir
    def update
      LogFile.append("oddb/debug", " bsv_fhir: getting BsvFhirPlugin.update", Time.now)

      save_dir = File.join(ODDB::WORK_DIR, "ndjson")
      paths = {}
      changed = false
      FHIR_LANGUAGES.each do |lang|
        url = "#{FHIR_BASE_URL}foph-sl-export-latest-#{lang}.ndjson"
        file_name = "foph-sl-export-latest-#{lang}.ndjson"
        LogFile.append("oddb/debug", " bsv_fhir: target_url = #{url}", Time.now)
        path = download_ndjson(url, save_dir, file_name)
        if path
          changed = true
          paths[lang] = path
        else
          # download_ndjson returns nil when the file is unchanged; reuse the cached copy
          cached = File.join(save_dir, file_name)
          paths[lang] = cached if File.exist?(cached)
        end
      end

      LogFile.append("oddb/debug", " bsv_fhir: paths = #{paths.inspect}", Time.now)

      unless paths[:de]
        LogFile.append("oddb/debug", " bsv_fhir: no German FHIR file available, aborting", Time.now)
        return nil
      end

      @fhir_url = "#{FHIR_BASE_URL}foph-sl-export-latest-de.ndjson"

      if changed
        _update(paths)
      end
      changed ? paths[:de] : nil
    end

    def _update(paths = @latest)
      paths = {de: paths} if paths.is_a?(String)
      paths = paths.transform_keys(&:to_sym)

      preload_translation_bundles(paths)

      LogFile.append("oddb/debug", " bsv_fhir: update_preparations_from_fhir", Time.now)
      File.open(paths[:de], "r:utf-8") do |io|
        update_preparations_from_fhir(io)
      end
    ensure
      @translation_bundles = nil
    end

    # Parse the FHIR NDJSON and feed the PreparationsListener-compatible data
    # into the same update logic as the XML parser
    def update_preparations_from_fhir(io, opts = {})
      @preparations_listener = safe_new_preparations_listener(@app, opts)
      origin = @@today.strftime("#{@fhir_url} (%d.%m.%Y)")

      line_count = 0
      io.each_line do |line|
        line.strip!
        next if line.empty?
        line_count += 1

        begin
          bundle = JSON.parse(line)
        rescue JSON::ParserError => e
          LogFile.debug("bsv_fhir: JSON parse error on line #{line_count}: #{e.message}")
          next
        end

        next unless bundle["resourceType"] == "Bundle"

        process_bundle(bundle, origin)
      end

      # After processing all bundles, delete SL entries for packages
      # that were not visited (same as XML "Preparations" tag_end)
      finalize_sl_entries

      LogFile.debug("Finished parsing FHIR NDJSON, processed #{line_count} bundles, " \
                     "visited #{@preparations_listener.nr_visited_preparations} preparations")
      @change_flags = @preparations_listener.change_flags
    end

    private

    # Download `target_url` to <save_dir>/<file_name>, replacing the existing
    # file only if the contents changed. Returns the save path when the file
    # was updated, nil if it was unchanged or the download failed.
    def download_ndjson(target_url, save_dir, file_name)
      LogFile.append("oddb/debug", " bsv_fhir: getting download_ndjson", Time.now)

      FileUtils.mkdir_p(save_dir)

      save_file = File.join(save_dir, file_name)
      tmp_file = "#{save_file}.tmp"

      LogFile.append("oddb/debug", " bsv_fhir: save_file = #{save_file}", Time.now)

      uri = URI.parse(target_url)
      response = Net::HTTP.get_response(uri)
      unless response.is_a?(Net::HTTPSuccess)
        LogFile.append("oddb/debug", " bsv_fhir: HTTP #{response.code} for #{target_url}", Time.now)
        return nil
      end

      File.open(tmp_file, "wb") { |f| f.write(response.body) }
      LogFile.append("oddb/debug", " bsv_fhir: downloaded #{File.size(tmp_file)} bytes to #{tmp_file}", Time.now)

      if File.exist?(save_file) && FileUtils.compare_file(tmp_file, save_file)
        FileUtils.rm_f(tmp_file)
        nil
      else
        FileUtils.mv(tmp_file, save_file)
        save_file
      end
    rescue EOFError, Errno::ECONNRESET, Net::ReadTimeout => e
      retries ||= 10
      if retries > 0
        retries -= 1
        sleep(10 - retries)
        retry
      else
        FileUtils.rm_f(tmp_file) if defined?(tmp_file) && tmp_file && File.exist?(tmp_file)
        raise
      end
    end

    # Process one FHIR Bundle (= one line in the NDJSON = one Preparation)
    def process_bundle(bundle, origin)
      resources = index_resources_by_type(bundle)
      return if resources.nil?

      # Extract the MedicinalProductDefinition (= Preparation level)
      med_products = resources["MedicinalProductDefinition"] || {}
      return if med_products.empty?

      med_product = med_products.values.first

      # Extract Preparation-level data
      names = extract_names(med_product)
      atc_code = extract_atc_code(med_product)
      org_gen_code = extract_org_gen_code(med_product)
      substances = extract_substances(resources["Ingredient"] || {})

      # Find the Marketing Authorisation for the product -> SwissmedicNo5
      reg_auths = resources["RegulatedAuthorization"] || {}
      iksnr = extract_iksnr_from_reg_auths(reg_auths)

      return unless iksnr && iksnr != "00000"

      # Per-language NDJSON files contain only one language of free-text content
      # per bundle (limitation texts, descriptions). Look up the matching FR/IT
      # bundles by SwissmedicNo8 and merge translated product names into `names`.
      bundle_no8s = extract_swissmedic_no8s(resources)
      merge_translation_names(names, bundle_no8s)

      # Find registration
      registration = @app.registration(iksnr)

      # Process Packs
      packaged_products = resources["PackagedProductDefinition"] || {}

      # Build a lookup: PackagedProductDefinition ID -> its RegulatedAuthorizations
      pack_auths = {}  # ppd_id -> { marketing: RA, reimbursement: RA }
      reg_auths.values.each do |ra|
        subjects = ra["subject"] || []
        subjects.each do |subj|
          ref = subj["reference"] || ""
          if ref.include?("PackagedProductDefinition/")
            ppd_id = ref.split("PackagedProductDefinition/").last
            pack_auths[ppd_id] ||= {}
            if is_marketing_auth?(ra)
              pack_auths[ppd_id][:marketing] = ra
            elsif is_reimbursement_sl?(ra)
              pack_auths[ppd_id][:reimbursement] = ra
            end
          end
        end
      end

      @preparations_listener.instance_variable_set(:@nr_visited_preparations,
        @preparations_listener.nr_visited_preparations + 1)

      # Simulate the PreparationsListener tag_start/tag_end for "Preparation"
      sl_entries = {}
      lim_texts = {}
      report_data = {}
      reg_data = {}
      deferred_packages = []
      sequence = nil
      duplicate_iksnr = false

      report_data[:name_base] = names[:de]
      report_data[:swissmedic_no5_bag] = iksnr

      # Check for duplicate iksnrs (simplified version)
      visited_iksnrs = @preparations_listener.instance_variable_get(:@visited_iksnrs) || {}
      atc_name = visited_iksnrs[iksnr]
      if atc_name.nil? || atc_name[0] == atc_code || atc_name[0].to_s.empty? || atc_code.to_s.empty?
        visited_iksnrs[iksnr] = [atc_code, names]
      else
        duplicate_iksnr = true
        @preparations_listener.duplicate_iksnrs.push(report_data)
      end
      @preparations_listener.instance_variable_set(:@visited_iksnrs, visited_iksnrs)

      if registration && registration.packages.empty?
        completed = @preparations_listener.instance_variable_get(:@completed_registrations) || {}
        completed[iksnr] = report_data
        @preparations_listener.instance_variable_set(:@completed_registrations, completed)
      end

      # OrgGenCode / generic_type
      if org_gen_code
        gtype = PreparationsListener::GENERIC_TYPES[org_gen_code]
        unless registration && registration.keep_generic_type
          reg_data[:generic_type] = gtype || :unknown
        end
      end

      # Index therapeuticus (IT codes) from MedicinalProductDefinition classification
      it_codes = extract_it_codes(med_product)
      if it_codes && !it_codes.empty?
        # Use the most specific (longest) IT code, like the XML parser does
        itcode = it_codes.max_by { |c| c[:code].length }
        reg_data[:index_therapeuticus] = itcode[:code]
      end

      # Process each PackagedProductDefinition
      packaged_products.each_value do |ppd|
        ppd_id = ppd["id"]
        auths = pack_auths[ppd_id] || {}

        # SwissmedicNo8 from Marketing Authorisation identifier
        marketing_auth = auths[:marketing]
        swissmedic_no8 = nil
        ikscd = nil
        if marketing_auth
          swissmedic_no8 = extract_identifier(marketing_auth)
        end

        if swissmedic_no8
          report_data[:swissmedic_no8_bag] = swissmedic_no8
          ikscd = "%03i" % swissmedic_no8[-3, 3].to_i
        end

        # GTIN from packaging identifier
        gtin = extract_gtin(ppd)

        # SwissmedicCategory from legalStatusOfSupply
        ikscat = extract_swissmedic_category(ppd)

        # Description
        description = ppd["description"]

        # Find or create the pack
        pack = nil
        if registration && swissmedic_no8
          pack = @app.package_by_ikskey(sprintf("%08i", swissmedic_no8.to_i))
          if pack && !pack.out_of_trade
            report_data[:swissmedic_no5_oddb] = registration.iksnr
          end
        end

        out_of_trade = pack ? pack.out_of_trade : false

        # Build pack data
        data = {}
        data[:ikscat] = ikscat if ikscat

        # SL generic type
        if org_gen_code
          sl_generic_type = PreparationsListener::GENERIC_TYPES[org_gen_code]
          data[:sl_generic_type] = sl_generic_type if sl_generic_type
        end

        # Reimbursement SL data
        reimbursement = auths[:reimbursement]
        sl_data = {limitation_points: nil, limitation: nil}
        lim_data = {}

        if reimbursement
          sl_ext = extract_reimbursement_extension(reimbursement)
          if sl_ext
            # BagDossierNo
            dossier_no = sl_ext[:foph_dossier_number]
            sl_data[:bsv_dossier] = dossier_no if dossier_no

            # IntegrationDate / firstListingDate
            if sl_ext[:first_listing_date]
              sl_data[:introduction_date] = parse_date(sl_ext[:first_listing_date])
            end

            # ValidFromDate from listing period start
            if sl_ext[:listing_period_start]
              valid_from = parse_date(sl_ext[:listing_period_start])
              sl_data[:valid_from] = valid_from if valid_from
            end

            # StatusTypeCodeSl - FHIR listing status
            listing_code = sl_ext[:listing_status_code]
            if listing_code
              status_code = LISTING_STATUS_MAP[listing_code] || "0"
              sl_data[:status] = status_code
            end

            # costShare -> deductible (FlagSB20 equivalent)
            # costShare 10 = normal 10% deductible = deductible_g (FlagSB20=N)
            # costShare 40 = higher 40% deductible = deductible_o (FlagSB20=Y)
            cost_share = sl_ext[:cost_share]
            if cost_share
              data[:deductible] = (cost_share.to_i > 10) ? :deductible_o : :deductible_g
            end

            # expiryDate -> valid_until
            if sl_ext[:expiry_date]
              sl_data[:valid_until] = parse_date(sl_ext[:expiry_date])
            end
          end

          # Limitations from indication[].extension[regulatedAuthorization-limitation]
          lim_data = extract_limitation_data(reimbursement, names, it_codes, :de)
          merge_translation_limitations(lim_data, swissmedic_no8, names, it_codes)
          if !lim_data.empty?
            sl_data[:limitation] = true
          end

          # Prices
          prices = extract_prices(reimbursement)

          price_exfactory = nil
          price_public = nil
          pexf_change_code = nil
          ppub_change_code = nil

          prices.each do |price_info|
            money = Util::Money.new(price_info[:value], price_info[:type], "CH")
            money.origin = origin
            money.authority = :sl
            money.mutation_code = price_info[:change_type_code]
            money.valid_from = price_info[:change_date] ? parse_time(price_info[:change_date]) : nil

            if price_info[:type] == :exfactory
              price_exfactory = money
              pexf_change_code = price_info[:change_type_code]
            elsif price_info[:type] == :public
              price_public = money
              ppub_change_code = price_info[:change_type_code]
            end
          end

          # FlagSB20 / deductible - not present in FHIR, keep existing value
          # FlagNarcosis - not present in FHIR, keep existing value

          # Update the pack (same logic as XML PreparationsListener tag_end "Pack")
          if pack && !duplicate_iksnr
            data.delete(:ikscat) if pack.ikscat
            data.delete(:narcotic)  # comes from Swissmedic, not BAG

            if price_exfactory
              if !price_exfactory.to_s.eql?(pack.price_exfactory.to_s) ||
                  !pexf_change_code.eql?(pack.price_exfactory.mutation_code)
                LogFile.debug("#{iksnr} #{ikscd}: set price_exfactory #{pack.price_exfactory} -> #{price_exfactory}")
                pack.price_exfactory = price_exfactory
                pack.price_exfactory.mutation_code = pexf_change_code
                pack.price_exfactory.valid_from = price_exfactory.valid_from
              end
            end

            if price_public
              if !price_public.to_s.eql?(pack.price_public.to_s) ||
                  !ppub_change_code.eql?(pack.price_public.mutation_code)
                LogFile.debug("#{iksnr} #{ikscd}: set price_public #{pack.price_public} -> #{price_public}")
                pack.price_public = price_public
                pack.price_public.valid_from = price_public.valid_from
                pack.price_public.mutation_code = ppub_change_code
              end
            end

            if data[:deductible]
              pack.deductible.eql?(data[:deductible]) ? data.delete(:deductible) : pack.deductible = data[:deductible]
            end
            if data[:sl_generic_type]
              pack.sl_generic_type.eql?(data[:sl_generic_type]) ? data.delete(:sl_generic_type) : pack.sl_generic_type = data[:sl_generic_type]
            end

            if data.keys.size > 0
              @app.update(pack.pointer, data, :bag)
            end

            sl_entries[pack.pointer] = sl_data
            lim_texts[pack.pointer] = lim_data

            # fix_flags_with_rss_logic equivalent
            fix_flags_with_rss_logic_for(pack, price_public, iksnr)
          elsif pack.nil? && registration
            if !out_of_trade
              if completed_regs = @preparations_listener.instance_variable_get(:@completed_registrations)
                if completed_regs[iksnr]
                  deferred_packages.push({
                    ikscd: ikscd,
                    sequence: {},
                    package: data,
                    sl_entry: sl_data,
                    lim_text: lim_data,
                    size: description || ""
                  })
                  next
                end
              end
              report_data[:swissmedic_no5_oddb] = registration.iksnr if registration
              @preparations_listener.unknown_packages.push(report_data.dup)
            else
              report_data[:swissmedic_no5_oddb] = registration.iksnr if registration
              @preparations_listener.unknown_packages_oot.push(report_data.dup)
            end
          elsif pack.nil? && registration.nil?
            # unknown registration handled below
          end
        end

        if pack
          sequence = pack.sequence
          pack.odba_store
        end
      end

      # End of Preparation processing (same as XML tag_end "Preparation")
      seq = sequence || identify_sequence_for(registration, names, substances)

      if !deferred_packages.empty? && seq
        deferred_packages.each do |info|
          ptr = seq.pointer + [:package, info[:ikscd]]
          @app.update(seq.pointer, info[:sequence])
          unless seq.package(info[:ikscd])
            seq.create_package(info[:ikscd])
          end
          @app.update(ptr.creator, info[:package])
          pptr = ptr + [:part]
          size = (info[:size] || "").sub(/(^| )[^\d.,]+(?= )/, "")
          @app.update(pptr.creator, size: size, composition: seq.compositions.first)
          sl_entries[ptr] = info[:sl_entry]
          lim_texts[ptr] = info[:lim_text]
        end
      end

      if seq
        add_bag_composition_to_sequence_for(seq, substances)
      end

      # Update SL entries (same logic as XML)
      known_packages = @preparations_listener.instance_variable_get(:@known_packages) || {}
      sl_entries.each do |pac_ptr, sl_data|
        pac = pac_ptr.resolve(@app)
        known_packages.delete(pac_ptr)
        next if pac.nil?
        if pac.is_a?(ODDB::Package)
          pointer = pac_ptr + :sl_entry
          if sl_data.empty?
            if pac.sl_entry
              increment_counter(:deleted_sl_entries)
              @app.delete(pointer)
            end
          else
            if pac.sl_entry
              increment_counter(:updated_sl_entries)
            else
              increment_counter(:created_sl_entries)
            end
            if (ld = lim_texts[pac_ptr]) && !ld.empty?
              sl_data[:limitation] = true
            end
            @app.update(pointer.creator, sl_data, :bag)
          end
        end
      rescue ODBA::OdbaError, ODDB::Persistence::InvalidPathError, NoMethodError
        # skip
      end

      # Update limitation texts (same logic as XML)
      lim_texts.each do |pac_ptr, lim_data|
        pac = pac_ptr.resolve(@app)
        next if pac.nil?
        if pac.is_a?(ODDB::Package)
          sl_entry = pac.sl_entry
          next if sl_entry.nil?
          sl_ptr = sl_entry.pointer
          sl_ptr ||= pac.pointer + [:sl_entry]
          txt_ptr = sl_ptr + :limitation_text
          if lim_data.nil? || lim_data.empty?
            if sl_entry.limitation_text
              increment_counter(:deleted_limitation_texts)
              @app.delete(txt_ptr)
            end
          else
            if sl_entry.limitation_text
              increment_counter(:updated_limitation_texts)
            else
              increment_counter(:created_limitation_texts)
            end
            begin
              if sl_entry.limitation_text || txt_ptr.resolve(@app)
                @app.delete(txt_ptr)
              end
            rescue ODDB::Persistence::UninitializedPathError,
                   ODDB::Persistence::InvalidPathError
              # skip
            end
            txt_ptr = sl_ptr + :limitation_text
            @app.update(txt_ptr.creator, lim_data, :bag)
          end
        end
      rescue TypeError, ODBA::OdbaError, ODDB::Persistence::InvalidPathError, NoMethodError
        # skip
      end

      # Update registration data
      if registration
        unless registration.index_therapeuticus.eql?(reg_data[:index_therapeuticus])
          @app.update(registration.pointer, reg_data, :bag)
        end
      else
        @preparations_listener.unknown_registrations.push(report_data)
      end
    end

    # Finalize: delete SL entries for packages not seen in the FHIR data
    def finalize_sl_entries
      known_packages = @preparations_listener.instance_variable_get(:@known_packages) || {}
      known_packages.each do |pointer, data|
        increment_counter(:deleted_sl_entries)
        @preparations_listener.flag_change(pointer, :sl_entry_delete)
        sl_ptr = pointer + :sl_entry
        begin
          @app.delete(sl_ptr)
        rescue ODBA::OdbaError
          LogFile.debug("bsv_fhir: unable to delete pointer #{pointer} data #{data}")
        end
      end
    end

    # ---- FHIR Resource extraction helpers ----

    # PreparationsListener#initialize iterates over all packages in the DB
    # to build @known_packages. Some ODBA stubs may resolve to corrupted
    # objects (e.g. PatinfoDocument instead of Package), causing NoMethodError.
    # This wrapper patches each_package to be resilient.
    def safe_new_preparations_listener(app, opts = {})
      # Create a delegator that wraps each_package with per-item rescue
      safe_app = SimpleDelegator.new(app)
      safe_app.define_singleton_method(:each_package) do |&block|
        app.each_package do |pac|
          begin
            block.call(pac)
          rescue NoMethodError, StandardError => e
            ODDB::LogFile.debug("bsv_fhir: skipping corrupted package #{pac.respond_to?(:odba_id) ? pac.odba_id : "?"}: #{e.message}")
          end
        end
      end
      PreparationsListener.new(safe_app, opts)
    end

    # ---- FHIR Resource extraction helpers (cont.) ----

    # Index a FHIR Bundle's entry resources by type and id.
    # Returns nil if the bundle is empty.
    def index_resources_by_type(bundle)
      entries = bundle["entry"] || []
      return nil if entries.empty?
      resources = {}
      entries.each do |entry|
        res = entry["resource"]
        next unless res
        rtype = res["resourceType"]
        rid = res["id"]
        resources[rtype] ||= {}
        resources[rtype][rid] = res
      end
      resources
    end

    def extract_iksnr_from_reg_auths(reg_auths)
      product_auth = reg_auths.values.find do |ra|
        is_marketing_auth?(ra) && (ra["subject"] || []).any? { |s| s["reference"].to_s.include?("MedicinalProductDefinition/") && !s["reference"].to_s.include?("PackagedProductDefinition/") }
      end
      return nil unless product_auth
      iksnr = extract_identifier(product_auth)
      iksnr ? "%05i" % iksnr.to_i : nil
    end

    # Pre-load the FR and IT NDJSON files into a hash keyed by SwissmedicNo8 so
    # `process_bundle` can look up matching translated bundles when iterating
    # the de file. Each bundle is indexed under every SwissmedicNo8 it contains
    # because a single iksnr can span many bundles (one per dose variant).
    # The de path is skipped — its bundles are streamed directly.
    def preload_translation_bundles(paths)
      @translation_bundles = {}
      FHIR_LANGUAGES.each do |lang|
        next if lang == :de
        path = paths[lang]
        next unless path && File.exist?(path)
        index = {}
        bundle_count = 0
        File.open(path, "r:utf-8") do |io|
          io.each_line do |line|
            line.strip!
            next if line.empty?
            bundle = begin
              JSON.parse(line)
            rescue JSON::ParserError
              next
            end
            resources = index_resources_by_type(bundle)
            next unless resources
            no8s = extract_swissmedic_no8s(resources)
            next if no8s.empty?
            no8s.each { |no8| index[no8] = bundle }
            bundle_count += 1
          end
        end
        @translation_bundles[lang] = index
        LogFile.append("oddb/debug", " bsv_fhir: pre-loaded #{bundle_count} #{lang} bundles (#{index.size} no8 keys)", Time.now)
      end
    end

    def extract_swissmedic_no8s(resources)
      reg_auths = resources["RegulatedAuthorization"] || {}
      no8s = []
      reg_auths.values.each do |ra|
        next unless is_marketing_auth?(ra)
        next unless (ra["subject"] || []).any? { |s| s["reference"].to_s.include?("PackagedProductDefinition/") }
        v = extract_identifier(ra)
        no8s << v if v
      end
      no8s
    end

    # Merge translated product names from FR/IT bundles into `names`. Uses the
    # first available SwissmedicNo8 from the de bundle as lookup key.
    def merge_translation_names(names, no8_lookup_keys)
      return unless @translation_bundles
      return if no8_lookup_keys.empty?
      FHIR_LANGUAGES.each do |lang|
        next if lang == :de
        index = @translation_bundles[lang] or next
        trans_bundle = no8_lookup_keys.lazy.map { |k| index[k] }.find { |b| b }
        next unless trans_bundle
        trans_resources = index_resources_by_type(trans_bundle)
        next unless trans_resources
        trans_med = (trans_resources["MedicinalProductDefinition"] || {}).values.first
        next unless trans_med
        trans_names = extract_names(trans_med)
        translated = trans_names[lang] || trans_names[:de] || trans_names.values.compact.first
        names[lang] = translated if translated
      end
    end

    # Merge translated limitation chapters from FR/IT bundles into `lim_data`
    # by looking up the bundle that contains a matching SwissmedicNo8.
    def merge_translation_limitations(lim_data, swissmedic_no8, names, it_codes)
      return unless @translation_bundles
      return unless swissmedic_no8
      FHIR_LANGUAGES.each do |lang|
        next if lang == :de
        trans_bundle = @translation_bundles.dig(lang, swissmedic_no8)
        next unless trans_bundle
        trans_resources = index_resources_by_type(trans_bundle)
        next unless trans_resources
        trans_reimbursement = find_reimbursement_for_pack(trans_resources, swissmedic_no8)
        next unless trans_reimbursement
        extract_limitation_data(trans_reimbursement, names, it_codes, lang, lim_data)
      end
    end

    # Find the reimbursement-SL RegulatedAuthorization in `resources` whose
    # subject references the PackagedProductDefinition with the given
    # SwissmedicNo8 (looked up via its marketing authorization).
    def find_reimbursement_for_pack(resources, swissmedic_no8)
      reg_auths = resources["RegulatedAuthorization"] || {}
      packaged_products = resources["PackagedProductDefinition"] || {}

      ppd_id = nil
      packaged_products.each_key do |id|
        marketing = reg_auths.values.find do |ra|
          is_marketing_auth?(ra) && (ra["subject"] || []).any? { |s| s["reference"].to_s.include?("PackagedProductDefinition/#{id}") }
        end
        if marketing && extract_identifier(marketing) == swissmedic_no8
          ppd_id = id
          break
        end
      end
      return nil unless ppd_id

      reg_auths.values.find do |ra|
        is_reimbursement_sl?(ra) && (ra["subject"] || []).any? { |s| s["reference"].to_s.include?("PackagedProductDefinition/#{ppd_id}") }
      end
    end

    def extract_names(med_product)
      names = {}
      (med_product["name"] || []).each do |name_entry|
        product_name = name_entry["productName"]
        (name_entry["usage"] || []).each do |usage|
          lang_code = usage.dig("language", "coding", 0, "code")
          lang_key = LANGUAGE_MAP[lang_code]
          names[lang_key] = product_name if lang_key
        end
      end
      names
    end

    def extract_atc_code(med_product)
      (med_product["classification"] || []).each do |cls|
        (cls["coding"] || []).each do |coding|
          if coding["system"] == "http://www.whocc.no/atc"
            return coding["code"]
          end
        end
      end
      nil
    end

    def extract_org_gen_code(med_product)
      (med_product["classification"] || []).each do |cls|
        (cls["coding"] || []).each do |coding|
          if coding["system"]&.include?("foph-product-type")
            return PRODUCT_TYPE_MAP[coding["code"]]
          end
        end
      end
      nil
    end

    def extract_it_codes(med_product)
      codes = []
      (med_product["classification"] || []).each do |cls|
        (cls["coding"] || []).each do |coding|
          if coding["system"]&.include?("index-therapeuticus")
            codes << {code: coding["code"], display: coding["display"]}
          end
        end
      end
      codes
    end

    # Extract limitation data from RegulatedAuthorization indication extensions.
    # Builds a Text::Chapter for the given lang_key (default :de), matching the
    # XML plugin's lim_data format: { de: Text::Chapter, fr: Text::Chapter, it: Text::Chapter }.
    # Per-language NDJSON files contain only one language of text per bundle, so
    # callers pass the language matching the source file. Pass an existing
    # `lim_data` hash to merge additional languages into.
    def extract_limitation_data(regulated_auth, names, it_codes, lang_key = :de, lim_data = {})
      indications = regulated_auth["indication"] || []
      return lim_data if indications.empty?

      indications.each do |ind|
        (ind["extension"] || []).each do |ext|
          next unless ext["url"]&.include?("regulatedAuthorization-limitation")

          limitation_text = nil
          indication_code = nil

          (ext["extension"] || []).each do |sub_ext|
            case sub_ext["url"]
            when "limitationText"
              limitation_text = sub_ext["valueString"]
            when "indicationCode"
              indication_code = sub_ext["valueString"]
            end
          end

          next unless limitation_text && !limitation_text.empty?

          subheading = nil
          if indication_code && it_codes && !it_codes.empty?
            it_desc = it_codes.max_by { |c| c[:code].length }
            subheading = [indication_code, it_desc[:display]].compact.join(": ")
          elsif indication_code
            subheading = indication_code
          end

          chp = lim_data[lang_key] ||= Text::Chapter.new
          sec = chp.next_section
          if subheading
            sec.subheading += subheading.to_s + "\n"
          end
          limitation_text.each_line do |text_line|
            par = sec.next_paragraph
            par << text_line.chomp
          end
          chp.clean!
        end
      end
      lim_data
    end

    def extract_substances(ingredients_hash)
      ingredients_hash.values.select { |ing|
        role = ing.dig("role", "coding", 0, "code")
        role == "756005051001"  # Active
      }.map { |ing|
        substance = ing["substance"] || {}
        name = substance.dig("code", "concept", "text") || ""
        strength = (substance["strength"] || []).first || {}
        qty = strength.dig("presentationQuantity", "value")
        unit = strength.dig("presentationQuantity", "unit")
        # Handle text presentations like "340-660"
        if qty.nil? && strength["textPresentation"]
          qty = strength["textPresentation"].to_f
        end
        {lt: name, dose: qty.to_f, unit: unit.to_s}
      }
    end

    def extract_identifier(regulated_auth)
      (regulated_auth["identifier"] || []).first&.dig("value")
    end

    def extract_gtin(packaged_product)
      packaging = packaged_product["packaging"] || {}
      (packaging["identifier"] || []).each do |ident|
        if ident["system"] == "urn:oid:2.51.1.1"
          return ident["value"]
        end
      end
      nil
    end

    def extract_swissmedic_category(packaged_product)
      (packaged_product["legalStatusOfSupply"] || []).each do |ls|
        (ls.dig("code", "coding") || []).each do |coding|
          cat = SWISSMEDIC_CATEGORY_MAP[coding["code"]]
          return cat if cat
        end
      end
      nil
    end

    def is_marketing_auth?(ra)
      (ra.dig("type", "coding") || []).any? do |c|
        c["code"] == "756000002001"  # Marketing Authorisation
      end
    end

    def is_reimbursement_sl?(ra)
      (ra.dig("type", "coding") || []).any? do |c|
        c["code"] == "756000002003"  # Reimbursement SL
      end
    end

    def extract_reimbursement_extension(regulated_auth)
      (regulated_auth["extension"] || []).each do |ext|
        next unless ext["url"]&.include?("reimbursementSL")
        result = {}
        (ext["extension"] || []).each do |sub_ext|
          case sub_ext["url"]
          when "FOPHDossierNumber"
            result[:foph_dossier_number] = sub_ext.dig("valueIdentifier", "value")
          when "status"
            result[:reimbursement_status_code] = sub_ext.dig("valueCodeableConcept", "coding", 0, "code")
          when "statusDate"
            result[:status_date] = sub_ext["valueDate"]
          when "listingStatus"
            result[:listing_status_code] = sub_ext.dig("valueCodeableConcept", "coding", 0, "code")
          when "listingPeriod"
            result[:listing_period_start] = sub_ext.dig("valuePeriod", "start")
          when "firstListingDate"
            result[:first_listing_date] = sub_ext["valueDate"]
          when "costShare"
            result[:cost_share] = sub_ext["valueInteger"]
          when "expiryDate"
            result[:expiry_date] = sub_ext["valueDate"]
          end
        end
        return result
      end
      nil
    end

    def extract_prices(regulated_auth)
      prices = []
      # productPrice extensions are nested inside the reimbursementSL extension
      (regulated_auth["extension"] || []).each do |reimb_ext|
        next unless reimb_ext["url"]&.include?("reimbursementSL")
        (reimb_ext["extension"] || []).each do |ext|
          next unless ext["url"]&.include?("productPrice")
          price_info = {}
          (ext["extension"] || []).each do |sub_ext|
            case sub_ext["url"]
            when "type"
              code = sub_ext.dig("valueCodeableConcept", "coding", 0, "code")
              case code
              when "756002005001"
                price_info[:type] = :public
              when "756002005002"
                price_info[:type] = :exfactory
              end
            when "changeType"
              code = sub_ext.dig("valueCodeableConcept", "coding", 0, "code")
              price_info[:change_type_code] = PRICE_CHANGE_TYPE_MAP[code] || code
            when "value"
              price_info[:value] = sub_ext.dig("valueMoney", "value")
            when "changeDate"
              price_info[:change_date] = sub_ext["valueDate"]
            end
          end
          prices << price_info if price_info[:type] && price_info[:value]
        end
      end
      prices
    end

    # ---- Helper methods that delegate to PreparationsListener logic ----

    def identify_sequence_for(registration, names, substances)
      return nil if registration.nil?
      subs = substances.map do |data|
        [data[:lt], ODDB::Dose.new(data[:dose], data[:unit])]
      end
      seqs = registration.sequences.values
      sequence = seqs.find do |seq|
        subs.size == seq.active_agents.size && subs.all? do |sub, dose|
          seq.active_agents.any? { |act| act.respond_to?(:same_as?) && act.same_as?(sub) && act.dose == dose }
        end
      end
      sequence ||= seqs.find { |seq| seq.active_agents.empty? }
      if sequence.nil?
        seqnr = (registration.sequences.keys.max || "00").next
        ptr = registration.pointer + [:sequence, seqnr]
        sequence = @app.update(ptr.creator, name_base: names[:de])
      end
      sequence
    rescue => e
      LogFile.debug("bsv_fhir: identify_sequence error: #{e.message}")
      nil
    end

    def add_bag_composition_to_sequence_for(sequence, substances)
      return if substances.empty?
      subs = substances.map do |data|
        [data[:lt], ODDB::Dose.new(data[:dose], data[:unit])]
      end

      composition_pointer = sequence.pointer + :bag_composition
      comp = if sequence.bag_compositions.nil? || sequence.bag_compositions.empty?
        @app.create(composition_pointer)
      else
        sequence.bag_compositions[0]
      end

      if !sequence.bag_compositions.empty?
        first_composition = sequence.bag_compositions[0]
        if first_composition.respond_to?(:active_agents)
          first_composition.active_agents.each do |agent|
            first_composition.delete_active_agent(agent)
            agent.odba_delete
            first_composition.odba_store
          end
        end
      end

      subs.each do |name, dose|
        substance = @app.substance(name)
        unless substance
          sptr = Persistence::Pointer.new(:substance)
          substance = @app.update(sptr.creator, lt: name)
        end
        if comp.pointer
          pointer = comp.pointer + [:active_agent, name]
          @app.update(pointer.creator, dose: dose, substance: substance.oid)
        end
      end
    rescue => e
      LogFile.debug("bsv_fhir: add_bag_composition error: #{e.message}")
    end

    def fix_flags_with_rss_logic_for(pack, price_public, iksnr)
      return unless price_public && pack
      today = Date.today
      cutoff = (today << 1) + 1
      first = Time.local(cutoff.year, cutoff.month, cutoff.day)
      last = Time.local(today.year, today.month, today.day)
      range = first..last
      if range.cover?(price_public.valid_from)
        previous = pack.price_public
        if previous.nil?
          if price_public.authority == :sl
            @preparations_listener.flag_change(pack.pointer, :sl_entry)
          end
        elsif [:sl, :lppv, :bag].include?(pack.data_origin(:price_public))
          if previous > price_public
            @preparations_listener.flag_change(pack.pointer, :price_cut)
          elsif price_public > previous
            @preparations_listener.flag_change(pack.pointer, :price_rise)
          end
        end
      end
    end

    def parse_date(text)
      return nil if text.to_s.empty?
      Date.parse(text)
    rescue ArgumentError
      nil
    end

    def parse_time(text)
      return nil if text.to_s.empty?
      Time.parse(text)
    rescue ArgumentError
      nil
    end

    def increment_counter(name)
      current = @preparations_listener.send(name)
      @preparations_listener.instance_variable_set(:"@#{name}", current + 1)
    end

    # ---- Reporting (delegates to BsvXmlPlugin) ----

    # report, log_info, log_info_bsv, report_bsv etc. are inherited from BsvXmlPlugin
    # They use @preparations_listener which we've populated with the same data
  end
end
