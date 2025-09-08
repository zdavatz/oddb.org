#!/usr/bin/env ruby
require "nokogiri"
require File.expand_path(File.join(File.dirname(__FILE__), "common.rb"))

aipsDownload = File.join(TopDir, "data", "xml", "AipsDownload_latest.xml")
unless File.exist?(aipsDownload)
  puts "Could not find #{aipsDownload}"
  exit 2
end
puts "Using #{aipsDownload} #{(File.size(aipsDownload) / 1024).round} KBytes"

@doc = Nokogiri::XML(File.read(aipsDownload))
@doc.xpath(".//medicalInformation").each { |x|
  # require 'debug'; binding.break
  to_delete = true
  iksnr = ""
  x.children.each { |child|
    if /authNrs/i.match?(child.name.to_s)
      iksnr = child.text.to_s
      IKSNRS_TO_EXTRACT.each { |nr|
        to_delete = false if child.text.to_s.index(nr)
      }
      puts "Preserving #{iksnr} #{x.attributes["type"]} #{x.attributes["lang"]}" unless to_delete
    end
  }
  x.remove if to_delete
}
ausgabe = File.join(TopDir, "test", "integration", "data", "AipsDownload_latest.xml")
content = @doc.to_xml.split("\n")
file = File.open(ausgabe, "w")
content.each { |line| file.puts line unless /^\s*$/.match?(line.chomp) }
puts "Created #{ausgabe} #{(File.size(ausgabe) / 1024).round} KBytes"
