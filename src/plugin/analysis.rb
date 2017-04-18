#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::AnalysisPlugin -- oddb.org -- 11.01.2012 -- mhatakeyama@ywesee.com
# ODDB::AnalysisPlugin -- oddb.org -- 09.06.2006 -- sfrischknecht@ywesee.com

$: << path = File.expand_path("../..", File.dirname(__FILE__)) unless $:.include?(path)

require 'plugin/plugin'
require 'model/analysis/group'
require 'rubyXL'
require 'mechanize'
require 'util/logfile'

module ODDB
  class AnalysisPlugin < Plugin
# in xlsx of 2014.10.08.xlsx
# Kapitel  Pos.-Nr.  TP  Bezeichnung  Limitation  Fach-bereich
# A        B         C   D            E           F
    BASE_URL  = "https://www.bag.admin.ch"
    INDEX_URL = "#{BASE_URL}/bag/de/home/themen/versicherungen/krankenversicherung/krankenversicherung-leistungen-tarife/Analysenliste.html"
    LANGUAGES = { 'de' => 'Deutsch',
                  'fr' => 'Français',
                  'it' => 'Italiano',
                  }
    COL = {
      :chapter              => 0, # A
      :group_position_code  => 1, # B
      :taxpoints            => 2, # C
      :description          => 3, # D
      :limitation_text      => 4, # E
      :lab_areas            => 5, # F
    }
    def save_for_log(msg)
      LogFile.append('oddb/debug', " AnalysisPlugin #{msg}", Time.now)
      withTimeStamp = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}"
      # $stderr.puts withTimeStamp
      @@logInfo << withTimeStamp
    end
    def initialize(app)
      @@logInfo = []
      @archive = File.join ARCHIVE_PATH, 'xls'
      FileUtils.mkdir_p @archive
      save_for_log "@archive #{@archive}"
      super
    end
    def update(agent=Mechanize.new)
      @agent = agent
      needs_update, target = get_latest_file
      if needs_update || @app.analysis_groups.size == 0
        save_for_log "deleting all_analysis_group (#{@app.analysis_groups.size} groups)"
        ODBA.transaction do
          @app.delete_all_analysis_group
          LANGUAGES.each {|short, name| update_group_position(target, short, name) }
        end
      end
      save_for_log "update finished with #{@app.analysis_groups.size} groups and #{@app.analysis_positions.size} positions"
      @app.recount
    end
    def update_group_position(path, short, name)
      save_for_log " update_group_position #{short} #{name} #{path}"
      parse_xlsx(path, short, name).each { |position|
        group = update_group(position)
        if(position[:analysis_revision] == 'S')
          delete_position(group, position)
        else
          position = update_position(group, position, short, name)
        end
      }
    end
    def get_latest_file
      page = @agent.get INDEX_URL
      keyword = 'Liste der Analysenpositionen'
      links = page.links.find_all{|link| /excelforma/i.match (link.href) }
      link = links.first or raise "could not identify url to analysis.xlsx"
      file = @agent.get(link.href)
      download = file.body
      latest = File.join @archive, "analysis_latest.xlsx"
      target = File.join @archive, @@today.strftime("analysis_%Y.%m.%d.xlsx")
      needs_update = true
      if(!File.exist?(latest) or download.size != File.size(latest))
        FileUtils.makedirs(File.dirname(latest)) unless File.directory?(File.dirname(latest))
        File.open(latest, 'w+') { |f| f.write download }
        save_for_log "saved get_latest_file as #{target} and #{latest}"
      else
        save_for_log "latest_file #{target} is uptodate"
        needs_update = false
      end
      return needs_update,latest
    end
    def parse_xlsx(path, short, name)
      workbook = RubyXL::Parser.parse(path)
      positions = []
      rows = 0
      found_language = false
      examined = []
      workbook.each do |worksheet|
        next if found_language
        examined <<  worksheet.sheet_name
        next unless worksheet.sheet_name.eql?(name)
        worksheet.each do |row|
          # workbook[0].sheet_name, eg. Deutsch
          rows += 1
          if rows > 1
            next unless row[COL[:group_position_code]]# puts "Skipping rows #{rows}"
            found_language = true
            string = sprintf('%6.2f',row[COL[:group_position_code]].value)
            groupcd, poscd = string.split('.')
            poscd ||= '00'
            chapter            = row[COL[:chapter]]           ? row[COL[:chapter]].value            : nil
            taxpoints          = row[COL[:taxpoints]]         ? row[COL[:taxpoints]].value          : nil
            description        = row[COL[:description]]       ? row[COL[:description]].value        : nil
            limitation_text    = row[COL[:limitation_text]]   ? row[COL[:limitation_text]].value    : nil
            lab_areas          = row[COL[:lab_areas]]         ? row[COL[:lab_areas]].value          : nil
            positions << {
              :chapter            => chapter,
              :group              => groupcd,
              :position           => poscd,
              :taxpoints          => taxpoints,
              :description        => description,
              :limitation_text    => limitation_text,
              :lab_areas          => lab_areas,
            }
          end
        end
      end
      raise "Unable to find worksheet for #{short} #{name} examined #{examined}" unless found_language
      positions
    end
    def update_group(position)
      groupcd = position.delete(:group)
      unless group = @app.analysis_group(groupcd)
        ptr = Persistence::Pointer.new([:analysis_group, groupcd])
        @app.create(ptr)
      else
        group
      end
    end
    def update_position(group, position, short, name)
      poscd   = position.delete(:position)
      position.store(short, position.delete(:description))
      lim_txt = position.delete(:limitation_text)
      return unless group
      pos = if grp_obj = @app.analysis_group(group.oid) and pos_obj = grp_obj.position(poscd)
              pos_obj
            else
                ptr = group.pointer + [:position, poscd]
              @app.update(ptr.creator, position, :analysis)
            end
      if(lim_txt)
        lim_txt.gsub!(/^Limitation: /,'')
        lim_ptr = pos.pointer + :limitation_text
        args = {short => lim_txt}
        lim = @app.update(lim_ptr.creator, args, :analysis)
        @app.update(pos.pointer, {:limitation_text => lim}, :anaylsis)
      end
      pos
    end

    # send a log mail after running the import
    def log_info
      info = super
      info.update(:parts => {}, :report => @@logInfo.join("\n"))
      info
    end
  end
end
