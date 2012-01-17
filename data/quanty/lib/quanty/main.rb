# encoding: utf-8
#
# quanty/main.rb
#
#   Copyright (c) 2001 Masahiro Tanaka <masa@ir.isas.ac.jp>
#
#   This program is free software.
#   You can distribute/modify this program under the terms of
#   the GNU General Public License version 2 or later.

# require 'fact.rb'

def Quanty(*a)
  Quanty.new(*a)
end

class Quanty #< Numeric
  Self = self
  RadianUnit = Quanty::Fact.new('radian')

  def initialize(*a)
    case a.size
    when 1
      if String === a[0]
	@val,@unit,@fact = 1.0, a[0], nil
      else
	@val,@unit,@fact = a[0], '', nil
      end
    when 2..3
        @val,@unit,@fact = a
    else
      raise ArgumentError, 'wrong # of arguments'
    end
    unless Fact === @fact
      @fact = Fact.new(@unit)
    end
  end

  attr_reader :val
  attr_reader :unit
  attr_reader :fact
  alias value val

  def adjust(other)
    if other.kind_of?(Self)
      unless @fact === other.fact
	raise "not same unit: %s != %s" % [@unit,other.unit]
      end
      other.val * ( other.fact.factor / @fact.factor )
    else
      raise @unit + ": not null unit" unless @fact.null?
      other / @fact.factor
    end
  end

  def want(unit)
    obj = Self.new(unit)
    val = obj.adjust(self)
    Self.new( val, unit, obj.fact )
  end

  def + (other)
    val = @val + adjust(other)
    if @unit==''
      val
    else
      Self.new( val, @unit, @fact )      
    end
  end

  def - (other)
    val = @val - adjust(other)
    if @unit==''
      val
    else
      Self.new( val, @unit, @fact )      
    end
  end

  def +@ ; Self.new(  @val, @unit, @fact ) end
  def -@ ; Self.new( -@val, @unit, @fact ) end

  def <=> (other); @val <=> adjust(other) end
  def  == (other); @val  == adjust(other) end
  def  >= (other); @val  >= adjust(other) end
  def  <= (other); @val  <= adjust(other) end
  def  <  (other); @val  <  adjust(other) end
  def  >  (other); @val  >  adjust(other) end

  def **(n)
    if /^[A-Za-z_]+&/ou =~ @unit
      unit = @unit+'^'+n.to_s
    else
      unit = '('+@unit+')^'+n.to_s+''
    end
    Self.new( @val**n, unit, @fact**n )
  end

  def * (other)
    if other.kind_of?(Self)
      unit = other.unit
      unless @unit.empty?
	if unit.empty?
	  unit = @unit
	else
	  if /\A[A-Za-z_]/ou =~ unit
	    unit = @unit+' '+unit
	  else
	    unit = @unit+' ('+unit+')' 
	  end
	end
      end
      Self.new( @val*other.val, unit, @fact*other.fact )
    else
      Self.new( @val*other, @unit, @fact )
    end
  end

  def / (other)
    if other.kind_of?(Self)
      unit = other.unit
      if unit.empty?
	unit = @unit
      else
	if /\A[A-Za-z_-]+((\^|\*\*)?[0-9.]+)?$/ou =~ unit
	  unit = '/ '+unit
	else
	  unit = '/ ('+unit+')' 
	end
	unit = @unit+' '+unit unless @unit.empty?
      end
      Self.new( @val/other.val, unit, @fact/other.fact )
    else
      Self.new( @val/other, @unit, @fact )
    end
  end

  def coerce(other)
    [ Self.new(other), self ]
  end

  def to_f
    if @fact.null?
      @val * @fact.factor
    elsif @fact === RadianUnit
      want('radian').value
    else
      raise 'cannot convert into non-dimensional Float'
    end
  end

  def to_s
    @val.to_s + "[" + @unit + "]"
  end

  def inspect
    "Quanty(" + @val.to_s + ",'" + @unit + "')"
  end

end
