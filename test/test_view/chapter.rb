#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestChapter -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com
# ODDB::View::TestChapter -- oddb.org -- 02.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'view/chapter'
require 'stub/cgi'
require 'model/text'
require 'flexmock'

module ODDB
	module View
		class TestChapter <Minitest::Test
			def setup 
				@lookandfeel = FlexMock.new 'lookandfeel'
				@lookandfeel.should_receive(:section_style).and_return { 'section_style' }
				session = FlexMock.new 'session'
				session.should_receive(:lookandfeel).and_return { @lookandfeel }
        session.should_receive(:user_input)
				assert(session.respond_to?(:lookandfeel))
				@view = View::Chapter.new(:name, nil, session)
			end	
			def test_escaped_paragraphs
				txt = "Guten Tag! & wie gehts uns Heute? < oder >?"
				par1 = Text::Paragraph.new
				par2 = Text::Paragraph.new
				par1 << txt
				par2 << txt
				par1.preformatted!
				result = @view.paragraphs(CGI.new, [par1, par2])
				expected = <<-EOS
		<PRE style="#{View::Chapter.const_get(:PRE_STYLE)}">Guten Tag! &amp; wie gehts uns Heute? &lt; oder &gt;?</PRE><SPAN style="#{View::Chapter.const_get(:PAR_STYLE)}">Guten Tag! &amp; wie gehts uns Heute? &lt; oder &gt;?</SPAN><BR>
				EOS
				assert_equal(expected.strip, result)
			end

      def test_emit_http_links
        vorher  = 'vorher: '
        nachher = ' und nachher'
        link = 'http://www.nzz.ch'
        par1 = Text::Paragraph.new
        par1 << vorher
        par1.add_link(link)
        par1 << nachher
        result = @view.paragraphs(CGI.new, [par1])
        expected = <<-EOS
    <SPAN style="padding-bottom: 4px; white-space: normal; line-height: 1.4em;">vorher:<A href="http://www.nzz.ch"> http://www.nzz.ch</A> und nachher</SPAN><BR>
        EOS
        assert_equal(expected.strip, result)
        assert(result.index(nachher.strip), "Must have '#{nachher}' in HTML")
        assert(result.index(vorher.strip), "Must have '#{vorher}' in HTML")
        assert(result.index(nachher), "Must have '#{nachher}' in HTML")
        skip("Exepected should have a space bevor und nachhher, .eg.'> und nachher'")
        assert(result.index(vorher), "Must have '#{vorher}' in HTML")
      end
			def test_escaped_heading
				chapter = Text::Chapter.new
				chapter.heading = "F?r Zwerge > 1.5 m"
				@view.value = chapter
				expected = '<H3>F?r Zwerge &gt; 1.5 m</H3>'
				result = @view.to_html(CGI.new)
				assert_equal(expected, result)
			end
			def test_escaped_subheading
				chapter = Text::Chapter.new
				section = chapter.next_section
				section.subheading = "F?r Zwerge > 1.5 m"
				@view.value = chapter
				expected = <<-EOS
<P style="section_style"><SPAN style="font-style: italic">F?r Zwerge &gt; 1.5 m</SPAN>&nbsp;</P>
				EOS
				result = @view.to_html(CGI.new)
				assert_equal(expected.strip, result)
			end
			def test_formatted_paragraph
				par = Text::Paragraph.new
				par << "Guten "
				par.set_format(:italic)
				par << "Tag"
				par.set_format
				par << "! Guten "
				par.set_format(:bold)
				par << "Abend"
				par.set_format
				par << "! Guten "
				par.set_format(:bold, :italic)
				par << "Morgen!!!"
				par.set_format
				par << " Danke."
				result = @view.paragraphs(CGI.new, [par])
				expected = <<-EOS
<SPAN style="#{View::Chapter.const_get(:PAR_STYLE)}">Guten<SPAN style="font-style:italic;"> Tag</SPAN>! Guten<SPAN style="font-weight:bold;"> Abend</SPAN>! Guten<SPAN style="font-style:italic; font-weight:bold;"> Morgen!!!</SPAN> Danke.</SPAN><BR>
				EOS
				assert_equal(expected.strip, result)
			end
		end
    class TestChapter2 <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf     = flexmock('lookandfeel')
        @session = flexmock('session', :lookandfeel => @lnf)
        value    = flexmock('value', 
                            :heading  => 'heading',
                            :sections => ['section']
                           )
        @model   = flexmock('model', :name => value)
        @chapter = ODDB::View::Chapter.new(:name, @model, @session)
      end
      def test_to_html
        flexmock(@lnf, :section_style => 'section_style')
        flexmock(@session, :user_input  => 'highlight')
        context  = flexmock('context', 
                           :h3 => 'h3',
                           :p  => 'p'
                           )
        assert_equal('h3p', @chapter.to_html(context))
      end
      def test_table
        context = flexmock('context') do |c|
          c.should_receive(:table).and_yield
          c.should_receive(:tr).and_yield
          c.should_receive(:td).and_yield
          c.should_receive(:span).and_return('span')
          c.should_receive(:br).and_return('br')
        end
        format  = flexmock('format', 
                           :link?        => false,
                           :italic?      => nil,
                           :bold?        => nil,
                           :superscript? => nil,
                           :subscript?   => nil,
                           :symbol?      => nil,
                           :range        => 'range'
                          )
        cell    = flexmock('cell', 
                           :col_span => 'col_span',
                           :row_span => 'row_span',
                           :text     => 'text',
                           :formats  => [format],
                           :preformatted? => nil
                          )
        row     = [cell]
        table   = flexmock('table', :rows => [row])
        assert_equal('spanbr', @chapter.table(context, table))
      end
      def test_paragraphs
        context   = flexmock('context', 
                             :span => 'span',
                             :br   => 'br'
                            )
        format    = flexmock('format',
                             :italic?      => nil,
                             :link?        => false,
                             :bold?        => nil,
                             :superscript? => nil,
                             :subscript?   => nil,
                             :symbol?      => nil,
                             :range        => 'range'
                            )
        paragraph = flexmock('paragraph', 
                             :text    => 'text',
                             :formats => [format],
                             :preformatted? => nil
                            )
        assert_equal('spanbr', @chapter.paragraphs(context, [paragraph]))
      end
      def test_paragraphs__text_imagelink
        context   = flexmock('context', 
                             :span => 'span',
                             :br   => 'br',
                             :p    => 'p'
                            )
        format    = flexmock('format',
                             :italic?      => nil,
                             :link?        => false,
                             :bold?        => nil,
                             :superscript? => nil,
                             :subscript?   => nil,
                             :symbol?      => nil,
                             :range        => 'range'
                            )
        paragraph = flexmock('paragraph', 
                             :text    => 'text',
                             :formats => [format],
                             :preformatted? => nil,
                            )
        flexmock(paragraph) do |p|
          p.should_receive(:is_a?).with(Text::ImageLink).once.and_return(true)
        end
        assert_equal('p', @chapter.paragraphs(context, [paragraph]))
      end
      def test_paragraphs__text_table
        context   = flexmock('context', 
                             :span  => 'span',
                             :br    => 'br',
                             :table => 'table'
                            )
        format    = flexmock('format',
                             :italic?      => nil,
                             :link?        => false,
                             :bold?        => nil,
                             :superscript? => nil,
                             :subscript?   => nil,
                             :symbol?      => nil,
                             :range        => 'range'
                            )
        paragraph = flexmock('paragraph', 
                             :text    => 'text',
                             :formats => [format],
                             :preformatted? => nil
                            )
        flexmock(paragraph) do |p|
          p.should_receive(:is_a?).with(Text::ImageLink).and_return(false)
          p.should_receive(:is_a?).with(Text::Table).and_return(true)
        end
        assert_equal('table', @chapter.paragraphs(context, [paragraph]))
      end
      def test_formats
        format    = flexmock('format',
                             :italic?      => nil,
                             :link?        => false,
                             :bold?        => nil,
                             :superscript? => nil,
                             :subscript?   => nil,
                             :symbol?      => nil,
                             :range        => 'range'
                            )
        paragraph = flexmock('paragprah', 
                             :text    => 'text',
                             :formats => [format],
                             :preformatted? => nil
                            )
        context = flexmock('context', 
                           :span => 'span',
                           :br   => 'br'
                          )
        assert_equal('spanbr', @chapter.formats(context, paragraph))
      end
      def test_formats__superscript
        format    = flexmock('format',
                             :italic?      => nil,
                             :link?        => false,
                             :bold?        => nil,
                             :superscript? => true,
                             :subscript?   => nil,
                             :symbol?      => nil,
                             :range        => 'range'
                            )
        paragraph = flexmock('paragprah', 
                             :text    => 'text',
                             :formats => [format],
                             :preformatted? => true
                            )
        context = flexmock('context', 
                           :span => 'span',
                           :br   => 'br',
                           :sup  => 'sup',
                           :pre  => 'pre'
                          )
        assert_equal('pre', @chapter.formats(context, paragraph))
      end
      def test_sections
        flexmock(@lnf, :section_style => 'section_style')
        format    = flexmock('format',
                             :italic?      => nil,
                             :link?        => false,
                             :bold?        => nil,
                             :superscript? => true,
                             :subscript?   => nil,
                             :symbol?      => nil,
                             :range        => 'range'
                            )
        paragraph = flexmock('paragraph', 
                             :text => 'text',
                             :formats => [format],
                             :preformatted? => nil
                            )
        section = flexmock('section', 
                           :subheading => "subheading\n\s",
                           :paragraphs => [paragraph]
                          )
        context = flexmock('context', 
                           :br   => 'br',
                           :sup  => 'sup',
                           :pre  => 'pre'
                          )
 
        flexmock(context) do |c|
          c.should_receive(:p).and_yield
          c.should_receive(:span).and_yield
        end
        assert_equal("subheading\n brsupbr", @chapter.sections(context, [section]))
      end
    end

    class TestChapterEditor <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf      = flexmock('lookandfeel', 
                             :section_style => 'section_style',
                             :attributes    => {}
                            )
        @session  = flexmock('session', :lookandfeel => @lnf)
        @model    = flexmock('model')
        @textarea = ODDB::View::ChapterEditor.new('name', @model, @session)
      end
      def test_init
        expected = {"name"=>"name", "data-dojo-type"=>"dijit.Editor"}
        assert_equal(expected, @textarea.init)
      end
      def test__to_html
        value   = flexmock('value', :sections => ['section'])
        context = flexmock('context', :p => 'p')
        assert_equal('p', @textarea._to_html(context, value))
      end
    end

    class TestEditChapterForm <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf     = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {},
                            :base_url   => 'base_url',
                           )
        @session = flexmock('session', 
                            :lookandfeel => @lnf,
                            :error       => 'error',
                           )
        @model   = flexmock('model',
                            :name => 'name',
                           )
        @form    = ODDB::View::EditChapterForm.new('name', @model, @session)
      end
      def test_edit_chapter
        assert_kind_of(ODDB::View::ChapterEditor, @form.edit_chapter(@model))
      end
      def test_hidden_fields
        flexmock(@lnf, 
                 :flavor   => 'flavor',
                 :language => 'language'
                )
        flexmock(@session, 
                 :state => 'state',
                 :zone  => 'zone'
                )
        context  = flexmock('context', :hidden => 'hidden')
        expected = "hiddenhiddenhiddenhiddenhiddenhidden"
        assert_equal(expected, @form.hidden_fields(context))
      end
      def test_toolbar
        flexmock(@lnf, :resource_global => 'resource_global')
        skip("Don't know how to toolbar. is it really needed here?")
        assert_kind_of(HtmlGrid::Div, @form.toolbar(@model))
      end
    end
    
    class TestEditChapterTableToHtml <Minitest::Test
      include FlexMock::TestCase
      def test_table_to_html
        @lookandfeel = FlexMock.new 'lookandfeel'
        @lookandfeel.should_receive(:section_style).and_return { 'section_style' }
        @lookandfeel.should_receive(:subheading).and_return { 'subheading' }
        session = FlexMock.new 'session'
        session.should_receive(:lookandfeel).and_return { @lookandfeel }
        session.should_receive(:user_input)
        assert(session.respond_to?(:lookandfeel))
        
        @view = View::Chapter.new(:name, @model, session)
        chapter = Text::Chapter.new
        chapter.heading = "Tabellentest"
        section = chapter.next_section
        section.next_paragraph
        section.subheading = "F?r Zwerge > 1.5 m"
        table = Text::Table.new
        table << 'first'
        table.next_row!
        cell1 = table.next_cell!
        table << 'cell1'
        cell2 = table.next_cell!
        table << 'cell2'
        section.paragraphs << table
        @view.value = chapter
        result = @view.to_html(CGI.new)
        assert(result.index('<H3>Tabellentest</H3>'))
        assert(result.index('Zwerge &gt; 1.5 m'))
        assert(result.index('first</SPAN>'))
        assert(result.index('cell1</SPAN>'))
        assert(result.index('cell2</SPAN>'))
        assert(result.index('Zwerge &gt; 1.5 m'))
      end
      def test_table_with_paragraphs_in_cell_to_html
        @lookandfeel = FlexMock.new 'lookandfeel'
        @lookandfeel.should_receive(:section_style).and_return { 'section_style' }
        @lookandfeel.should_receive(:subheading).and_return { 'subheading' }
        session = FlexMock.new 'session'
        session.should_receive(:lookandfeel).and_return { @lookandfeel }
        session.should_receive(:user_input)
        assert(session.respond_to?(:lookandfeel))
        
        @view = View::Chapter.new(:name, @model, session)
        chapter = Text::Chapter.new
        chapter.heading = "TestTable"
        section = chapter.next_section
        section.next_paragraph
        section.subheading = "Tabelle"
        table = Text::Table.new
        table.next_row!
        cell1 = table.next_multi_cell!
        cell1.next_paragraph
        cell1 << 'first'
        cell1.next_paragraph
        cell1 << ''
        cell1.next_paragraph
        cell1 << ''
        cell1.next_paragraph
        cell1 << 'second'
        section.paragraphs << table
        @view.value = chapter
        result = @view.to_html(CGI.new)
        assert(result.index(/<h3>TestTable<\/H3>/i), 'must contain TestTable as H3')
        refute_nil(result.index('>Tabelle<'), 'must contain Tabelle as element')
        refute_nil(result.index(/second<br>/i), 'second must be followed by line break')
        refute_nil(result.index(/first<br>/i), 'first must be followed by line break')
        assert_nil(result.index(/<span [^>]*><\/span>/i), 'it may not contain an empty span')
        assert_nil(result.index(/<p [^>]*><\/p>/i), 'it may not contain an empty paragraph')
      end      
    end

	end
end
