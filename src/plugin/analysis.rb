#!/usr/bin/env ruby
#  AnalysisPlugin -- oddb.org -- 09.06.2006 -- sfrischknecht@ywesee.com

require 'plugin/plugin'
require 'ext/analysisparse/src/analysis_hpricot'
require 'model/analysis/group'

module ODDB
	class AnalysisPlugin < Plugin
		ANALYSIS_PARSER = DRbObject.new(nil, ANALYSISPARSE_URI)
		def update(path, lang)
			ANALYSIS_PARSER.parse_pdf(path).each { |position|
				group = update_group(position)
				if(position[:analysis_revision] == 'S')
					delete_position(group, position)
				else
					position = update_position(group, position, lang)
				end
			}
			@app.recount
		end
		def delete_position(group, position)
			## TODO
			#	position.odba_delete
		end
		def update_group(position)
			groupcd = position.delete(:group)
			ptr = Persistence::Pointer.new([:analysis_group, groupcd])
			@app.create(ptr)
		end
		def update_position(group, position, language)
			poscd = position.delete(:position)
			position.delete(:code)
			position.store(language, position.delete(:description))
			if(perms = position.delete(:permissions))
				perms.collect! { |pair|
					Analysis::Permission.new(*pair)	
				}
			end
			lim_txt = position.delete(:limitation)
			footnote = position.delete(:footnote)
			list_title = position.delete(:list_title)
			taxnote = position.delete(:taxnote)
			ptr = group.pointer + [:position, poscd]
			pos = @app.update(ptr.creator, position)
			if(lim_txt)
				lim_ptr = pos.pointer + :limitation_text
				args = {language => lim_txt}
				@app.update(lim_ptr.creator, args)
			elsif(lim = pos.limitation_text)
				@app.delete(lim.pointer)
			end
			if(footnote)
				ft_ptr = pos.pointer + :footnote
				args = {language => footnote}
				if(footnote != nil)
				end
				@app.update(ft_ptr.creator, args)
			elsif(note = pos.footnote)
				@app.delete(note.pointer)
			end
			if(list_title)
				lt_ptr = pos.pointer + :list_title
				args = {language =>	list_title}
				@app.update(lt_ptr.creator, args)
			elsif(title = pos.list_title)
				@app.delete(title.pointer)
			end
			if(taxnote)
				tn_ptr = pos.pointer + :taxnote
				args = {language => taxnote}
				@app.update(tn_ptr.creator, args)
			elsif(tnote = pos.taxnote)
				@app.delete(tnote.pointer)
			end
			if(perms)
				perm_ptr = pos.pointer + :permissions
				args = {language => perms}
				@app.update(perm_ptr.creator, args)
			elsif(ps = pos.permissions)
				@app.delete(ps.pointer)
			end
		end
		def update_dacapo
			ANALYSIS_PARSER.dacapo { |code, info|
				unless(info.empty?)
					groupcd, poscd = code.split('.')
					if((grp = @app.analysis_group(groupcd)) \
						 && (pos = grp.position(poscd)))
						ptr = pos.pointer + [:detail_info, :dacapo]
						@app.update(ptr.creator, info)	
					end
				end
			}
		end
	end
end
