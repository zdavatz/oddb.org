#!/usr/bin/env ruby
# OddbApp -- oddb -- hwyss@ywesee.com

require 'benchmark'
require 'custom/lookandfeelbase'
require 'util/failsafe'
require 'util/oddbconfig'
require 'util/session'
require 'util/updater'
require 'util/exporter'
require 'util/validator'
require 'util/loggroup'
require 'models'
require 'commands'
require 'sbsm/drbserver'
require 'sbsm/index'
require 'datastructure/chartree'
require 'datastructure/soundextable'
require 'madeleine'
require 'util/drb'
require 'odba'
require 'odba/index_definition'
require 'yaml'

class OddbPrevalence
	include ODDB::Failsafe
	include ODBA::Persistable
	ODBA_EXCLUDE_VARS = [
		"@sequence_index",
		"@indication_index",
		"@substance_index",
		"@substance_name_index",
		"@company_index",
		"@atc_index",
	]
	attr_reader :galenic_groups, :companies
	attr_reader	:atc_classes, :last_update
	attr_reader :atc_chooser, :registrations
	attr_reader :last_medication_update
	attr_reader :orphaned_patinfos, :orphaned_fachinfos
	attr_reader :fachinfos
	attr_reader :patinfos_deprived_sequences, :patinfos
	def initialize		
		super
		@atc_classes ||= {}
		@companies ||= {}
		@cyp450s ||= {}
		@fachinfos ||= {}
		@galenic_forms ||= []
		@galenic_groups ||= []
		@generic_groups ||= {}
		@orphaned_fachinfos ||= {}
		@orphaned_patinfos ||= {}
		@patinfos ||= {}
		@incomplete_registrations ||= {}
		@indications ||= {}
		@last_medication_update ||= Time.now()
		@log_groups ||= {}
		@registrations ||= {}
		@substances ||= {}
		create_unknown_galenic_group()
		create_root_user()
	end
	def init
		create_unknown_galenic_group()
		create_root_user()
		@atc_classes ||= {}
		@patinfos_deprived_sequences ||= []
		@companies ||= {}
		@cyp450s ||= {}
		#@fachinfos ||= {}
		@galenic_forms ||= []
		@galenic_groups ||= []
		@generic_groups ||= {}
		@incomplete_registrations ||= {}
		@indications ||= {}
		@last_medication_update ||= Time.now()
		@log_groups ||= {}
		@registrations ||= {}
		@substances ||= {}
		@orphaned_patinfos ||= {}
		@orphaned_fachinfos ||= {}
		#rebuild_indices
	end
	# prevalence-methods ################################
	def create(pointer)
		#puts [__FILE__,__LINE__,"create(#{pointer})"].join(':')
		@last_update = Time.now()
		failsafe {
			if(item = pointer.issue_create(self))
				puts item
				updated(item)
				item
			end
		}
	end
	def delete(pointer)
		@last_update = Time.now()
		failsafe(ODDB::Persistence::UninitializedPathError) {
			if(item = pointer.resolve(self))
				updated(item)
				#	checkout(item)
			end
			pointer.issue_delete(self)
		}
	end
	def update(pointer, values)
		@last_update = Time.now()
		item = failsafe(ODDB::Persistence::UninitializedPathError, nil) {
			pointer.resolve(self)
		}
		# if this item has been newly created, we want its pointer back
		pointer = item.pointer unless item.nil? 
		updated(item)
		update_item(item, values)
		item
	end
	def update_item(item, values)
		pointer = item.pointer
		case item
		when ODDB::Sequence
			#	delete_from_index(@sequence_index, item.name, item)
			pointer.issue_update(self, values)
		when ODDB::Substance
			#delete_from_index(@substance_index, item.name, item)
			pointer.issue_update(self, values)
		when ODDB::Indication
			item.descriptions.values.uniq.each { |desc|
				#delete_from_index(@indication_index, desc, item)
			}	
			pointer.issue_update(self, values)
			item.descriptions.values.uniq.each { |desc|
				#store_in_index(@indication_index, desc, item)
			}	
=begin
		when ODDB::Indication
			diff = item.diff(values, self)
			before = diff.keys.collect { |lang|
				item.send(lang)
			}
			after = diff.values
			before.each { |descr|
				@indication_index.delete(descr.downcase, item)
			}
			pointer.issue_update(self, values)
			after.each { |descr|
				@indication_index.store(descr.downcase, item)
			}
=end
		else
			pointer.issue_update(self, values) unless pointer.nil?
		end
	end
	#####################################################
	def accepted_orphans
		@accepted_orphans ||= {}
	end
	def atcless_sequences
		@registrations.values.collect { |reg|
			reg.atcless_sequences
		}.flatten
	end
	def atc_class(code)
		@atc_classes[code]
	end
=begin
	def checkout(item)
		case item
		when ODDB::Registration
			item.sequences.each_value { |seq|
				checkout(seq)
			}
		when ODDB::Sequence
			delete_from_index(@sequence_index, item.name, item)
		when ODDB::Company
			delete_from_index(@company_index, item.name, item)
		when ODDB::Indication
			item.descriptions.values.uniq.each { |desc|
				delete_from_index(@indication_index, desc, item)
			}
		when ODDB::Substance	
			keys = item.descriptions.values
			keys.push(item.connection_key)
			if(keys.empty?)
				keys = [ item.name ]
			end
			keys.each { |key|
				delete_from_index(@substance_index, key, item)
				delete_from_index(@substance_name_index, key, item.sequences)
			}
		end
	end
	def clear_indices
		@sequence_index = nil
		@indication_index = nil
		@substance_index = nil
		@substance_name_index = nil
		@company_index = nil
		@atc_index = nil
		@atc_chooser = nil
	end
=end
	def company(oid)
		@companies[oid.to_i]
	end
	def company_by_name(name)
		namedown = name.to_s.downcase
		@companies.each_value { |company|
			if company.name.to_s.downcase == namedown
				return company
			end
		}
		nil
	end
	def cyp450(id)
		@cyp450s[id]
	end
	def cyp450s
		@cyp450s.values
	end
	def create_atc_class(atc_class)
		@atc_classes.store(atc_class, ODDB::AtcClass.new(atc_class))
	end
	def create_patinfo_deprived_sequences
		@patinfos_deprived_sequences ||= []
		pat = ODDB::PatinfoDeprivedSequences.new
	  @patinfos_deprived_sequences.store(pat.oid, pat)
	end
	def create_orphaned_fachinfo
		@orphaned_fachinfos ||= {}
		orphan = ODDB::OrphanedFachinfo.new
	  @orphaned_fachinfos.store(orphan.oid, orphan)
	end
	def create_orphaned_patinfo
		@orphaned_patinfos ||= {}
		orphan = ODDB::OrphanedPatinfo.new
	  @orphaned_patinfos.store(orphan.oid, orphan)
	end
	def create_company
		company = ODDB::Company.new
		@companies.store(company.oid, company)
	end
	def create_cyp450(cyp_id)
		@cyp450s ||= {}
		cyp450 = ODDB::CyP450.new(cyp_id)
		@cyp450s.store(cyp_id, cyp450)
	end
	def create_fachinfo
		@fachinfos ||= {}
		fachinfo = ODDB::Fachinfo.new
		@fachinfos.store(fachinfo.oid, fachinfo)
	end
	def create_galenic_group
		galenic_group = ODDB::GalenicGroup.new
		@galenic_groups.store(galenic_group.oid, galenic_group)
	end
	def create_generic_group(package_pointer)
		@generic_groups.store(package_pointer, ODDB::GenericGroup.new)
	end
	def create_incomplete_registration
		incomplete = ODDB::IncompleteRegistration.new
		@incomplete_registrations.store(incomplete.oid, incomplete)
	end
	def create_indication
		indication = ODDB::Indication.new
		@indications.store(indication.oid, indication)
	end
	def create_log_group(key)
		@log_groups[key] ||= ODDB::LogGroup.new(key)
	end
	def create_patinfo
		@patinfos ||= {}
		patinfo = ODDB::Patinfo.new
		@patinfos.store(patinfo.oid, patinfo)
	end
	def create_registration(iksnr)
		unless @registrations.include?(iksnr)
			reg = ODDB::Registration.new(iksnr)
			reg.odba_store
			@registrations.store(iksnr, reg)
			@registrations.odba_store
			reg
		end
	end
	def create_substance(key=nil)
		if(!key.nil? && (subs = substance(key)))
			subs
		else
			subs = ODDB::Substance.new
			unless(key.nil?)
				values = {
					'lt'	=>	key,
				}
				diff = subs.diff(values, self)
				subs.update_values(diff)
				begin
					#store_in_index(@substance_index, key, subs)
					#store_in_index(@substance_name_index, key, *subs.sequences)
				rescue
					puts $!.class
					puts $!.message
					puts $!.backtrace
				end
			end
			@substances.store(subs.oid, subs)
		end
	end
	def create_user
		@users ||= {}
		user = ODDB::CompanyUser.new
		@users.store(user.oid, user)
	end
	def delete_atc_class(atccode)
		atc = @atc_classes[atccode]
		#delete_from_index(@atc_index, atc.name, atc)
		@atc_chooser.delete(atccode)
		@atc_classes.delete(atccode)
	end
	def delete_cyp450(cyp_id)
		@cyp450s.delete(cyp_id)
	end
	def delete_patinfo_deprived_sequences(oid)
		@patinfos_deprived_sequences.delete(oid.to_i)
	end
	def delete_orphaned_fachinfo(oid)
		@orphaned_fachinfos.delete(oid.to_i)
	end
	def delete_orphaned_patinfo(oid)
		@orphaned_patinfos.delete(oid.to_i)
	end
	def delete_company(oid)
		#comp = @companies[oid]
		#@company_index.delete(comp.name.downcase, comp)
		@companies.delete(oid)
	end
	def delete_fachinfo(oid)
		@fachinfos.delete(oid)
	end
	def delete_galenic_group(oid)
		group = galenic_group(oid)
		unless (group.nil? || group.empty?)
			raise 'e_nonempty_galenic_group'
		end
		@galenic_groups.delete(oid.to_i)
	end
	def delete_incomplete_registration(oid)
		@incomplete_registrations.delete(oid)
	end
	def delete_indication(oid)
		@indications.delete(oid)
	end
	def delete_registration(iksnr)
		@registrations.delete(iksnr)
		@registrations.odba_store
	end
	def delete_substance(key)
		substance = nil
		if(key.to_i.to_s == key.to_s)
			substance = @substances.delete(key.to_i)
		else
			substance = @substances.delete(key.to_s.downcase)
		end
		checkout(substance)
	end
	def each_atc_class(&block)
		@atc_classes.each_value(&block)
	end
	def each_galenic_form(&block)
		@galenic_groups.each_value { |galgroup|
			galgroup.each_galenic_form(&block)
		}
	end
	def each_package(&block)
		@registrations.each_value { |reg|
			reg.each_package(&block)
		}
	end
	def execute_command(command)
		command.execute(self)
	end
	def fachinfo(oid)
		@fachinfos[oid.to_i]
	end
	def galenic_form(name)
		@galenic_groups.values.collect { |galenic_group|
			galenic_group.get_galenic_form(name)
		}.compact.first
	end
	def galenic_group(oid)
		@galenic_groups[oid.to_i]
	end
	def generic_group(package_pointer)
		@generic_groups[package_pointer]
	end
	def incomplete_registration(oid)
		@incomplete_registrations[oid.to_i]
	end
	def incomplete_registrations
		@incomplete_registrations.values
	end
	def indication(oid)
		@indications[oid.to_i]
	end
	def indication_by_text(text)
		@indications.values.select { |indication|
			indication.has_description?(text)
		}.first
	end
	def indications
		@indications.values
	end
	def login(email, pass)
		@users.values.select { |user| user.identified_by?(email, pass)}.first
	end
	def log_group(key)
		@log_groups[key]
	end
	def patinfo(oid)
		@patinfos[oid.to_i]
	end
	def patinfo_deprived_sequences(oid)
		@patinfos_deprived_sequences[oid.to_i]
	end
	#=begin
	def odba_store(name = nil)
		failsafe {
			#clear_indices
			super
			#rebuild_indices
		}
	end
	def rebuild_atc_chooser
		@atc_chooser = ODDB::AtcNode.new(nil)
		@atc_classes.values.sort_by { |atc| 
			atc.code 
		}.each { |atc|
			@atc_chooser.add_offspring(ODDB::AtcNode.new(atc))
		}
	end
	#for testing only
	def rebuild_odba
		#initialize scalar cache and cache_server 
		#(otherwise deadlock problems will occur) 
		ODBA.scalar_cache.scalar_cache.size
		ODBA.cache_server.indices.size
		#delete_if only for Testing!!!!!
		@fachinfos.delete_if{|key, val| val.descriptions["de"].name.nil?}	
		#@atc_classes.delete_if{|key, atc| atc.sequences.empty?}
		odba_store('oddbapp')
		#odba_take_snapshot
		rebuild_odba_indices
	end			
	def rebuild_odba_indices
		begin
			path = File.expand_path("../../etc/index_definitions.yaml", 
				File.dirname(__FILE__))
			file = File.open(path)
			YAML.load_documents(file) { |index_definition|
				ODBA.cache_server.create_index(index_definition, ODDB)
				puts "name: #{index_definition.index_name}"
					ODBA.cache_server.fill_index(index_definition.index_name, instance_eval(index_definition.init_source))
			}
		rescue
			puts "INDEX CREATION ERROR"
		ensure
			file.close
		end
	end
=begin
		ODBA.cache_server.create_index('atc_index_company',ODDB::Company, ODDB::AtcClass, :name, "atc_classes.each{ |atc| atc}", "sequences.collect{|seq| seq.company}")

		ODBA.cache_server.create_index('atc_index', ODDB::AtcClass, ODDB::AtcClass, :code, "")

		 ODBA.cache_server.create_index('substance_index_atc', ODDB::Substance, ODDB::AtcClass, :name, 'sequences.collect { |seq| seq.atc_class }', "sequences.collect{|seq| seq.active_agents.collect{|agent| agent.substance}}")

		 ODBA.cache_server.create_index('sequence_index_atc', ODDB::Sequence, ODDB::AtcClass, :name, "atc_class", "sequences")
=end
=begin
	def how_many_objects
		arr = []
		objs = {}
		ObjectSpace.each_object{|obj|
			arr.push(obj.class)
		}
		arr.uniq!
		arr.each { |klass|
			objs.store(klass, ObjectSpace.each_object(klass){})
		}
		sortres	=		objs.sort {|a,b| a[1]<=>b[1]}
		sortres.each{|res|
			puts res
		}
	end
=end
	def orphaned_fachinfo(oid)
		@orphaned_fachinfos[oid.to_i]
	end
	def orphaned_patinfo(oid)
		@orphaned_patinfos[oid.to_i]
	end
	def package_count
		@registrations.values.inject(0) { |inj, reg|
			inj += reg.package_count
		}
	end
=begin
	def rebuild_indices
		@indication_index = Datastructure::CharTree.new
		@indications.each_value { |indication|
			indication.descriptions.values.uniq.each { |desc|
				store_in_index(@indication_index, desc, indication)
			}
		}
		@atc_index = Datastructure::CharTree.new
		@atc_classes.each_value { |atc|
			store_in_index(@atc_index, atc.code, atc)
		}
		@atc_chooser = ODDB::AtcNode.new(nil)
		@atc_classes.values.sort_by { |atc| 
			atc.code 
		}.each { |atc|
			@atc_chooser.add_offspring(ODDB::AtcNode.new(atc))
		}
	end
=end
	def registration(registration_id)
		@registrations[registration_id]
	end
	def resolve(pointer)
		pointer.resolve(self)
	end
	def search(query, lang)
		result = ODDB::SearchResult.new
		# atcless_search, experimental -->
		if(query == 'atcless')
			atc = ODDB::AtcClass.new('n.n.')
			@registrations.each_value { |reg|
				reg.sequences.each_value { |seq|
					if(seq.atc_class.nil? && !seq.packages.empty?)
						atc.add_sequence(seq)
						#return [atc] if(atc.sequences.size > 50)
					end	
				}	
			}
			result.atc_classes = [atc]
			return result
		elsif(match = /(?:\d{4})?(\d{5})(?:\d{4})?/.match(query))
			iksnr = match[1]
			if(reg = registration(iksnr))
				atc = ODDB::AtcClass.new('n.n.')
				reg.sequences.each_value { |seq|
					atc.add_sequence(seq)
				}
				return [atc]
			end
		end
		# <--
		key = query.to_s.downcase
		result.atc_classes = ODBA.cache_server.retrieve_from_index('atc_index', key)
		if result.atc_classes.empty?
			result.atc_classes = ODBA.cache_server.retrieve_from_index('atc_index_company', key)
			filtered_result = []
			result.atc_classes.each { |atc|
				filtered_result.push(atc.company_filter_search(key))
			}
			result.atc_classes = filtered_result.flatten.compact.uniq
			result
		end
		if result.atc_classes.empty?
			result.atc_classes = ODBA.cache_server.retrieve_from_index('substance_index_atc', key)
			filtered_result = []
			result.atc_classes.each { |atc|
				filtered_result.push(atc.substance_filter_search(key))
			}
			result.atc_classes = filtered_result.flatten.compact.uniq
			result
		end
		if result.atc_classes.empty?
			result.atc_classes = ODBA.cache_server.retrieve_from_index("fachinfo_index_#{lang}", key, result)
			result
		end
		if result.atc_classes.empty?
			result.atc_classes = ODBA.cache_server.retrieve_from_index('sequence_index_atc', key)
			result
		end
		result.atc_classes.delete_if { |atc| atc.code.length == 0 }
		puts "before result"
		puts "we have #{result.atc_classes.size} atc-classes"
		result
	end
	def search_interaction(query)
		keys = query.to_s.downcase.split(" ")
		result = []
		keys.each { |key|
			if(atc_codes = sequences_by_name(key))
				atc_codes.each { |atc_code|
					result << atc_code.substances
				} 
			end
			result << soundex_substances(key)
		}
		result.flatten!
		result
	end
	def sequences_by_name(name)
		puts "retrieving_sequences_by_name"
		ODBA.cache_server.retrieve_from_index("sequence_index_atc", name)
	end
	def soundex_substances(name)
		ODBA.cache_server.retrieve_from_index("substance_index", name)
	end
	def sponsor
		@sponsor ||= ODDB::Sponsor.new
	end
=begin
	def store_in_index(index, key, *values)
		parts = key.to_s.split(/\s+/)
		parts << key.to_s
		parts.uniq!
		parts.each { |part|
			index.store(part.downcase, *values) if part.length > 3
		}
	end
=end
	def substance(key)
		if(key.to_i.to_s == key.to_s)
			@substances[key.to_i]
		elsif(substance = @substances[key.to_s.downcase])
			substance
		else
			@substances.values.each { |subs|
				if(subs.same_as?(key))
					return subs
				end
			}
			nil
		end
	end
	def substance_by_connection_key(connection_key)
		key = connection_key.to_s.downcase
		@substances.values.select { |substance|
			substance.connection_key == key
		}.first
	end
	def substances
		@substances.values
	end
	def substance_count
		@substances.length
	end
	def updated(item)
		case item
		when ODDB::Registration, ODDB::Sequence, ODDB::Package, ODDB::AtcClass
			@last_medication_update = Date.today
		end
	end
	def user(oid)
		@users[oid]
	end
	def user_by_email(email)
		@users.values.select { |user| user.unique_email == email }.first
	end
	private
	def create_unknown_galenic_group
		unless(@galenic_groups.is_a?(Hash) && @galenic_groups.size > 0)
			@galenic_groups = {}
			pointer = ODDB::Persistence::Pointer.new([:galenic_group])
			group = create(pointer)
			raise "Default GalenicGroup has illegal Object ID (#{group.oid})" unless group.oid == 1
			update(group.pointer, {'de'=>'Unbekannt'})
		end
	end
	def create_root_user
		@users ||= {}
		if(@users[0].nil?)
			@users.store(0, ODDB::RootUser.new)
		end
	end
=begin
	def delete_from_index(index, key, value)
		parts = key.to_s.split(/\s+/)
		parts << key.to_s
		parts.uniq!
		parts.each { |part|
			index.delete(part.downcase, value) if part.length > 3
		}
	end
=end
end

module ODDB
	class App < SBSM::DRbServer
		include Failsafe
		AUTOSNAPSHOT = true
		CLEANING_INTERVAL = 5*60
		EXPORT_HOUR = 2
		RUN_CLEANER = true
		RUN_EXPORTER = true
		RUN_UPDATER = true
		SESSION = Session
		SNAPSHOT_INTERVAL = 4*60*60
		STORAGE_PATH = File.expand_path('log/prevalence', PROJECT_ROOT)
		UNKNOWN_USER = UnknownUser
		UPDATE_INTERVAL = 24*60*60
		VALIDATOR = Validator
		attr_reader :cleaner, :updater
		def initialize
			puts STORAGE_PATH
			#=begin
		 	@prevalence = Madeleine::SnapshotMadeleine.new(STORAGE_PATH) {
				sys = OddbPrevalence.new
			}
			puts "prevalence initialized"
			@system = @prevalence.system
			#=end
=begin
			ODBA.cache_server.prefetch
			@system = ODBA.cache_server.fetch_named('oddbapp', self){
				puts "new oddbprevalence created"
				puts "with db start"
				@system.OddbPrevalence.new
			}
			#rebuild the atc_chooser
			@system.rebuild_atc_chooser
=end
			puts "system init..."
			@system.init
			#@system.odba_store
			puts "...done"
			#@prevalence.startAutoSnapshot(SNAPSHOT_INTERVAL) if AUTOSNAPSHOT
			#@prevalence.takeSnapshot
			puts "setup drb-delegation"
			super(@system)
			puts "reset"
			reset()
			puts "system initialized"
		end
		# prevalence-methods ################################
		def accept_incomplete_registration(reg)
			command = AcceptIncompleteRegistration.new(reg.pointer)
			@system.execute_command(command)
			registration(reg.iksnr)
		end
		def accept_orphaned(orphan, pointer, symbol)
			command = AcceptOrphan.new(orphan, pointer,symbol)
			@system.execute_command(command)
		end
		def create(pointer)
			@system.execute_command(CreateCommand.new(pointer))
		end
		def delete(pointer)
			@system.execute_command(DeleteCommand.new(pointer))
		end
		def merge_companies(source_pointer, target_pointer)
			command = MergeCommand.new(source_pointer, target_pointer)
			@system.execute_command(command)
		end
		def merge_galenic_forms(source, target)
			command = MergeCommand.new(source.pointer, target.pointer)
			@system.execute_command(command)
		end
		def merge_substances(source_pointer, target_pointer)
			command = MergeCommand.new(source_pointer, target_pointer)
			@system.execute_command(command)
		end
		def replace_fachinfo(iksnr, pointer)
			@system.execute_command(ReplaceFachinfoCommand.new(iksnr, pointer))
		end
		def update(pointer, values)
			#puts "updating #{pointer} with #{values}"
			@system.execute_command(UpdateCommand.new(pointer, values))
			#@system.update(pointer, values)
		end
=begin
		def take_snapshot
			failsafe {
				@prevalence.system.clear_indices
				@prevalence.take_snapshot
				@prevalence.system.rebuild_indices
			}
		end
=end
		#####################################################
		def admin(src, priority=-1)
			Thread.current.priority = priority
			Thread.current.abort_on_exception = false
			failsafe {
				response = begin
					instance_eval(src)
				rescue NameError
					#@prevalence.system.instance_eval(src)
					@system.instance_eval(src)
				end
				str = response.to_s
				if(str.length > 40)
					response.class
				else
					str
				end
			}
		end
		def login(session)
			pair = session.user_input(:email, :pass)
			@system.login(pair[:email], pair[:pass])
		end
		def reset
			@updater.kill if(@updater.is_a? Thread)
			@exporter.kill if(@exporter.is_a? Thread)
			@updater = run_updater if RUN_UPDATER
			@exporter = run_exporter if RUN_EXPORTER
			@mutex.synchronize {
				@sessions.clear
			}
		end
		def run_exporter
			Thread.new {
				Thread.current.priority=-10
				Thread.current.abort_on_exception = true
				today = (EXPORT_HOUR > Time.now.hour) ? Date.today : Date.today.next
				loop {
					next_run = Time.local(today.year, today.month, today.day, EXPORT_HOUR)
					sleep(next_run - Time.now)
					Exporter.new(self).run
					GC.start
					today = Date.today.next
				}
			}
		end
		def run_updater
			puts "running updater thread"
			Thread.new {
				Thread.current.priority=-5
				Thread.current.abort_on_exception = true
				loop {
					Updater.new(self).run
					#@prevalence.take_snapshot
					GC.start
					sleep UPDATE_INTERVAL
				}
			}
		end
	end
end

begin 
	require 'testenvironment'
rescue LoadError
end
