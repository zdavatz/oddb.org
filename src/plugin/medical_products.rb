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
    @@products = []
    ATC_CLASS_CODE    = 'medical product'
    ATC_CLASS_NAME_DE = 'Medizinprodukte ohne ATC-Klassierung'
    PackageInfo       = Struct.new("PackageInfo", :ean13, :iksnr, :ikscat, :ikscd, :size_unit_info, :commercial_localized)
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
            fachinfo = nil
            parts = {}
            reg = nil
            packages = []
            LogFile.debug "file is #{file}"
            writer = ODDB::FiParse::TextinfoPseudoFachinfo.new
            pseudo_fi_text = nil
            open(file) { |fh| pseudo_fi_text = writer.extract(fh)}
            return false unless pseudo_fi_text.lang
            return false unless pseudo_fi_text.lang and pseudo_fi_text.packages

            # collect iniformation about each package, aka ean13
            pseudo_fi_text.packages.paragraphs.each{ |paragraph|
              packInfo = extract_package_info(paragraph)
              next unless packInfo
              packages << packInfo
            }
            packages.each{ |packInfo|
              LogFile.debug "Will TextInfoPlugin::create_registration #{pseudo_fi_text.name} #{packInfo.inspect}"
              registration = @app.registration(packInfo.iksnr)
              authHolder = pseudo_fi_text.distributor.paragraphs.first.strip.match(/^[^,\n]+/)[0]
              info = SwissmedicMetaInfo.new(packInfo.iksnr, nil, pseudo_fi_text.name, authHolder, nil)
              @@products << "#{pseudo_fi_text.lang} #{packInfo.iksnr} #{packInfo.ikscat} #{packInfo.ikscd}: #{pseudo_fi_text.name}"
              TextInfoPlugin::create_registration(@app, info, packInfo.ikscat, packInfo.ikscd)
              registration = @app.registration(packInfo.iksnr)
              registration.each_sequence { |seq| LogFile.debug "#{seq.iksnr} has seq #{seq.seqnr} #{seq.pointer.inspect}" }
              sequence = registration.sequence(packInfo.ikscat)
              @app.update(sequence.pointer, {:name_base => pseudo_fi_text.name}, :medical_product)
              unless sequence.atc_class
                res = @app.update(sequence.pointer,  {:atc_class => atc_code.code }, :medical_product)
              end
              fi_args =  {pseudo_fi_text.lang => pseudo_fi_text}
              fachinfo ||= TextInfoPlugin::store_fachinfo(@app, registration, fi_args)
              TextInfoPlugin::replace_textinfo(@app, fachinfo, registration, :fachinfo)
              package = sequence.package(packInfo.ikscd)
              oldParts = package.parts
              newPart = nil
              args = {:size => packInfo.size_unit_info}
              if oldParts == nil or oldParts.size == 0
                LogFile.debug "create_part "
                newPart = package.create_part
              elsif oldParts.size != 1
                report_error("File #{file} does not contain a chapter Packages with an ean13 inside")
                next
              end
              if (comform = @app.commercial_form_by_name(packInfo.commercial_localized))
                args[:commercial_form] = comform.pointer
              else
                report_error("No commercial_form '#{packInfo.commercial_localized}' for ean #{packInfo.ean13}")
              end
              sequence.fix_pointers unless defined?(MiniTest)
              @app.update(package.parts.first.pointer, args, :medical_product)
            }
        }
      }
    end # update
   private
    def report_error(msg)
      @@errors << msg
      LogFile.debug msg
    end

    def extract_package_info(paragraph)
      raw = paragraph.text.gsub("\n","").gsub(/\s+/, ' ').gsub(' ,',',')
      m = raw.match(/^(\d{13})/);
      return nil unless m
      packInfo = PackageInfo.new
      packInfo.ean13 = Ean13.new(m[1])
      packInfo.iksnr  = packInfo.ean13[2..11].clone # 10 digits
      packInfo.ikscat = packInfo.ean13[7..8].clone # 2 digits sequence nr
      packInfo.ikscd  = packInfo.ean13[9..11].clone # 3 digits package nr
      packInfo.commercial_localized = raw.match(/^(\d{13})[\s,][\d\s]*([^\d,]+)/)[2].strip
      m2 = paragraph.text.match(/(\d{13})($|\s|\W)(.+)(\d+)\s+(\w+)/)
      if m2
        pInfo = [m2[3].strip, m2[4].strip, m2[5].strip ]
        packInfo.size_unit_info = "#{pInfo[0]} #{pInfo[1]} #{pInfo[2]}"
      end
      packInfo
    end
  end # MedicalProductPlugin
end
