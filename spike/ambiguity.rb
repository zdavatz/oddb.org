require 'rockit/rockit'

def ambiguity_parser
  Parse.generate_parser <<-'END_OF_GRAMMAR'
  Grammar Expressions
     Tokens
       WS         = /\s+/               [:Skip]
       NUM        = /\d+/
     Productions
			Expr	->	A
								[AVal: a]
						|		B
								[BVal: b]
						|		Expr Expr+
			A			->	NUM
			B			->	NUM
		Priorities
			AVal > BVal
			left(A), left(B)
  END_OF_GRAMMAR
end

begin
	puts ambiguity_parser.parse('1 5').inspect_multi
rescue Exception => e
	e.alternatives.each { |alt|
		puts alt.inspect_compact
	}
end
