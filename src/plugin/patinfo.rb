#!/usr/bin/env ruby
# PatinfoPlugin -- oddb -- 29.10.2003 -- rwaltert@ywesee.com

require 'plugin/plugin'
require 'util/persistence'
require 'util/oddbconfig'
require 'drb'

module ODDB
	class PatinfoPlugin < Plugin
		HTML_PATH = File.expand_path('../../data/html/patinfo', 
			File.dirname(__FILE__))
		LANGUAGES = ['de', 'fr']
		KOMBI = "(\w+(?:[\s-]\w+)*)?\s*([0-9]+)?"
		PARSER = DRbObject.new(nil, FIPARSE_URI)
		RECIPIENTS = []
		def initialize(app)
			super
			@iksnrs = []
			@names  = []
			@assigned_documents = [] 
			@named_documents = {}
			@iksnr_documents = {}
			@error_documents =  {}
			@orphaned_documents = {}
			@parse_error_documents = []
			@patinfos = {}
		end
		def collect_orphaned_documents
			@named_documents.each { |key, value|
				if(!@assigned_documents.include?(value))
					@orphaned_documents.store(key,value)
				end
			}
			@iksnr_documents.each { |key, value|
				if (!@assigned_documents.include?(value))
					@orphaned_documents.store(key,value)
				end
			}
		end
		def extract_iksnrs(pi)
			if(pi.iksnrs && (iksnrs = pi.iksnrs.match(/[0-9]+(,\s*[0-9]+)*/u)))
				iksnrs[0].split(/,\s*/u)
			else
				[]
			end
		end
		def extract_names(pi)
			unless(pi.name.nil?)
				names = pi.name.gsub("#{174.chr}", "")
				case names
				when /(\w+)\s+(\w+)\/(\w+)\/(\w+)/u
					[
						"#{$~[1]} #{$~[2]}", 
						"#{$~[1]} #{$~[3]}", 
						"#{$~[1]} #{$~[4]}",
					]
				when /#{KOMBI}\s*\/\s*#{KOMBI}/u
					match = $~
					if(match[3].nil?)
						[
							match[1,2].compact.join(' '), 
							[match[1], match[4]].join(' '),
						]
					else
						[
							match[1,2].compact.join(' '), 
							match[3,2].compact.join(' '), 
						]
					end
				when /#{KOMBI}/u
					[$~.to_s]
				end
			else
				[]
			end
		end
		def package_languages(idx)
			@iksnrs = []
			@names  = []
			self::class::LANGUAGES.inject({}) { |inj, language|
				if(pi = parse_patinfo(language, idx))
					@names += extract_names(pi)
					@iksnrs += extract_iksnrs(pi)
					inj.store(language, pi)
				end
				inj
			}
		end
		def package_patinfo(idx)
			languages = package_languages(idx)
			unless(@iksnrs.empty?)
				patinfo_triage(@iksnr_documents, @iksnrs, languages)
			else
				patinfo_triage(@named_documents, @names, languages)
			end
		end
		def package_patinfos
			0.upto(6500) { |idx| 
				package_patinfo(idx)
			}
			nil
		end
		def parse_patinfo(language, idx)
			filepath = File.expand_path(
				sprintf("%s/%s.html", language, idx),
				self::class::HTML_PATH
			)
			if(File.exist?(filepath))
				begin 
					pat = self::class::PARSER.parse_patinfo_html(File.read(filepath))
					unless(pat.date)		
						@parse_error_documents.push(filepath)
						#replace with nil in online verison or pat for testing
						nil
					else
						pat
					end
				rescue StandardError => e
					puts e
					puts e.message
				end
			end
		end
		def patinfo_link_check
			@named_documents.merge(@iksnr_documents).each { |key, val|
				unless(@app.registrations.has_key?(key))
					@error_documents.store(key, [val])
				end
			}
		end
		def patinfo_triage(target, keys, languages)
			keys.uniq.each { |key|
				# were there any duplicates with this key before?
				if(@error_documents.has_key?(key))
					@error_documents[key].push(languages)
				# is this a duplicate key?
				elsif(target.has_key?(key))
					tmp = [
						target.delete(key),
						languages
					]
					@error_documents.store(key, tmp)
				else
					target.store(key, languages)
				end
			}
			target
		end
		def report
			[
				"==============Patinfo Report=============",
				"Mit iks Nr. #{@iksnr_documents.size}",
				"Mit Name: #{@named_documents.size}",
				"Mit Fehler: #{@error_documents.size}",
				"Ohne Registration: #{@orphaned_documents.size}",
				"Patinfos mit Strukturfehler: #{@parse_error_documents.size}",
				"==============Error Documents==============",
				@error_documents.collect { |name, ambiguity| 
					(name.to_s + ":").ljust(32) +  ambiguity.collect { |hsh| 
						begin
							hsh.values.first.name
						rescue StandardError => e
							e.message
						end
					}.join(', ')
				}.sort.join("\n"),
				"==============Orphan Documents==============",
				@orphaned_documents.collect { |key, languages|
					(key.to_s + ":").ljust(32) + begin 
						languages.values.first.name
					rescue StandardError => e
						e.message
					end
				}.sort.join("\n"),
				"============ParseError Documents===========",
				@parse_error_documents.each { |val|
					val
				}.join("\n")
			].join("\n")
		end
		def store_patinfo(languages)
			pointer = Persistence::Pointer.new(:patinfo)
			@app.update(pointer.creator, languages)
		end	
		def sequence_info_by_name(seq)
			patinfo = nil
			name = [seq.name_base, seq.name_descr].join(' ')
			key = if(patinfo = @named_documents[seq.name_base])
				seq.name_base
			elsif(patinfo = @named_documents[name])
				name
			end
			if(@error_documents.include?(seq.iksnr))
				@error_documents[seq.iksnr].push(patinfo)
				@named_documents.delete(key)
				nil
			else
				patinfo
			end
		end
		def update
			package_patinfos()
			update_registrations()
			collect_orphaned_documents()
			store_orphaned_patinfos()
		end
		def update_news
			newsdir = File.expand_path('news', self::class::HTML_PATH)
			updates = self::class::LANGUAGES.inject([]) { |inj, lang|
				target_dir = File.expand_path(lang, self::class::HTML_PATH)
				source_dir = File.expand_path(lang, newsdir)
				Dir.foreach(source_dir) { |entry|
					if(match = /(.*)\.html$/u.match(entry))
						inj << match[1].to_s
						File.rename(File.expand_path(entry, source_dir), 
							File.expand_path(entry, target_dir))
					end
				}
				inj
			}.uniq
			updates.each { |idx|
				package_patinfo(idx)
			}
			update_registrations()
			collect_orphaned_documents()
			store_orphaned_patinfos()
		end
		def	update_sequence(sequence, languages)
			@assigned_documents.push(languages)
			patinfo = @patinfos[languages] or begin
				pointer = Persistence::Pointer.new([:patinfo])
				patinfo = @app.update(pointer.creator, languages)
				@patinfos.store(languages, patinfo)	
			end
			values = {:patinfo => patinfo.pointer}
			@app.update(sequence.pointer, values)
		end	
		def update_registrations
			@app.registrations.each { |iksnr, reg|
				if(languages = @iksnr_documents[iksnr])
					reg.sequences.each { |key, seq|
						update_sequence(seq, languages)
					}
				else
					reg.sequences.each { |key, seq|
						if(languages = sequence_info_by_name(seq))
							update_sequence(seq, languages)
						end
					}
				end
			}
		end
		def store_orphaned(key, meanings, reason)
			pointer  = Persistence::Pointer.new(:orphaned_patinfo)
			store = {
				:key => key,
				:meanings => meanings,
				:reason => reason,
			}
			@app.update(pointer.creator, store)
		end
		def store_orphaned_patinfos
			@error_documents.each { |key, value|
				store_orphaned(key, value, :ambiguous)
			}
			@orphaned_documents.each { |key, value|
				store_orphaned(key, [value], :orphan)
			}
		end
	end
end
