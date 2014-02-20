#!/usr/bin/env ruby
# encoding: UTF-8
  $: << File.expand_path('../..', File.dirname(__FILE__))
  $: << File.expand_path('../../src', File.dirname(__FILE__))

  require 'plugin/plugin'
  require 'util/oddbconfig'
  require 'util/persistence'
  require 'drb'
  require 'model/medical_product'
  require 'ydocx'

  module ODDB
  class MedicalProductPlugin < Plugin
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
        'fabrication'          => /^Herstellerin$/u,
        },
        'fr' => {
          'name'                => /^Nom$/u, # 1
          'composition'         => /^Composition$/u, # 2
          'galenic_form'        => /^Forme\s+galénique\s+et\s+quantité\s+de\s+principe\s+actif\s+par\s+unité|^Forme\s*gal.nique/iu, # 3
          'indications'         => /^Indications\s*\/\s*Possibilités\s+d'emploi/u, # 4
          'usage'               => /^Posologie\s*\/\s*Mode\s+d'emploi/u, # 5
          'contra_indications'  => /^Contre\-indications$/iu, # 6
          'restrictions'        => /^Mises\s+en\s+garde\s+et\s+précautions/u, # 7
          'interactions'        => /^Interactions$/u, # 8
          'pregnancy'           => /^Grossesse\s*\/\s*Allaitement/u, # 9
          'driving_ability'     => /^Effet\s+sur\s+l'aptitude\s+&agrave;\s+la\s+conduite\s+et\s+l'utilisation\s+de\s+machines/u, # 10
          'unwanted_effects'    => /^Effets\s+indésirables$/u, # 11
          'overdose'            => /^Surdosage$/u, # 12
          'effects'             => /^Propriétés\s*\/\s*Effets$/iu, # 13
          'kinetic'             => /^Pharmacocinétique$/iu, # 14
          'preclinic'           => /^Données\s+précliniques$/u, # 15
          'other_advice'        => /^Remarques\s+particuli&egrave;res$/u, # 16
          'iksnrs'              => /^Numéro\s+d'autorisation$/u, # 17
          'packages'            => /^Présentation$/u, # 18
          'registration_owner'  => /^Titulaire\s+de\s+l'autorisation$/u, # 19
          'date'                => /^Mise\s+.\s+jour$|^Etat\s+de\s+l'information/iu, # 20
          'fabrication'         => /^Fabricant$/u,
        }
      }
    
    def initialize(app,  opts={})
      super(app)
      @options = opts
    end
    def report
      "Read Medical Products: #{@app.medical_products.length}\n"
    end

    def update(options = {:files => ['*.docx'], :lang => 'de'})
      require 'ydocx/templates/fachinfo'
      options[:lang] = 'de' unless options[:lang]
      lang = options[:lang]
      data_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', defined?(Minitest) ? 'test' : '.', 'data', 'medical_products', lang))
      $stdout.puts  "#{Time.now}: file #{options[:files]} lang #{lang} #{lang.class} YDocx #{YDocx::VERSION}"
      options[:files].each{
        |param|
        files = (Dir.glob(param) + Dir.glob(File.join(data_dir, param))).collect{ |file| File.expand_path(file) }.uniq
        files.each {
          |file|
            $stdout.puts  "#{Time.now}: file is #{file}" ; $stdout.flush
            doc = YDocx::Document.open(file)
            xml_file = file.sub('.docx', '.xml')
            doc.to_xml(xml_file, {})
            out = doc.output_file('xml')
            doc_xml = Nokogiri::XML(open(xml_file))
            chapters = {}
            ean13s = []
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
              chapters[chapterName] = x.xpath('paragraph').text
              if chapterName.match(/packages/)
                x.xpath('paragraph').each {
                |p| m= p.text.match(/(\d{13})($|\s|\W)/); ean13s << m[1] if m
                                          }
              end
            }
            medical_product = @app.create_medical_product(name)
            medical_product.ean13s = ean13s
            medical_product.chapters = chapters
            @app.odba_store
            @app.medical_products.odba_store unless defined?(MiniTest)
            @app.medical_products.each{|item| item.odba_store}
            medical_product
          }
      }
    end
  end
end
