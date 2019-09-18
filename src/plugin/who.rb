#!/usr/bin/env ruby
# encoding: utf-8
# WhoPlugin -- ODDB -- 23.02.2004 -- hwyss@ywesee.com

require 'mechanize'
require 'plugin/plugin'
require 'model/text'
require 'model/dose'
require 'util/persistence'
require 'open-uri'

module ODDB
  class WhoPlugin < Plugin
    attr_reader :codes, :repairs
    class CodeHandler
      ATC_TOP_LEVEL = %w{A B C D G H J L M N P R S V}
      attr_reader :queue, :visited
      def initialize
        @queue = ATC_TOP_LEVEL.dup
        @visited = []
      end
      def push(code)
        unless((@queue + @visited).include?(code))
          @queue.push(code)
        end
      end
      def shift
        code = @queue.shift
        @visited.push(code) if code
        code
      end
    end
    @@query_re = /code=([A-Z0-9]+)/
    @@lower = /^(and|for|in(cl)?|on|plain|with)$/i
    UNIT_REPLACEMENTS = {
      'TSD E' => 'TsdI.E.',
      'MIO E' => 'MioI.E.',
    }
    def initialize *args
      super
      @root_url = 'http://www.whocc.no/'
      @ddd_url  = @root_url+ 'atc_ddd_index/'
      @new_url  = @root_url+ 'atc/lists_of_new_atc_ddds_and_altera/new_atc/?order_by=1&d=DESC'
      @codes = CodeHandler.new
      @count = 0
      @created = 0
      @ddd_guidelines = 0
      @guidelines = 0
      @repairs = []
    end
    def capitalize_all(str)
      ## benchmarked fastest against an append (<<) solution
      str.split(/\b/).collect { |part|
        @@lower.match(part) ? part.downcase : part.capitalize }.join
    end
    def extract_text(node)
      unless(node.children.any? { |br| br.element? && br.name != 'br' })
        html = node.inner_html
        html.gsub(/\s+/, ' ').gsub(/\s*<br\s*\/?>\s*/, "\n").strip
      end
    end
    def import(agent=Mechanize.new)
      # reset origin of whocc
      @app.atc_classes.each{ |key, value| value.origin = nil if value.origin == :whocc }
      # Fix atc_classes which point to wrong sequences
      @app.atc_classes.each{
        |key, value|
        next unless value
        msg = value.repair_needed?
        @repairs << msg if msg
      }
      # run import
      while(code = @codes.shift)
        @count += 1
        import_code(agent, code)
      end
      import_new_codes(agent)
      @app.atc_classes.odba_store
      report
    end
    def import_atc(code, name, origin = :whocc)
      name = capitalize_all name
      atc = @app.atc_class(code)
      pointer = if atc = @app.atc_class(code)
                  atc.pointer
                else
                  @created += 1
                  Persistence::Pointer.new([:atc_class, code]).creator
                end
      @app.update pointer.creator, {:en => name, :origin => origin}
    end
    def import_new_codes(agent)
      page = Nokogiri::HTML(open(@new_url).read)
      new_codes = {}
      page.css('tr').each {
        |tr|
        next if tr.css('td').length != 4
        new_codes[tr.css('td').first.content] =
      [
       tr.css('td')[1].content, # substance
       tr.css('td')[2].content, # deadline
       tr.css('td')[3].content.chomp, # year
      ]
      }
      new_codes.each{ |atc, details|
          if atc.length > 0
            atc_code = import_atc(atc, details[0], :whocc_new)
            @codes.push(atc_code)
        end
      }
    end
    def import_code(agent, get_code)
      page = agent.get(@ddd_url + "?code=%s&showdescription=yes" % get_code)
      (page/"//b/a").each do |link|
        if(match = @@query_re.match(link.attributes['href']))
          code = match[1]
          if(code == get_code && code.length > 0)
            atc = import_atc(code, link.inner_text.to_s)
            import_guidelines(atc, link)
          end
          @codes.push(code)
        end
      end
      (page/"//ul//a").each do |link|
        if(match = @@query_re.match(link.attributes['href']))
          code = match[1]
          atc = import_atc(code, link.inner_text.to_s)
          import_ddds(atc, link.parent.parent) if atc && atc.is_a?(ODDB::AtcClass)
        end
      end
    rescue NoMethodError, SocketError => e
      @repairs << "Unable to fetch #{get_code} because of #{e}"
    end
    def import_ddds(atc, row)
      code = nil
      old_keys = atc.ddds.keys
      new_keys = []
      begin
        code, link, dose, unit, adm, comment = row.children.collect do |td| extract_text(td).to_s end
        comment = comment.empty? ? nil: comment
        break unless code.empty? || code == atc.code
        unless dose.empty?
          key = "%s%s" % [adm.empty? ? '*' : adm, comment]
          new_keys << key
          pointer = if ddd = atc.ddd(key)
                      ddd.pointer
                    else
                      atc.pointer + [:ddd, key]
                    end
          unit = UNIT_REPLACEMENTS.fetch(unit, unit)
          @app.update pointer.creator, :note => comment, :dose => Drugs::Dose.new(dose, unit)
          atc.ddds[key] = ddd
        end
      end while row = row.next_sibling
      (old_keys - new_keys).each do |key|
        atc.delete_ddd(key)
      end
      atc.repair_needed?
      atc.odba_store
      nil
    end
    def import_ddd_guidelines(atc, table)
      chp, sec = nil
      if(table)
        (table/'td').each do |td|
          if (txt = extract_text(td)) && !txt.empty?
            chp ||= Text::Chapter.new
            sec ||= chp.next_section
            par = sec.next_paragraph
            par << txt
          end
        end
      end
      unless atc.ddd_guidelines && atc.ddd_guidelines.en == chp
        @ddd_guidelines += 1
        pointer = atc.pointer + :ddd_guidelines
        @app.update pointer.creator, :en => chp
        modified = true
      end
    end
    def import_guidelines(atc, link)
      node = link.parent
      while(node.name != 'p')
        node = node.next_sibling or return
      end
      ## nokogiri fixes the faulty html of whocc.no, and moves the table element
      #  out of the p-container.
      table = node.next_sibling
      modified = false
      if table.name == 'table' && table[:bgcolor] == '#cccccc'
        modified = import_ddd_guidelines(atc, table)
      end
      chp = nil
      if (txt = extract_text(node)) && !txt.empty?
        chp = Text::Chapter.new
        sec = chp.next_section
        par = sec.next_paragraph
        par << txt
      end
      unless atc.guidelines && atc.guidelines.en == chp
        @guidelines += 1
        pointer = atc.pointer + :guidelines
        @app.update pointer.creator, :en => chp
        modified = true
      end
      modified
    end
    def report
      [
        sprintf("Imported %3i ATC-Codes", @count),
        sprintf("Created  %3i English descriptions", @created),
        sprintf("Updated  %3i Guidelines", @guidelines),
        sprintf("Updated  %3i DDD-Guidelines", @ddd_guidelines),
        sprintf("Repaired %3i wrong sequences", @repairs.size),
        @repairs.join("\n"),
      ].join("\n")
    end
  end
end
