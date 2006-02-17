#!/usr/bin/env ruby
# TestWhoPlugin -- ODDB -- 23.02.2004 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/who'

module ODDB
	class TestWhoWriter < Test::Unit::TestCase
		class StubRow < Array
			alias :cdata :at
		end
		def setup
			@writer = WhoWriter.new
			@dir = File.expand_path('../data/html/who', File.dirname(__FILE__))
		end
		def test_href2atc
			ATC_TOP_LEVEL.each { |toplevel|
				assert_equal(toplevel, @writer.href2atc("query=#{toplevel}"))
			}
			assert_nil(@writer.href2atc("query=A0"))
			assert_equal('A12', @writer.href2atc("query=A12"))
			assert_equal('B12A', @writer.href2atc("query=B12A"))
			assert_equal('B12AC', @writer.href2atc("query=B12AC"))
			assert_equal('B12AC03', @writer.href2atc("query=B12AC03"))
			assert_nil(@writer.href2atc("query=B12AC03C"))
			assert_equal('B12AC03', @writer.href2atc("query=B12AC03&"))
		end
		def test_row2ddd1
			row = StubRow.new
			row << 'B01AB01'
			row << 'Heparin'
			row << '10'
			row << 'TU'
			row << 'P'
			row << ''
			expected = {
				:dose	=>	ODDB::Dose.new(10, 'TU'),
				:administration_route	=>	'P',
			}
			assert_equal(expected, @writer.row2ddd(row))
		end
		def test_row2ddd2
			row = StubRow.new
			row << 'B01AB11'
			row << 'Sulodexide'
			row << '500'
			row << 'LSU1)'
			row << 'O'
			row << '1) LSU = lipoprotein lipase releasing units'
			expected = {
				:dose	=>	ODDB::Dose.new(500, 'LSU'),
				:administration_route	=>	'O',
				:note =>	'LSU = lipoprotein lipase releasing units'
			}
			puts "we can expect"
			assert_equal(expected, @writer.row2ddd(row))
		end
	end
	class TestWhoWriter_A < Test::Unit::TestCase
		def setup
			@writer = WhoWriter.new
			@dir = File.expand_path('../data/html/who', File.dirname(__FILE__))
			file = File.expand_path("A.html", @dir)
			html = File.read(file)
			formatter = HtmlFormatter.new(@writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
		end
		def test_extract_descriptions
			descriptions = @writer.extract_descriptions
			assert_instance_of(Hash, descriptions)
			assert_equal(17, descriptions.size)
			assert_equal('ALIMENTARY TRACT AND METABOLISM', descriptions['A'])
		end
		def test_extract_guidelines
			guidelines = @writer.extract_guidelines
			assert_instance_of(Hash, guidelines)
			assert_equal(4, guidelines.size)
			chapter = guidelines["A12"]
			assert_instance_of(Text::Chapter, chapter)
			expected = <<-EOS
This group contains mineral supplements used for treatment of mineral deficiency. Magnesium carbonate used for treatment of mineral deficiency is classified in A02A A01.
			EOS
			assert_equal(expected.strip, chapter.to_s)
		end
		def test_extract_guidelines__no_ddd
			guidelines = @writer.extract_guidelines
			assert_instance_of(Hash, guidelines)
			assert_equal(4, guidelines.size)
			chapter = guidelines["A15"]
			assert_instance_of(Text::Chapter, chapter)
			assert_equal(2, chapter.sections.size)
			section1 =  <<-EOS
This group comprises preparations only used as appetite stimulants.
A number of drugs with other main actions may have appetite stimulating properties.
			EOS
			section2 = <<-EOS
Cyproheptadine, also used as an appetite stimulant in children, is classified in R06A X. Pizotifen is classified in N02C X.
			EOS
			assert_equal(section1.strip, chapter.sections.first.to_s)
			assert_equal(section2.strip, chapter.sections.last.to_s)
		end
		def test_extract_ddd_guidelines
			guidelines = @writer.extract_ddd_guidelines
			assert_instance_of(Hash, guidelines)
			assert_equal(2, guidelines.size)
			chapter = guidelines["A15"]
			assert_equal(1, chapter.sections.size)
			section =  <<-EOS
No DDDs are established in this group.
			EOS
			assert_equal(section.strip, chapter.sections.first.to_s)
		end
	end
	class TestWhoWriter_C03AA < Test::Unit::TestCase
		def setup
			@writer = WhoWriter.new
			@dir = File.expand_path('../data/html/who', File.dirname(__FILE__))
			file = File.expand_path("C03AA.html", @dir)
			html = File.read(file)
			formatter = HtmlFormatter.new(@writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
		end
		def test_extract_descriptions
			descriptions = @writer.extract_descriptions
			assert_instance_of(Hash, descriptions)
			assert_equal(14, descriptions.size)
			assert_equal('Polythiazide', descriptions['C03AA05'])
		end
		def test_extract_guidelines__no_ddd
			guidelines = @writer.extract_guidelines
			assert_instance_of(Hash, guidelines)
			assert_equal(2, guidelines.size)
			chapter = guidelines["C03"]
			assert_instance_of(Text::Chapter, chapter)
			assert_equal(6, chapter.sections.size)
			section1 =  <<-EOS
This group comprises diuretics, plain and in combination with potassium or other agents. Potassium-sparing agents are classified in C03D and C03E.
			EOS
			section6 = <<-EOS
Combinations with agents acting on the renin angiotensin system, see C09B and C09D.
			EOS
			assert_equal(section1.strip, chapter.sections.first.to_s)
			assert_equal(section6.strip, chapter.sections.last.to_s)
		end
		def test_extract_ddd_guidelines
			guidelines = @writer.extract_ddd_guidelines
			assert_instance_of(Hash, guidelines)
			assert_equal(2, guidelines.size)
			chapter = guidelines["C03"]
			assert_equal(2, chapter.sections.size)
			section1 =  <<-EOS
The DDDs for diuretics are based on monotherapy. Most diuretics are used both for the treatment of edema and hypertension in similar doses and the DDDs are therefore based on both indications.
			EOS
			section2 =  <<-EOS
The DDDs for combinations correspond to the DDD for the diuretic component, except for ATC group C03E, see comments under this level.
			EOS
			assert_equal(section1.strip, chapter.sections.first.to_s)
			assert_equal(section2.strip, chapter.sections.last.to_s)
		end
		def test_extract_ddd
			ddd = @writer.extract_ddd
			assert_instance_of(Hash, ddd)	
			assert_equal(9, ddd.size)
			ddd1 = [{
				:dose									=>	Dose.new(2.5, 'mg'),
				:administration_route	=>	'O',
			}]
			assert_equal(ddd1, ddd['C03AA01'])
			ddd9 = [{
				:dose									=>	Dose.new(5, 'mg'),
				:administration_route	=>	'O',
			}]
			assert_equal(ddd9, ddd['C03AA09'])
		end
	end
	class TestWhoWriter_C01BB < Test::Unit::TestCase
		def setup
			@writer = WhoWriter.new
			@dir = File.expand_path('../data/html/who', File.dirname(__FILE__))
			file = File.expand_path("C01BB.html", @dir)
			html = File.read(file)
			formatter = HtmlFormatter.new(@writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
		end
		def test_extract_ddd
			ddd = @writer.extract_ddd
			assert_instance_of(Hash, ddd)	
			assert_equal(4, ddd.size)
			ddd2 = [
				{
					:dose									=>	Dose.new(0.8, 'g'),
					:administration_route	=>	'O',
				},
				{
					:dose									=>	Dose.new(0.8, 'g'),
					:administration_route	=>	'P',
				},
			]
			assert_equal(ddd2, ddd['C01BB02'])
			ddd4 = [
				{
					:dose									=>	Dose.new(0.1, 'g'),
					:administration_route	=>	'O',
				},
				{
					:dose									=>	Dose.new(0.1, 'g'),
					:administration_route	=>	'P',
				},
			]
			assert_equal(ddd4, ddd['C01BB04'])
		end
	end
	class TestWhoWriter_A09AB < Test::Unit::TestCase
		def setup
			@writer = WhoWriter.new
			@dir = File.expand_path('../data/html/who', File.dirname(__FILE__))
			file = File.expand_path("A09AB.html", @dir)
			html = File.read(file)
			formatter = HtmlFormatter.new(@writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)
		end
		def test_extract_ddd
			ddd = @writer.extract_ddd
			assert_instance_of(Hash, ddd)	
			assert_equal(3, ddd.size)
			ddd1 = [
				{
					:dose									=>	Dose.new(1.5, 'g'),
					:administration_route	=>	'O',
				},
			]
			assert_equal(ddd1, ddd['A09AB01'])
			ddd2 = [
				{
					:dose									=>	Dose.new(1, 'g'),
					:administration_route	=>	'O',
				},
			]
			assert_equal(ddd2, ddd['A09AB02'])
			ddd4 = [
				{
					:dose									=>	Dose.new(2, 'g'),
					:administration_route	=>	'O',
				},
			]
			assert_equal(ddd4, ddd['A09AB04'])
		end
	end
	class TestWhoCodeHandler < Test::Unit::TestCase
		def setup
			@handler = WhoCodeHandler.new
		end
		def test_shift
			@handler.instance_variable_set('@codes', ['A', 'B'])
			assert_equal('A', @handler.shift)
			assert_equal(['A'], @handler.instance_variable_get('@visited'))
			assert_equal(['B'], @handler.instance_variable_get('@codes'))
		end
		def test_push
			@handler.instance_variable_set('@codes', ['A'])
			@handler.push('B')
			assert_equal(['A', 'B'], @handler.instance_variable_get('@codes'))
		end
		def test_push__visited
			@handler.instance_variable_set('@codes', ['A'])
			@handler.instance_variable_set('@visited', ['B'])
			@handler.push('B')
			assert_equal(['A'], @handler.instance_variable_get('@codes'))
		end
		def test_push__twice
			@handler.instance_variable_set('@codes', ['A', 'B'])
			@handler.push('B')
			assert_equal(['A', 'B'], @handler.instance_variable_get('@codes'))
		end
	end
	class TestWhoSession < Test::Unit::TestCase
=begin
<form action="index.php" method="post">
	<table cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td>E-mail:</td>
			<td>&nbsp;<input type="text" name="username" value="" size="20" maxlength="150">
			</td>
		</tr>
		<tr>
			<td>Password:</td>
			<td>&nbsp;<input type="password" name="password" size="20" maxlength="14">
			</td>
		</tr>
		<tr>
			<td>
				<input type="submit" value="log in">
			</td>
			<td>
			</td>
		</tr>
	</table>
</form>
=end
		def setup
			@session = WhoSession.new
		end
		def test_login
			expected = <<-EOS
<input type="text" name="query" maxlength="100" size="20" value=""><br>
			EOS
			msg = <<-EOS
Login at www.whocc.no failed! 
You need to have valid credentials stored in the file:
$PROJECTROOT/etc/who.txt
in the form:
username = who-username
password = who-password
			EOS
			begin
				result = @session.login()	
			rescue Timeout::Error => e
				flunk(e.message)
			end
			body = result.read_body.strip
			assert_not_nil(body.index(expected), msg)
		end
		def test_load_credentials
			expected = {
				'email'	=>	'someone@somewhere.com',
				'password'	=>	'somepass',
			}
			filename = File.expand_path('../data/etc/who.txt', 
				File.dirname(__FILE__))
			result = @session.load_credentials(filename)
			assert_equal(expected, result)
		end
		def test_post_body
			hash = {
				"foo"	=>	"test@escapism.com",
				"bar"	=>	"Bar",
			}
			expected = <<-EOS
bar=Bar&foo=test%40escapism.com
			EOS
			assert_equal(expected.strip, @session.post_body(hash))
		end
		def test_update_cookies
			assert_equal({}, @session.instance_variable_get('@cookies'))
			resp = {
				'set-cookie'	=>	'PHPSESSID=1e34818c8af18e330a12d19ee4b654be; path=/',
			}
			expected = {
				'PHPSESSID'	=>	'1e34818c8af18e330a12d19ee4b654be'
			}
			@session.update_cookies(resp)
			assert_equal(expected, @session.instance_variable_get('@cookies'))
			resp = {
				'set-cookie'	=>	'foobar=baz',
			}
			@session.update_cookies(resp)
			expected = {
				'PHPSESSID'	=>	'1e34818c8af18e330a12d19ee4b654be',
				'foobar'		=>	'baz',
			}
			assert_equal(expected, @session.instance_variable_get('@cookies'))
		end
		def test_cookies
			cookies = {
				'foo'	=>	'bar',
				'baz'	=>	'faz',
			}
			@session.instance_variable_set('@cookies', cookies)
			assert_equal('baz=faz; foo=bar', @session.cookies)
		end
		def test_get_headers
			cookies = {
				'foo'	=>	'bar',
				'baz'	=>	'faz',
			}
			@session.instance_variable_set('@cookies', cookies)
			expected = {
				'Accept'          =>  'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1',
				'Accept-Charset'	=>	'ISO-8859-1',
				'Accept-Language' =>  'de-ch,en-us;q=0.7,en;q=0.3',
				'Accept-Encoding' =>  'gzip,deflate',
				'Connection'			=>	'keep-alive',
				'Cookie'          =>  'baz=faz; foo=bar',
				'Host'						=>	'www.whocc.no',
				'Keep-Alive'			=>	'300',
				'User-Agent'      =>  'Mozilla/5.0 (X11; U; Linux ppc; en-US; rv:1.4) Gecko/20030716',
				'Referer'         =>  'http://www.whocc.no/atcddd/database/index.php',
			}
			assert_equal(expected, @session.get_headers)
		end
		def test_post_headers
			cookies = {
				'foo'	=>	'bar',
				'baz'	=>	'faz',
			}
			@session.instance_variable_set('@cookies', cookies)
			expected = {
				'Accept'          =>  'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1',
				'Accept-Charset'	=>	'ISO-8859-1',
				'Accept-Language' =>  'de-ch,en-us;q=0.7,en;q=0.3',
				'Accept-Encoding' =>  'gzip,deflate',
				'Connection'			=>	'keep-alive',
				'Content-Type'		=>	'application/x-www-form-urlencoded',
				'Cookie'          =>  'baz=faz; foo=bar',
				'Host'						=>	'www.whocc.no',
				'Keep-Alive'			=>	'300',
				'User-Agent'      =>  'Mozilla/5.0 (X11; U; Linux ppc; en-US; rv:1.4) Gecko/20030716',
				'Referer'         =>  'http://www.whocc.no/atcddd/database/index.php',
			}
			assert_equal(expected, @session.post_headers)
		end
		def test_atc_query
			expected = '/atcddd/database/index.php?query=A&showdescription=yes'
			assert_equal(expected, @session.atc_query('A'))
		end
	end
	class TestWhoPlugin < Test::Unit::TestCase
		class StubApp
			attr_accessor :atc_classes, :pointers, :values, :results, :resolves
			def initialize
				@pointers = []
				@values = []
				@results = []
				@resolves = []
			end
			def atc_class(code)
				@atc_classes[code]
			end
			def update(pointer, values, origin)
				@pointers << pointer
				@values << values
				@results.shift
			end
			def resolve(pointer)
				@resolves.shift
			end
		end
		class StubWriter
			attr_accessor :extract_descriptions, :extract_guidelines
			attr_accessor :extract_ddd_guidelines, :extract_ddd
		end
		class StubLanguage
			attr_accessor :en
		end
		def setup
			@app = StubApp.new
			@plugin = WhoPlugin.new(@app)
			@dir = File.expand_path('../data/html/who', File.dirname(__FILE__))
		end
		def test_extract
			html = File.read(File.expand_path('A.html', @dir))
		end
		def test_extract_descriptions1
			writer = StubWriter.new
			writer.extract_descriptions = {
				'A'	=>	'ALIMENTARY TRACT AND METABOLISM',
			}
			@app.atc_classes = {}
			@plugin.extract_descriptions(writer)
			pointer = Persistence::Pointer.new([:atc_class, 'A'])
			assert_equal([pointer.creator], @app.pointers)
			expected = [{:en => 'ALIMENTARY TRACT AND METABOLISM'}]
			assert_equal(expected, @app.values)
		end
		def test_extract_descriptions2
			writer = StubWriter.new
			writer.extract_descriptions = {
				'A'	=>	'ALIMENTARY TRACT AND METABOLISM',
			}
			atc = StubLanguage.new
			atc.en = 'SOME OLDER DESCRIPTION'
			@app.atc_classes = {
				'A'	=>	atc,
			}
			@plugin.extract_descriptions(writer)
			pointer = Persistence::Pointer.new([:atc_class, 'A'])
			assert_equal([pointer.creator], @app.pointers)
			expected = [{:en => 'ALIMENTARY TRACT AND METABOLISM'}]
			assert_equal(expected, @app.values)
		end
		def test_extract_descriptions3
			writer = StubWriter.new
			writer.extract_descriptions = {
				'A'	=>	'ALIMENTARY TRACT AND METABOLISM',
			}
			atc = StubLanguage.new
			atc.en = 'ALIMENTARY TRACT AND METABOLISM'
			@app.atc_classes = {
				'A'	=>	atc,
			}
			@plugin.extract_descriptions(writer)
			assert_equal([], @app.pointers)
			assert_equal([], @app.values)
		end
		def test_extract_guidelines1
			writer = StubWriter.new
			writer.extract_guidelines = {
				'A'	=>	'A Chapter Object'
			}
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:guidelines])
			@plugin.extract_guidelines(writer)
			assert_equal([pointer.creator], @app.pointers)
			assert_equal([{:en	=>	'A Chapter Object'}], @app.values)
		end
		def test_extract_guidelines2
			writer = StubWriter.new
			writer.extract_guidelines = {
				'A'	=>	'A Chapter Object'
			}
			document = StubLanguage.new
			document.en = "Another Chapter Object"
			@app.resolves << document
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:guidelines])
			@plugin.extract_guidelines(writer)
			assert_equal([pointer.creator], @app.pointers)
			assert_equal([{:en	=>	'A Chapter Object'}], @app.values)
		end
		def test_extract_guidelines3
			writer = StubWriter.new
			writer.extract_guidelines = {
				'A'	=>	'A Chapter Object'
			}
			document = StubLanguage.new
			document.en = "A Chapter Object"
			@app.resolves << document
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:guidelines])
			@plugin.extract_guidelines(writer)
			assert_equal([], @app.pointers)
			assert_equal([], @app.values)
		end
		def test_extract_ddd_guidelines1
			writer = StubWriter.new
			writer.extract_ddd_guidelines = {
				'A'	=>	'A Chapter Object'
			}
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:ddd_guidelines])
			@plugin.extract_ddd_guidelines(writer)
			assert_equal([pointer.creator], @app.pointers)
			assert_equal([{:en	=>	'A Chapter Object'}], @app.values)
		end
		def test_extract_ddd_guidelines2
			writer = StubWriter.new
			writer.extract_ddd_guidelines = {
				'A'	=>	'A Chapter Object'
			}
			document = StubLanguage.new
			document.en = "Another Chapter Object"
			@app.resolves << document
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:ddd_guidelines])
			@plugin.extract_ddd_guidelines(writer)
			assert_equal([pointer.creator], @app.pointers)
			assert_equal([{:en	=>	'A Chapter Object'}], @app.values)
		end
		def test_extract_ddd_guidelines3
			writer = StubWriter.new
			writer.extract_ddd_guidelines = {
				'A'	=>	'A Chapter Object'
			}
			document = StubLanguage.new
			document.en = "A Chapter Object"
			@app.resolves << document
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:ddd_guidelines])
			@plugin.extract_ddd_guidelines(writer)
			assert_equal([], @app.pointers)
			assert_equal([], @app.values)
		end
		def test_extract_ddd1
			writer = StubWriter.new
			writer.extract_ddd = {
				'A'	=>	[
					{
						:dose									=>	Dose.new(1.5, 'g'),
						:administration_route	=>	'O',
					},
				],
			}
			@plugin.extract_ddd(writer)
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:ddd, 'O'])
			assert_equal([pointer.creator], @app.pointers)
			assert_equal([{:dose	=>	Dose.new(1.5, 'g')}], @app.values)
		end
		def test_extract_ddd2
			writer = StubWriter.new
			writer.extract_ddd = {
				'A'	=>	[
					{
						:dose									=>	Dose.new(1.5, 'g'),
						:administration_route	=>	'O',
					},
				],
			}
			@app.resolves << {
				:dose									=>	Dose.new(2.5, 'g'),
				:administration_route	=>	'O',
			}
			@plugin.extract_ddd(writer)
			pointer = Persistence::Pointer.new([:atc_class, 'A'], [:ddd, 'O'])
			assert_equal([pointer.creator], @app.pointers)
			assert_equal([{:dose	=>	Dose.new(1.5, 'g')}], @app.values)
		end
		def test_extract_ddd3
			writer = StubWriter.new
			writer.extract_ddd = {
				'A'	=>	[
					{
						:dose									=>	Dose.new(1.5, 'g'),
						:administration_route	=>	'O',
					},
				],
			}
			@app.resolves << {
				:dose									=>	Dose.new(1.5, 'g'),
				:administration_route	=>	'O',
			}
			@plugin.extract_ddd(writer)
			assert_equal([], @app.pointers)
			assert_equal([], @app.values)
		end
	end
end
