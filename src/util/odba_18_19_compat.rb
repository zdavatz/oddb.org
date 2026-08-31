#!/usr/bin/env ruby
# encoding: utf-8
#
# Uebernommen aus odba 1.1.9 (lib/odba/18_19_loading_compatibility.rb,
# 09.12.2011, mhatakeyama@ywesee.com). odba 1.2.0 hat die Datei geloescht;
# wir brauchen sie weiter, also liegt sie jetzt hier.
#
# Der Name taeuscht: das ist keine Hilfe, um *unter* Ruby 1.8/1.9 zu
# laufen, sondern um *Daten zu lesen, die dort geschrieben wurden*. Sie
# definiert Date._load fuer die alte kleingeschriebene `u`-Form und
# Encoding::Character::UTF8 - genauer dessen leeres Modul Methods, mit dem
# Marshal Strings vom Typ `e` wieder erweitert.
#
# jobs/rewrite_legacy_dumps hat am 31.08.2026 4341 von 4346 solcher Dumps
# neu geschrieben. Uebrig sind 2 SimpleLanguage::Descriptions, die sich
# nicht neu schreiben lassen, und 3 IncompleteRegistration, deren Klasse
# es nicht mehr gibt. Solange die zwei da sind, bleibt diese Datei.

require 'date'
require 'strscan'

if RUBY_VERSION >= '1.9'
  def u str
    str
  end
  class Date
    def self._load(str)
      scn = StringScanner.new str
      a = []
      while match = scn.get_byte
        case match
        when ":"
          len = scn.get_byte
          name = scn.scan /.{#{Marshal.load("\x04\bi#{len}")}}/
        when "i"
          int = scn.get_byte
          size, = int.unpack('c')
          if size > 1 && size < 5
            size.times do 
              int << scn.get_byte
            end
          end
          dump = "\x04\bi" << int
          a.push Marshal.load(dump)
        end
      end
      ajd = of = sg = 0
      if a.size == 3
        num, den, sg = a
        if den > 0
          ajd = Rational(num,den)
          ajd -= 1.to_r/2
        end
      else
        num, den, of, sg = a
        if den > 0
          ajd = Rational(num,den)
        end
      end
      ajd += 1.to_r/2
      jd(ajd)
    end
  end
  class Encoding
    class Character
      class UTF8 < String
        module Methods
        end
        ## when loading Encoding::Character::UTF8 instances simply return
        #  an encoded String
        def self._load data
          str = Marshal.load(data)
          str.force_encoding 'UTF-8'
          str
        end
      end
    end
  end
else
  class Date
    def marshal_load a
      @ajd, @of, @sg, = a
      @__ca__ = {}
    end
  end
  class Rational
    def marshal_load a
      @numerator, @denominator, = a
    end
  end
end
