#!/usr/bin/env ruby
require 'debug'
require 'ox'
#require 'marshall'
SwissmedicMetaInfo = Struct.new("SwissmedicMetaInfo", :iksnr, :authNrs, :atcCode, :title, :authHolder,
                                :substances, :type, :lang, :informationUpdate, :refdata,
                                :html_file, :cache_file, :cache_sha256, :download_url)

#require "/opt/src/oddb.org-358/src/plugin/text_info.rb"
@iksnrs_meta_info = {}
meta_xml = File.join(Dir.pwd, "data/xml/AipsMetaInfo.xml")
@infos = Ox.load(File.read(meta_xml), :mode => :object) # Ox
@extTest = File.expand_path(File.dirname(__FILE__))

require 'fileutils'
require 'debug'
def update_text_file(iksnr, type, lang, path, url, name)
  puts "update_text_file #{iksnr} #{type} #{lang} #{path} #{url}"
  short = /^[a-zA-Z]+/.match(name)[0]
  new_html_file = File.join(@extTest, "data", "html", "#{iksnr}_#{type}_#{lang}_#{short}.html")
#  binding.break
  mtime = File.exist?(new_html_file) ? File.mtime(new_html_file) : false
  res = system("wget --quiet --timestamping #{url} -O #{new_html_file}")
  full_type = type.downcase.to_s.eql?("pi") ? "Patinfo" : "Fachinfo"
  pi_or_fi = "@@#{full_type.downcase}"
  document = type.downcase.to_s.eql?("pi") ? "PatinfoDocument" : "FachinfoDocument2001"
  new_test_file = File.join(@extTest, "test_#{iksnr}_#{type}_#{lang}_#{short}.rb")
  if  !(File.exist?(new_test_file) && (File.size(new_test_file) == 0))
    File.open(new_test_file, "w+") do |file|
      file.puts %(#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "minitest/autorun"
require "fiparse"
require "flexmock/minitest"
require "util/workdir"

module ODDB
  class #{full_type}Document
    def odba_id
      1
    end
  end
  module FiParse
    class Test#{full_type}#{short}#{lang.capitalize} < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(#{pi_or_fi}) && #{pi_or_fi}
        @@path = File.join(File.dirname(__FILE__), "data", "html", "#{File.basename(new_html_file)}")
        @parser = ODDB::FiParse
        #{pi_or_fi} =  @parser.parse_#{full_type.downcase}_html(File.read(@@path), lang: "#{lang.downcase}")
      end
      def test_#{full_type.downcase}
        assert_equal(ODDB::#{document}, #{pi_or_fi}.class)
      end
      def test_name
        assert_match(/#{short}/, #{pi_or_fi}.name.heading)
      end
      def test_chapters
        ODDB::#{full_type}Document2001::CHAPTERS.each do |chapter|
          begin
            res = eval("#{pi_or_fi}.\#{chapter}")
          rescue => error
            puts "For #{File.basename(new_html_file)} chapter \#{chapter} is not defined"
          end
        end
      end
    end
  end
end
)
    end
  end
  puts "Created #{new_test_file}"
end

files = Dir.glob(File.join(@extTest, "data/html/*/*.html"))
files = files.collect{|x| File.expand_path(x)}
files.each do |path|
  if m = /\/(de|fr)\/(fi|pi)_(\d{5})/.match(path)
    lang = m[1]
    type = m[2]
    iksnr = m[3]
    key = [iksnr, type, lang]
    this = @infos[key]
    if this
      url = this.first.download_url
  #    puts "Found #{iksnr} #{type} #{lang} #{url}"
       update_text_file(iksnr, type, lang, path, url, this.first.title)
#      puts "Nothing found for #{key}"
    else
      puts "#{__LINE__} #{path}"
#      require 'debug'; binding.break
    end
  else
    puts "#{__LINE__} #{path}"
  end
end if false

%(
update_text_file 30785 fi de /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/fi_30785_ponstan.html https://files.refdata.ch/simis-public-prod/MedicinalDocuments/12006aef84984eb08c3b1304f0d57f54-de.html

57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/alcac.fi.html
57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/cimifemin.html
53 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/fi_58106_finasterid.de.html
53 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/fi_62111_bisoprolol.de.html
53 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/fi_62184_cipralex_de.html
53 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/fi_62439_xalos_duo.de.html
57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/inderal.html
57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/nasivin.html
57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/de/ponstan.html
57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/fr/cimifemin.html
57 /opt/src/oddb.org-standard/ext/fiparse/test/data/html/fr/fi_Zyloric.fr.html

)

@searches = [
    [ /Ponstan/, "pi", "de",  "de/ponstan.html"],
    [ /cimifemin/i, "pi", "fr",  "fr/cimifemin.html"],
    [ /cimifemin/i, "pi", "de",  "de/cimifemin.html"],
    [ /Nasivin/i, "pi", "de",  "de/nasivin.html"],
    [ /alcac/i, "fi", "de",  "de/nasivin.html"],
    [ /Zyloric/i, "fi", "fr",  "fr/fi_Zyloric.html"],
    [ /Normolytoral/i, "fi", "de",  "de/fi_Normolytoral.html"]
]
searches = [
    [ /Normolytoral/i, "fi", "de",  "de/fi_Normolytoral.html"]
  ]

%(bin/admin all names
File.open("all_patinfos_name.txt", "w+") {|f| f.puts patinfos.values.collect{|x| x.name.dup.force_encoding('UTF-8')[0..80].split.first}.join("\n")}

)
def one_manual(x, path)
  fullPath = File.join(@extTest, "data", "html", path)
  puts "#{fullPath} #{File.exist?(fullPath)}"
 # update_text_file(iksnr, type, lang, path, url, this.first.title)
  update_text_file(x.iksnr, x.type, x.lang, fullPath, x.download_url, x.title)
end

def update_rest
  @searches.each do |search|
    meta = @infos.values.flatten.find{|x| search[0].match(x.title) && x.type.eql?(search[1]) && x.lang.eql?(search[2])}
    if meta
      one_manual(meta, search[3])
    else
      puts "Nothing found for #{search}"
    end
  end
end
update_rest
