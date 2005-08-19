#!/usr/bin/env ruby
# Persistence -- oddb -- 26.02.2003 -- hwyss@ywesee.com

require 'rockit/rockit'
require 'odba/persistable'

module ODDB
	module PersistenceMethods
		attr_reader :oid
		attr_accessor :pointer
		def init(app)
		end
		def ancestors(app)
			@pointer.ancestors.collect { |pointer| pointer.resolve(app) }
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
		def update_values(values)
			values.each { |key, value|
				self.send(key.to_s + '=', value)
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
=begin
		def current_oid(klass)
			oids = []
			ObjectSpace.each_object(klass) { |obj|
				oids << obj.oid.to_i
			}
			oids.max
		end
=end
		def set_oid
=begin
			self.class.instance_eval <<-EOS unless(self.class.respond_to?(:next_oid))
				@oid = nil
				class << self
					def next_oid
						# Persistence.current_oid(self).next # will break many tests,
						# but might solve the problem of mysterious reseting of oids
						@oid = (@oid || Persistence.current_oid(self)).next
					end
				end
			EOS
			@oid ||= self.class.next_oid
=end
			@oid ||= self.odba_id
		end
		#module_function :current_oid
	end
	module Persistence
		include PersistenceMethods
		include ODBA::Persistable
		ODBA_CARRY_METHODS = [:pointer]
		def initialize(*args)
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
				puts "Could not delete: #{to_s}, reason: #{e.message}"
			end
			def issue_update(hook, values)
				obj = resolve(hook)
				unless(obj.nil?)
					obj.update_values(obj.diff(values, hook))
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
						#arity = hook.method(step.first).arity
						#if(((arity >= 0) && (step.size == arity.next)) \
						#		|| ((arity < 0) && (step.size >= -arity)))
								hook.send(*step)
						#end
						rescue
							puts "#{hook.class}::#{step.join(',')}: Arity did not match!!!!!!!"
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
			def +(other)
				dir = @directions.dup << [other].flatten
				Pointer.new(*dir)
			end
			def ==(other)
				other.is_a?(Pointer) \
					&& @directions == other.directions
			end
			protected 
			attr_reader :directions
		end
		class CreateItem
			attr_reader :pointer, :inner_pointer
			def initialize(pointer=Pointer.new)
				@inner_pointer = pointer
				@pointer = Pointer.new([:create, pointer])
			end
			def ancestors(app)
				@inner_pointer.ancestors.collect { |pointer| pointer.resolve(app) }
			end
			def append(val)
				@inner_pointer.append(val)
			end
			def carry(key, val=nil)
				instance_eval("@#{key} = val")
				instance_eval <<-EOS
					def #{key}
						@#{key}
					end
				EOS
			end
			def method_missing(*args)
				nil
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
