#
# Soundex.rb
#
# Implementation of the soundex algorithm as described by Knuth 
# in volume 3 of The Art of Computer Programming
#
# author:  Michael Neumann (neumann@s-direktnet.de)
# version: 1.0
# date:    26.07.2000
# license: GNU GPL
#


module ODDB
module Text
module Soundex

  def soundex(str_or_arr)
    case str_or_arr
    when String
      soundex_str(str_or_arr)
    when Array
      str_or_arr.collect{|ele| soundex_str(ele)}
    else
      nil
    end
  end
  module_function :soundex
  
  private

  #
  # returns nil if the value couldn't be calculated (empty-string, wrong-character)
  # do not change the parameter "str"
  #
  def soundex_str(str)
    return nil if str.empty?

		str = prepare(str)
    str = str.upcase
    last_code = get_code(str[0,1])
    soundex_code = str[0,1]

    for index in 1...(str.size) do
      return soundex_code if soundex_code.size == 4

      code = get_code(str[index,1])
      
      if code == "0" then
        last_code = nil
      elsif code == nil then
        return nil
      elsif code != last_code then
        soundex_code += code
        last_code = code        
      end 
    end # for
    
    return soundex_code + "000"[0,4-soundex_code.size]
  end
  module_function :soundex_str
            
  def get_code(char)
    char.tr! "AEIOUYWHBPFVCSKGJQXZDTLMNR", "00000000111122222222334556"
  end
  module_function :get_code

	def prepare(str)
		str = str.dup
		str.gsub!(/[äÄæÆ]/, 'ae')
		str.gsub!(/[áÁàÀâÂãÃ]/, 'a')
		str.gsub!(/[çÇ]/, 'c')
		str.gsub!(/[ëËéÉèÈêÊ]/, 'e')
		str.gsub!(/[ïÏíÍìÌîÎ]/, 'i')
		str.gsub!(/[öÖ]/, 'oe')
		str.gsub!(/[óÓòÒôÔõÕøØ]/, 'o')
		str.gsub!(/[üÜ]/, 'ue')
		str.gsub!(/[úÚùÙûÛ]/, 'u')
		str.tr!('şßğ', 'psd')
		str.gsub!(/[-\s]/i, ' ')
		str.gsub!(/[^a-z\s]/i, '')
		str.strip
	end
	module_function :prepare
	
end # module Soundex
end # module Text
end






#
# test-program
#
if __FILE__ == $0
  testvec = "Euler Ellery Gauss Ghosh Hilbert Heilbronn Knuth Kant Lloyd Ladd Lukasiewicz Lissajous".split(" ")
  resvec  = "E460 E460 G200 G200 H416 H416 K530 K530 L300 L300 L222 L222".split(" ")
   
  wrong = 0
  
  testvec.each_with_index {|str,i| 
    res = Text::Soundex.soundex(str)
    print "#{str.ljust(11)} => #{res} ... "
    if res == resvec[i] then
      puts "ok"
    else
      wrong += 1
      puts "failed, had to be #{resvec[i]}"
    end    
  }
  puts "summary: #{wrong} of #{testvec.size} tests failed!"      
  readline
end
