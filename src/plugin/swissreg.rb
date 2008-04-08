#!/usr/bin/env ruby
# SwissregPlugin -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'uri'

module ODDB
	class SwissregPlugin < Plugin
		SWISSREG_SERVER = DRb::DRbObject.new(nil, SWISSREG_URI)
		def initialize(app)
			super
			@substances = 0
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
			fmt = "%s -> http://www.swissreg.ch/srclient/faces/jsp/spc/sr300.jsp?language=de&section=spc&id=%s\n"
			iksnrs = data[:iksnrs] || []
			sprintf(fmt, iksnrs.join(','), data[:certificate_number])
		end
		def report
			fmt =  "Checked   %4i Substances for connected Patents\n"
			fmt << "Found     %4i Patents\n"
			fmt << "of which  %4i had a Swissmedic-Number.\n"
			fmt << "          %4i Registrations were successfully updated;\n"
			fmt << "for these %4i Swissmedic-Numbers no Registration was found:\n\n"
			str = sprintf(fmt, 
										@substances, @patents, @iksnrs, @successes, @failures.size)
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
						reg.each_sequence { |seq|
							substances += seq.active_agents.collect { |act| 
								act.substance.to_s.split(' ').first
							}
						}
					end
				}
			end
			update_substances(substances)
		end
		def update_registrations(substance_name)
			@substances += 1
			SWISSREG_SERVER.search(substance_name).each { |data|
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
		def update_substances(substances)
			substances.collect { |substance|
				substance.to_s.gsub(/(i|e|um)$/, '')
			}.compact.uniq.each { |substance_name|
				update_registrations(substance_name) 
			}
		end
	end
end
