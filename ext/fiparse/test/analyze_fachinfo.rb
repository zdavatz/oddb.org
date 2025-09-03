#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "fiparse"
require "util/workdir"
require "model/fachinfo"
require 'debug'
require 'ox'
require 'plugin/text_info'
require_relative "../../../test/stub/odba"

SwissmedicMetaInfo = ODDB::SwissmedicMetaInfo

module HtmlAnalyse
@iksnrs_meta_info = {}
meta_xml = File.join(Dir.pwd, "data/xml/AipsMetaInfo.xml")
unless File.exist?(meta_xml)
  raise "File #{meta_xml} muss exist"
end

@infos = Ox.load(File.read(meta_xml), :mode => :object) # Ox
@extTest = File.expand_path(File.dirname(__FILE__))
@long_stat = {}
@empty_stat = {}
def self.analyse_one_fachinfo(meta)
  image_subfolder = "/tmp/tmp_images"
  res = ODDB::FiParse.parse_fachinfo_html(meta.cache_file, image_folder: image_subfolder)
  if meta.title
    m = /^[a-zA-Z]+/.match(meta.title)
    if m
      short = m[0]
    else
      short = "Unkown1"
    end
  else
    short = "Unkown2"
  end
  dump_name =File.join(File.dirname(__FILE__), "dumps", meta.type, meta.lang, "#{meta.iksnr}_#{meta.type}_#{meta.lang}_#{short}")
  FileUtils.makedirs(File.dirname(dump_name))
  File.open(dump_name, 'w+') do |f| f.puts res.text end
  ODDB::FachinfoDocument::CHAPTERS.each do |chapter|
    @long_stat[chapter]  = [] unless  @long_stat[chapter]
    @empty_stat[chapter] = [] unless @empty_stat[chapter]
    test_name = "test_#{meta.iksnr}_#{meta.type}_#{meta.lang}_#{short}.rb"
    begin
      head = eval("res.#{chapter}.to_s")
      @empty_stat[chapter] <<  [ test_name, meta.download_url] if head.size == 0
    rescue => error
#      puts "For #{File.basename(@@path)} chapter #{chapter} is not defined"
      @long_stat[chapter] << [ test_name, meta.download_url]
    end
  end
end

def self.analyse_all_fachinfos
  @nrTextInfos = 0
  total = @infos.values.flatten.size
  @infos.values.flatten.each_with_index do |meta, idx|
    next unless meta.type.eql?("fi")
    next if meta.lang.eql?("it")
    next if meta.lang.eql?("en")
    analyse_one_fachinfo(meta)
    @nrTextInfos += 1
    if @nrTextInfos.modulo(500) == 0
      puts "#{File.basename(__FILE__)} #{Time.now}: at #{@nrTextInfos}/#{idx}/#{total}"
    end
#    break if @nrTextInfos > 50
  end
end

def self.show_stat
  @stopTime = Time.now
  duration = (@stopTime - @startTime).to_i
  puts
  puts "Showing statistics for #{@nrTextInfos} analysied fachinfos"
  puts
  puts "  Showing occurrences a given chapter was not found"
  pp @long_stat
  puts

  puts "  Showing nr occurrences and first 3 FI where chapter was empty"
  @empty_stat.each do | key, values|
    next if values.size == 0
    puts %(#{key} #{values.size} #{values[0..2].join("\n   ")}")
  end
  puts
  puts "Running #{File.basename(__FILE__)} took #{duration} seconds"
end
@startTime = Time.now

end
HtmlAnalyse.analyse_all_fachinfos
HtmlAnalyse.show_stat
