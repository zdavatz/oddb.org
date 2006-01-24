#
# quanty/fact.rb
#
#   Copyright (c) 2001 Masahiro Tanaka <masa@ir.isas.ac.jp>
#
#   This program is free software.
#   You can distribute/modify this program under the terms of
#   the GNU General Public License version 2 or later.

class Quanty

  class Fact < Hash
    Self = self
    Parser = Parse.new

    attr_reader :factor

    # Basic units:	Fact.new("m",true) => {"m"=>1}
    # Derivative units:	Fact.new("km") => 1000*{"m"=>1}
    def initialize(key=nil,base=false)
      self.default = 0.0
      @factor = 1.0
      case key
      when Numeric
	@factor = key
      when String
	if base
	  store(key, 1.0)
	else
	  decomp(key)
	end
      when Self
	replace(key)
      end
    end

    def []=(key,val)
      if val == 0
	delete(key)
      else
	super(key,val)
      end
    end

    def replace(other)
      @factor = other.factor
      super(other)
    end

    def dup
      Fact.new(self)
    end

    def find_prefix(a,n)
      Prefix.each{ |key,factor|
	if /^#{key}-?/ =~ a && (unit = List[b=$']) && b.size>n
	  #p [a,b,factor]
	  return Fact.new(b).fac!(factor)
	end
      }
      nil
    end

    def decomp(a)
      if /^([µA-Za-z_]+([A-Za-z_0-9-]+[A-Za-z_])?)$|^[$%'"]'?$/o =~ a
      #if /^[A-Za-z_0-9$%-]+$/o =~ a
	unit = List[a] || find_prefix(a,0) ||
	  if a.size>3 && /chs$/o !~ a && /(.*[a-rt-y])s$/o =~ a
	    b = $1
	    List[b] || find_prefix(b,2) ||
	      if a.size>4 && /(.*s|.*z|.*ch)es$/o =~ a
		b = $1
		List[b] || find_prefix(b,2)
	      end
	  end
      else
	unit = Parser.parse(a)
      end
      unless unit
	raise "`%s': unknown unit"%a 
      end
      @factor *= factor if factor
      mul!(unit)
    end

    def mul!(other)
      raise unless other.kind_of?(Fact)
      other.each{ |key,val| self[key] += val }
      delete_if{ |key,val| val == 0 }
      @factor *= other.factor
      self
    end

    def * (other)
      dup.mul!(other)
    end

    def div!(other)
      raise unless other.kind_of?(Fact)
      other.each{ |key,val| self[key] -= val }
      delete_if{ |key,val| val == 0 }
      @factor /= other.factor
      self
    end

    def / (other)
      dup.div!(other)
    end

    def pow!(other)
      raise unless other.kind_of?(Numeric)
      each{ |key,val| self[key] = other*val }
      @factor **= other
      self
    end

    def ** (other)
      dup.pow!(other)
    end
  
    def fac!(other)
      raise unless other.kind_of?(Numeric)
      @factor *= other
      self
    end

    def inspect
      @factor.to_s+"*"+super
    end

    def to_s
      a = []
      each{|k,v|
	if v != 1
	  v  = v.to_i if v%1 == 0
	  k += v.to_s
	end
	a.push k
      }
      @factor.to_s+" "+a.join(" ")
    end

    def null?
      each_value{ |val| return false if val != 0 }
      true
    end

    alias __equal__ :==

    def ==(other)
      if other.kind_of?(Numeric)
	null? && @factor==other
      else
	__equal__(other) && @factor==other.factor
      end
    end

    # check only dimension
    def ===(other)
      if other.kind_of?(Numeric)
	null?
      else
	__equal__(other)
      end
    end

    def to_f
      raise inspect + ": not null unit" unless null?
      @factor
    end

    class << self
      def mkdump filename
	Prefix.clear
	List.clear
	#s = open("units.succ","w")
	#f = open("units.fail","w")
	open("units.dat","r").readlines.each do |str|
	  if /^([µA-Za-z_0-9%$"'-]+)\s+([^#]+)/ =~ str
	    name,repr = $1,$2.strip
	    # conversion due to the different rule from GNU units:
	    #   A / B C => A / (B C)
	    if /\// =~ repr #/
	      pre,suf = $`,$'.strip
	      if /\s/ =~ suf
		repr = pre + ' / (' + suf + ')'
	      end
	    end
	    if repr=="!"
	      List[name] = Fact.new(name,true).freeze
	    elsif /-$/  =~ name
	      Prefix[name[0..-2]] = Prefix[repr] || (List[repr] || repr).to_f
	    else
	      #p [name,repr]
	      List[name] = Fact.new(repr).freeze
	    end
	    #s.print str
	    #rescue
	    #f.print str
	  end
	end
	#Prefix.each{|key,val| p [key,val]}
	#List.each{|key,val| p [key,val]}
	Marshal.dump( [Prefix, List], open(filename,"w") )
      end
    end

  end # class Fact


  ### Loading unit data ###
=begin
  fn = nil
  $:.each{ |dir|
    fn = dir + "/quanty/units.dump"
    break if FileTest.exist?( fn )
    fn = nil
  }
=end
	fn = File.expand_path('units.dump', File.dirname(__FILE__))
	fn = nil unless FileTest.exist?( fn )
  if fn
    Prefix, List = Marshal.load(open(fn,"r"))
  else
    Prefix, List = {},{}
  end

end # class Quanty
