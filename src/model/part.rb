#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Part -- oddb.org -- 05.05.2008 -- hwyss@ywesee.com
# ODDB::Part -- oddb.org -- 05.05.2008 -- hwyss@ywesee.com

require 'model/dose'
require 'util/persistence'
require 'strscan'
require 'util/iso-latin1'

module ODDB
  module SizeParser
    UNIT = ODDB::Dose.new(1)
    def active_agents
      @composition ? @composition.active_agents : []
    end
    def comparable_size
      ODDB::Dose.from_quanty(@comparable_size)
    end
    def multiplier
      count = @count || 1
      addition = @addition || 0
      [@descr.to_f, 1].max * (@multi || 1).to_f * (count.to_i + addition.to_i)
    end
    def set_comparable_size!
      measure = (@measure.nil? || @measure == UNIT) \
              ? _composition_scale \
              : @measure
      measure ||= UNIT
      scale = @scale || UNIT
      @comparable_size = multiplier * measure / scale
    end
    def size=(size)
      unless size.to_s.strip.empty?
        @addition, @multi, @count, @measure, @scale, @comform = parse_size(size) 
        if @count == 0
          @count, @multi = @multi, nil
        end
        set_comparable_size!
      end
    end
    def parse_size(size)
      unit_pattern = /(([kmµucMG]?([glLJm]|mol|Bq))(\/([mµu]?[glL]))?)|(Mio\.?\s)?((U\.?I\.?)|(I\.E\.))|(%( [mV]\/[mV])?)|(I\.E\.)|(Fl\.)/
      numeric_pattern = /\d+(\'\d+)*([.,]\d*)?/
      isolatin1 = ODDB::Util::IsoLatin1::DOWNCASE_PAIRS.values.join
      iso_pattern = /[[:alpha:]()\-#{isolatin1}]+/

      description = /(?!#{unit_pattern}\s)#{iso_pattern}(\s+#{iso_pattern})*/u
      numeric     = /#{numeric_pattern}/u
      unit        = /#{unit_pattern}/u

      count     = /(?<je>je)?\s*(?<numeric>#{numeric})/
      multiple  = /(?<numeric>#{numeric})\s*(?<unit>#{unit})?\s*(?<set>[xXà])/
      measure   = /(?<numeric>#{numeric})\s*(?<unit1>#{unit})\s*(?<unit2>#{unit})?/
      addition  = /(?<numeric>#{numeric})\s*(?<unit>#{unit})?\s*(?<plus>\+)/
      range     = /(?<minus>\-)\s*(?<numeric>#{numeric}\s*(?<unit>#{unit})?)/
      part      = /(?<in>in)\s*(?<numeric>#{numeric})?\s*(?<unit>#{unit})/
      scale     = /(?<slash>(\/|pro))\s*(?<numeric>#{numeric})?\s*(?<unit>#{unit})/
      dose      = /\(\s*#{numeric}\s*#{unit}\s*\)/

      s = StringScanner.new(size)
      s_multi = []
      s_comform = ""
      s_count = nil
      s_measure = nil
      until s.eos?
        s.skip(/\s+/)
        case
        when s.scan(/#{multiple}/)
          m = s[0].match(/#{multiple}/)
          s_multi << [m[:numeric], m[:unit], m[:set]] unless s_count
        when s.scan(/#{addition}/)
          m = s[0].match(/#{addition}/)
          s_addition = [m[:numeric], m[:unit], m[:plus]]
        when s.scan(/#{range}/)
          m = s[0].match(/#{range}/)
          s_range = [m[:minus], m[:numeric], m[:unit]]
        when s.scan(/#{part}/)
          m = s[0].match(/#{part}/)
          s_part = [m[:in], m[:numeric], m[:unit]]
        when s.scan(/#{measure}/)
          m = s[0].match(/#{measure}/)
          s_measure = [m[:numeric], m[:unit1], m[:unit2]] unless s_measure
        when s.scan(/#{count}/)
          m = s[0].match(/#{count}/)
          s_count = [m[:je], m[:numeric]] unless s_count
        when s.scan(/#{scale}/)
          m = s[0].match(/#{scale}/)
          s_scale = [m[:slash], m[:numeric], m[:unit]]
        when s.scan(/#{dose}/)
          s_dose = s[0]
        when s.scan(/#{description}/)
          s_comform += s[0]
        when s.scan(/.*/)
        end
      end
      s_comform = nil if s_comform.empty?
      s_count = (s_count ? s_count[1].to_i : 1)
      s_measure ||= [1, (s_range && s_range[2] or s_part && s_part[2]), nil]
      if s_comform
        s_comform.gsub!('()','')
        s_comform.strip!
      end
      [
        (s_addition ? s_addition.first.to_i : 0),
        dose_from_multi(s_multi),
        s_count,
        dose_from_measure(s_measure),
        dose_from_scale(s_scale),
        s_comform,
      ]
    end
    def dose_from_measure(measure)
      values = measure ? measure[0,2] : [1,nil]
      Dose.new(*values)
    end
    def dose_from_scale(scale)
      values = scale ? scale[1,2] : [1,nil]
      Dose.new(*values)
    end
    def dose_from_multi(multi)
      unless(multi.nil?)
        multi.inject(UNIT) { |inj, node|
          unit = (node[1] if node[1])
          dose = ODDB::Dose.new(node[0], unit)
          inj *= dose
        }
      else
        UNIT
      end
    end
    def _composition_scale
      if @composition && dose = @composition.doses.compact.first
        dose.scale
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
      add = @addition.to_i
      if(multi > 1) 
        parts.push(multi)
      end
      @measure = nil if @measure == 1
      if(count > 0 && multi > 1 && !@measure)
        parts.push('x')
      end
      if add > 0
        parts.push add, '+'
      end
      if(count > 1 || (count > 0 && multi > 1 && !@measure))
        parts.push(count)
      end
      if(@commercial_form)
        parts.push @commercial_form
        parts.push "à" if @measure
      elsif @measure && !parts.empty?
        parts.push('x')
      end
      parts.push @measure if @measure
      parts.push('/', @scale) if @scale && @scale != 1
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
