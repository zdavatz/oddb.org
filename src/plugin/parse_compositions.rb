# encoding: utf-8

# This file is shared since oddb2xml 2.0.0 (lib/oddb2xml/parse_compositions.rb)
# with oddb.org src/plugin/parse_compositions.rb
#
# It allows an easy parsing of the column P Zusammensetzung of the swissmedic packages.xlsx file
#

module ParseUtil
  SCALE_P = %r{pro\s+(?<scale>(?<qty>[\d.,]+)\s*(?<unit>[kcmuµn]?[glh]))}u
  ParseComposition   = Struct.new("ParseComposition",  :source, :label, :label_description, :substances, :galenic_form, :route_of_administration)
  ParseSubstance     = Struct.new("ParseSubstance",    :name, :qty, :unit, :chemical_substance, :chemical_qty, :chemical_unit, :is_active_agent, :dose, :cdose)
  def ParseUtil.capitalize(string)
    string.split(/\s+/u).collect { |word| word.capitalize }.join(' ')
  end

  def ParseUtil.dose_to_qty_unit(string, filler=nil)
    return nil unless string
    dose = string.split(/\b\s*(?![.,\d\-]|Mio\.?)/u, 2)
    if dose && (scale = SCALE_P.match(filler)) && dose[1] && !dose[1].include?('/')
      unit = dose[1] << '/'
      num = scale[:qty].to_f
      if num <= 1
        unit << scale[:unit]
      else
        unit << scale[:scale]
      end
      dose[1] = unit
    elsif dose and dose.size == 2
      unit = dose[1]
    end
    dose
  end

  def ParseUtil.parse_compositions(composition, active_agents_string = '')
    rep_1 = '----';   to_1 = '('
    rep_2 = '-----';  to_2 = ')'
    rep_3 = '------'; to_3 = ','
    active_agents = active_agents_string ? active_agents_string.downcase.split(/,\s+/) : []
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
      components = line.gsub(/(\d),(\d+)/, "\\1.\\2").split(/([^\(]+\([^)]+\)[^,]+|),/).each {
        |component|
        next unless component.size > 0
        next if /^ratio:/i.match(component.strip)
        to_consider = component.strip.split(':')[-1].gsub(to_1, rep_1).gsub(to_2, rep_2).gsub(to_3, rep_3) # remove label
        # very ugly hack to ignore ,()
        ptrn1 = /^(?<name>.+)(\s+|$)(?<dose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))))/
        m =  /^(?<name>.+)(\s+|$)/.match(to_consider)
        m_with_dose = ptrn1.match(to_consider)
        m = m_with_dose if m_with_dose
        if m2 = /^(|[^:]+:\s)(E\s+\d+)$/.match(component.strip)
          to_add = ParseSubstance.new(m2[2], '', nil, nil, nil, nil, active_agents.index(m2[2].downcase) ? true : false)
          substances << to_add
        elsif m
          ptrn = /(?<name>.+)\s+(?<dose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))))(\s*(?:ut|corresp\.?)\s+(?<chemical>[^\d,]+)\s*(?<cdose>[\d\-.]+(\s*(?:(Mio\.?\s*)?(U\.\s*Ph\.\s*Eur\.|[^\s,]+))(\s*[mv]\/[mv])?))?)/
          m_with_chemical = ptrn.match(to_consider)
          m = m_with_chemical if m_with_chemical
          name      = m[:name].strip
          chemical  = m_with_chemical ? m[:chemical] : nil
          cdose     = m_with_chemical ? m[:cdose] : nil
          dose      = m_with_dose     ? m[:dose]  : nil
          if m_with_chemical and active_agents.index(m_with_chemical[:chemical].strip)
            is_active_agent = true
            name            = m[:chemical].strip
            dose            = m[:cdose]
            chemical        = m[:name].strip
            cdose           = m[:dose]
          else
            is_active_agent =  active_agents.index(m[:name].strip) != nil
          end
          unit = nil
          name = name.gsub(rep_3, to_3).gsub(rep_2, to_2).gsub(rep_1, to_1)
          emulsion_pattern = /\s+pro($|\s+)|emulsion|solution/i
          next if emulsion_pattern.match(name)
          name = name.split(/\s/).collect{ |x| x.capitalize }.join(' ').strip
          chemical = chemical.split(/\s/).collect{ |x| x.capitalize }.join(' ').strip if chemical
          qty,  unit  = ParseUtil.dose_to_qty_unit(dose, filler)
          cqty, cunit = ParseUtil.dose_to_qty_unit(cdose, filler)
          dose = "#{qty} #{unit}" if unit and unit.match(/\//)
          substances << ParseSubstance.new(name, qty, unit, chemical, cqty, cunit, is_active_agent, dose, cdose)
        end
      }
      comps << ParseComposition.new(line, label, label_description, substances) if substances.size > 0
    end
    comps
  end
end