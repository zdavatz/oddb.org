#!/usr/bin/env ruby
require "model/patinfo"
require "textinfo_html_parser"

module ODDB
  module FiParse
    class PatinfoHtmlParser < TextinfoHtmlParser
      attr_reader :amendments, :amzv, :composition, :contra_indications,
        :date, :distribution, :effects, :iksnrs, :fabrication, :galenic_form,
        :general_advice, :packages, :precautions, :pregnancy,
        :unwanted_effects, :usage
      def identify_chapter(code, chapter)
        case code
        when "7600"
          @amzv = chapter
        when "2000", "7620"
          @effects = chapter
        when "2500", "7640"
          @amendments = chapter
        when "3000", "7625", "7660", "7680"
          @contra_indications = chapter
        when "3500", "7700"
          @precautions = chapter
        when "4000", "7720"
          @pregnancy = chapter
        when "4500", "7740"
          @usage = chapter
        when "5000", "7760"
          @unwanted_effects = chapter
        when "5500", "7780"
          @general_advice = chapter
        when "6000", "7840"
          @composition = chapter
        when "7860"
          @iksnrs = chapter
        when "6500", "7880"
          @packages = chapter
        when "7000", "7900"
          @distribution = chapter
        when "7920"
          @fabrication = chapter
        when "7930"
          @delivery = chapter
        when "7520", "7940", "7950"
          if @date # we are overwriting an existing @date
            chapter.sections = @date.sections
          end
          @date = chapter
        when "9000"
          @company = chapter
        when nil # special chapers without heading
          case chapter.to_s
          when /^\d{5}/u
            @iksnrs ||= chapter
          when /\b\d{4}\b/u
            @date ||= chapter
          end
        when "9010" # swissmedicinfo
          # 56933_pi_fr_Cimifemine.html  would assign Cimifemine® forte comprimés
          @name = chapter unless /^$|AMZV|^\w+ Arzneimittel|^Médicament|^Wann |^Was /.match(chapter.heading)
        else
          raise "Unknown chapter-code #{code}, while parsing #{@name}"
        end
      end

      def to_textinfo
        pat = if @amzv
          pat = PatinfoDocument2001.new
          pat.amzv = @amzv
          pat
        else
          pat = PatinfoDocument.new
          pat
        end
        pat.iksnrs = @iksnrs
        pat.name = @name
        pat.company = @company
        pat.galenic_form = @galenic_form
        pat.effects = @effects
        pat.amendments = @amendments
        pat.contra_indications = @contra_indications
        pat.precautions = @precautions
        pat.pregnancy = @pregnancy
        pat.usage = @usage
        pat.unwanted_effects = @unwanted_effects
        pat.general_advice = @general_advice
        # pat.other_advice      = @other_advice ## not identified yet.
        pat.composition = @composition
        pat.packages = @packages
        pat.distribution = @distribution
        pat.fabrication = @fabrication
        pat.date = @date
        pat
      end

      private

      def detect_chapter(elem)
        pp unless /^section[0-9]*$/.match?(elem.attributes["id"].to_s)
        return [nil, nil] unless /^section[0-9]*$/.match?(elem.attributes["id"].to_s)
        # TODO
        #   Update chapter detection if swissmedic repairs FI/PI format.
        #
        #   Currently, id attribute 'section*' is not fixed number.
        #   And Section order is also not fixed :(

        res = PatinfoHtmlParser.text_to_chapter(text(elem))
        pp res
        res
      end

      def self.text_to_chapter(text)
        code =
          case text
          when /^Was\s*sollte\s*dazu\s*beachtet\s*werden|^De\s*quai\s*faut-il|^De quoi faut-il tenir/ then "7640"
          when /^Wann\s*(darf|d.rfen)\s*.*nicht\s*.*werden\??|^Quand\s*.*ne\sdoit-(il|elle)|Quand \S+ ne/ then "7680"
          when /^(Was|Wann)\s*.*angewendet[\?]?|^Qu.est-ce\s*que/ then "7620"
          when /^Quand \S+ (est|sont)-.*/ then "7620"
          when /^Wann\s*ist\s*bei\s*der\s*[\w\s\/]*Vorsicht\s*geboten\??|^Quelles\s*sont\s*les\s*pr.cautions/ then "7700"
          when /Schwangerschaft|pendant\s*la\s*grossesse\s*ou\s*l.allaitement\??/ then "7720"
          when /^Wie\s*verwenden\s*Sie|^Comment\s*utiliser/ then "7740"
          when /^Welche\s*Nebenwirkungen\s*(kann|k.nnen)|^Quels\s*effets\s*secondaires/ then "7760"
          when /^Was\s*ist\s*ferner\s*zu\s*beachten\??|^.\s*quoi\s*faut-il\s*encore\s*faire\s*attention\??/ then "7780"
          when /^Was\s*ist[\w\s,\-]*enthalten\??|^Que\s*contient/ then "7840"
          when /^Zulassungsnummer|^Num.ro\s*d.autorisation/ then "7860"
          when /^Wo\s*erhalten\s*Sie|^O.\s*obtenez-vous|^Que contiennent \S+/ then "7880"
          when /^Herstellerin|^Fabricant/ then "7920"
          when /^Diese\s*Packungsbeilage\s*wurde|^Cette\s*notice\s*/ then "7940"
          when /^Zulassungsinhaberin(en)?|^Titulaire\s*de\s*l.autorisation/ then "9000"
          when /^Name\s*des\s*Pr.parate[s].*|^Nom\s*de\s*la\s*pr.paration|^(\S+ )?Arzneimittel\(*/ then "9010"
          when /^Kurzcharakteristikum|^Caract.ristique\s*.\s*court|^Médicament.*/ then "9010"
          end
        [code, text]
      end
    end
  end
end
