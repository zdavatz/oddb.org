#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 09.04.2012 -- yasaka@ywesee.com
#  -- oddb -- 16.08.2005 -- ffricker@ywesee.com


$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../..', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'chaptparser'
require 'ext/chapterparse/src/writer'

module ODDB
	module ChapterParse 
		class Parser
			attr_reader :nofill
		end
		class TestParserIntegrate <Minitest::Test
			def setup
				@writer = ChapterParse::Writer.new
				@formatter = HtmlFormatter.new(@writer)
				@parser = ChapterParse::Parser.new(@formatter)
			end	
			def	test_italic_excipiens
				html = <<-EOS
<div class="section">
	<span style="font-style: italic;"> </span>
	<span class="paragraph">
		Dieser Text ist normal 
		<span style="font-style: italic;">
			und dieser in Italic
		</span>
	</span>
</div>
				EOS
				@parser.feed(html)
				chapter = @writer.chapter
				assert_instance_of(Text::Chapter, chapter)
				assert_equal('', chapter.heading)
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('Dieser Text ist normal und dieser in Italic',
					paragraph.text)
				assert_equal(3, paragraph.formats.size)
				fmt1 = paragraph.formats.at(0)
				assert_equal(0..21, fmt1.range)
				assert_equal([], fmt1.values)
				fmt2 = paragraph.formats.at(1)
				assert_equal(22..42, fmt2.range)
				assert_equal([:italic], fmt2.values)
				fmt3 = paragraph.formats.at(2)
				assert_equal(43..-1, fmt3.range)
				assert_equal([], fmt3.values)
			end	
      def test_subheading_newline
        html = <<-EOS
        <span style="font-style: italic;">Kinder ab ½ Jahr: </span><br> <div style="font-style: italic;"><span style="font-style: italic;">½-1 Jahr:</span>&nbsp;<span class="paragraph">2×&nbsp;täglich 1 Suppositorium 125&nbsp;mg.</span></div> <div style="font-style: italic;"><span style="font-style: italic;">1-3 Jahre:</span>&nbsp;<span class="paragraph">3×&nbsp;täglich 1 Suppositorium 125&nbsp;mg.</span></div><div style="font-style: italic;"><span class="paragraph"></span><span class="paragraph"><br> </span><span class="paragraph"></span></div>
        EOS
        @parser.feed(html)
        chapter = @writer.chapter
        assert_equal(5, chapter.sections.size)
        sct1, sct2, sct3 = chapter.sections
        assert_equal("Kinder ab ½ Jahr:\n", sct1.subheading)
        assert_equal([], sct1.paragraphs)
        assert_equal("½-1 Jahr:", sct2.subheading)
        assert_equal(0, sct2.paragraphs.size)
    #   pg1 = sct2.paragraphs.first
    #   assert_equal('2× täglich 1 Suppositorium 125 mg.', pg1.text)
      end
			def test_courier_output
				src = <<-EOS
				<span style="font-family: courier new,mono;">Dies ist Courier.</span>
				EOS
				@parser.feed(src)
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				assert_equal("Dies ist Courier.\n", paragraph.text)
			end
			def test_table__0
				src = <<-EOS
<table>
	<tbody>
		<tr>
			<td>
				table
			</td>
		</tr>
	</tbody>
</table>
				EOS
				@parser.feed(src)
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				expected = "-----\ntable\n-----\n"
				assert_equal(expected, paragraph.text)
			end
			def test_table__1
				src = <<-EOS
<table border="1" bordercolor="#000000" cellpadding="5" cellspacing="0" frame="hsides" rules="groups" width="462">
	<col width="143">
	<col width="147">
	<col width="143">
	<tbody>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH"><br>
				</p>
			</td>
			<td width="147">
				<p style="margin-bottom: 0cm;" lang="de-CH"><font face="Courier New, monospace"><font size="2">Disktest*</font></font></p>
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">Hemmhofdurchmesser
						(mm)</font></font></p>
			</td>
			<td width="143">
				<p style="margin-bottom: 0cm;" lang="de-CH"><font face="Courier New, monospace"><font size="2">Verdünnungstest**</font></font></p>
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">MHK
						(mg/l) </font></font>
				</p>
			</td>
		</tr>
	</tbody>
</table>
				EOS
				@parser.feed(src)
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				expected = <<-TABLE
--------------------------------------------------
  Disktest*                      Verdünnungstest**
  Hemmhofdurchmesser
                                                (mm)  MHK
                                                (mg/l)
--------------------------------------------------
				TABLE
				puts paragraph
        assert_equal(expected, paragraph.text.gsub(/ *$/m, '')) # ignore trailing space
			end
			def test_table
				src = <<-EOS
<table border="1" bordercolor="#000000" cellpadding="5" cellspacing="0" frame="hsides" rules="groups" width="462">
	<col width="143">
	<col width="147">
	<col width="143">
	<tbody>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH"><br>
				</p>
			</td>
			<td width="147">
				<p style="margin-bottom: 0cm;" lang="de-CH"><font face="Courier New, monospace"><font size="2">Disktest*</font></font></p>
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">Hemmhofdurchmesser
						(mm)</font></font></p>
			</td>
			<td width="143">
				<p style="margin-bottom: 0cm;" lang="de-CH"><font face="Courier New, monospace"><font size="2">Verdünnungstest**</font></font></p>
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">MHK
						(mg/l) </font></font>
				</p>
			</td>
		</tr>
	</tbody>
	<tbody>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH">
				</p>
			</td>
			<td width="147">
				<p lang="de-CH"><font face="Arial Unicode MS, sans-serif"><font size="3"><font size="2"><font face="Courier New, monospace"><span lang="fr-FR">³
				</span>16</font></font></font></font></p>
			</td>
			<td width="143">
				<p lang="de-CH"><font face="Arial Unicode MS, sans-serif"><font size="3"><font size="2"><font face="Courier New, monospace">£
								2 + £ 38</font></font></font></font></p>
			</td>
		</tr>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH"><br>
				</p>
			</td>
			<td width="147">
				<p lang="de-CH"><br>
				</p>
			</td>
			<td width="143">
				<p lang="de-CH"><br>
				</p>
			</td>
		</tr>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">Teilweise
						empfindlich</font></font></p>
			</td>
			<td width="147">
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">11
						- 15</font></font></p>
			</td>
			<td width="143">
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">4
						+ 76</font></font></p>
			</td>
		</tr>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH"><br>
				</p>
			</td>
			<td width="147">
				<p lang="de-CH"><br>
				</p>
			</td>
			<td width="143">
				<p lang="de-CH"><br>
				</p>
			</td>
		</tr>
		<tr valign="top">
			<td width="143">
				<p lang="de-CH"><font face="Courier New, monospace"><font size="2">Résistance</font></font></p>
			</td>
			<td width="147">
				<p lang="de-CH"><font face="Arial Unicode MS, sans-serif"><font size="3"><font size="2"><font face="Courier New, monospace">£
								10</font></font></font></font></p>
			</td>
			<td width="143">
				<p lang="de-CH"><font face="Arial Unicode MS, sans-serif"><font size="3"><font size="2"><font face="Courier New, monospace"><span lang="fr-FR">³
				</span>8 + <span lang="fr-FR">³ </span>152</font></font></font></font></p>
			</td>
		</tr>
	</tbody>
</table>
				EOS
				@parser.feed(src)
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				expected = <<-TABLE
------------------------------------------------------------------------------
                             Disktest*                      Verdünnungstest**
                             Hemmhofdurchmesser
                                                (mm)  MHK
                                                (mg/l)
                             ³
                                16                       £
                                                                2 + £ 38
Teilweise
                                                empfindlich  11
                                                - 15                  4
                                                + 76
Résistance                   £
                                                                10                   ³
                                8 + ³ 152
------------------------------------------------------------------------------
				TABLE
        assert_equal(expected, paragraph.text.gsub(/ *$/m, '')) # ignore trailing space
			end
		end
	end 
end
