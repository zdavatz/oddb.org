#!/usr/bin/env ruby
#  -- oddb.org -- 09.06.2006 -- sfrischknecht@ywesee.com

require 'plugin/plugin'

module ODDB
	class AnalysisPlugin < Plugin
		ANALYSIS_PARSER = DRbObject.new(nil, ANALYSISPARSE_URI)
		def update(path)
			ANALYSIS_PARSER.parse_pdf(path).each { |position|
				group = update_group(position)
				if(position[:revision] == 'S')
					delete_position(group, position)
				else
					position = update_position(group, position)
				end
			}
		end
		def delete_position(group, position)
			## TODO
		end
		def update_group(position)
			groupcd = position.delete(:group)
			ptr = Persistence::Pointer.new([:analysis_group, groupcd])
			@app.create(ptr)
		end
		def update_position(group, position)
			poscd = position.delete(:position)
			position.delete(:code)
			if(perms = position[:permissions])
				perms.collect! { |pair|
					Analysis::Permission.new(*pair)	
				}
			end
			ptr = group.pointer + [:position, poscd]
			@app.update(ptr.creator, position)
		end
	end
end
