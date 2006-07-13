#!/usr/bin/env ruby
# Persistence -- oddb -- 26.02.2003 -- hwyss@ywesee.com

require 'rockit/rockit'
require 'odba/persistable'

module ODBA
	class Stub
		def odba_replace(name=nil)
			@receiver || begin
				@receiver = ODBA.cache.fetch(@odba_id, @odba_container)
				if(@odba_container)
					@odba_container.odba_replace_stubs(self, @receiver)
				end
				@receiver
			rescue OdbaError => e
				msg = "ODBA::Stub was unable to replace #{@odba_class}:#{@odba_id} - "
				if(@odba_container.respond_to?(:pointer))
					msg << @odba_container.pointer.to_s	
				end
				names = @odba_container.instance_variables.select { |name|
					eql?(@odba_container.instance_variable_get(name))
				}
				msg << "[" << names.join(',') << "]"
				warn msg
			end
		end
	end
end
module ODDB
	module PersistenceMethods
		attr_reader :oid
		attr_accessor :pointer, :revision
		def init(app)
		end
		def ancestors(app)
			if(@pointer)
				@pointer.ancestors.collect { |pointer| pointer.resolve(app) }
			end
		end
		def data_origin(key)
			data_origins[key.to_s]
		end
		def data_origins
			@data_origins ||= {}
		end
		def diff(values, app=nil)
			result = {}
			adjust_types(values, app).each { |key, value|
				if(self.respond_to?(key))
					oldval = self.send(key)
					if(oldval.nil? || undiffable?(oldval) || value != oldval)
						result.store(key, value)
					end
				end
			}
			result
		end
		def checkout
		end
		def nil_if_empty(value)
			val = value.to_s.strip
			(val.empty?) ? nil : val
		end
		def parent(app)
			@pointer.parent.resolve(app)
		end
		def pointer_descr
			self.class.to_s
		end
		def undiffable?(val)
			defined?(val.class::DISABLE_DIFF) && val.class::DISABLE_DIFF
		end
		def update_values(values, origin=nil)
			@revision = Time.now
			values.each { |key, value|
				key = key.to_s
				data_origins.store(key, origin)
				self.send(key + '=', value)
			}
		end
		private
		def adjust_types(values, app=nil)
			values
		end
		def checkout_helper(connections, remove_command)
			connections.each { |var|
				if(var.respond_to?(remove_command))
					var.send(remove_command, self)
				end
			}
		end
		def set_oid
			@oid ||= self.odba_id
		end
	end
	module Persistence
		include PersistenceMethods
		include ODBA::Persistable
		ODBA_PREDEFINE_SERIALIZABLE = ['@data_origins']
		def initialize(*args)
			@revision = Time.now
			super
			set_oid()
		end
		class PathError < RuntimeError
			attr_reader :pointer
			def initialize(msg, pointer)
				@pointer = pointer
				super(msg)
			end
		end
		class UninitializedPathError < PathError
		end
		class InvalidPathError < PathError
		end
		class Pointer
      SECURE_COMMANDS = [
        :active_agent, :address, :address_suggestion, :atc_class, :analysis_group, :company,
        :doctor, :hospital, :cyp450, :fachinfo, :feedback, :galenic_group,
        :generic_group, :incomplete_registration, :indication, :invoice,
        :address_suggestion, :migel_group, :subgroup, :product, :narcotic,
        :orphaned_fachinfo, :orphaned_patinfo, :package, :patent, :patinfo, :position,
        :poweruser, :registration, :sequence, :slate, :sl_entry, :sponsor,
        :substance, :user, :limitation_text
      ]
			@parser = Parse.generate_parser <<-EOG
Grammar OddbSize
	Tokens
		STEP = /!/
		ARG  = /,/
		PTR  = /:/
		PEND = /\\./
		EXPR = /([^!,:.%]|%[!,:.%])+/
	Productions
		Pointer -> PTR Step* PEND?
							 [: _, steps, _]
		Step		-> STEP EXPR Arg* 
							 [: _, command, arguments]
		Arg			-> ARG (EXPR | Pointer)
							 [: _, argument]
			EOG
			class << self
				def parse(string)
					ast = @parser.parse(string)
					ast.compact!
					produce_pointer(ast)
				end
        def from_yus_privilege(string)
          ## does not support encapsulated pointers
          args = string.scan(/!([^!]+)/).collect { |matches|
            matches.first.split('.').compact
          }
          self.new(*args)
        end
				private
				def produce_argument(ast)
					arg = ast.argument
					if(arg.name == 'Pointer')
						produce_pointer(arg)
					else
						arg.value.gsub(/%([!,:.%])/, '\1')
					end
				end
				def produce_pointer(ast)
					steps = ast.steps.collect { |node|
						produce_step(node)
					}
					Pointer.new(*steps)
				end
				def produce_step(ast)
					step = [ast.command.value.intern]
					ast.arguments.each { |arg| 
						step.push produce_argument(arg)
					}
					step
				end
			end
			def initialize(*args)
				@directions = args.collect { |arg| [arg].flatten }
			end
			def ancestors
				pointer = self
				ancestors = []
				while(pointer = pointer.parent)
					ancestors.unshift(pointer)
				end
				ancestors
			end
			def append(value)
				@directions << [] unless @directions.last
				last_step = @directions.last
				unless last_step.last == value
					last_step << value
				end
			end
			def creator
				Pointer.new([:create, self])
			end
			def dup
				directions = @directions.collect { |step| step.dup }
				Pointer.new(*directions)
			end
			def eql?(other)
				to_s.eql?(other.to_s)
			end
      def insecure?
        @directions.any? { |step|
          !SECURE_COMMANDS.include?(step.first.to_sym) \
          || step.any? { |arg|
            arg.is_a?(Pointer)
          }
        }
      end
			def issue_create(app)
				new_obj = resolve(app)
				unless new_obj.nil?
					return new_obj
				end
				pointer = dup
				command = pointer.directions.pop
				command[0] = 'create_' << command.first.to_s
				hook = pointer.resolve(app)
				new_obj = hook.send(*(command.compact))
				new_obj.pointer = self
				new_obj.init(app)
				# Only the hook must be stored in issue_create
				# because wie scan its connections for unsaved objects
				# see ODBA::Persistable
				# In the case where the newly created object were saved
				# *before* the hook, any intermediate collections might not 
				# be properly stored, resulting in the newly created object
				# being inaccessible after a restart
				hook.odba_store
				new_obj
			end
			def issue_delete(app)
				obj = resolve(app)
					if obj.respond_to?(:checkout)
						obj.checkout
					end
					pointer = dup
					command = pointer.directions.pop
					command[0] = 'delete_' << command.first.to_s
					hook = pointer.resolve(app)
					if(hook.respond_to?(command.first))
						hook.send(*(command.compact))
						### ODBA needs the delete_<command> method to call
						### odba_store or odba_isolated_store on whoever was the
						### last connection to this item.
					end
					if(obj.respond_to?(:odba_delete))
						obj.odba_delete
					end
			rescue InvalidPathError, UninitializedPathError => e
				warn "Could not delete: #{to_s}, reason: #{e.message}"
			end
			def issue_update(hook, values, origin = nil)
				obj = resolve(hook)
				unless(obj.nil?)
					obj.update_values(obj.diff(values, hook), origin)
					obj.odba_store
				end
				obj
			end
			def last_step
				@directions.last.dup
			end
			def parent
				parent = dup
				parent.directions.pop
				parent unless parent.directions.empty?
			end
			def resolve(hook)
				lasthook = hook
				laststep = []
				@directions.each { |step|
					if(hook.nil?)
						call = laststep.shift
						args = laststep.join(',')
						msg = "#{to_s} -> #{lasthook.class}::#{call}(#{args}) returned nil"
						raise(UninitializedPathError.new(msg, self))
					elsif(hook.respond_to?(step.first))
						lasthook = hook
						laststep = step
						hook = begin
							hook.send(*step)
						rescue 
						end
					else
						call = step.shift
						args = step.join(',')
						msg = "#{to_s} -> undefined Method #{hook.class}::#{call}(#{args})"
						raise(InvalidPathError.new(msg, self))
					end
				}
				hook
			end
			def skeleton
				@directions.collect { |step| 
					cmd = step.first
					cmd.is_a?(Symbol) ? cmd : cmd.intern
				}
			end
			def to_s
				':' << @directions.collect { |orig|
					step = orig.collect { |arg|
						if(arg.is_a? Pointer)
							arg
						else
							arg.to_s.gsub('%','%%').gsub(/[:!,.]/, '%\0')
						end
					}
					'!' << step.join(',')
				}.join << '.'
			end
      def to_yus_privilege
        @directions.inject('org.oddb.model') { |yus, steps|
          steps = steps.dup
          yus << '.!' << steps.shift.to_s
          steps.inject(yus) { |yus, step| yus << '.' << step.to_s }
        }
      end
			def +(other)
				dir = @directions.dup << [other].flatten
				Pointer.new(*dir)
			end
			def ==(other)
				eql?(other)
			end
			def hash
				to_s.hash
			end
			protected 
			attr_reader :directions
		end
		class CreateItem
			attr_reader :pointer, :inner_pointer
			def initialize(pointer=Pointer.new)
				@inner_pointer = pointer
				@pointer = Pointer.new([:create, pointer])
        @data = {}
			end
			def ancestors(app)
				@inner_pointer.ancestors.collect { |pointer| pointer.resolve(app) }
			end
			def append(val)
				@inner_pointer.append(val)
			end
			def carry(key, val=nil)
        @data.store(key, val)
			end
			def method_missing(key, *args)
        @data[key]
			end
			def parent(app)
				@inner_pointer.parent.resolve(app)
			end
			def respond_to?(key)
				key != :pointer_descr
			end
		end
	end
end
