#!/usr/bin/env ruby
# Part -- oddb.org -- 05.05.2008 -- hwyss@ywesee.com

require 'model/dose'
require 'rockit/rockit'
require 'util/persistence'

module ODDB
  module SizeParser
    unit_pattern = '(([kmucMG]?([glLJm]|mol|Bq)\b)(\/([mu]?[glL])\b)?)|((Mio\s)?U\.?I\.?)|(%( [mV]\/[mV])?)|(I\.E\.)|(Fl\.)'
    numeric_pattern = '\d+(\'\d+)*([.,]\d+)?'
    iso_pattern = "[a-zA-Z#{0xC0.chr}-#{0xFF.chr}()\-]+"
    @@parser = Parse.generate_parser <<-EOG
Grammar OddbSize
  Tokens
    DESCRIPTION	= /(?!#{unit_pattern}\s)#{iso_pattern}(\s+#{iso_pattern})*/
    NUMERIC			= /#{numeric_pattern}/
    SPACE				= /\s+/		[:Skip]
    UNIT				= /#{unit_pattern}/
  Productions
    Size			->	Multiple* Addition? Count? Measure? Scale? Dose? DESCRIPTION?
    Count			->	'je'? NUMERIC
    Multiple	->	NUMERIC UNIT? /[xXà]|Set/
    Measure		->	NUMERIC UNIT UNIT?
    Addition	->	NUMERIC UNIT? '+'
    Scale			->	'/' NUMERIC? UNIT
    Dose			->	'(' NUMERIC UNIT ')'
    EOG
    def active_agents
      @composition ? @composition.active_agents : []
    end
    def comparable_size
      ODDB::Dose.from_quanty(@comparable_size)
    end
    def multiplier
      count = @count || 1
      addition = @addition || 0
      [@descr.to_f, 1].max * (@multi || 1).to_f * (count + addition)
    end
    def set_comparable_size!
      measure = @measure || Dose.new(1, nil)
      scale = @scale || Dose.new(1, nil)
      @comparable_size = multiplier * measure / scale
    end
    def size=(size)
      unless size.to_s.strip.empty?
        @addition, @multi, @count, @measure, @scale, @comform = parse_size(size) 
        set_comparable_size!
      end
    end
    def parse_size(size)
      multi, addition, count, measure, scale, dose, comform = nil
      begin
        ast = @@parser.parse(size)
        multi, addition, count, measure, scale, dose, comform = ast.flatten
        count = (count ? count[1].value.to_i : 1)
      rescue ParseException, AmbigousParseException => e
        count = size.to_i
      end
      if(!dose.nil? && @package.sequence.dose.nil?)
        @package.sequence.dose = Dose.new(*(dose.childrens[1,2].collect { |c| 
          c.value }))
      end
      [
        (addition ? addition.first.value.to_i : 0),
        dose_from_multi(multi),
        count,
        dose_from_measure(measure),
        dose_from_scale(scale),
        (comform.value if comform),
      ]
    end
    def dose_from_measure(measure)
      values = measure ? measure.childrens[0,2].collect{ |c| c.value } : [1,nil]
      Dose.new(*values)
    end
    def dose_from_scale(scale)
      values = scale ? scale.childrens[1,2].collect{ |c| c.value } : [1,nil]
      Dose.new(*values)
    end
    def dose_from_multi(multi)
      unless(multi.nil?)
        multi.childrens.inject(Dose.new(1,nil)) { |inj, node| 
          unit = (node[1].value if node[1])
          dose = Dose.new(node[0].value, unit)
          inj *= dose
        }
      else
        Dose.new(1,nil)
      end
    end
  end
  class Part
    include Persistence
		include SizeParser
    class << self
      def package_delegate *args
        args.each { |name|
          define_method(name) { 
            @package.send(name) if @package
          }
        }
      end
      def update_comparable_size *args
        args.each { |name|
          attr_reader name
          define_method("#{name}=") { |arg|
            instance_variable_set("@#{name}", arg)
            set_comparable_size!
            arg
          }
        }
      end
    end
    attr_reader :comform, :commercial_form
    attr_accessor :package, :composition
    update_comparable_size :count, :multi, :measure, :addition, :scale
    package_delegate :sequence, :registration
    def init(app)
      @pointer.append(@oid)
    end
    def commercial_form=(commercial_form)
      unless(@commercial_form.nil?)
        @commercial_form.remove_package(@package)
      end
      unless(commercial_form.nil?)
        commercial_form.add_package(@package)
      end
      @commercial_form = commercial_form
    end
    def fix_pointers
      @pointer = @package.pointer + [:part, @oid]
      odba_store
    end
    def size
      parts = []
      multi = @multi.to_i
      count = @count.to_i
      if(multi > 1) 
        parts.push(multi)
      end
      if(multi > 1 && count > 1)
        parts.push('x')
      end
      if(count > 1 || (count > 0 && multi > 1))
        parts.push(count)
      end
      @measure = nil if @measure == 1
      if(@commercial_form)
        parts.push @commercial_form
        parts.push "à" if @measure
      elsif @measure && !parts.empty?
        parts.push('x')
      end
      parts.push @measure if @measure
      parts.join(' ')
    end
    private
    def adjust_types(values, app=nil)
      values = values.dup
      values.each { |key, value|
        case value
        when Persistence::Pointer
          values[key] = value.resolve(app)
        else 
          case key
          when :measure, :scale
            values[key] = Dose.new(*value) if value
          when :multi, :count, :addition
            values[key] = value.to_i if value
          end
        end 
      }
      values
    end
  end
end
