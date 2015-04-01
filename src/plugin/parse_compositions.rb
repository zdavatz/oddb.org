# encoding: utf-8

# This file is shared since oddb2xml 2.0.0 (lib/oddb2xml/parse_compositions.rb)
# with oddb.org src/plugin/parse_compositions.rb
#
# It allows an easy parsing of the column P Zusammensetzung of the swissmedic packages.xlsx file
#

module ParseUtil
  SCALE_P = %r{pro\s+(?<scale>(?<qty>[\d.,]+)\s*(?<unit>[kcmuµn]?[glh]))}u
  ParseComposition   = Struct.new("ParseComposition",  :source, :label, :label_description, :substances, :galenic_form, :route_of_administration)
  ParseSubstance     = Struct.new("ParseSubstance",    :name, :qty, :unit, :chemical_substance, :chemical_dose)
  def ParseUtil.capitalize(string)
    string.split(/\s+/u).collect { |word| word.capitalize }.join(' ')
  end

  def ParseUtil.parse_compositions(composition)
    rep_1 = '----';   to_1 = '('
    rep_2 = '-----';  to_2 = ')'
    rep_3 = '------'; to_3 = ','

    comps = []
    label_pattern = /^(?<label>A|I|B|II|C|III|D|IV|E|V|F|VI)(\):|\))\s*(?<description>[^:]+)/
    composition_text = composition.gsub(/\r\n?/u, "\n")
    puts "composition_text for #{name}: #{composition_text}" if composition_text.split(/\n/u).size > 1 and $VERBOSE
    lines = composition_text.split(/\n/u)
    idx = 0
    compositions = lines.select do |line|
      if match = label_pattern.match(line)
        label = match[:label]
        label_description = match[:description]
      else
        label = nil
        label_description = nil
      end
      idx += 1
      next if idx > 1 and /^(?<label>A|I|B|II|C|III|D|IV|E|V|F|VI)[)]\s*(et)/.match(line) # avoid lines like 'I) et II)'
      next if idx > 1 and /^Corresp\./i.match(line) # avoid lines like 'Corresp. mineralia: '
      substances = []
      filler = line.split(',')[-1].sub(/\.$/, '')
      filler_match = /^(?<name>[^,\d]+)\s*(?<dose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))))/.match(filler)
      components = line.split(/([^\(]+\([^)]+\)[^,]+|),/).each {
        |component|
        # require 'pry'; binding.pry
        next unless component.size > 0
        to_consider = component.strip.split(':')[-1].gsub(to_1, rep_1).gsub(to_2, rep_2).gsub(to_3, rep_3) # remove label
        # very ugly hack to ignore ,()
        ptrn1 = /^(?<name>.+)\s+(?<dose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))))/
        m = ptrn1.match(to_consider)
        if m2 = /^(|[^:]+:\s)(E\s+\d+)$/.match(component.strip)
          to_add = ParseSubstance.new(m2[2], '', '')
          substances << to_add
        elsif m
          ptrn = /(?<name>.+)\s+(?<dose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))))(\s*(?:ut|corresp\.?)\s+(?<chemical>[^\d,]+)\s*(?<cdose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))(\s*[mv]\/[mv])?))?)/
          m3 = ptrn.match(to_consider)
          m = m3 if m3
          dose = nil
          unit = nil
          name = m[:name].split(/\s/).collect{ |x| x.capitalize }.join(' ').strip.gsub(rep_3, to_3).gsub(rep_2, to_2).gsub(rep_1, to_1)
          dose = m[:dose].split(/\b\s*(?![.,\d\-]|Mio\.?)/u, 2) if m[:dose]
          if dose && (scale = SCALE_P.match(filler)) && dose[1] && !dose[1].include?('/')
            unit = dose[1] << '/'
            num = scale[:qty].to_f
            if num <= 1
              unit << scale[:unit]
            else
              unit << scale[:scale]
            end
          elsif dose.size == 2
            unit = dose[1]
          end
          next if /\s+pro($|\s+)|emulsion|solution/i.match(name)
          chemical = m3 ? capitalize(m3[:chemical]) : nil
          cdose    = m3 ? m3[:cdose] : nil
          substances << ParseSubstance.new(name, dose ? dose[0].to_f : nil, unit ? unit.gsub(rep_3, to_3).gsub(rep_2, to_2).gsub(rep_1, to_1) : nil,
                                      chemical, cdose)
        end
      }
      comps << ParseComposition.new(line, label, label_description, substances) if substances.size > 0
    end
    comps
  end
end