#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::SwissregPlugin -- oddb.org -- 16.04.2013 -- yasaka@ywesee.com
# ODDB::SwissregPlugin -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'uri'

module ODDB
	class SwissregPlugin < Plugin
		SWISSREG_SERVER = DRb::DRbObject.new(nil, SWISSREG_URI)
		def initialize(app)
			super
			@patents = 0
			@iksnrs = 0
			@successes = 0
			@failures = []
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
			fmt = "Found     %4i Patents\n"
			fmt << "of which  %4i had a Swissmedic-Number.\n"
			fmt << "          %4i Registrations were successfully updated;\n"
			fmt << "for these %4i Swissmedic-Numbers no Registration was found:\n\n"
			str = sprintf(fmt, @patents, @iksnrs, @successes, @failures.size)
			@failures.each { |data|
				str << format_data(data)
			}
			str
		end
		def update
			substances = []
			@app.substances.each { |substance|
				if((substance_name = substance.de.split(' ').first) \
					 && (substance_name.length > 6) \
					 && (substance.is_effective_form? \
					 || (!substance.has_effective_form? && !substance.sequences.empty?)) \
					 && !substance.sequences.any? { |seq| seq.registration.patent })
					 #|| (!substance.has_effective_form? && !substance.sequences.empty?)))#
					substances.push(substance_name)
				end
			}
			update_substances(substances)
		end
		def update_news
			substances = []
			if((group = @app.log_group(:swissmedic)) && (log = group.latest))
				log.change_flags.each_key { |ptr| 
					if(reg = ptr.resolve(@app))
            update_registrations(reg.iksnr)
					end
				}
			end
		end
		def update_registrations(iksnr)
			SWISSREG_SERVER.search(iksnr).each { |data|
				@patents += 1
        if(iksnrs = data[:iksnrs])
          @iksnrs += 1
          iksnrs.each { |iksnr|
            update_registration(iksnr, data)
          }
        end
				sleep(2)
			}
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
