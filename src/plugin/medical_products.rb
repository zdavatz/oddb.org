#!/usr/bin/env ruby
# encoding: UTF-8
  $: << File.expand_path('../..', File.dirname(__FILE__))
  $: << File.expand_path('../../src', File.dirname(__FILE__))

  require 'plugin/plugin'
  require 'util/oddbconfig'
  require 'util/persistence'
  require 'drb'
  require 'ydocx'
  require 'src/plugin/text_info'
  require 'ydocx/templates/fachinfo'
  module ODDB
  class MedicalProductPlugin < Plugin
    @@errors = []
    @@products = []
  ChapterDef = {
        'de' => {
        'name'                 => /^Name\s+des\s+Präparates$/u, # 1
        'composition'          => /^Zusammensetzung|Wirkstoffe|Hilsstoffe/u, # 2
        'galenic_form'         => /^Galenische\s+Form\s*(und|\/)\s*Wirkstoffmenge\s+pro\s+Einheit$/iu, # 3
        'indications'          => /^Indikationen(\s+|\s*(\/|und)\s*)Anwendungsmöglichkeiten$/u, # 4
        'usage'                => /^Dosierung\s*(\/|und)\s*Anwendung/u, # 5
        'contra_indications'   => /^Kontraindikationen($|\s*\(\s*absolute\s+Kontraindikationen\s*\)$)/u, # 6
        'restrictions'         => /^Warnhinweise\s+und\s+Vorsichtsmassnahmen($|\s*\/\s*(relative\s+Kontraindikationen|Warnhinweise\s*und\s*Vorsichtsmassnahmen)$)/u, # 7
        'interactions'         => /^Interaktionen$/u, # 8
        'pregnancy'            => /^Schwangerschaft(,\s*|\s*\/\s*|\s+und\s+)Stillzeit$/u, # 9
        'driving_ability'      => /^Wirkung\s+auf\s+die\s+Fahrtüchtigkeit\s+und\s+auf\s+das\s+Bedienen\s+von\s+Maschinen$/u, # 10
        'unwanted_effects'     => /^Unerwünschte\s+Wirkungen$/u, # 11
        'overdose'             => /^Überdosierung$/u, # 12
        'effects'              => /^Eigenschaften\s*\/\s*Wirkungen($|\s*\(\s*(ATC\-Code|Wirkungsmechanismus|Pharmakodyamik|Klinische\s+Wirksamkeit)\s*\)\s*$)/iu, # 13
        'kinetic'              => /^Pharmakokinetik($|\s*\((Absorption,\s*Distribution,\s*Metabolisms,\s*Elimination\s|Kinetik\s+spezieller\s+Patientengruppen)*\)$)/iu, # 14
        'preclinic'            => /^Präklinische\s+Daten$/u, # 15
        'other_advice'         => /^Sonstige\s*Hinweise($|\s*\(\s*(Inkompatibilitäten|Beeinflussung\s*diagnostischer\s*Methoden|Haltbarkeit|Besondere\s*Lagerungshinweise|Hinweise\s+für\s+die\s+Handhabung)\s*\)$)|^Remarques/u, # 16
        'iksnrs'               => /^Zulassungsnummer(n|:|$|\s*\(\s*Swissmedic\s*\)$)/u, # 17
        'packages'             => /^Packungen($|\s*\(\s*mit\s+Angabe\s+der\s+Abgabekategorie\s*\)$)/u, # 18
        'registration_owner'   => /^Zulassungsinhaberin($|\s*\(\s*Firma\s+und\s+Sitz\s+gemäss\s*Handelsregisterauszug\s*\))/u, # 19
        'date'                 => /^Stand\s+der\s+Information$/iu, # 20
        'fabrication'          => /^Herstellerin/u,
        'distributor'              => /^Vertriebsfirma/u,
        },
        'fr' => {
          'name'                => /^Nom$/u, # 1
          'composition'         => /^Composition$/u, # 2
          'galenic_form'        => /^Forme\s+galénique\s+et\s+quantité\s+de\s+principe\s+actif\s+par\s+unité|^Forme\s*gal.nique/iu, # 3
          'indications'         => /^Indications/u, # 4
          'usage'               => /^Posologiei/u, # 5
          'contra_indications'  => /^Contre\-indications/iu, # 6
          'restrictions'        => /^Mises/u, # 7
          'interactions'        => /^Interactions/u, # 8
          'pregnancy'           => /^Grossesse\s*\/\s*Allaitement/u, # 9
          'driving_ability'     => /^Effet\s+sur\s+l'aptitude\s+&agrave;\s+la\s+conduite\s+et\s+l'utilisation\s+de\s+machines/u, # 10
          'unwanted_effects'    => /^Effets/u, # 11
          'overdose'            => /^Surdosage$/u, # 12
          'effects'             => /^Propriétés/iu, # 13
          'kinetic'             => /^Pharmacocinétique$/iu, # 14
          'preclinic'           => /^Données\s+précliniques$/u, # 15
          'other_advice'        => /^Remarques/u, # 16
          'iksnrs'              => /^Numéro\s+d'autorisation$/u, # 17
          'packages'            => /^Présentation/iu, # 18
          'registration_owner'  => /^Titulaire\s+de\s+l'autorisation$/u, # 19
          'date'                => /^Mise à jour/iu, # 20
          'fabrication'         => /^Fabricant$/u,
          'distributor'             => /^Distributeur/u,
        }
      }
    
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
      data_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', defined?(Minitest) ? 'test' : '.', 'data', 'medical_products', lang))
      LogFile.debug "file #{@options[:files]} lang #{lang} #{lang.class} YDocx #{YDocx::VERSION}"
      @options[:files].each{
        |param|
        files = (Dir.glob(param) + Dir.glob(File.join(data_dir, param))).collect{ |file| File.expand_path(file) }.uniq
        files.each {
          |file|
            LogFile.debug "file is #{file}"
            doc = YDocx::Document.open(file, {:lang => @options[:lang]})
            xml_file = file.sub('.docx', '.xml')
            doc.to_xml(xml_file, {})
            out = doc.output_file('xml')
            doc_xml = Nokogiri::XML(open(xml_file))
            chapters = {}
            ean13s = []
            parts = {}
            number = -1
            name = doc_xml.xpath('//chapters/paragraph').text
            doc_xml.xpath('//chapters/chapter').each{
              |x|
              next if x.xpath('heading').size == 0;
              chapterName = nil
              localizedName = x.xpath('heading').text
              ChapterDef[lang].each{
                              |key, value|
                                if localizedName.match(value)
                                  chapterName = key
                                  break
                                end
                              }
              next unless chapterName
              chapters[chapterName] = x.xpath('paragraph').text
              if chapterName.match(/packages|other_advice/)
                x.xpath('paragraph').each {
                |p| m  = p.text.match(/(\d{13})($|\s|\W)/); ean13s << m[1] if m
                    m2 = p.text.match(/(\d{13})($|\s|\W)(.+)(\d+)\s+(\w+)/)
                    LogFile.debug "#{lang} parts m2 #{m2.inspect}" if m2
                    parts[m2[1]] = [m2[3].strip, m2[4].strip, m2[5].strip ] if m2
                                          }
              end
            }
            unless ean13s.size > 0
              msg = "File #{file} does not contain a chapter Packages with an ean13 inside"
              @@errors << msg
              LogFile.debug "#{msg}"
              next
            end
            distributor = chapters['distributor']
            idx = distributor.index(/,|\n/)
            distributor = distributor[0..idx-1]
            reg = nil
            ean13s.each{
                        |ean|
                          number = ean[2..2+6] # 7 digits
                          packNr = ean[9..11] # 3 digits
                          info = SwissmedicMetaInfo.new(number, nil, name, distributor, nil)
                          reg = TextInfoPlugin::create_registration(@app, info, '00', packNr)
                          @@products << "#{lang} #{number} #{packNr}: #{name}"
                          if parts[ean] 
                            package = reg.sequence('00').package(packNr)
                            pInfo = parts[ean]
                            pSize = "#{pInfo[0]} #{pInfo[1]} #{pInfo[2]}"
                          end
                       }
            parser = DRb::DRbObject.new nil, FIPARSE_URI
            registration = @app.registration(number)
            unless registration
                @app.registrations.store(number, reg)
                @app.registrations.odba_store
                registration = @app.registration(number)
            end
            parsed_info = parser.parse_fachinfo_docx(file, number, lang)
            fachinfo = nil
            fachinfo ||= TextInfoPlugin::store_fachinfo(@app, reg, {lang => parsed_info})
            TextInfoPlugin::replace_textinfo(@app, fachinfo, reg, :fachinfo)
            ean13s.each{
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
                              msg = "Found #{oldParts.size} parts. Problem in database with #{lang} #{number} #{packNr}: #{name}"
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
