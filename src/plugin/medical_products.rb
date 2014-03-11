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
    ATC_CLASS_CODE    = 'medical product'
    ATC_CLASS_NAME_DE = 'Medizinprodukte ohne ATC-Klassierung'
    def initialize(app,  opts = {:files => ['*.docx']})
      super(app)
      @options = opts
      @@errors = []
      @@products = []
    end
    def report
      msg = "Read #{@@products.length} medical products\n\n"
      @@products.each{ |product| msg += product + "\n" }
      msg += "\n\nHad the following errors\n" if @@errors.size > 0
      @@errors.each{ |error| msg += error + "\n" }
      msg
    end

    def add_dummy_medical_product(atc_code = ATC_CLASS_CODE, lang = :de, name = ATC_CLASS_NAME_DE)
      pointer = if atc = @app.atc_class(atc_code)
          atc.pointer
        else
          Persistence::Pointer.new([:atc_class, atc_code]).creator
        end
      LogFile.debug ("Adding #{atc_code} #{lang} #{name}")
      @app.update(pointer.creator, lang => name)
    end
    
    def update
      data_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', defined?(Minitest) ? 'test' : '.', 'data', 'docx'))
      LogFile.debug "file #{@options[:files]} YDocx #{YDocx::VERSION} data_dir #{data_dir}"
      atc_code = @app.atc_class(atc_code) 
      atc_code = add_dummy_medical_product unless atc_code
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
            if pseudo_fi_text.packages
              pseudo_fi_text.packages.paragraphs.each{
                |paragraph|
              full_info = paragraph.text.gsub("\n","").gsub(/\s+/, ' ').gsub(' ,',',')
              m = full_info.match(/^(\d{13})/);
              next unless m
              ean = Ean13.new(m[1])
              number = ean[2..11] # 10 digits
              seqNr  = ean[7..8]  # 2 digits
              packNr = ean[9..11] # 3 digits
              LogFile.debug "Adding #{number} seq #{seqNr} pack #{packNr}"
              m3 = full_info.match(/^(\d{13})[\s,][\d\s]*([^\d,]+)/);
              commercial_localized = m3[2].strip
              m2 = paragraph.text.match(/(\d{13})($|\s|\W)(.+)(\d+)\s+(\w+)/)
              parts[ean] = [m2[3].strip, m2[4].strip, m2[5].strip ] if m2
              authHolder = pseudo_fi_text.distributor.paragraphs.first.strip.match(/^[^,\n]+/)[0]
              info = SwissmedicMetaInfo.new(number, nil, pseudo_fi_text.name, authHolder, nil)
              reg = TextInfoPlugin::create_registration(@app, info, seqNr, packNr)
              @@products << "#{pseudo_fi_text.lang} #{number} #{packNr}: #{pseudo_fi_text.name}"
              registration = @app.registration(number)
              unless registration
                  @app.registrations.store(number, reg)
                  @app.registrations.odba_store
                  registration = @app.registration(number)
              end
              sequence = registration.sequence(seqNr)
              unless unless sequence.atc_class
                LogFile.debug "Adding atc #{atc_code.code} to #{registration.iksnr} seq #{seqNr} pack #{packNr}"
                res = @app.update(sequence.pointer,  {:atc_class => atc_code.code }, :medical_product)
              end
              fachinfo = nil
              fachinfo ||= TextInfoPlugin::store_fachinfo(@app, registration, {pseudo_fi_text.lang => pseudo_fi_text})
              TextInfoPlugin::replace_textinfo(@app, fachinfo, registration, :fachinfo)
              if parts[ean]
                package = registration.sequence(seqNr).package(packNr)
                oldParts = package.parts
                pInfo = parts[ean]
                pSize = "#{pInfo[0]} #{pInfo[1]} #{pInfo[2]}"
              
                newPart = nil
                args = {:size => pSize}                 
                if oldParts == nil or oldParts.size == 0
                  newPart = package.create_part
                elsif oldParts.size != 1
                  msg = "File #{file} does not contain a chapter Packages with an ean13 inside"
                  @@errors << msg
                  LogFile.debug "#{msg}"
                  next
                end
                if (comform = @app.commercial_form_by_name(commercial_localized))
                  args[:commercial_form] =comform.pointer
                else
                  msg = "No commercial_form '#{commercial_localized}' for ean #{ean} "
                  @@errors << msg
                  LogFile.debug "#{msg}"
                end
                @app.update(package.parts.first.pointer, args, :medical_product)
                package.parts.first.odba_store
                package.odba_store
                package.fix_pointers unless defined?(MiniTest)
                @app.odba_isolated_store # Why doesn't @app.updated consider the Part class?
              end
            end
            }
          end
        }
      }
    end # update
  end # MedicalProductPlugin
end
