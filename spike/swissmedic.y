class SpikeParser

rule

reg_list						: /* nothing */
										| reg_list registrierung
										{
											result = val.join(" #####################\n ")
										}

registrierung				:	complete_name 
											company_address 
											complete_header
											composition
											indication
											packages
											valid_until
											{
												result = val.join(' * ')
											}

complete_name				: INTEGER text name_description NEWLINE
										{
											p "complete_name: #{val[0]} - #{val[1]} - #{val[2]}"
											result = val.join(' ').strip
										}
										| complete_name iks_reg text_name_description NEWLINE
										{
											p "complete_name: #{val[1]} - #{val[2]} - #{val[3]}"
											result = val.join(' ').strip
										}

text								: WORD
										{
											p "text: #{val[0]}"
											result = val[0]
										}
										| text WORD
										{
											p "text: #{val[1]}"
											result = val[1]
										}

name_description		: /* nothing */
										| ',' text
										{
											p "name_description: #{val[1]}"
											result = val[1]
										}

company_address			: company_name ',' street_number ',' plz_location NEWLINE
										{
											p "company_address: #{val.join(' ')}"
											result = val.join(',')
										}

company_name				: text AG { result = val.join(' ') }

street_number				: text INTEGER { result = val.join(' ') }

plz_location				: INTEGER text { result = val.join(' ') }

complete_header			: registration iks_cat index_therapeuticus DATE_NUMERIC NEWLINE
										{
											p val.join(' - ')
											result = val.join(' ')
										}

registration				: REGISTRATION INTEGER { result = val.join(' ') }

iks_cat							: IKS_CAT IKS_CAT_VAL { result = val.join(' ') }

index_therapeuticus : INDEX_TH INDEX_TH_VAL { result = val.join(' ') }

composition					: COMPOSITION INTEGER ingredients 
										{
											p val.join(' - ')
											result = val.join(' ')
										}
										| composition INTEGER ingredients
										{
											result = val[1..2].join(' ')
										}

ingredients					: active_ingredients ',' passive_ingredients ',' galenic_form '.' NEWLINE { result = val.join(' ') }
										| active_ingredients ',' galenic_form '.' NEWLINE { result = val.join(' ') }
						

active_ingredients	: active_ingredient { result = val.join(' ') }
										| active_ingredients ',' active_ingredient { result = val.join(' ') }

active_ingredient		: text quantity { result = val.join(' ') }
										| text quantity AGENT_IN_FORM_OF text { result = val.join(' ') }

passive_ingredients : passive_ingredient { result = val.join(' ') }
										| passive_ingredients ',' passive_ingredient { result = val.join(' ') }

passive_ingredient	: text { result = val.join(' ') }
										| conservatives { result = val.join(' ') }
										| antioxidants { result = val.join(' ') }

conservatives				: CONSERV E123_VAL { result = val.join(' ') }
										| conservatives ',' E123_VAL { result = val.join(' ') }

antioxidants				: ANTIOX E123_VAL { result = val.join(' ') }
										| antioxidants ',' E123_VAL { result = val.join(' ') }

galenic_form				: EXCIPIENS PRO text { result = val.join(' ') }
										| EXCIPIENS AD text PRO quantity { result = val.join(' ') }

quantity						: FLOAT UNIT { result = val.join(' ') }
										| INTEGER UNIT { result = val.join(' ') }

indication					: INDICATION text NEWLINE { result = val.join(' ') }

packages						: PACKAGE package { result = val.join(' ') }
										| packages package { result = val.join(' ') }

package							: INTEGER INTEGER package_size IKS_CAT_VAL NEWLINE { result = val.join(' ') }
										| INTEGER package_size IKS_CAT_VAL NEWLINE { result = val.join(' ') }

package_size				: INTEGER package_unit { result = val.join(' ') }
										| INTEGER 'x' INTEGER package_unit { result = val.join(' ') }

package_unit				: UNIT { result = val.join(' ') }
										| WORD { result = val.join(' ') }

valid_until					: VALID_UNTIL date_localized NEWLINE { result = val.join(' ') }

date_localized			: INTEGER '.' MONTH INTEGER { result = val.join(' ') }

end

---- inner

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
		
	do_parse
end

def next_token
	p @q.first
  @q.shift
end

---- footer

if File.readable?(ARGV[0])
	puts "parsing #{ARGV[0]}:"
	src = File.read(ARGV[0])
	print src
	puts
	puts "result:"
	p SpikeParser.new.parse( src )
end

