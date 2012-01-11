#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::AnalysisPlugin -- oddb.org -- 11.01.2012 -- mhatakeyama@ywesee.com
# ODDB::AnalysisPlugin -- oddb.org -- 09.06.2006 -- sfrischknecht@ywesee.com

$: << path = File.expand_path("../..", File.dirname(__FILE__)) unless $:.include?(path)

require 'plugin/plugin'
require 'model/analysis/group'
require 'spreadsheet'
require 'mechanize'

module ODDB
	class AnalysisPlugin < Plugin
    COL = {
      :chapter              => 0, # A
      :analysis_revision    => 1, # B
      :group_position_code  => 2, # C 
      :taxpoints            => 3, # D
      :description          => 4, # E
      :limitation_text      => 5, # F
      :taxnote              => 6, # G
      :lab_areas            => 7, # H
    }
    def initialize(app)
      @archive = File.join ARCHIVE_PATH, 'xls'
      FileUtils.mkdir_p @archive
      super
    end
    def update
      @app.delete_all_analysis_group
      if target = get_latest_file('de')
        update_group_position(target, 'de')
      end
      if target = get_latest_file('fr')
        update_group_position(target, 'fr')
      end
    end
		def update_group_position(path, lang)
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
      link = links.first or raise "could not identify url to analysis_#{lang}.xls (#{keyword})"
      file = agent.get(link.href)
      download = file.body
      latest = File.join @archive, 'analysis_de_latest.xls'
      target = File.join @archive, @@today.strftime("analysis_#{lang}_%Y.%m.%d.xls")
      if(!File.exist?(latest) or download.size != File.size(latest))
        file.save_as target
        target
      end
    end
    def parse_xls(path)
      workbook = Spreadsheet.open(path)
      positions = []
      workbook.worksheet(0).each do |row|
        groupcd, poscd = row[COL[:group_position_code]].split('.')
        if poscd
          positions << {
            :chapter     => row[COL[:chapter]],
            :analysis_revision => row[COL[:analysis_revision]],
            :group       => groupcd,
            :position    => poscd,
            :taxpoints   => row[COL[:taxpoints]],
            :description => row[COL[:description]],
            :limitation_text   => row[COL[:limitation_text]],
            :taxnote     => row[COL[:taxnote]],
            :lab_areas   => row[COL[:lab_areas]],
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
			poscd = position.delete(:position)
			position.store(language, position.delete(:description))
			lim_txt = position.delete(:limitation_text)
			taxnote = position.delete(:taxnote)
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
			if(taxnote)
				tn_ptr = pos.pointer + :taxnote
				args = {language => taxnote}
				tax = @app.update(tn_ptr.creator, args, :analysis)
        @app.update(pos.pointer, {:taxnote => tax}, :anaylsis)
			end
      pos
		end
	end
end
