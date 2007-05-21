#!/usr/bin/env ruby
# Plugin::MiniFi -- oddb.org -- 26.04.2007 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'view/rss/minifi'
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
      postprocess
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
    def postprocess
      model = @app.sorted_minifis
      l10n_sessions { |stub|
        view = View::Rss::MiniFi.new(model, stub, nil)
        path = File.join(RSS_PATH, stub.language, 'minifi.rss')
        tmp = File.join(RSS_PATH, stub.language, '.minifi.rss')
        FileUtils.mkdir_p(File.dirname(path))
        File.open(tmp, 'w') { |fh|
          fh.puts view.to_html(CGI.new('html4'))
        }
        File.mv(tmp, path)
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
