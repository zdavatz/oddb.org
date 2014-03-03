#!/usr/bin/env ruby
# encoding: UTF-8
  $: << File.expand_path('../..', File.dirname(__FILE__))
  $: << File.expand_path('../../src', File.dirname(__FILE__))
  $: << File.expand_path('../../ext/fiparse/src', File.dirname(__FILE__))

  require 'plugin/plugin'
  require 'model/text'
  require 'util/oddbconfig'
  require 'util/persistence'
  require 'drb'
  require 'ydocx'
  require 'src/plugin/text_info'
  require 'ydocx/templates/fachinfo'
  require 'textinfo_pseudo_fachinfo'

  module ODDB
  class MedicalProductPlugin < Plugin
    @@errors = []
    @@products = []
    def initialize(app,  opts = {:files => ['*.docx'], :lang => 'de'})
      super(app)
      @options = opts
      @@errors = []
      @@products = []
    end
    def report
      msg = "Read Medical Products: #{@@products.length}\n\n"
      @@products.each{ |product| msg += product + "\n" }
      msg += "\n\nHad the following errors\n" if @@errors.size > 0
      @@errors.each{ |error| msg += error + "\n" }
      msg
    end

    def update
      @options[:lang] = 'de' unless @options[:lang]
      lang = @options[:lang].to_s
      data_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', defined?(Minitest) ? 'test' : '.', 'data', 'medical_products'))
      pp data_dir
      LogFile.debug "file #{@options[:files]} lang #{lang} #{lang.class} YDocx #{YDocx::VERSION}"
      @options[:files].each{
        |param|
        files = (Dir.glob(param) + Dir.glob(File.join(data_dir, param))).collect{ |file| File.expand_path(file) }.uniq
        files.each {
          |file|
            parts = {}
            number = -1
            reg = nil
            LogFile.debug "file is #{file}"
            writer = ODDB::FiParse::TextinfoPseudoFachinfo.new
            fachinfo = nil
            open(file) { |fh| fachinfo = writer.extract(fh)}
            fachinfo.iksnrs.each{
                        |ean|
                          number = ean[2..2+6] # 7 digits
                          packNr = ean[9..11] # 3 digits
                          info = SwissmedicMetaInfo.new(number, nil, fachinfo.name, fachinfo.distributor, nil)
                          reg = TextInfoPlugin::create_registration(@app, info, '00', packNr)
                          @@products << "#{lang} #{number} #{packNr}: #{fachinfo.name}"
                          if parts[ean] 
                            package = reg.sequence('00').package(packNr)
                            pInfo = parts[ean]
                            pSize = "#{pInfo[0]} #{pInfo[1]} #{pInfo[2]}"
                          end
                       }
            registration = @app.registration(number)
            unless registration
                @app.registrations.store(number, reg)
                @app.registrations.odba_store
                registration = @app.registration(number)
            end
            TextInfoPlugin::replace_textinfo(@app, fachinfo, registration, :fachinfo)
            fachinfo.iksnrs.each{
                        |ean|
                          number = ean[2..2+6] # 7 digits
                          packNr = ean[9..11] # 3 digits
                          if parts[ean]
                            package = registration.sequence('00').package(packNr)
                            oldParts = package.parts
                            pInfo = parts[ean]
                            # in plugin/swissmedic.rb
                            # :size => [cell(row, column(:size)), cell(row, column(:unit))].compact.join(' '),
                            pSize = "#{pInfo[0]} #{pInfo[1]} #{pInfo[2]}"
                            newPart = nil
                            if oldParts == nil or oldParts.size == 0
                              newPart = package.create_part
                            elsif oldParts.size != 1
#                               msg = "Found #{oldParts.size} parts. Problem in database with #{lang} #{number} #{packNr}: #{fachinfo.name}"
                              @@errors << msg
                              LogFile.debug "#{msg}"
                              next
                            end
                            @app.update(package.parts.first.pointer, {:size => pSize}, :medical_product)
                            package.parts.first.odba_store
                            package.odba_store
                            package.fix_pointers
                            @app.odba_isolated_store # Why doesn't @app.updated consider the Part class?
                          end
                       }
          }
      }
    end
  end
end
