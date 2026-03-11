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
      "0" => "Keine Massnahmen notwendig",
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

    # Look up curated EPha interaction between two ATC codes
    def self.find_epha_interaction(atc1, atc2)
      return nil unless db
      row = db.execute(
        "SELECT * FROM epha_interactions WHERE atc1 = ? AND atc2 = ? LIMIT 1",
        [atc1, atc2]
      ).first
      row
    end

    # Extract context sentence around a keyword match in text.
    # Scans all occurrences and returns the one with highest severity.
    def self.extract_context(text, keyword)
      kw_lower = keyword.downcase
      txt_lower = text.downcase
      best_sentence = nil
      best_score = -1
      offset = 0
      while (idx = txt_lower.index(kw_lower, offset))
        start_pos = text.rindex(/[.:]/, [idx - 1, 0].max) || 0
        start_pos += 1 if start_pos > 0
        end_pos = text.index(/[.]/, idx + keyword.length) || text.length
        sentence = text[start_pos..end_pos].strip
        sentence = sentence[0, 500] if sentence.length > 500
        sev = score_severity(sentence)
        if sev > best_score
          best_score = sev
          best_sentence = sentence
        end
        offset = idx + keyword.length
      end
      best_sentence
    end

    # Score severity of a text context based on clinical language
    def self.score_severity(text)
      t = text.downcase
      return 3 if t.match?(/kontraindiziert|nicht anwenden|darf nicht|kontraindikation/)
      return 2 if t.match?(/gefährlich|schwerwiegend|lebensbedroh|erhöhtes.*blutungsrisiko/)
      return 1 if t.match?(/vorsicht|warnung|überwach|achten|kontrolle|erhöht.*risiko|verstärkt/)
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

      # Check reverse direction severity for hint
      reverse_severity = class_severity_for_direction(other_atc_code, my_atc_code)

      results = []
      atc_keywords.each do |prefix, keywords|
        next unless other_atc_code.start_with?(prefix)
        keywords.each do |kw|
          next unless fi_text.downcase.include?(kw.downcase)
          context = extract_context(fi_text, kw)
          next unless context
          severity = score_severity(context)
          hint = ""
          if reverse_severity > severity
            hint = "<br><span style='background-color: #ffec8b; padding: 2px 6px; font-size: 11px;'>Gegenrichtung hat höhere Einstufung — diese FI stuft die Interaktion tiefer ein</span>"
          end
          severity_s = severity.to_s
          header = "#{my_drug.name_with_size} [#{my_atc_code}] \u2194 #{other_drug.name_with_size} [#{other_atc_code}]"
          text = "ATC-Klasse (FI-Text)<br><i>Keyword «#{kw}» gefunden in Fachinformation von #{my_drug.name_with_size}</i><br>#{context}#{hint}"
          results << {
            header: header,
            severity: severity_s,
            color: Colors[severity_s],
            text: "#{severity_s}: #{Ratings[severity_s]}<br>#{text}"
          }
          break # one match per ATC prefix is enough
        end
      end
      results
    end

    # Build EPha interaction result for display
    def self.build_epha_result(epha_row, my_drug, my_atc_code, other_drug, other_atc_code)
      severity_s = epha_row["severity_score"].to_s
      risk_label = epha_row["risk_label"]
      effect = epha_row["effect"]
      mechanism = epha_row["mechanism"]
      measures = epha_row["measures"]

      header = "#{my_drug.name_with_size} [#{my_atc_code}] \u2194 #{other_drug.name_with_size} [#{other_atc_code}]"
      parts = ["#{severity_s}: #{risk_label}"]
      parts << "<br><b>#{effect}</b>" unless effect.to_s.empty?
      parts << "<br>#{mechanism}" unless mechanism.to_s.empty?
      parts << "<br><i>Massnahmen: #{measures}</i>" unless measures.to_s.empty?

      {
        header: header,
        severity: severity_s,
        color: Colors[severity_s],
        text: parts.join
      }
    end

    # Get interactions for a specific drug against all other drugs in the basket.
    # Three lookup strategies:
    # 1. EPha curated ATC-to-ATC interactions (epha_interactions table)
    # 2. Substance-level interactions (interactions table via ATC code)
    # 3. Class-level interactions (class_keywords + interactions_text)
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
            header = "#{my_sub} (#{my_drug.name_with_size}) => #{row["interacting_substance"]}"
            if row["interacting_brands"] && !row["interacting_brands"].empty?
              header += " (#{row["interacting_brands"].split(",").first(3).join(", ")})"
            end
            text = "#{severity}: #{Ratings[severity]}"
            text += "<br>#{row["description"]}<br>" if row["description"] && !row["description"].empty?

            results << {
              header: header,
              severity: severity,
              color: Colors[severity],
              text: text
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
