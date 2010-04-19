#!/usr/bin/env ruby
# WhoPlugin -- ODDB -- 23.02.2004 -- hwyss@ywesee.com

require 'mechanize'
require 'plugin/plugin'
require 'model/text'
require 'model/dose'
require 'util/persistence'

module ODDB
  class WhoPlugin < Plugin
    attr_reader :codes
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
      @url = 'http://www.whocc.no/atc_ddd_index/'
      @codes = CodeHandler.new
      @count = 0
      @created = 0
      @ddd_guidelines = 0
      @guidelines = 0
    end
    def capitalize_all(str)
      ## benchmarked fastest against an append (<<) solution
      str.split(/\b/).collect { |part|
        @@lower.match(part) ? part.downcase : part.capitalize }.join
    end
    def extract_text(node)
      unless(node.children.any? { |br| br.element? && br.name != 'br' })
        html = node.inner_html
        if RUBY_VERSION < '1.9'
          html.gsub! /\240/, ''
        end
        html.gsub(/\s+/, ' ').gsub(/\s*<br\s*\/?>\s*/, "\n").strip
      end
    end
    def import(agent=Mechanize.new)
      while(code = @codes.shift)
        @count += 1
        import_code(agent, code)
      end
      report
    end
    def import_atc(code, link)
      name = capitalize_all link.inner_text.to_s
      pointer = if atc = @app.atc_class(code)
                  atc.pointer
                else
                  @created += 1
                  Persistence::Pointer.new([:atc_class, code]).creator
                end
      @app.update pointer.creator, :en => name
    end
    def import_code(agent, get_code)
      page = agent.get(@url + "?code=%s&showdescription=yes" % get_code)
      (page/"//b/a").each do |link|
        if(match = @@query_re.match(link.attributes['href']))
          code = match[1]
          if(code == get_code)
            atc = import_atc(code, link)
            import_guidelines(atc, link)
          end
          @codes.push(code)
        end
      end
      (page/"//ul//a").each do |link|
        if(match = @@query_re.match(link.attributes['href']))
          code = match[1]
          atc = import_atc(code, link)
          import_ddds atc, link.parent.parent
        end
      end
    end
    def import_ddds(atc, row)
      code = nil
      begin
        code, link, dose, unit, adm, comment = row.children.collect do |td|
          extract_text(td).to_s end
        comment = comment.empty? ? nil: comment
        return unless code.empty? || code == atc.code
        unless dose.empty?
          key = "%s%s" % [adm.empty? ? '*' : adm, comment]
          pointer = if ddd = atc.ddd(key)
                      ddd.pointer
                    else
                      atc.pointer + [:ddd, key]
                    end
          unit = UNIT_REPLACEMENTS.fetch(unit, unit)
          @app.update pointer.creator, :note => comment,
                                       :dose => Drugs::Dose.new(dose, unit)
        end
      end while row = row.next_sibling
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
        sprintf("Updated  %3i English descriptions", @created),
        sprintf("Updated  %3i Guidelines", @guidelines),
        sprintf("Updated  %3i DDD-Guidelines", @ddd_guidelines),
      ]
    end
  end
end
