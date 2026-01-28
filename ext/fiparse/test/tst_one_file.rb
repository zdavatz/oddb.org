#!/usr/bin/env ruby
require 'debug'
require 'ox'
require 'optimist'
require 'fileutils'
require 'open-uri'

$: << File.expand_path("../../../ext/fiparse/src", File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))
require 'fiparse'

OUT_DIR = File.join(Dir.pwd, 'output_fiparse')
FileUtils.makedirs(OUT_DIR)
opts = Optimist::options do
  banner <<-EOS
#{__FILE__} runs fiparse for the specified IKSNR.
The HTML file to parse is looked up data/xml/AipsMetaInfo.xml
It will be downloaded from https://files.refdata.ch/simis-public-prod/ and stored under
* #{OUT_DIR}/<iksnr>_<fi|pi>_<de|fr>.html

It uses pandoc to generate text (aka plain) files before and after running the parser.
It creates the files
* #{OUT_DIR}/<iksnr>_<fi|pi>_<de|fr>.before
* #{OUT_DIR}/<iksnr>_<fi|pi>_<de|fr>.after

Afterwards you may examine the differences between the original and the parsed by calling
diff output_fiparse/<iksnr>_fi_de._*

       #{__FILE__} [options] <iksnr>+

Options are:
EOS
    opt :format, "Format fi or pi", :type => :string, :short => 'f', :default => 'fi'
    opt :language, "Language de or fr", :short => 'l', :default => 'de'
  end

SwissmedicMetaInfo = Struct.new("SwissmedicMetaInfo", :iksnr, :authNrs, :atcCode, :title, :authHolder,
                                :substances, :type, :lang, :informationUpdate, :refdata,
                                :html_file, :cache_file, :cache_sha256, :download_url)
module ODDB
  class FachinfoDocument
    def odba_id
      1
    end
  end
  class PatinfoDocument
    def odba_id
      1
    end
  end
end
meta_xml = File.join(Dir.pwd, "data/xml/AipsMetaInfo.xml")
@infos = Ox.load(File.read(meta_xml), :mode => :object) # Ox

ARGV.each do |iksnr|
  puts iksnr
  key = [iksnr, opts[:format], opts[:language]]
  str_key = key.join('_')
  this = @infos[key]
  url = this.first.download_url
  uri = URI.parse(url)
  str = uri.read; str.size
  html_file = File.join(OUT_DIR, str_key + '.html')
  before_file = File.join(OUT_DIR, str_key + '._before')
  after_file = File.join(OUT_DIR, str_key + '._after')
  File.open(html_file, 'w+') do |f| f.write str end
  cmd = "pandoc --to=plain #{html_file} --output #{before_file}"
  raise("Unable to generate #{before_file} using pandoc") unless system(cmd)
  before = File.readlines(before_file)
  before.delete_if{|line| line.length <2 } # remove empty lines
  File.open(before_file, 'w+') do |f| f.write before.join end
  if opts[:format].eql?('fi')
    parsed_fi_pi =  ODDB::FiParse.parse_fachinfo_html(html_file, lang: opts[:language]).text
  else
    parsed_fi_pi =  ODDB::FiParse.parse_patinfo_html(html_file, lang: opts[:language]).to_s
  end
  File.open(after_file, 'w+') do |f| f.write parsed_fi_pi end
end

