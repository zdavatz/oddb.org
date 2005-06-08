#!/usr/bin/env ruby
# State::Admin::AssignDeprivedSequence -- oddb -- 15.12.2003 -- rwaltert@ywesee.com

require 'state/admin/global'
require 'view/admin/assign_deprived_sequence'

module ODDB
	module State
		module Admin
class AssignDeprivedSequence < State::Admin::Global
	VIEW = View::Admin::AssignDeprivedSequence
=begin
	class DeprivedSequenceFacade < Array
		attr_reader :sequence
		def initialize(seq)
			@sequence = seq
			sequences = seq.registration.sequences.values
			self.sequences=(seq.registration.sequences.values)
		end
		def sequences=(array)
			array.each{ |seq|
				unless(seq.patinfo.nil?)
					self << seq
				end
			}
		end
	end
=end
	class DeprivedSequenceFacade
		attr_reader :sequence
		attr_reader :sequences
		include Enumerable
		def initialize(seq)
			@sequence = seq
			self.sequences = seq.registration.sequences.values
		end
		def each(&block)
			@sequences.each(&block)
		end
		def empty?
			false #@sequences.empty?
		end
		def name_base
			@sequence.name_base
		end
		def pointer
			@sequence.pointer
		end
		def sequences=(array)
			@sequences = array.select { |seq| 
				seq.has_patinfo? && (seq != @sequence) }
		end
	end
	def init
		super
		@model = DeprivedSequenceFacade.new(@model)
		if(@model.sequences.empty? \
			&& (match = /^[^\s]+/.match(@model.name_base)) \
			&& match[0].size > 3)
			#&& match[0] != @model.name_base \
			@model.sequences = named_sequences(match[0])
		end
	end
	def assign_deprived_sequence
		if(!@session.error? \
			&& (pointer = @session.user_input(:patinfo_pointer)))
			values = {}
			if(pointer.last_step == [:pdf_patinfo])
				values.store(:pdf_patinfo, @session.resolve(pointer))
			else
				values.store(:patinfo, pointer)
			end
			@session.app.update(@model.pointer, values)
			if(@previous.direct_event == :patinfo_deprived_sequences)
				patinfo_deprived_sequences
			else
				@previous
			end
		else
			err = create_error(:e_no_sequence_selected, :pointers, nil)
			@errors.store(:pointers, err)
			self
		end
	end
	def named_sequences(name)
		if(name.size < 3)
			add_warning(:w_name_to_short,:name, name)
			[]
		else
			returnvalue = @session.app.search_sequences(name.downcase)
			if(returnvalue.size > 50)
				add_warning(:w_too_many_sequences, :name, nil)
				[]
			else
				returnvalue
			end
		end
	end
	def search_sequences
		name = @session.user_input(:search_query)
		if(name.is_a? String)
			@model.sequences = named_sequences(name)
		else
			err = create_error(:e_name_to_short, :name, name)
			@errors.store(name, err)
		end
		self
	end
	def shadow
		@session.app.update(@model.pointer, {:patinfo_shadow => true})
		patinfo_deprived_sequences
	end
	def symbol
		:name_base
	end
	def preview 
		if(lang = @session.user_input(:language_select))
			doc = @model.languages[lang]
			State::Admin::PatinfoPreview.new(@session, doc)
		else
			self
		end
	end
end
		end
	end
end
