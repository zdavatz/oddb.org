#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse -- oddb.org -- 11.07.2012 -- yasaka@ywesee.com
# ODDB::FiParse -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com
# ODDB::FiParse -- oddb.org -- 20.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)
require 'odba'
require 'drb/drb'
require 'util/oddbconfig'
require 'fachinfo_writer'
require 'fachinfo_pdf'
require 'fachinfo_doc'
require 'indications'
require 'minifi'
require 'fachinfo_hpricot'
require 'patinfo_hpricot'
require 'rpdf2txt/parser'
require 'ydocx/document'
require 'ydocx/templates/fachinfo'

module YDocx
  class Parser
    # There are no following chapter
    # * fabrication
    # * delivery
    # * distribution
    @@chapter_codes = {
        'AMZV'                => '6900', # amzv (pseudo)
        #'Name'                => '',
        'Zusammens.'          => '7000', # composition
        'Galen.Form'          => '7050', # galenic_form
        'Ind./Anw.m&ouml;gl.' => '7100', # indications
        'Dos./Anw.'           => '7150', # usage
        'Kontraind.'          => '7200', # contraindication
        'Warn.hinw.'          => '7250', # restrictions
        'Interakt.'           => '7300', # interactions
        'Schwangerschaft'     => '7350', # pregnancy
        'Fahrt&uuml;cht.'     => '7400', # driving_ability
        'Unerw.Wirkungen'     => '7450', # unwanted_effects
        '&Uuml;berdos.'       => '7500', # overdose
        'Eigensch.'           => '7550', # effects
        'Pharm.kinetik'       => '7600', # kinetic
        'Pr&auml;klin.'       => '7650', # preclinic
        'Sonstige H.'         => '7700', # other_advice
        'Swissmedic-Nr.'      => '7750', # iksnrs
        #'Packungen'           => '',     # packages
        'Reg.Inhaber'         => '7850', # registration_owner
        'Stand d. Info.'      => '8000', # date
    }
    def init
      @resource_path = File.join ODDB::PROJECT_ROOT, 'doc', 'resources'
      @image_path = File.join @resource_path , 'images', 'fachinfo'
    end
    def parse_heading(text, id)
      chapter = @indecies.last
      if chapter and @@chapter_codes.keys.include?(chapter[:text])
        text = markup(:a, text, {:name => @@chapter_codes[chapter[:text]]})
      end # pseudo anchor
      return markup(:h2, text, {:id => id})
    end
    def parse_title(node, text)
      if @indecies.empty? and
         (node.previous.nil? or
          node.previous.inner_text.strip.empty? or
          node.parent.previous.nil?)
        # as empty AMZV chapter heading
        @indecies << {:text => 'AMZV', :id => 'amzv'}
        text = markup(:a, '', {:name => @@chapter_codes['AMZV']})
        return markup(:h2, text, {:id => 'amzv'})
      else
        return nil
      end
    end
    def source_path(target)
      target = File.basename(target).gsub(/image/, "#{@lang.upcase}_#{@code}_")
      source = File.join @resource_path, 'fachinfo', @code, '/'
      if defined? Magick::Image and
         ext = File.extname(target).match(/\.wmf$/).to_a[0]
        source << target.gsub(/wmf/, 'png')
      else
        source << target
      end
      source
    end
  end
  class Builder
    def init
      @block_class = 'paragraph' # same with html on docmed
      @container = markup(:div, [], {:id => 'container'})
    end
  end
  class Document
    def init
      @directory = 'fachinfo' # in doc/resources
      @references = []
      #prepare_reference
    end
    def output_directory
      unless @files
        if @options[:iksnr]
          @files = @path.dirname.join @options[:iksnr]
        end
      end
      @files
    end
    private
    def optional_copy(source_path) # copy to resources/images/fachinfo/:lang
      file = File.basename source_path
      image_path = File.join ODDB::PROJECT_ROOT, 'doc', 'resources', 'images', @directory
      image_file = File.join image_path, @options[:lang], file
      FileUtils.cp_r source_path, image_file
    end
    def read(file)
      @path = Pathname.new file
      @zip = Zip::ZipFile.open(@path.realpath)
      doc = @zip.find_entry('word/document.xml').get_input_stream
      rel = @zip.find_entry('word/_rels/document.xml.rels').get_input_stream
      @parser = Parser.new(doc, rel) do |parser|
        parser.code = @options[:iksnr] # add option
        parser.lang = @options[:lang]  # add option
        @contents = parser.parse
        @indecies = parser.indecies
        @images = parser.images
      end
      @zip.close
    end
  end
end
module ODDB
	class FachinfoDocument
		def initialize
		end
	end
	module FiParse
		def storage=(storage)
			ODBA.storage = storage
		end
    def FiParse.extract_indications(path)
      Indications.extract(path)
    end
    def FiParse.extract_minifi(path)
      MiniFi.extract(path)
    end
		def parse_fachinfo_doc(path)
			parser = Rwv2.create_parser(path)
			handler = FachinfoTextHandler.new
			parser.set_text_handler(handler)
      parser.set_table_handler(handler.table_handler)
			parser.parse
      if(handler.writers.empty?)
        ## Product-Name was not written large enough - retry with whatever was 
        #  the largest fontsize
        handler.cutoff_fontsize = handler.max_fontsize
        parser.parse
      end
			handler.writers.collect { |wt| wt.to_fachinfo }.compact.first
		end
    def parse_fachinfo_docx(path, iksnr, lang='DE')
      doc = YDocx::Document.open(path, {
        :iksnr => iksnr,
        :lang  => lang.downcase
      })
      writer = FachinfoHpricot.new
      writer.new_format_flag = false
      writer.extract(Hpricot(doc.to_html(true)))
    end
    def parse_fachinfo_html(src, new_format_flag = false)
      if File.exist?(src)
        src = File.read src
      end
      writer = FachinfoHpricot.new
      writer.new_format_flag = new_format_flag
      writer.extract(Hpricot(src))
    end
		def parse_fachinfo_pdf(src)
			writer = FachinfoPDFWriter.new
			parser = Rpdf2txt::Parser.new(src, 'UTF-8')
			parser.extract_text(writer)
			writer.to_fachinfo
		end
		def parse_patinfo_html(src, new_format_flag = false)
      if File.exist?(src)
        src = File.read src
      end
			writer = PatinfoHpricot.new
      writer.new_format_flag = new_format_flag
      writer.extract(Hpricot(src))
		end
    module_function :storage=
    module_function :parse_fachinfo_doc
    module_function :parse_fachinfo_docx
    module_function :parse_fachinfo_html
    module_function :parse_fachinfo_pdf
    module_function :parse_patinfo_html
	end
end
