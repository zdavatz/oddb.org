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
    def initialize(app,  opts = {:files => ['*.docx']})
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
      data_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', defined?(Minitest) ? 'test' : '.', 'data', 'medical_products'))
      LogFile.debug "file #{@options[:files]} YDocx #{YDocx::VERSION} data_dir #{data_dir}"
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
            pseudo_fi_text = nil
            open(file) { |fh| pseudo_fi_text = writer.extract(fh)}
            return false unless pseudo_fi_text.lang
            pseudo_fi_text.iksnrs.each{
                        |ean|
                          number = ean[2..2+6] # 7 digits
                          packNr = ean[9..11] # 3 digits
                          authHolder = pseudo_fi_text.distributor.paragraphs.first.strip.match(/^[^,\n]+/)[0]
                          info = SwissmedicMetaInfo.new(number, nil, pseudo_fi_text.name, authHolder, nil)
                          reg = TextInfoPlugin::create_registration(@app, info, '00', packNr)
                          @@products << "#{pseudo_fi_text.lang} #{number} #{packNr}: #{pseudo_fi_text.name}"
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
            fachinfo = nil
            fachinfo ||= TextInfoPlugin::store_fachinfo(@app, registration, {pseudo_fi_text.lang => pseudo_fi_text})
            TextInfoPlugin::replace_textinfo(@app, fachinfo, registration, :fachinfo)
            pseudo_fi_text.iksnrs.each{
                        |ean|
                          number = ean[2..2+6] # 7 digits
                          packNr = ean[9..11] # 3 digits
                          if parts[ean]
                            package = registration.sequence('00').package(packNr)
                            oldParts = package.parts
                            pInfo = parts[ean]
                            pSize = "#{pInfo[0]} #{pInfo[1]} #{pInfo[2]}"
                            newPart = nil
                            if oldParts == nil or oldParts.size == 0
                              newPart = package.create_part
                            elsif oldParts.size != 1
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
