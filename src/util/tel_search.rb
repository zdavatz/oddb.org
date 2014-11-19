#!/usr/bin/env ruby
# encoding: utf-8

require 'nokogiri'

class TelSearch
  Key = '74dfc27b10b775b49ccaaaea2a941b81'
  # return phone or fax numbers for a given search
  def TelSearch.search(name, plz=nil, street = nil, typ = :phone)
    # http://tel.search.ch/api/?was=niklaus+giger&wo=8753
    # http://tel.search.ch/api/?lang=en&maxnum=10&was=niklaus+giger&wo=8753+Wieshoschet
    addition = name.gsub(/\s/,'+')
    url = "http://tel.search.ch/api/?lang=en&maxnum=10&was="
    if plz or street
      addition += '&wo='
      addition += "#{plz}" if plz
      addition += "#{plz ? '+' : ''}#{street}" if street
    end
    url += addition
    # http://tel.search.ch/api/?was=john+meier&key=
    url += "&key=#{Key}"
    filename = (addition + '.xml').gsub(/[&?]/,'_')
    if (File.exist?(filename) and (File.size(filename) > 100) and (Time.now-File.mtime(filename)).to_i < 24*3600)
      return TelSearch.analyse_answer(IO.read(filename), typ)
    end
    test_ausgabe = File.open(filename, 'w+')
    inhalt = open(url){
      |f|
        f.each_line {|line| test_ausgabe.puts line }
      }
    test_ausgabe.close
    puts "Saving #{filename}"
    return TelSearch.analyse_answer(IO.read(filename), typ)
  end
private
  def TelSearch.normalize_tel_nr(tel_nr)
    if m = tel_nr.match(/(\+41)(\d{2})(\d{3})(\d{2})(\d+)/)
      return "0#{m[2]} #{m[3]} #{m[4]} #{m[5]}"
    else
      return tel_nr
    end
  end
  def TelSearch.analyse_answer(xml, type = :phone)
    # puts "analyse_answer from #{filename} #{File.size(filename)} bytes at #{File.mtime(filename)}"
    xml_doc  = Nokogiri::XML(xml.gsub(':', '_')) # work around a bug of nokogiri that cannot handle xpath like tel:phone
    if xml_doc.css('entry').size > 5
      puts "Is this okay? Found #{xml_doc.css('entry').size} entries."
      # binding.pry if
      return nil
    end
    item =xml_doc.css('entry').first

    if type == :phone
      return TelSearch.normalize_tel_nr(item.css('tel_phone').text)
    elsif type == :fax
      elem = item.css('tel_extra')
      if elem and elem.first and elem.first['type'].eql?('Fax')
        return TelSearch.normalize_tel_nr(elem.text)
      else
        return nil
      end
    else
      raise "unexpected phone type #{type}"
    end
    return nil
  end
end
