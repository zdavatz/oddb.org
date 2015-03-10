#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/persistence'
require 'drb'
require 'model/epha_interaction'

module ODDB
  class EphaInteractionPlugin < Plugin
    @@report = []

    def debug_msg(msg)
      if defined?(MiniTest) then $stdout.puts Time.now.to_s + ': ' + msg; $stdout.flush; return end
      if not defined?(@checkLog) or not @checkLog
        name = LogFile.filename('oddb/debug/', Time.now)
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, 'a+')
        $stdout.puts "Opened #{name}"
      end
      @checkLog.puts("#{Time.now}: #{msg}")
      @checkLog.flush
    end

    def initialize(app, options = nil)
      super
    end
    def report
      @@report.join("\n")
    end
        
    def update(agent=Mechanize.new, csv_file_path = ODDB::EphaInteractions::CSV_FILE)
      @@report = []
      latest = csv_file_path.sub(/\.csv$/, '-latest.csv')
      if EphaInteractions.get.size > 0 and File.exist?(latest) and ((Time.now-File.mtime(latest))/3600).round < 24 # less than 24 hours old
        msg = "EphaInteractionPlugin.update: skip #{EphaInteractions.get.size } items as latest #{latest} #{File.exist?(latest)} is only #{((Time.now-File.mtime(latest))/3600).round} hours old"
        @@report << msg
        debug_msg(msg)
      else
        FileUtils.rm_f(csv_file_path, :verbose => true)
        target = agent.get(ODDB::EphaInteractions::CSV_ORIGIN_URL)
		if target.is_a?(String)
			File.open(csv_file_path, 'w+') { |file| file.write(target) }
		else
			target.save_as csv_file_path
		end
        FileUtils.cp(csv_file_path,  latest, :preserve => true, :verbose => true)
        msg = "EphaInteractionPlugin.update latest #{latest} #{File.exists?(latest)} via #{File.expand_path(csv_file_path)} from #{ODDB::EphaInteractions::CSV_ORIGIN_URL}"
        @@report << msg
        debug_msg(msg)
        @lineno = 0
        first_line = nil
        @app.delete_all_epha_interactions
        File.readlines(latest).each do |line|
          @lineno += 1
          line = line.force_encoding('utf-8')
          next if /ATC1.*Name1.*ATC2.*Name2/.match(line)
          begin
            elements = CSV.parse_line(line)
          rescue CSV::MalformedCSVError
            msg << "CSV::MalformedCSVError in line #{@lineno}: #{line}"
            next
          end
          next if elements.size == 0 # Eg. empty line at the end
          epha_interaction = @app.create_epha_interaction(elements[0], elements[2])
          epha_interaction.atc_code_self = elements[0]
          epha_interaction.atc_name = elements[1]
          epha_interaction.atc_code_other = elements[2]
          epha_interaction.name_other = elements[3]
          epha_interaction.info = elements[4]
          epha_interaction.action = elements[5]
          epha_interaction.effect = elements[6]
          epha_interaction.measures = elements[7]
          epha_interaction.severity = elements[8]
          EphaInteractions.get[ [epha_interaction.atc_code_self, epha_interaction.atc_code_other  ]] = epha_interaction
          epha_interaction.odba_isolated_store
        end
        @app.odba_store
        msg = "Added #{EphaInteractions.get.size} interactions from #{latest}";
        @@report << msg
        debug_msg(msg)
      end
      true
    end
  end
end
