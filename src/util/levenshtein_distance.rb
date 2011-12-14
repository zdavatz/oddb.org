# encoding: utf-8
=begin
LevenshteinDistance
A String add-on to calculate the number of operation required
to transform a string to another. Operations are defined as deletion,
insertion, and modification of a character.

Example:

require 'levenshtein_distance'
include LevenshteinDistance
p "ABC".ld "ABCD" # => 1
p "ABC1".ld "ABC24" # => 2
p "ABC1".ld "ABC01" # => 1


Author: Yohanes Santoso
Date: 2002 November 19
License: Same as Ruby's
=end

module LevenshteinDistance
  def ld_min(a,b,c)
    if a<b 
      if a<c then a else c end 
    else 
      if b<c then b else c end 
    end
  end

  #
  # the string distance between this string and t.
  #
  def ld(t)
    s = self
    s_len = s.length
    t_len = t.length
    
    if s_len == 0 then return t_len end
    if t_len == 0 then return s_len end
    
		cur = Array.new(t_len.next, 0)
		lst = Array.new(t_len.next, 0)

    (0..s_len).each {|row|
      (0..t_len).each {|col|
	cost = if s[row] == t[col] then 0 else 1 end
	cur[col] = ld_min(lst[col] + 1, 
			       cur[col-1] + 1, 
			       lst[col-1] + cost)
      }
			cur, lst = lst, cur
    }
    lst[t_len]
  end
    
end

class String 
  include LevenshteinDistance
end
