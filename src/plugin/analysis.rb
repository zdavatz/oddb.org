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

    COL = {
      :chapter              => 0, # A
      :group_position_code  => 1, # B
      :taxpoints            => 2, # C
      :description          => 3, # D
      :limitation_text      => 4, # E
      :lab_areas            => 5, # F
    }
    def initialize(app)
      @archive = File.join ARCHIVE_PATH, 'xls'
      FileUtils.mkdir_p @archive
      LogFile.append('oddb/debug', " AnalysisPlugin @archive #{@archive} ", Time.now)
      super
    end
    def update
      LogFile.append('oddb/debug', " AnalysisPlugin update deleting all_analysis_group", Time.now)
      @app.delete_all_analysis_group
      if target = get_latest_file('de')
        res = update_group_position(target, 'de')
      end
      if target = get_latest_file('fr')
        res = update_group_position(target, 'fr')
      end
      LogFile.append('oddb/debug', " AnalysisPlugin update finished", Time.now)
      res 
    end
    def update_group_position(path, lang)
      LogFile.append('oddb/debug', " AnalysisPlugin update_group_position #{lang} #{path}", Time.now)
      parse_xls(path).each { |position|
        group = update_group(position)
        if(position[:analysis_revision] == 'S')
          delete_position(group, position)
        else
          position = update_position(group, position, lang)
        end
      }
      @app.recount
    end
    def get_latest_file(lang = 'de')
      agent = Mechanize.new
      url = "http://www.bag.admin.ch/themen/krankenversicherung/00263/00264/04185/index.html?lang=#{lang}"
      page = agent.get url
      keyword = if lang == 'de'
                  'Liste der Analysenpositionen'
                elsif lang == 'fr'
                  'Liste des positions relatives aux analyses'
                end
      links = page.links.select do |link|
        ptrn = keyword.gsub /[^A-Za-z]/u, '.'
        /#{ptrn}/iu.match link.attributes['title']
      end
      link = links.first or raise "could not identify url to analysis_#{lang}.xlsx (#{keyword})"
      file = agent.get(link.href)
      download = file.body
      latest = File.join @archive, "analysis_#{lang}_latest.xlsx"
      target = File.join @archive, @@today.strftime("analysis_#{lang}_%Y.%m.%d.xlsx")
      if(!File.exist?(latest) or download.size != File.size(latest))
        File.open(latest, 'w+') { |f| f.write download }
        File.open(target, 'w+') { |f| f.write download }
        LogFile.append('oddb/debug', " AnalysisPlugin saved get_latest_file as #{target} and #{latest}", Time.now)
        target
      else
        LogFile.append('oddb/debug', " AnalysisPlugin not saving get_latest_file #{target} ", Time.now)
        nil # not new file
      end
    end
    def parse_xls(path)
      workbook = RubyXL::Parser.parse(path)
      positions = []
      rows = 0
      workbook[0].each do |row|
        rows += 1
        if rows > 1
          unless row[COL[:group_position_code]]
            LogFile.append('oddb/debug', " AnalysisPlugin parse_xls skip row #{rows} chapter #{row[COL[:chapter]]}:", Time.now)
          end
          groupcd, poscd = row[COL[:group_position_code]].value.to_s.split('.')
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
    def update_position(group, position, language)
      poscd   = position.delete(:position)
      position.store(language, position.delete(:description))
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
        args = {language => lim_txt}
        lim = @app.update(lim_ptr.creator, args, :analysis)
        @app.update(pos.pointer, {:limitation_text => lim}, :anaylsis)
      end
      pos
    end
  end
end
