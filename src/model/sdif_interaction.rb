#!/usr/bin/env ruby

require "util/persistence"
require "util/searchterms"
require "util/language"
require "util/logfile"
require "sqlite3"

module ODDB
  module EphaInteractions
    # Severity ratings aligned with SDIF/EPha risk classes
    # A=0, B=1, C=1, D=2, X=3
    Ratings = {
      "0" => "Keine Einstufung",
      "1" => "Vorsichtsmassnahmen",
      "2" => "Kombination vermeiden",
      "3" => "Kontraindiziert"
    }
    # Colors mapped to severity scores
    Colors = {
      "0" => "#caff70",
      "1" => "#ffec8b",
      "2" => "#ff82ab",
      "3" => "#ff6a6a"
    }
    # EPha risk class to severity score
    RiskClassSeverity = {
      "A" => 0, "B" => 1, "C" => 1, "D" => 2, "X" => 3
    }

    DB_FILE = File.join(ODDB::WORK_DIR, "sqlite/interactions.db")

    def self.db
      @db ||= if File.exist?(DB_FILE)
        db = SQLite3::Database.new(DB_FILE, readonly: true)
        db.results_as_hash = true
        db
      end
    end

    def self.reload_db
      @db&.close rescue nil
      @db = nil
      @atc_keywords = nil
      @cyp_rules = nil
      @epha_table_exists = nil
      db
    end

    # Load ATC class keywords from class_keywords table
    # Returns hash: { "B01A" => ["antikoagul", "warfarin", ...], ... }
    def self.atc_keywords
      @atc_keywords ||= begin
        keywords = {}
        if db
          db.execute("SELECT atc_prefix, keyword FROM class_keywords").each do |row|
            prefix = row["atc_prefix"]
            kw = row["keyword"]
            (keywords[prefix] ||= []) << kw
          end
        end
        keywords
      end
    end

    # Load CYP450 rules from cyp_rules table
    def self.cyp_rules
      @cyp_rules ||= begin
        rules = []
        if db
          db.execute("SELECT enzyme, text_pattern, role, atc_prefix, substance FROM cyp_rules").each do |row|
            rules << row
          end
        end
        rules
      end
    end

    # Look up full SDIF drug info for an ATC code
    def self.sdif_drug_info_for_atc(atc_code)
      return nil unless db && atc_code
      row = db.execute(
        "SELECT brand_name, active_substances, interactions_text, route, combo_hint FROM drugs WHERE atc_code = ? AND length(interactions_text) > 0 ORDER BY length(interactions_text) DESC LIMIT 1",
        [atc_code]
      ).first
      row
    end

    def self.calculate_atc_codes(drugs)
      atc_codes = []
      if drugs && !drugs.empty?
        drugs.each { |ean, drug|
          atc_codes << drug.atc_class.code if drug && drug.atc_class
        }
      end
      atc_codes
    end

    def self.substance_names_for_drug(drug)
      return [] unless drug
      drug.substances.map { |s| s.name }.compact
    end

    # Look up SDIF substance names for an ATC code via the drugs table
    def self.sdif_substances_for_atc(atc_code)
      return [] unless db && atc_code
      rows = db.execute("SELECT DISTINCT active_substances FROM drugs WHERE atc_code = ?", [atc_code])
      rows.flat_map { |r| r["active_substances"].to_s.split(", ") }.uniq
    end

    # Get the interactions_text for a drug by ATC code
    def self.interactions_text_for_atc(atc_code)
      return nil unless db && atc_code
      row = db.execute("SELECT interactions_text FROM drugs WHERE atc_code = ? AND length(interactions_text) > 0 LIMIT 1", [atc_code]).first
      row&.dig("interactions_text")
    end

    # Look up curated EPha interaction between two ATC codes.
    # Returns nil if the epha_interactions table doesn't exist (SDIF built without --epha).
    def self.find_epha_interaction(atc1, atc2)
      return nil unless db
      return nil unless epha_table_exists?
      row = db.execute(
        "SELECT * FROM epha_interactions WHERE atc1 = ? AND atc2 = ? LIMIT 1",
        [atc1, atc2]
      ).first
      row
    end

    def self.epha_table_exists?
      return @epha_table_exists unless @epha_table_exists.nil?
      @epha_table_exists = db && !db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='epha_interactions'").empty?
    end

    # Extract context sentence around a keyword match in text.
    # Scans all occurrences and returns the one with highest severity.
    def self.extract_context(text, keyword)
      kw_lower = keyword.downcase
      txt_lower = text.downcase
      best_sentence = nil
      best_score = -1
      best_is_animal = false
      offset = 0
      while (idx = txt_lower.index(kw_lower, offset))
        start_pos = text.rindex(/[.:]/, [idx - 1, 0].max) || 0
        start_pos += 1 if start_pos > 0
        end_pos = text.index(/[.]/, idx + keyword.length) || text.length
        sentence = text[start_pos..end_pos].strip
        sentence = sentence[0, 500] if sentence.length > 500
        sev = score_severity(sentence)

        # Deprioritize if substance appears after Tiermodell/Tierstudie/Tierversuch
        prefix_lower = txt_lower[start_pos...idx]
        is_animal = prefix_lower.include?("tiermodell") || prefix_lower.include?("tierstudie") || prefix_lower.include?("tierversuch")
        effective_sev = is_animal ? 0 : sev

        if effective_sev > best_score || (effective_sev == best_score && best_is_animal && !is_animal) || best_sentence.nil?
          best_score = effective_sev
          best_is_animal = is_animal
          best_sentence = sentence
        end
        offset = idx + keyword.length
      end
      best_sentence
    end

    # Score severity of a text context based on clinical language
    def self.score_severity(text)
      t = text.downcase
      return 3 if t.match?(/kontraindiziert|kontraindikation|darf nicht|nicht angewendet werden|nicht verabreicht werden|nicht kombiniert werden|nicht gleichzeitig|ist verboten|nicht zusammen|nicht eingenommen werden|nicht anwenden/)
      return 2 if t.match?(/erhöhtes risiko|erhöhte gefahr|schwerwiegend|schwere|lebensbedrohlich|lebensgefährlich|gefährlich|stark erhöht|stark verstärkt|toxisch|toxizität|nephrotoxisch|hepatotoxisch|ototoxisch|neurotoxisch|kardiotoxisch|tödlich|fatale|blutungsrisiko|blutungsgefahr|serotoninsyndrom|serotonin-syndrom|qt-verlängerung|qt-zeit-verlängerung|torsade|rhabdomyolyse|nierenversagen|niereninsuffizienz|nierenfunktionsstörung|leberversagen|atemdepression|herzstillstand|arrhythmie|hyperkaliämie|agranulozytose|stevens-johnson|anaphyla|lymphoproliferation|immundepression|immunsuppression|panzytopenie|abgeraten|wird nicht empfohlen/)
      return 1 if t.match?(/vorsicht|überwach|monitor|kontroll|engmaschig|dosisanpassung|dosis reduz|dosis anpassen|dosisreduktion|sorgfältig|regelmässig|regelmäßig|aufmerksam|cave|beobacht|verstärkt|vermindert|abgeschwächt|erhöh|erniedrigt|beeinflusst|wechselwirkung|plasmaspiegel|plasmakonzentration|serumkonzentration|bioverfügbarkeit|subtherapeutisch|supratherapeutisch|therapieversagen|wirkungsverlust|wirkverlust/)
      0
    end

    # Compute the best class-level severity score for one direction (my_atc → other_atc)
    def self.class_severity_for_direction(my_atc_code, other_atc_code)
      fi_text = interactions_text_for_atc(my_atc_code)
      return 0 unless fi_text
      best = 0
      atc_keywords.each do |prefix, keywords|
        next unless other_atc_code.start_with?(prefix)
        keywords.each do |kw|
          next unless fi_text.downcase.include?(kw.downcase)
          context = extract_context(fi_text, kw)
          next unless context
          sev = score_severity(context)
          best = sev if sev > best
        end
      end
      best
    end

    # Find class-level interactions by searching interactions_text for ATC class keywords
    def self.find_class_interactions(my_atc_code, my_drug, other_atc_code, other_drug)
      return [] unless (fi_text = interactions_text_for_atc(my_atc_code))

      results = []
      atc_keywords.each do |prefix, keywords|
        next unless other_atc_code.start_with?(prefix)
        keywords.each do |kw|
          next unless fi_text.downcase.include?(kw.downcase)
          context = extract_context(fi_text, kw)
          next unless context
          severity = score_severity(context)
          severity_s = severity.to_s
          my_route = route_span(my_atc_code)
          other_route = route_span(other_atc_code)
          header = "#{my_drug.name_with_size}#{my_route} [#{my_atc_code}] \u2194 #{other_drug.name_with_size}#{other_route} [#{other_atc_code}]"
          source = "<span style='background-color: #d5ecd5; padding: 1px 6px; font-size: 11px; border-radius: 3px;'>Quelle: Swissmedic FI</span><br>"
          text = "ATC-Klasse<br><i>Keyword «#{kw}» gefunden in Fachinformation von #{my_drug.name_with_size}</i><br>#{context}"
          results << {
            header: header,
            severity: severity_s,
            color: Colors[severity_s],
            text: "#{source}#{severity_s}: #{Ratings[severity_s]}<br>#{text}",
            source: "fi",
            atc_pair: [my_atc_code, other_atc_code].sort
          }
          break # one match per ATC prefix is enough
        end
      end
      results
    end

    # Find CYP enzyme-mediated interactions
    def self.find_cyp_interactions(my_atc_code, my_drug, other_atc_code, other_drug, other_substances)
      fi_text = interactions_text_for_atc(my_atc_code)
      return [] unless fi_text

      text_lower = fi_text.downcase
      other_subst_lower = other_substances.map(&:downcase)
      rules = cyp_rules
      return [] if rules.empty?

      # Group rules by enzyme
      rules_by_enzyme = rules.group_by { |r| r["enzyme"] }
      results = []
      matched_enzymes = Set.new

      rules_by_enzyme.each do |enzyme, enzyme_rules|
        # Check if interaction text mentions this CYP enzyme
        matched_pattern = nil
        enzyme_rules.each do |rule|
          if text_lower.include?(rule["text_pattern"].downcase)
            matched_pattern = rule["text_pattern"]
            break
          end
        end
        next unless matched_pattern

        # Check if other drug matches any inhibitor or inducer rule
        is_inhibitor = false
        is_inducer = false
        enzyme_rules.each do |rule|
          matches = false
          if rule["atc_prefix"] && !rule["atc_prefix"].empty? && other_atc_code&.start_with?(rule["atc_prefix"])
            matches = true
          end
          if rule["substance"] && !rule["substance"].empty? && other_subst_lower.include?(rule["substance"].downcase)
            matches = true
          end
          if matches
            is_inhibitor = true if rule["role"] == "inhibitor"
            is_inducer = true if rule["role"] == "inducer"
          end
        end

        if (is_inhibitor || is_inducer) && !matched_enzymes.include?(enzyme)
          matched_enzymes << enzyme
          role = is_inhibitor ? "Hemmer" : "Induktor"
          context = extract_context(fi_text, matched_pattern)
          next unless context
          severity = score_severity(context)
          severity_s = severity.to_s
          my_route = route_span(my_atc_code)
          other_route = route_span(other_atc_code)
          header = "#{my_drug.name_with_size}#{my_route} [#{my_atc_code}] \u2194 #{other_drug.name_with_size}#{other_route} [#{other_atc_code}]"
          source = "<span style='background-color: #d5ecd5; padding: 1px 6px; font-size: 11px; border-radius: 3px;'>Quelle: Swissmedic FI</span><br>"
          text = "CYP<br><i>#{other_drug.name_with_size} ist #{enzyme}-#{role} — Fachinformation von #{my_drug.name_with_size} erwähnt dieses Enzym</i><br>#{context}"
          results << {
            header: header,
            severity: severity_s,
            color: Colors[severity_s],
            text: "#{source}#{severity_s}: #{Ratings[severity_s]}<br>#{text}",
            source: "fi",
            atc_pair: [my_atc_code, other_atc_code].sort
          }
        end
      end
      results
    end

    # Format route indicator span
    def self.route_span(atc_code)
      info = sdif_drug_info_for_atc(atc_code)
      return "" unless info
      route = info["route"].to_s
      return "" if route.empty?
      " <span style='background-color: #e8e0f0; padding: 1px 4px; font-size: 10px; border-radius: 2px;'>#{route}</span>"
    end

    # Format combo_hint span
    def self.combo_span(atc_code)
      info = sdif_drug_info_for_atc(atc_code)
      return "" unless info
      combo = info["combo_hint"].to_s
      return "" if combo.empty?
      " <span style='background-color: #dff0d8; padding: 1px 4px; font-size: 10px; border-radius: 2px;'>#{combo}</span>"
    end

    # Build EPha interaction result for display.
    # Checks if EPha severity differs between directions (asymmetric EPha rating).
    def self.build_epha_result(epha_row, my_drug, my_atc_code, other_drug, other_atc_code)
      severity_s = epha_row["severity_score"].to_s
      risk_label = epha_row["risk_label"]
      effect = epha_row["effect"]
      mechanism = epha_row["mechanism"]
      measures = epha_row["measures"]

      my_route = route_span(my_atc_code)
      other_route = route_span(other_atc_code)
      header = "#{my_drug.name_with_size}#{my_route} [#{my_atc_code}] \u2194 #{other_drug.name_with_size}#{other_route} [#{other_atc_code}]"
      parts = ["<span style='background-color: #dde8f0; padding: 1px 6px; font-size: 11px; border-radius: 3px;'>Quelle: EPha.ch</span><br>"]
      parts << "#{severity_s}: #{risk_label}"
      parts << "<br><b>#{effect}</b>" unless effect.to_s.empty?
      parts << "<br>#{mechanism}" unless mechanism.to_s.empty?
      parts << "<br><i>Massnahmen: #{measures}</i>" unless measures.to_s.empty?

      # Check EPha reverse direction for asymmetric severity
      reverse_epha = find_epha_interaction(other_atc_code, my_atc_code)
      if reverse_epha
        reverse_sev = reverse_epha["severity_score"].to_i
        my_sev = epha_row["severity_score"].to_i
        if reverse_sev > my_sev
          parts << "<br><span style='background-color: #ffec8b; padding: 2px 6px; font-size: 11px;'>Gegenrichtung hat höhere Einstufung (#{Ratings[reverse_sev.to_s]} vs #{Ratings[my_sev.to_s]})</span>"
        end
      end

      {
        header: header,
        severity: severity_s,
        color: Colors[severity_s],
        text: parts.join,
        source: "epha",
        atc_pair: [my_atc_code, other_atc_code].sort
      }
    end

    # Get interactions for a specific drug against all other drugs in the basket.
    # Four lookup strategies:
    # 1. EPha curated ATC-to-ATC interactions (epha_interactions table)
    # 2. Substance-level interactions (interactions table via ATC code)
    # 3. Class-level interactions (class_keywords + interactions_text)
    # 4. CYP enzyme-mediated interactions (cyp_rules table)
    def self.get_interactions(my_atc_code, drugs)
      return [] unless db && drugs && !drugs.empty?

      # Find the drug with matching ATC code
      my_drug = nil
      other_drugs = []
      drugs.each do |ean, drug|
        if drug&.atc_class&.code == my_atc_code
          my_drug = drug
        else
          other_drugs << drug
        end
      end
      return [] unless my_drug

      results = []
      matched_atc_pairs = Set.new

      # 1. EPha curated interactions (highest quality — direct ATC-to-ATC lookup)
      other_drugs.each do |other_drug|
        other_atc = other_drug&.atc_class&.code
        next unless other_atc

        epha_row = find_epha_interaction(my_atc_code, other_atc)
        if epha_row
          results << build_epha_result(epha_row, my_drug, my_atc_code, other_drug, other_atc)
          matched_atc_pairs << other_atc
        end
      end

      # 2. Substance-level interactions (for drugs not already matched by EPha)
      my_substances = sdif_substances_for_atc(my_atc_code)
      unmatched_drugs = other_drugs.reject { |d| matched_atc_pairs.include?(d&.atc_class&.code) }
      unmatched_atc_codes = unmatched_drugs.map { |d| d&.atc_class&.code }.compact.uniq
      # Map substance names back to ATC codes for atc_pair tracking
      substance_to_atc = {}
      unmatched_atc_codes.each do |atc|
        sdif_substances_for_atc(atc).each { |sub| substance_to_atc[sub.downcase] = atc }
      end
      other_substances = unmatched_atc_codes.flat_map { |atc| sdif_substances_for_atc(atc) }.uniq

      unless my_substances.empty? || other_substances.empty?
        my_substances.each do |my_sub|
          other_conditions = other_substances.map { "LOWER(interacting_substance) = LOWER(?)" }.join(" OR ")
          sql = <<~SQL
            SELECT drug_brand, drug_substance, interacting_substance, interacting_brands,
                   description, severity_score, severity_label
            FROM interactions
            WHERE LOWER(drug_substance) = LOWER(?)
              AND (#{other_conditions})
          SQL
          rows = db.execute(sql, [my_sub] + other_substances)
          rows.each do |row|
            severity = row["severity_score"].to_s
            my_route = route_span(my_atc_code)
            other_atc_for_route = substance_to_atc[row["interacting_substance"].to_s.downcase]
            other_route = other_atc_for_route ? route_span(other_atc_for_route) : ""
            header = "#{my_sub} (#{my_drug.name_with_size})#{my_route} => #{row["interacting_substance"]}"
            if row["interacting_brands"] && !row["interacting_brands"].empty?
              header += " (#{row["interacting_brands"].split(",").first(3).join(", ")})#{other_route}"
            end
            text = "<span style='background-color: #d5ecd5; padding: 1px 6px; font-size: 11px; border-radius: 3px;'>Quelle: Swissmedic FI</span><br>"
            text += "#{severity}: #{Ratings[severity]}"
            text += "<br>#{row["description"]}<br>" if row["description"] && !row["description"].empty?

            other_atc = substance_to_atc[row["interacting_substance"].to_s.downcase]
            results << {
              header: header,
              severity: severity,
              color: Colors[severity],
              text: text,
              source: "fi",
              atc_pair: other_atc ? [my_atc_code, other_atc].sort : nil
            }
          end
        end
      end

      # 3. Class-level interactions (for drugs not already matched by EPha)
      unmatched_drugs.each do |other_drug|
        other_atc = other_drug&.atc_class&.code
        next unless other_atc
        class_results = find_class_interactions(my_atc_code, my_drug, other_atc, other_drug)
        results.concat(class_results)
      end

      # 4. CYP enzyme interactions (for all drug pairs)
      other_drugs.each do |other_drug|
        other_atc = other_drug&.atc_class&.code
        next unless other_atc
        other_subs = sdif_substances_for_atc(other_atc)
        cyp_results = find_cyp_interactions(my_atc_code, my_drug, other_atc, other_drug, other_subs)
        results.concat(cyp_results)
        # Reverse direction
        my_subs = sdif_substances_for_atc(my_atc_code)
        reverse_cyp = find_cyp_interactions(other_atc, other_drug, my_atc_code, my_drug, my_subs)
        results.concat(reverse_cyp)
      end

      # Compute pair-max severity across all interaction types for this drug
      # Include EPha, class-level, and CYP severities from both directions
      pair_max = {}
      results.each do |r|
        key = r[:atc_pair]
        next unless key
        pair_max[key] = [pair_max[key] || 0, r[:severity].to_i].max
      end
      # Also check reverse direction severities (from other drugs' perspective)
      other_drugs.each do |other_drug|
        other_atc = other_drug&.atc_class&.code
        next unless other_atc
        key = [my_atc_code, other_atc].sort
        # Reverse EPha
        reverse_epha = find_epha_interaction(other_atc, my_atc_code)
        if reverse_epha
          sev = reverse_epha["severity_score"].to_i
          pair_max[key] = [pair_max[key] || 0, sev].max
        end
        # Reverse class-level
        reverse_class_sev = class_severity_for_direction(other_atc, my_atc_code)
        pair_max[key] = [pair_max[key] || 0, reverse_class_sev].max
      end

      # Post-process: add Gegenrichtung hint to FI results where severity < pair max
      results.each do |r|
        next unless r[:source] == "fi" && r[:atc_pair]
        max_sev = pair_max[r[:atc_pair]] || 0
        if r[:severity].to_i < max_sev
          r[:text] += "<br><span style='background-color: #ffec8b; padding: 2px 6px; font-size: 11px;'>Gegenrichtung hat höhere Einstufung</span>"
        end
      end

      results.uniq { |r| [r[:header]] }.sort_by { |item| item[:severity].to_s + item[:header].to_s }.reverse
    end

    # Look up a single interaction between two substances by name
    def self.get_interaction_detail(substance1, substance2)
      return nil unless db
      sql = <<~SQL
        SELECT drug_brand, drug_substance, interacting_substance, interacting_brands,
               description, severity_score, severity_label
        FROM interactions
        WHERE LOWER(drug_substance) = LOWER(?)
          AND LOWER(interacting_substance) = LOWER(?)
        LIMIT 1
      SQL
      row = db.execute(sql, [substance1, substance2]).first
      return nil unless row
      row
    end

    # Search for interactions by brand name
    def self.get_interactions_by_brand(brand_name)
      return [] unless db
      sql = <<~SQL
        SELECT drug_brand, drug_substance, interacting_substance, interacting_brands,
               description, severity_score, severity_label
        FROM interactions
        WHERE drug_brand = ?
      SQL
      db.execute(sql, [brand_name])
    end

    # Backward compatibility - return empty hash (no longer loading CSV into memory)
    def self.get
      {}
    end

    def self.read_from_csv(csv_file)
      LogFile.debug("read_from_csv called but interactions now come from SQLite DB: #{DB_FILE}")
    end

    # Legacy method - look up EPha interaction by ATC codes
    def self.get_epha_interaction(atc_code_self, atc_code_other)
      find_epha_interaction(atc_code_self, atc_code_other)
    end
  end
end
