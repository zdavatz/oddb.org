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
    CSV_FILE = File.expand_path('../../data/csv/interactions_de_utf8.csv', File.dirname(__FILE__))
    CSV_ORIGIN_URL  = 'http://community.epha.ch/interactions_de_utf8.csv'
    
    def initialize(app)
      super
    end
    def report
      "Read Epha Interactions: #{@app.epha_interactions.length}\n"
    end
        
    def update(csv_file_path = nil)
      unless csv_file_path and File.exist?(csv_file_path)
        csv_file_path = CSV_FILE
        target = Mechanize.new.get(CSV_ORIGIN_URL)
        target.save_as csv_file_path
        # $stdout.puts  "EphaInteractionPlugin.update: #{File.expand_path(csv_file_path)} ?  #{File.exists?(csv_file_path)}"
      end
      if File.exist?(csv_file_path)
        # $stdout.puts "deleting #{@app.epha_interactions.size} epha_interactions class #{@app.epha_interactions.class}"; $stdout.flush
        @app.delete_all_epha_interactions
        @lineno = 0
        first_line = nil
        File.readlines(csv_file_path).each do |line|
          unless first_line
            first_line = line
            # $stdout.puts "first: "+ first_line
            next
          end
          @lineno += 1
          # $stdout.puts  "#{Time.now} #{@lineno}: #{line}"; $stdout.flush
          elements = line.chomp.split(';')
          values = Hash.new
          elements.each{ |elem| elem.gsub!(/^"|"$/,'') }
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
        end
        # $stdout.puts  "#{Time.now} read #{@lineno} lines. Storing the results"; $stdout.flush
        @app.epha_interactions.each{|item| item.odba_store }
        @app.epha_interactions.odba_store unless defined?(MiniTest) # Niklaus does not know howto mock easily this command
        @app.odba_store
      end
    end
  end
end
