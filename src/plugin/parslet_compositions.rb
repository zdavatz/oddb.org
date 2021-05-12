# This file is shared since oddb2xml 2.0.0 (lib/oddb2xml/parse_compositions.rb)
# with oddb.org src/plugin/parse_compositions.rb
#
# It allows an easy parsing of the column P Zusammensetzung of the swissmedic packages.xlsx file
#

require "parslet"
require "parslet/convenience"
require_relative "compositions_syntax"
VERBOSE_MESSAGES ||= false

module ParseUtil
  include Parslet
  # this class is responsible to patch errors in swissmedic entries after
  # oddb.org detected them, as it takes sometimes a few days (or more) till they get corrected
  # Reports the number of occurrences of each entry
  @@saved_parsed ||= {}
  @@nr_saved_parsed_used ||= 0

  class HandleSwissmedicErrors
    attr_accessor :nrParsingErrors
    class ErrorEntry < Struct.new("ErrorEntry", :pattern, :replacement, :nr_occurrences)
    end

    def reset_errors
      @errors = []
      @nr_lines = 0
      @nr_parsing_errors = 0
    end

    # error_entries should be a hash of  pattern, replacement
    def initialize(error_entries)
      reset_errors
      error_entries.each { |pattern, replacement| @errors << ErrorEntry.new(pattern, replacement, 0) }
    end

    def report
      s = ["Report of changed compositions in #{@nr_lines} lines. Had #{@nr_parsing_errors} parsing errors"]
      @errors.each { |entry|
        s << "  replaced #{entry.nr_occurrences} times '#{entry.pattern}'  by '#{entry.replacement}'"
      }
      s
    end

    def apply_fixes(string)
      result = string.clone
      @errors.each { |entry|
        intermediate = result.clone
        result = result.gsub(entry.pattern, entry.replacement)
        unless result.eql?(intermediate)
          entry.nr_occurrences += 1
          puts "#{File.basename(__FILE__)}:#{__LINE__}: fixed \nbefore: #{intermediate}\nafter:  #{result}" if $VERBOSE
        end
      }
      @nr_lines += 1
      result
    end
    #  hepar sulfuris D6 2,2 mg hypericum perforatum D2 0,66 mg where itlacks a comma and should be hepar sulfuris D6 2,2 mg, hypericum perforatum D2 0,66 mg
  end

  def self.capitalize(string)
    string.split(/\s+/u).collect { |word| word.capitalize }.join(" ").strip
  end

  def self.nr_saved_parsed_used
    @@nr_saved_parsed_used
  end

  def self.parse_compositions(composition_text, active_agents_string = "")
    active_agents = active_agents_string ? active_agents_string.delete("[").downcase.split(/,\s+/) : []
    key = [composition_text, active_agents]
    saved_value = @@saved_parsed[key]
    if saved_value
      @@nr_saved_parsed_used += 1
      return saved_value
    end
    comps = []
    lines = composition_text.gsub(/\r\n?/u, "\n").split(/\n/u)
    lines.select do |line|
      composition = ParseComposition.from_string(line)
      if composition.is_a?(ParseComposition)
        composition.substances.each do |substance_item|
          active_substance_name = substance_item.name.downcase.sub(/^cum\s/, "")
          substance_item.is_active_agent = !active_agents.find { |x|
            /#{x.downcase
            .gsub('(', '\(')
            .gsub(')', '\)')
            .gsub('[', '\[')
            .gsub(']', '\]')
              }($|\s)/
              .match(active_substance_name)
          }.nil?
          substance_item.is_active_agent = true if substance_item.chemical_substance && active_agents.find { |x| x.downcase.eql?(substance_item.chemical_substance.name.downcase) }
        end
        comps << composition
      end
    end
    comps << ParseComposition.new(composition_text.split(/,|:|\(/)[0]) if comps.size == 0
    @@saved_parsed[key] = comps
    comps
  rescue => error
    puts "error #{error}"
    # binding.pry
    raise error
  end
end

class IntLit < Struct.new(:int)
  def eval
    int.to_i
  end
end

class QtyLit < Struct.new(:qty)
  def eval
    qty.to_i
  end
end

class CompositionTransformer < Parslet::Transform
  @@more_info = nil
  def self.get_ratio(parse_info)
    if parse_info[:ratio]
      if (parse_info[:ratio].to_s.length > 0) && (parse_info[:ratio].to_s != ", ")
        parse_info[:ratio].to_s.sub(/^,\s+/, "").sub(/,\s+$/, "")
      end
    end
  end

  def self.check_e_substance(substance)
    return unless /^E \d\d\d/.match?(substance.name)
    unless substance.more_info
      case substance.name[2]
      when "1"
        substance.more_info = "color."
      when "2"
        substance.more_info = "conserv."
      end
      substance.more_info ||= @@more_info
    end
    @@more_info = substance.more_info
  end

  def self.add_excipiens(info)
    @@more_info = nil
    @@excipiens = ParseSubstance.new(info[:excipiens_description] || "Excipiens")
    @@excipiens.dose = info[:dose] if info[:dose]
    @@excipiens.more_info = CompositionTransformer.get_ratio(info)
    @@excipiens.cdose = info[:dose_corresp] if info[:dose_corresp]
    @@excipiens.more_info = info[:more_info] if info[:more_info]
  end

  rule(corresp: simple(:corresp)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    @@corresp = dictionary[:corresp].to_s
  }
  rule(substance_name: simple(:substance_name),
       dose: simple(:dose)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    dose = dictionary[:dose].is_a?(ParseDose) ? dictionary[:dose] : nil
    substance = ParseSubstance.new(dictionary[:substance_name], dose)
    @@substances << substance
    substance
  }

  rule(more_info: simple(:more_info)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    @@corresp = dictionary[:more_info].to_s.strip.sub(/:$/, "")
  }
  rule(more_info: simple(:more_info),
       substance_name: simple(:substance_name),
       dose: simple(:dose)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    dose = dictionary[:dose].is_a?(ParseDose) ? dictionary[:dose] : nil
    substance = ParseSubstance.new(dictionary[:substance_name].to_s, dose)
    substance.more_info = dictionary[:more_info].to_s.strip.sub(/:$/, "") if dictionary[:more_info] && (dictionary[:more_info].to_s.length > 0)
    CompositionTransformer.check_e_substance(substance)
    @@substances << substance
    substance
  }

  rule(lebensmittel_zusatz: simple(:lebensmittel_zusatz),
       more_info: simple(:more_info),
       digits: simple(:digits)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    substance = ParseSubstance.new("#{dictionary[:lebensmittel_zusatz]} #{dictionary[:digits]}")
    substance.more_info = dictionary[:more_info].to_s.strip.sub(/:$/, "") if dictionary[:more_info] && (dictionary[:more_info].to_s.length > 0)
    CompositionTransformer.check_e_substance(substance)
    @@substances << substance
    substance
  }
  rule(excipiens: subtree(:excipiens)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    info = dictionary[:excipiens].is_a?(Hash) ? dictionary[:excipiens] : dictionary[:excipiens].first
    if info[:excipiens_description] ||
        info[:dose] ||
        info[:dose_corresp] ||
        info[:more_info] ||
        CompositionTransformer.get_ratio(dictionary)
      CompositionTransformer.add_excipiens(info)
      info
    end
    nil
  }
  rule(composition: subtree(:composition)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    info = dictionary[:composition].is_a?(Hash) ? dictionary[:composition] : dictionary[:composition].first
    CompositionTransformer.add_excipiens(info) if info.is_a?(Hash)
    info
  }
  rule(substance: simple(:substance),
       chemical_substance: simple(:chemical_substance),
       substance_ut: sequence(:substance_ut),
       ratio: simple(:ratio)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    ratio = CompositionTransformer.get_ratio(dictionary)
    if ratio && (ratio.length > 0)
      if dictionary[:substance].more_info
        dictionary[:substance].more_info += " " + ratio.strip
      else
        dictionary[:substance].more_info = ratio.strip
      end
    end
    if dictionary[:chemical_substance]
      dictionary[:substance].chemical_substance = dictionary[:chemical_substance]
      @@substances -= [dictionary[:chemical_substance]]
    end
    if dictionary[:substance_ut].size > 0
      dictionary[:substance].salts += dictionary[:substance_ut].last.salts
      dictionary[:substance_ut].last.salts = []
      dictionary[:substance].salts << dictionary[:substance_ut].last
      @@substances -= dictionary[:substance_ut]
    end
    dictionary[:substance]
  }

  rule(int: simple(:int)) { IntLit.new(int) }
  rule(number: simple(:nb)) {
    /[eE.]/.match?(nb) ? Float(nb) : Integer(nb)
  }
  rule(
    qty_range: simple(:qty_range),
    unit: simple(:unit)
  ) {
    ParseDose.new(qty_range, unit)
  }
  rule(
    qty_range: simple(:qty_range)
  ) {
    ParseDose.new(qty_range)
  }
  rule(
    qty: simple(:qty),
    unit: simple(:unit)
  ) {
    ParseDose.new(qty, unit)
  }
  rule(
    unit: simple(:unit)
  ) { ParseDose.new(nil, unit) }
  rule(
    qty: simple(:qty)
  ) { ParseDose.new(qty, nil) }
  rule(
    qty: simple(:qty),
    unit: simple(:unit),
    dose_right: simple(:dose_right)
  ) {
    dose = ParseDose.new(qty, unit)
    dose.unit = dose.unit.to_s + " et " + ParseDose.new(dose_right).to_s
    dose
  }

  @@substances ||= []
  @@excipiens = nil
  def self.clear_substances
    @@more_info = nil
    @@substances = []
    @@excipiens = nil
    @@corresp = nil
  end

  def self.substances
    @@substances.clone
  end

  def self.excipiens
    @@excipiens ? @@excipiens.clone : nil
  end

  def self.corresp
    @@corresp ? @@corresp.clone : nil
  end
end

class ParseDose
  attr_reader :qty, :qty_range
  attr_accessor :unit
  def initialize(qty = nil, unit = nil)
    puts "ParseDose.new from #{qty.inspect} #{unit.inspect} #{unit.inspect}" if VERBOSE_MESSAGES
    if qty && (qty.is_a?(String) || qty.is_a?(Parslet::Slice))
      string = qty.to_s.delete("'")
      if string.index("-") && (string.index("-") > 0)
        @qty_range = string
      elsif string.index(/\^|\*|\//)
        @qty = string
      else
        @qty = string.index(".") ? string.to_f : string.to_i
      end
    elsif qty
      @qty = qty.eval
    else
      @qty = 1
    end
    @unit = unit ? unit.to_s : nil
  end

  def eval
    self
  end

  def to_s
    return @unit unless @qty || @qty_range
    res = "#{@qty}#{@qty_range}"
    res = "#{res} #{@unit}" if @unit
    res
  end
end

class ParseSubstance
  attr_accessor :name, :chemical_substance, :chemical_qty, :chemical_unit, :is_active_agent, :dose, :cdose, :is_excipiens
  attr_accessor :description, :more_info, :salts
  attr_writer :unit, :qty
  def initialize(name, dose = nil)
    puts "ParseSubstance.new from #{name.inspect} #{dose.inspect}" if VERBOSE_MESSAGES
    @name = ParseUtil.capitalize(name.to_s)
    @name.sub!(/\baqua\b/i, "aqua")
    @name.sub!(/\bDER\b/i, "DER")
    @name.sub!(/\bad pulverem\b/i, "ad pulverem")
    @name.sub!(/\bad iniectabilia\b/i, "ad iniectabilia")
    @name.sub!(/\bad suspensionem\b/i, "ad suspensionem")
    @name.sub!(/\bad solutionem\b/i, "ad solutionem")
    @name.sub!(/\bpro compresso\b/i, "pro compresso")
    @name.sub!(/\bpro\b/i, "pro")
    @name.sub!(/ Q\.S\. /i, " q.s. ")
    @name.sub!(/\s+\bpro$/i, "")
    @dose = dose if dose
    @salts = []
  end

  def qty
    return @dose.qty_range if @dose&.qty_range
    @dose ? @dose.qty : @qty
  end

  def unit
    return @unit if @unit
    @dose ? @dose.unit : @unit
  end

  def to_string
    s = "#{@name}:"
    s = " #{@qty}" if @qty
    s = " #{@unit}" if @unit
    s += @chemical_substance.to_s if chemical_substance
    s
  end
end

class ParseComposition
  attr_accessor :source, :label, :label_description, :substances, :galenic_form, :route_of_administration,
    :corresp, :excipiens

  ERRORS_TO_FIX = {
    /(\d+)\s+-\s*(\d+)/ => '\1-\2',
    "o.1" => "0.1",
    /polymerisat(i|um) \d:\d/ => "polymerisatum",
    /\s+(mg|g) DER:/ => ' \1, DER:',
    " mind. " => " min. ",
    " streptococci pyogen. " => " streptococci pyogen ",
    " ut excipiens" => ", excipiens",
    " Corresp. " => " corresp. ",
    ",," => ",",
    "avena elatior,dactylis glomerata" => "avena elatior, dactylis glomerata",
    " color.: corresp. " => " corresp.",
    / U\.: (excipiens) / => ' U. \1 ',
    / U\.: (alnus|betula|betula|betulae) / => ' U., \1 ',
    /^(acari allergeni extractum (\(acarus siro\)|).+\s+U\.:)/ => 'A): \1',
    "Solvens: alprostadilum" => "alprostadilum",
  }
  @@error_handler = ParseUtil::HandleSwissmedicErrors.new(ERRORS_TO_FIX)

  def initialize(source)
    @substances ||= []
    puts "ParseComposition.new from #{source.inspect} @substances #{@substances.inspect}" if VERBOSE_MESSAGES
    @source = source.to_s
  end

  def self.reset
    @@error_handler = ParseUtil::HandleSwissmedicErrors.new(ERRORS_TO_FIX)
  end

  def self.report
    @@error_handler.report
  end

  def self.from_string(string)
    return nil if string.nil? || string.eql?(".") || string.eql?("")
    stripped = string.gsub(/^"|["\n]+$/, "")
    return nil unless stripped
    cleaned = if /(U\.I\.|U\.)$/.match?(stripped)
      stripped
    else
      stripped.sub(/\.+$/, "")
    end
    puts "ParseComposition.from_string #{string}" if VERBOSE_MESSAGES # /ng-tr/.match(Socket.gethostbyname(Socket.gethostname).first)

    cleaned = @@error_handler.apply_fixes(cleaned)
    puts "ParseComposition.new cleaned #{cleaned}" if VERBOSE_MESSAGES && !cleaned.eql?(stripped)
    CompositionTransformer.clear_substances
    result = ParseComposition.new(cleaned)
    parser = CompositionParser.new
    transf = CompositionTransformer.new
    begin
      if defined?(RSpec)
        ast = transf.apply(parser.parse_with_debug(cleaned))
        puts "#{File.basename(__FILE__)}:#{__LINE__}: ==> " if VERBOSE_MESSAGES
        pp ast if VERBOSE_MESSAGES
      else
        ast = transf.apply(parser.parse(cleaned))
      end
    rescue Parslet::ParseFailed => error
      @@error_handler.nrParsingErrors += 1
      puts "#{File.basename(__FILE__)}:#{__LINE__}: failed parsing ==>  #{cleaned} #{error}"
      return nil
    end
    result.source = string
    return result unless ast
    return result if ast.is_a?(Parslet::Slice)

    result.substances = CompositionTransformer.substances
    result.excipiens = CompositionTransformer.excipiens
    result.corresp = CompositionTransformer.corresp if CompositionTransformer.corresp
    if result&.excipiens&.unit
      pro_qty = "/#{result.excipiens.qty} #{result.excipiens.unit}".sub(/\/1\s+/, "/")
      result.substances.each { |substance|
        next unless substance.is_a?(ParseSubstance)
        substance.chemical_substance.unit = "#{substance.chemical_substance.unit}#{pro_qty}" if substance.chemical_substance
        substance.dose.unit = "#{substance.dose.unit}#{pro_qty}" if substance.unit && !substance.unit.eql?(result.excipiens.unit)
      }
    end
    if ast.is_a?(Array) && ast.first.is_a?(Hash)
      label = ast.first[:label].to_s if ast.first[:label]
      label_description = ast.first[:label_description].to_s if ast.first[:label_description]
    elsif ast&.is_a?(Hash)
      label = ast[:label].to_s if ast[:label]
      label_description = ast[:label_description].to_s if ast[:label_description]
    end
    if label
      if label && !/((A|B|C|D|E|I|II|III|IV|\)+)\s+et\s+(A|B|C|D|E|I|II|III|IV|\))+)/.match(label)
        result.label = label
      end
      result.label_description = label_description.gsub(/:+$/, "").strip if label_description
    end
    result.corresp = ast[:corresp].to_s.sub(/:\s+/, "") if !result.corresp && ast.is_a?(Hash) && ast[:corresp]
    result
  end
end

class GalenicFormTransformer < CompositionTransformer
  rule(preparation_name: simple(:preparation_name),
       galenic_form: simple(:preparation_name)) { |dictionary|
    puts "#{File.basename(__FILE__)}:#{__LINE__}: dictionary #{dictionary}" if VERBOSE_MESSAGES
    dictionary[:preparation_name] ? dictionary[:preparation_name].to_s : nil
    dictionary[:galenic_form] ? dictionary[:galenic_form].to_s : nil
    # name, form
  }
end

class ParseGalenicForm
  def self.from_string(string)
    return nil if string.nil?
    stripped = string.gsub(/^"|["\n]+$/, "")
    return nil unless stripped
    puts "ParseGalenicForm.from_string #{string}" if VERBOSE_MESSAGES # /ng-tr/.match(Socket.gethostbyname(Socket.gethostname).first)

    parser = GalenicFormParser.new
    transf = GalenicFormTransformer.new
    begin
      if defined?(RSpec)
        ast = transf.apply(parser.parse_with_debug(string))
        puts "#{File.basename(__FILE__)}:#{__LINE__}: ==> " if VERBOSE_MESSAGES
        pp ast if VERBOSE_MESSAGES
      else
        ast = transf.apply(parser.parse(string))
      end
    rescue Parslet::ParseFailed => error
      @@error_handler.nrParsingErrors += 1
      puts "#{File.basename(__FILE__)}:#{__LINE__}: failed parsing ==>  #{string} #{error}"
      return nil
    end
    return [] unless ast
    form = ast[:galenic_form] ? ast[:galenic_form].to_s.sub(/^\/\s+/, "") : nil
    name = ast[:prepation_name] ? ast[:prepation_name].to_s.strip : nil
    [name, form]
  end
end
