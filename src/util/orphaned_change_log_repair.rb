#!/usr/bin/env ruby

# ODDB::OrphanedChangeLogRepair -- oddb.org -- 2026
#
# Hängt verwaiste ChangeLogItems wieder an das Dokument ihres Präparats.
#
# Ein change_log hängt am FachinfoDocument bzw. PatinfoDocument, nicht an
# Fachinfo/Patinfo. Wird ein Dokument ersetzt, ohne dass die Historie
# mitgenommen wird, zeigt nichts mehr auf sie - die Einträge bleiben aber
# unversehrt in der Datenbank liegen.
#
# Zugeordnet wird über die Zulassungsnummer, die am Ende jeder Fach- und
# Patienteninformation steht. Diffy::Diff speichert den vollständigen alten und
# neuen Text (@string1/@string2), die Nummer reist also im Eintrag selbst mit.
#
# Es wird ausschliesslich angehängt, nie gelöscht, und jedes Anhängen wird
# protokolliert, damit es einzeln rückgängig gemacht werden kann.

require "util/logfile"

module ODDB
  class OrphanedChangeLogRepair
    # Die Beschriftung vor der Nummer, in allen drei Sprachen. "Swissmedic"
    # steht mit dabei, weil ältere Texte die Nummer als "12345 (Swissmedic)"
    # ohne eigene Überschrift führen.
    LABEL = /Zulassungsnummer|Zulassungsvermerk|Numéro d.autorisation|
             Numéros d.autorisation|Numero dell.omologazione|
             Numeri dell.omologazione|Swissmedic/xi
    LANGUAGES = {
      "de" => /Zulassungsnummer|Zulassungsvermerk/i,
      "fr" => /Numéros? d.autorisation/i,
      "it" => /Numeri? dell.omologazione/i
    }
    # Die Nummer steht am Textende; weiter vorne stehen Mengenangaben, die
    # ebenfalls fünfstellig sein können.
    TAIL = 2500
    # Rueckgabe von patinfo_document, wenn mehrere Patinfos in Frage kommen.
    AMBIGUOUS = :mehrere_patinfos

    attr_reader :counts

    def initialize(app, opts = {})
      @app = app
      @apply = opts[:apply]
      @undo_log = opts[:undo_log]
      @counts = Hash.new(0)
      @undo = []
      @plan = opts[:plan] && File.open(opts[:plan], "w")
    end

    def close
      @plan&.close
    end

    def run(ids)
      ids.each_with_index do |id, idx|
        repair(id)
        report_progress(idx + 1) if ((idx + 1) % 1000).zero?
      end
      flush_undo
      report
      @counts
    end

    def repair(id)
      item = ODBA.cache.fetch(id, nil)
      texts = strings_of(item)
      return tally(:kein_text) if texts.compact.empty?
      iksnrs = iksnrs_in(texts)
      return tally(:keine_zulassungsnummer) if iksnrs.empty?
      language = language_of(texts)
      return tally(:keine_sprache) unless language
      document = target_document(item, iksnrs, language)
      return unless document          # target_document zählt selbst
      return tally(:schon_vorhanden) if already_there?(document, item)
      attach(document, item)
    rescue => error
      tally(:fehler)
      LogFile.debug("OrphanedChangeLogRepair #{id}: #{error.class} #{error.message}")
    end

    # Der alte und der neue Text des Diffs. Bei manchen Einträgen ist @string1
    # kein String, sondern ein ganzes Dokument - to_s liefert dann trotzdem den
    # Text.
    def strings_of(item)
      diff = item.diff
      [diff.instance_variable_get(:@string1).to_s,
        diff.instance_variable_get(:@string2).to_s]
    rescue
      []
    end

    def iksnrs_in(texts)
      texts.each do |text|
        next if text.to_s.empty?
        tail = (text.size > TAIL) ? text[-TAIL, TAIL] : text
        found = []
        tail.scan(/#{LABEL}[^\n]{0,200}/) { |m| found.concat m.scan(/\b(\d{5})\b/).flatten }
        found.concat(tail.scan(/\b(\d{5})\b/).flatten) if found.empty?
        return found.uniq unless found.empty?
      end
      []
    end

    def language_of(texts)
      texts.each do |text|
        LANGUAGES.each { |lang, pattern| return lang if text.to_s =~ pattern }
      end
      nil
    end

    def fachinfo?(item)
      item.class.to_s.include?("Fachinfo")
    end

    # Für Fachinfos teilen sich mehrere Registrationen dasselbe Fachinfo-Objekt,
    # mehrere Nummern sind dort also kein Widerspruch - solange sie auf dasselbe
    # Dokument zeigen. Für Patienteninformationen hängt das change_log am Paket,
    # und eine Registration kann mehrere verschiedene Patinfos haben; dort wird
    # jede Mehrdeutigkeit übersprungen und gezählt.
    def target_document(item, iksnrs, language)
      ambiguous = false
      documents = iksnrs.collect { |iksnr|
        registration = @app.registration(iksnr)
        next tally_nil(:keine_registration) unless registration
        found = if fachinfo?(item)
          fachinfo_document(registration, language)
        else
          patinfo_document(registration, language)
        end
        if found == AMBIGUOUS
          ambiguous = true
          next nil
        end
        found
      }.compact.uniq { |doc| doc.odba_id }
      case documents.size
      when 0 then tally_nil(ambiguous ? :mehrere_patinfos : :kein_dokument)
      when 1 then documents.first
      else tally_nil(:mehrdeutige_nummern)
      end
    end

    def fachinfo_document(registration, language)
      fachinfo = registration.fachinfo
      fachinfo.respond_to?(:descriptions) ? fachinfo.descriptions[language] : nil
    rescue
      nil
    end

    # Hat die Registration mehrere verschiedene Patinfo-Objekte, laesst sich
    # nicht sagen, an welches der Diff gehoert - das wird gemeldet und nicht
    # geraten. Nicht mit "gar kein Dokument" zu verwechseln: das eine ist eine
    # offene Frage, das andere ein fehlender Text.
    def patinfo_document(registration, language)
      patinfos = []
      registration.each_package { |package|
        patinfo = package.patinfo
        patinfos.push(patinfo) if patinfo.respond_to?(:descriptions)
      }
      patinfos.uniq! { |patinfo| patinfo.odba_id }
      return nil if patinfos.empty?
      return AMBIGUOUS if patinfos.size > 1
      patinfos.first.descriptions[language]
    rescue
      nil
    end

    # Nach odba_id, und ersatzweise nach Zeitpunkt und Textlängen - zwei
    # Einträge desselben Tages mit gleich langem altem und neuem Text sind
    # derselbe Eintrag.
    # respond_to?(:time) ist nicht ueberfluessig: es liegen PatinfoDocument-
    # Objekte in change_log-Arrays, wo ChangeLogItems stehen sollten. Die
    # Ansicht filtert sie mit derselben Frage weg (util/session.rb:316) - sonst
    # stuerzt die Diff-Seite ab.
    def already_there?(document, item)
      signature = [item.time.to_s, *strings_of(item).collect(&:size)]
      change_log_of(document).any? { |present|
        next true if present.odba_id == item.odba_id
        next false unless present.respond_to?(:time)
        [present.time.to_s, *strings_of(present).collect(&:size)] == signature
      }
    end

    # Die Zuordnung gegen das Ziel selbst pruefen: traegt der heutige Text des
    # Dokuments dieselbe Zulassungsnummer wie der verwaiste Diff? Nennt ein
    # Text im Schluss die Nummer eines anderen Praeparats - Kombipackungen,
    # Querverweise -, faellt das hier auf, bevor geschrieben wird.
    def confirm(document, item)
      wanted = iksnrs_in(strings_of(item))
      present = iksnrs_in([document_text(document)])
      if present.empty?
        tally(:ziel_ohne_nummer)
      elsif (wanted & present).empty?
        tally(:zuordnung_zweifelhaft)
        LogFile.debug("OrphanedChangeLogRepair #{item.odba_id}: will #{wanted.join(",")}, " \
                      "Ziel #{document.odba_id} traegt #{present.join(",")}")
        :zweifelhaft
      else
        tally(:zuordnung_bestaetigt)
        :bestaetigt
      end
    rescue
      tally(:ziel_ohne_text)
    end

    # FachinfoDocument fuehrt seinen Text unter text (fachinfo.rb:293),
    # PatinfoDocument unter to_s (patinfo.rb:164).
    def document_text(document)
      document.respond_to?(:text) ? document.text.to_s : document.to_s
    end

    # Zwei Eintraege desselben Tages auf einem Dokument sind kein Fehler, aber
    # ueber die URL /diff/<datum> ist nur der erste erreichbar (session.rb:336).
    def same_day?(document, item)
      day = item.time.strftime("%d.%m.%Y")
      Array(document.change_log).any? { |present|
        present.respond_to?(:time) && present.time.strftime("%d.%m.%Y") == day
      }
    end

    def attach(document, item)
      tally(:angehaengt)
      status = confirm(document, item) || :ungeprueft
      tally(:gleiches_datum_wie_vorhandener) if same_day?(document, item)
      @plan&.puts([item.odba_id, document.odba_id, status].join("\t"))
      return unless @apply
      store(document, item)
    end

    # Der eigentliche Schreibvorgang, gemeinsam genutzt vom Direktlauf und von
    # run_plan. Es wird nur angehaengt, nie ersetzt oder geloescht.
    # Liest das change_log und ersetzt es durch eine frische Liste, wenn der
    # Verweis ins Leere zeigt.
    #
    # 112 Zieldokumente tragen einen Stub auf eine odba_id, unter der in object
    # keine Zeile steht - die Liste wurde nie geschrieben. Datenbankweit gibt es
    # 7614 solcher haengenden Kanten. Da unter der id nichts liegt, geht durch
    # eine neue Liste nichts verloren; das Dokument wird dadurch ueberhaupt erst
    # wieder benutzbar, denn jeder Zugriff auf change_log wirft sonst OdbaError.
    def change_log_of(document)
      Array(document.change_log)
    rescue ODBA::OdbaError
      tally(:change_log_neu_angelegt)
      []
    end

    def store(document, item)
      log = change_log_of(document)
      log.push(item)
      document.change_log = log
      # Das change_log ist ein eigenes ODBA-Objekt mit eigener odba_id. Beim
      # Dumpen des Dokuments wird es durch einen Stub ersetzt
      # (odba_replace_persistables), sein Inhalt also nicht mitgeschrieben - ein
      # odba_isolated_store auf dem Dokument allein bleibt wirkungslos. Die
      # Liste muss selbst gespeichert werden, und zwar vor dem Dokument, damit
      # dessen Stub auf etwas zeigt, das schon da ist.
      log.odba_isolated_store
      document.odba_isolated_store
      @undo.push("#{document.odba_id} #{item.odba_id}")
      @counts[:geschrieben] += 1
    end

    # Haengt genau die Paare an, die in einem zuvor erzeugten Plan stehen -
    # keine erneute Zuordnung, keine Ueberraschungen. Der Plan ist damit das,
    # was gelesen und freigegeben wird, und nicht ein Lauf, der jedes Mal neu
    # entscheidet.
    def run_plan(pairs)
      pairs.each_with_index do |(item_id, document_id), index|
        item = ODBA.cache.fetch(item_id, nil)
        document = ODBA.cache.fetch(document_id, nil)
        if already_there?(document, item)
          tally(:schon_vorhanden)
        else
          store(document, item)
        end
        report_progress(index + 1) if ((index + 1) % 1000).zero?
      rescue => error
        tally(:fehler)
        LogFile.debug("OrphanedChangeLogRepair plan #{item_id}->#{document_id}: " \
                      "#{error.class} #{error.message}")
      end
      flush_undo
      report
      @counts
    end

    def tally(key)
      @counts[key] += 1
      nil
    end
    alias_method :tally_nil, :tally

    def report_progress(done)
      warn "#{done} bearbeitet, #{@counts[:angehaengt]} zugeordnet"
      flush_undo
    end

    def flush_undo
      return if @undo.empty? || @undo_log.nil? || !@apply
      File.open(@undo_log, "a") { |file| file.puts(@undo) }
      @undo.clear
    end

    def report
      puts @apply ? "=== angewendet ===" : "=== Trockenlauf, nichts geschrieben ==="
      @counts.sort_by { |_key, count| -count }.each { |key, count|
        puts format("  %-24s %7d", key, count)
      }
    end
  end
end
