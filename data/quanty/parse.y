#
# parse.y, quanty/parse.rb
#
#   Copyright (c) 2001 Masahiro Tanaka <masa@ir.isas.ac.jp>
#
#   This program is free software.
#   You can distribute/modify this program under the terms of
#   the GNU General Public License version 2 or later.

class Parse

  prechigh
    nonassoc UMINUS
    right POW UPOW
    left '*' '/' '|'
    left '+' '-'
  preclow

rule

  target: val
	| /* none */	{ result = Quanty::Fact.new }
	| num 		{ result = Quanty::Fact.new(val[0]) }
	;

  num	: NUMBER
        | '-' NUMBER = UMINUS { result = -val[1] }
        | num '+' num   { result += val[2] }
        | num '-' num   { result -= val[2] }
	| num '|' num	{ result /= val[2] }
	| num '/' num	{ result /= val[2] }
	| num '*' num	{ result *= val[2] }
	| num POW num	{ result **= val[2] }
	| '(' num ')'	{ result = val[1] }
	;

  val	: seq
 	| num seq	{ result = val[1].fac!(val[0]) }
	| '/' exp	{ result = val[1].pow!(-1) }
	| num '/' exp	{ result = val[2].pow!(-1).fac!(val[0]) }
	;

  seq	: exp
	| seq exp       { result.mul!(val[1]) }
	| seq '*' exp	{ result.mul!(val[2]) }
	| seq '/' exp	{ result.div!(val[2]) }
	| seq '*' num	{ result.fac!(val[2]) }
	| seq '/' num	{ result.fac!(val[2]**-1) }
	;

  exp	: unit
	| unit num = UPOW { result.pow!(val[1]) }
	| unit POW num	{ result.pow!(val[2]) }
	;

  unit	: WORD		{ result = Quanty::Fact.new(val[0]) }
	| '(' val ')'	{ result = val[1] }
	| '[' val ']'	{ result = val[1] }
	;

end

---- header ----

# parse.y, quanty/parse.rb
#
#   by Masahiro Tanaka <masa@ir.isas.ac.jp>
#
class Quanty

---- inner ----
  
  def parse( str )
    @q = []

    while str.size > 0 do
      #p str
      case str
      when /\A[\s\n]+/ou
      when /\A\d+\.?\d*([eE][+-]?\d+)?/ou
        @q.push [:NUMBER, $&.to_f]
			when /\A([A-Z]\.){2}/u
			when /\A[A-Za-z_]+ -/u
      when /\A[A-Za-z_µ]+([A-Za-z_µ0-9-]+[A-Za-z_µ])?/ou
        @q.push [:WORD, $&]
      when /\A[$%'"]'?/ou
        @q.push [:WORD, $&]
      when /\A\^|\A\*\*/ou
        @q.push [:POW, $&]
      when /\A./ou
        @q.push [$&,$&]
      end
        str = $'
    end
    @q.push [false, '$end']

    do_parse
  end

  def next_token
    @q.shift
  end

---- footer ----

end # class Quanty
