require 'racc/parser'

class SpikeParser < ::Racc::Parser

module_eval <<'..end swissmedic.y modeval..idb3576e7e96', 'swissmedic.y', 135

def parse(str)

	str.strip!

	months = %w[
		Januar Februar M.rz April Mai Juni Juli August September Oktober November Dezember
		Janvier F.vrier Mars Avril Juin Juillet Ao.t Septembre Octobre Novembre D.cembre
		Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre
	].join(')|(')

	@q = []
	until str.empty? do
		case str
		when /\A(Zul\.-Nr.)|(N. AMM):/
			@q.push([:REGISTRATION, 1])
		when /\A((Abgabekategorie)|(Cat.gorie de remise)|(Modo di vendita)):/
			@q.push([:IKS_CAT, 1])
		when /\AIndex:/
			@q.push([:INDEX_TH, 1])
		when /\A[0-3]\d\.[0-1]\d.[1-2]\d{3}/
			@q.push([:DATE_NUMERIC, $&])
		when /\A((#{months}))/
			@q.push([:MONTH, $&])
		when /\A((Zusammensetzung)|(Composition)|(Composizione)):/
			@q.push([:COMPOSITION, 1])
		when /\A((Anwendung)|(Indication)|(Indicazione)):/
			@q.push([:INDICATION, 1])
		when /\A((Packung(en)?)|(Conditionnements?)|(Confezion[ei])):/
			@q.push([:PACKAGE, 1])
		when /\A(Bemerkung):/
			@q.push([:COMMENT, 1])
		when /\A((G.ltig bis)|(Valable jusqu.au)|(Valevole fino al)):/
			@q.push([:VALID_UNTIL, 1])
		when /\AANTIOX.:/
			@q.push([:ANTIOX, 1])
		when /\ACONSERV.:/
			@q.push([:CONSERV, 1])
		when /\AEXCIPIENS/
			@q.push([:EXCIPIENS, 1])
		when /\AE \d{3}/
			@q.push([:E123_VAL, $&])
		when /\A(\d{2}\.){2}\d\./
			@q.push([:INDEX_TH_VAL, $&])
		when /\A\d+\.\d+/
			@q.push([:FLOAT, $&])
		when /\A[ABCD]\b/
			@q.push([:IKS_CAT_VAL, $&])
		when /\A((mg)|(g)|(ug)|(U\.I\.))\b/
			@q.push([:UNIT, $&])
		when /\Aad\b/
			@q.push([:AD, 1])
		when /\Apro\b/
			@q.push([:PRO, 1])
		when /\Aut\b/
			@q.push([:AGENT_IN_FORM_OF, 1])
		when /\A\d+/
			@q.push([:INTEGER, $&])
		when /\A(AG|GMBH)/i
			@q.push([:AG, $&])
		when /\A[\wהצüאיט()]+/
			@q.push([:WORD, $&])
		when /\A\s*[\n\r]+/
			@q.push([:NEWLINE, $&])
		when /\A\s+/
	    ;
		else
			c = str[0,1]
			@q.push([c,c])
      str = str[1..-1]
			next
		end
		str = $'
	end
	#@q.push [false, '$']   # DO NOT FORGET THIS!!!
		
	do_parse
end

def next_token
	p @q.first
  @q.shift
end

..end swissmedic.y modeval..idb3576e7e96

##### racc 1.4.1 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 0, 32, :_reduce_none,
 2, 32, :_reduce_2,
 7, 33, :_reduce_3,
 4, 34, :_reduce_4,
 4, 34, :_reduce_5,
 1, 41, :_reduce_6,
 2, 41, :_reduce_7,
 0, 42, :_reduce_none,
 2, 42, :_reduce_9,
 6, 35, :_reduce_10,
 2, 43, :_reduce_11,
 2, 44, :_reduce_12,
 2, 45, :_reduce_13,
 5, 36, :_reduce_14,
 2, 46, :_reduce_15,
 2, 47, :_reduce_16,
 2, 48, :_reduce_17,
 3, 37, :_reduce_18,
 3, 37, :_reduce_19,
 7, 49, :_reduce_20,
 5, 49, :_reduce_21,
 1, 50, :_reduce_22,
 3, 50, :_reduce_23,
 2, 53, :_reduce_24,
 4, 53, :_reduce_25,
 1, 51, :_reduce_26,
 3, 51, :_reduce_27,
 1, 55, :_reduce_28,
 1, 55, :_reduce_29,
 1, 55, :_reduce_30,
 2, 56, :_reduce_31,
 3, 56, :_reduce_32,
 2, 57, :_reduce_33,
 3, 57, :_reduce_34,
 3, 52, :_reduce_35,
 5, 52, :_reduce_36,
 2, 54, :_reduce_37,
 2, 54, :_reduce_38,
 3, 38, :_reduce_39,
 2, 39, :_reduce_40,
 2, 39, :_reduce_41,
 5, 58, :_reduce_42,
 4, 58, :_reduce_43,
 2, 59, :_reduce_44,
 4, 59, :_reduce_45,
 1, 60, :_reduce_46,
 1, 60, :_reduce_47,
 3, 40, :_reduce_48,
 4, 61, :_reduce_49 ]

racc_reduce_n = 50

racc_shift_n = 120

racc_action_table = [
    59,    55,    92,    96,    55,    36,    96,     9,    17,    55,
    40,    96,    58,    17,    17,    17,    17,     8,    17,     9,
    18,    31,    93,    56,     9,    93,    56,    62,    97,    37,
    93,    56,   114,    97,     9,     3,    69,     5,    73,    75,
    89,    90,    17,    20,    39,     9,    69,    17,    73,    75,
    41,    42,     9,     9,     9,    49,    52,    53,    54,     9,
    27,    59,    26,    64,     9,    24,    76,    77,    78,    79,
    81,    17,    83,    84,    85,    86,    87,    22,    88,    32,
     9,    33,    98,    99,   100,    19,   102,    16,   106,    35,
     9,    17,    15,   109,   110,   111,   112,   113,    17,    17,
     9,   115,     6,   117,   118,   101 ]

racc_action_check = [
    50,   114,    79,   110,    45,    25,    79,    89,    45,    72,
    29,    92,    48,    72,    29,    48,   108,     4,    10,     4,
    10,    21,   110,   114,    86,    79,    45,    50,    79,    25,
    92,    72,   108,    92,    54,     1,    86,     1,    86,    86,
    75,    75,    12,    12,    28,    20,    54,    30,    54,    54,
    33,    34,    35,    36,    37,    38,    39,    42,    44,    19,
    16,    49,    15,    51,    52,    14,    55,    56,    57,    59,
    62,    65,    67,    68,    69,    70,    71,    13,    73,    22,
    78,    23,    80,    81,    82,    11,    84,     8,    87,    24,
    90,    91,     7,    94,    97,    98,    99,   104,   105,   107,
     5,   109,     3,   112,   113,    83 ]

racc_action_pointer = [
   nil,    35,   nil,   102,    13,    94,   nil,    82,    82,   nil,
    12,    78,    36,    66,    50,    60,    57,   nil,   nil,    53,
    39,    18,    67,    68,    87,     3,   nil,   nil,    37,     8,
    41,   nil,   nil,    36,    42,    46,    47,    48,    28,    54,
   nil,   nil,    54,   nil,    51,     2,   nil,   nil,     9,    59,
    -2,    60,    58,   nil,    28,    41,    42,    51,   nil,    67,
   nil,   nil,    68,   nil,   nil,    65,   nil,    65,    66,    55,
    68,    60,     7,    59,   nil,    18,   nil,   nil,    74,     0,
    70,    67,    81,    86,    67,   nil,    18,    85,   nil,     1,
    84,    85,     5,   nil,    81,   nil,   nil,    92,    92,    66,
   nil,   nil,   nil,   nil,    81,    92,   nil,    93,    10,    98,
    -3,   nil,   101,   101,    -1,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
    -1,   -50,    -2,   -50,   -50,   -50,   120,   -50,   -50,    -6,
   -50,   -50,    -8,   -50,   -50,   -50,   -50,    -7,   -11,   -50,
   -50,   -50,   -50,   -50,   -50,   -50,   -15,    -5,   -50,   -50,
    -9,    -4,   -16,   -50,   -50,   -50,   -50,   -50,   -50,   -50,
   -12,   -17,   -50,   -18,   -50,   -50,   -22,   -19,   -50,   -50,
   -50,   -50,   -50,   -14,   -50,   -50,   -50,   -24,   -39,   -50,
   -40,   -41,   -50,    -3,   -10,   -13,   -26,   -50,   -50,   -50,
   -50,   -50,   -28,   -50,   -23,   -50,   -38,   -37,   -50,   -50,
   -50,   -50,   -50,   -50,   -50,   -31,   -50,   -50,   -33,   -50,
   -50,   -25,   -50,   -46,   -50,   -44,   -47,   -50,   -50,   -50,
   -48,   -32,   -34,   -27,   -50,   -28,   -21,   -35,   -50,   -50,
   -50,   -43,   -50,   -50,   -50,   -42,   -45,   -49,   -20,   -36 ]

racc_goto_table = [
    10,    12,    71,    66,    80,    60,    61,    43,    47,    51,
    50,    63,     1,    21,    11,    29,    30,    28,    38,    13,
    23,    34,    25,    70,    94,    14,    74,   119,     7,     4,
     2,   116,    82,    48,   104,   103,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    65,   nil,
    72,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    91,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   105,   nil,   nil,   107,   108 ]

racc_goto_check = [
    10,    10,    21,    24,    28,    27,    27,    18,    18,    14,
     8,     9,     1,    11,    12,    10,    10,    13,     7,    15,
    16,    17,     6,    20,    28,     5,    22,    23,     4,     3,
     2,    29,    30,    10,    21,    24,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    10,   nil,
    10,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    10,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    10,   nil,   nil,    10,    10 ]

racc_goto_pointer = [
   nil,    12,    29,    28,    24,    18,     8,    -7,   -28,   -39,
    -4,     1,    10,    -2,   -30,    12,     7,    -2,   -28,   nil,
   -31,   -52,   -28,   -87,   -51,   nil,   nil,   -44,   -55,   -79,
   -30 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    45,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    44,
   nil,   nil,    46,    57,   nil,    67,    68,   nil,   nil,    95,
   nil ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 :INTEGER => 2,
 :NEWLINE => 3,
 :iks_reg => 4,
 :text_name_description => 5,
 :WORD => 6,
 "," => 7,
 :AG => 8,
 :DATE_NUMERIC => 9,
 :REGISTRATION => 10,
 :IKS_CAT => 11,
 :IKS_CAT_VAL => 12,
 :INDEX_TH => 13,
 :INDEX_TH_VAL => 14,
 :COMPOSITION => 15,
 "." => 16,
 :AGENT_IN_FORM_OF => 17,
 :CONSERV => 18,
 :E123_VAL => 19,
 :ANTIOX => 20,
 :EXCIPIENS => 21,
 :PRO => 22,
 :AD => 23,
 :FLOAT => 24,
 :UNIT => 25,
 :INDICATION => 26,
 :PACKAGE => 27,
 "x" => 28,
 :VALID_UNTIL => 29,
 :MONTH => 30 }

racc_use_result_var = true

racc_nt_base = 31

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'INTEGER',
'NEWLINE',
'iks_reg',
'text_name_description',
'WORD',
'","',
'AG',
'DATE_NUMERIC',
'REGISTRATION',
'IKS_CAT',
'IKS_CAT_VAL',
'INDEX_TH',
'INDEX_TH_VAL',
'COMPOSITION',
'"."',
'AGENT_IN_FORM_OF',
'CONSERV',
'E123_VAL',
'ANTIOX',
'EXCIPIENS',
'PRO',
'AD',
'FLOAT',
'UNIT',
'INDICATION',
'PACKAGE',
'"x"',
'VALID_UNTIL',
'MONTH',
'$start',
'reg_list',
'registrierung',
'complete_name',
'company_address',
'complete_header',
'composition',
'indication',
'packages',
'valid_until',
'text',
'name_description',
'company_name',
'street_number',
'plz_location',
'registration',
'iks_cat',
'index_therapeuticus',
'ingredients',
'active_ingredients',
'passive_ingredients',
'galenic_form',
'active_ingredient',
'quantity',
'passive_ingredient',
'conservatives',
'antioxidants',
'package',
'package_size',
'package_unit',
'date_localized']

Racc_debug_parser = true

##### racc system variables end #####

 # reduce 0 omitted

 # reduce 1 omitted

module_eval <<'.,.,', 'swissmedic.y', 7
  def _reduce_2( val, _values, result )
						result = val.join(" #####################\n ")
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 18
  def _reduce_3( val, _values, result )
									result = val.join(' * ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 23
  def _reduce_4( val, _values, result )
									p "complete_name: #{val[0]} - #{val[1]} - #{val[2]}"
									result = val.join(' ').strip
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 28
  def _reduce_5( val, _values, result )
									p "complete_name: #{val[1]} - #{val[2]} - #{val[3]}"
									result = val.join(' ').strip
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 34
  def _reduce_6( val, _values, result )
									p "text: #{val[0]}"
									result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 39
  def _reduce_7( val, _values, result )
									p "text: #{val[1]}"
									result = val[1]
   result
  end
.,.,

 # reduce 8 omitted

module_eval <<'.,.,', 'swissmedic.y', 46
  def _reduce_9( val, _values, result )
									p "name_description: #{val[1]}"
									result = val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 52
  def _reduce_10( val, _values, result )
										p "company_address: #{val.join(' ')}"
										result = val.join(',')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 56
  def _reduce_11( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 58
  def _reduce_12( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 60
  def _reduce_13( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 64
  def _reduce_14( val, _values, result )
									p val.join(' - ')
									result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 68
  def _reduce_15( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 70
  def _reduce_16( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 72
  def _reduce_17( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 76
  def _reduce_18( val, _values, result )
								p val.join(' - ')
								result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 81
  def _reduce_19( val, _values, result )
								result = val[1..2].join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 84
  def _reduce_20( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 85
  def _reduce_21( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 88
  def _reduce_22( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 89
  def _reduce_23( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 91
  def _reduce_24( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 92
  def _reduce_25( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 94
  def _reduce_26( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 95
  def _reduce_27( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 97
  def _reduce_28( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 98
  def _reduce_29( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 99
  def _reduce_30( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 101
  def _reduce_31( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 102
  def _reduce_32( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 104
  def _reduce_33( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 105
  def _reduce_34( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 107
  def _reduce_35( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 108
  def _reduce_36( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 110
  def _reduce_37( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 111
  def _reduce_38( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 113
  def _reduce_39( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 115
  def _reduce_40( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 116
  def _reduce_41( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 118
  def _reduce_42( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 119
  def _reduce_43( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 121
  def _reduce_44( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 122
  def _reduce_45( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 124
  def _reduce_46( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 125
  def _reduce_47( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 127
  def _reduce_48( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

module_eval <<'.,.,', 'swissmedic.y', 129
  def _reduce_49( val, _values, result )
 result = val.join(' ')
   result
  end
.,.,

 def _reduce_none( val, _values, result )
  result
 end

end   # class SpikeParser


if File.readable?(ARGV[0])
	puts "parsing #{ARGV[0]}:"
	src = File.read(ARGV[0])
	print src
	puts
	puts "result:"
	p SpikeParser.new.parse( src )
end

