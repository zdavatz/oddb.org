#!/usr/bin/env ruby
# RockitSwissmedicSpike -- oddb -- 04.12.2002 -- hwyss@ywesee.com

require 'rockit/rockit'

def swissmedic_parser
	# spikesource
	Parse.generate_parser <<-'END_OF_GRAMMAR'
	Grammar SwissmedicJournal
		Tokens
			BLANK						=	/\s+/						[:Skip]
			COMPOSITION			=	/((Zusammensetzung)|(Composition)|(Composizione)):/
			DATENUM					=	/[0-3]\d\.[0-1]\d.[1-2]\d{3}/
			E123VAL					=	/E \d{3}/
			EXCP						= /EXCIPIENS/
			EXP							=	/((G.ltig bis)|(Valable jusqu.au)|(Valevole fino al)):/
			FLOAT						= /\d+\.\d+/
			IKSCAT					=	/((Abgabekategorie)|(Cat.gorie de remise)|(Modo di vendita)):/
			IKSCATVAL				=	/[A-E]/
			INDEXTH					=	/Index:/
			INDEXTHVAL			=	/(\d{2}\.){2}\d\./
			INDICATION			=	/((Anwendung)|(Indication)|(Indicazione)):/
			INTEGER					=	/[0-9]+/
			NEWLINE					= /\s*[\n\r]+/
			PACKAGE					=	/((Packung(en)?)|(Conditionnements?)|(Confezion[ei])):/
			REGISTRATION		=	/((Zul\.-Nr\.)|(N. AMM)):/
			UNIT						= /((mg)|(g)|(ug)|(U\.I\.))\b/
			WORD						= /[a-zהצüאיט()]+/i
		Productions
			Registrations				->	Registration+		[RegList: registrations]
			Registration				->	ProductName+	
															CompanyAddress 
															RegistrationHeader
															Composition
															Indication
															Packages
															ExpiryDate
															[: 
																productnames,
																address,
																header,
																composition,
																indication,
																sequences,
																expirydate
															]
			ProductName					->	INTEGER Text NEWLINE 
															[: seqnr, namebase, _]
													|		INTEGER Text ',' Text NEWLINE 
															[: seqnr, namebase, _, namedescr, _]
			CompanyAddress			->	Text ',' StreetAddress ',' PlzLocation NEWLINE
															[: company, _, address, _, location, _]
			StreetAddress				->	Text INTEGER? Text?
															[: street, number, modifier]
			PlzLocation					->	INTEGER Text		[: plz, location]
			RegistrationHeader	->	Registration IksCat IndexTh DATENUM NEWLINE
															[: registration, category, index, date, _]
			Registration				->	REGISTRATION INTEGER	[: _, iksnr]
			IksCat							->	IKSCAT IKSCATVAL			[: _, ikscat]
			IndexTh							->	INDEXTH INDEXTHVAL		[: _, index]
			Composition					->	COMPOSITION INTEGER	Ingredients	NEWLINE
															[: _, seqnr, ingredients]
			Ingredients					->	ActiveIngredients (',' PassiveIngredients)? ','
															GalenicForm
			ActiveIngredients		->	ActiveIngredient
													|		ActiveIngredients ',' ActiveIngredient
			ActiveIngredient		->	Text Quantity
													|		Text Quantity 'ut' Text
			PassiveIngredients	->	PassiveIngredient
													|		PassiveIngredients ',' PassiveIngredient
			PassiveIngredient		->	Text
													|		Conservatives
													|		Antioxidants
			Conservatives				->	'CONSERV.:' E123VAL
													|		Conservatives ',' E123VAL
			Antioxidants				->	'ANTIOX.:' E123VAL
													|		Antioxidants ',' E123VAL
			GalenicForm					->	EXCP 'pro' Text '.'
													|		EXCP 'ad' Text 'pro' Quantity '.'
			Indication					->	INDICATION Text NEWLINE
			Packages						->	PACKAGE Package+
			Package							->	INTEGER? INTEGER PackageSize IKSCATVAL NEWLINE
			PackageSize					->	INTEGER ('x' INTEGER)? PackageUnit
			PackageUnit					->	WORD
			ExpiryDate					->	EXP DateLocalized NEWLINE
			DateLocalized				->	INTEGER '.' WORD INTEGER
			Quantity						->	FLOAT UNIT
													|		INTEGER UNIT
			Text								->	WORD+
	END_OF_GRAMMAR
end

if (ARGV[0] && File.readable?(ARGV[0]))
	file = ARGV[0]
else
	file = '/var/www/oddb.org/spike/spikesource'
end
puts "parsing #{file}:"
src = File.read(file)
if src
	puts src
	puts "result:"
	p swissmedic_parser.parse( src )
end

