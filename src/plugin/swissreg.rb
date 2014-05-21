#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::SwissregPlugin -- oddb.org -- 18.04.2013 -- yasaka@ywesee.com
# ODDB::SwissregPlugin -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'uri'

module ODDB
	class SwissregPlugin < Plugin
		SWISSREG_SERVER = DRb::DRbObject.new(nil, SWISSREG_URI)
    def initialize(app)
      super
      @registrations = 0
      @patents       = 0
      @successes     = 0
      @iksnrs   = []
      @failures = []
      @notfound = []
    end
		def get_detail(url)
			uri = URI.parse(url)
			SWISSREG_SERVER.detail(uri.request_uri)
		end
		def format_data(data)
			fmt = "%s -> https://www.swissreg.ch/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=%s\n"
			iksnrs = data[:iksnrs] || []
			sprintf(fmt, iksnrs.join(','), data[:certificate_number])
		end
    def report
      fmt = "Checked  %4i Registrations\n"
      fmt << "Found     %4i Patents\n"
      fmt << "of which  %4i had a Swissmedic-Number.\n"
      fmt << "              %4i Registrations were successfully updated;\n"
      fmt << "for these %4i Swissmedic-Numbers no Registration was found:\n\n"
      str = sprintf(fmt, @registrations, @patents, @iksnrs.length, @successes, @failures.length)
      # detail
      str << "\nUpdates:\n"
      @iksnrs.each { |data| str << format_data(data) }
      str << "\nFailures:\n"
      @failures.each { |data| str << format_data(data) }
      str << "\nNotFound:\n"
      @notfound.each { |iksnr| str << iksnr + "\n" }
      str
    end
    def update_news
      substances = []
      if((group = @app.log_group(:swissmedic)) && (log = group.latest))
        log.change_flags.each_key { |ptr|
          if(reg = ptr.resolve(@app))
            @registrations += 1
            update_registrations(reg.iksnr)
          end
        }
      end
    end
    def update_registrations(iksnr)
      patents = SWISSREG_SERVER.search(iksnr)
      unless patents.empty?
        patents.each do |data|
          # if found in swissreg.ch
          @patents += 1
          if(iksnrs = data[:iksnrs])
            @iksnrs.push(data)
            iksnrs.each { |iksnr|
              update_registration(iksnr, data)
            }
          else
          end
        sleep(2)
        end
      else
        @notfound << iksnr
      end
    end
		def update_registration(iksnr, data)
			if(reg = @app.registration(iksnr))
				@successes += 1
				ptr = reg.pointer + [:patent]
				@app.update(ptr.creator, data, :swissreg)
			else
				@failures.push(data)
			end
		end
  end
end
