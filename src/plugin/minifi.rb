#!/usr/bin/env ruby
# Plugin::MiniFi -- oddb.org -- 26.04.2007 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'rss/maker'
require 'iconv'

module ODDB
  class MiniFiPlugin < Plugin
    def initialize(app)
      super
      @imported = []
      @attached = []
    end
    def update(month)
      path = File.join(ARCHIVE_PATH, 'pdf', 
                       month.strftime('%m_%Y.pdf'))
      minifis = DRbObject.new(nil, FIPARSE_URI).extract_minifi(path)
      minifis.each { |data|
        data.store(:publication_date, month)
        minifi = update_minifi(data)
        update_registration(minifi)
      }
    end
    def update_minifi(data)
      pointer = Persistence::Pointer.new(:minifi)
      minifi = @app.update(pointer.creator, data, :minifi)
      @imported.push(minifi)
      minifi
    end
    def update_registration(minifi)
      sequences = @app.search_sequences(minifi.name)
      registrations = sequences.collect { |seq| 
        seq.registration }.compact.uniq
      registrations.each { |reg|
        @attached.push(minifi)
        @app.update(reg.pointer, {:minifi => minifi}, :minifi)
      }
    end
    def report
      lines = [
        "Imported #{@imported.size} Mini-Fachinfos:",
      ]
      lines.concat @imported.collect { |minifi|
        " - %s" % minifi.name
      }
      lines.concat [ nil, 
        "Attached #{@attached.size} Mini-Fachinfos to Registrations:" ]
      lines.concat @attached.collect { |minifi|
        " - %s" % minifi.name
      }
      lines.join("\n")
    end
  end
end
