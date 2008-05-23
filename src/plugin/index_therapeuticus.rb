#!/usr/bin/env ruby
# IndexTherapeuticusPlugin -- oddb.org -- 19.05.2008 -- hwyss@ywesee.com

require 'mechanize'
require 'model/index_therapeuticus'
require 'plugin/plugin'
require 'util/persistence'

module ODDB
  class IndexTherapeuticusPlugin < Plugin
    def initialize *args
      super
      @found = @created = @updated = @deleted = 0
      @current_indices = {}
    end
    def update agent=WWW::Mechanize.new
      get_toplevel(agent).each { |pagename| get_details agent, pagename }
      prune
      report
    end
    def get_toplevel agent
      url = 'http://www.galinfo.net/batchhtm/IT.htm'
      categories = []
      if page = agent.get(url)
        categories = (page/'a').collect { |link| link.attributes['href'] }
      end
      categories
    end
    def get_details agent, pagename
      url = "http://www.galinfo.net/batchhtm/#{pagename}"
      iths = []
      if page = agent.get(url)
        (page/'table#SL2ITTAB').each { |table|
          code, name = (table/'td#SL2ITL1').collect { |cell| cell.innerText }
          if code.nil?
            code, name = (table/'td#SL2ITL2').collect { |cell| cell.innerText }
          end
          if code.nil?
            code, name = (table/'td#SL2ITL3').collect { |cell| cell.innerText }
          end
          de, fr = titles name
          next if de.empty?
          @found += 1
          code = IndexTherapeuticus.normalize_code code
          ptr = Persistence::Pointer.new [ :index_therapeuticus, code ]
          if ptr.resolve(@app)
            @updated += 1
          else
            ptr = ptr.creator
            @created += 1
          end
          ith = @app.update ptr, { :de => de, :fr => fr }, :index_therapeuticus
          @current_indices.store code, ith
          iths.push ith
          comments = table/'td#SL2SUB1'
          if !comments.empty?
            de, fr, it = comments.collect { |cell| cell.innerText }
            ptr = ith.pointer + :comment
            @app.update ptr.creator, { :de => de, :fr => fr, :it => it },
                        :index_therapeuticus
          elsif cm = ith.comment
            @app.delete cm.pointer
          end
          if cell = (table/'td#SL2PRLLINE').first
            lines = text_lines cell
            step = lines.size / 3
            de = lines[0, step].join("\n")
            fr = lines[step, step].join("\n")
            it = lines[2 * step, step].join("\n")
            de.gsub! /^Limitatio:\s*/, ''
            ptr = ith.pointer + :limitation_text
            @app.update ptr.creator, { :de => de, :fr => fr, :it => it },
                        :index_therapeuticus
          elsif lt = ith.limitation_text
            @app.delete lt.pointer
          end
        }
      end
      iths
    end
    def prune
      return if @current_indices.empty?
      @app.indices_therapeutici.dup.each { |key, ith|
        unless @current_indices.delete key
          @deleted += 1
          @app.delete ith.pointer
        end
      }
    end
    def report
      sprintf <<-EOS, @found, @created, @updated, @deleted
Found   %3i Indices Therapeutici
Created %3i 
Kept    %3i
Deleted %3i
      EOS
    end
    def text_lines(cell)
      cell.innerHTML.gsub(%r{\s*</?[bi]>\s*}, ' ')\
          .strip.split(%r{\s*<br\s*/?>\s*})
    end
    def titles(str)
      str.to_s.split(/\s*-\s*/, 2)
    end
  end
end
