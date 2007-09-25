#!/usr/bin/env ruby
# GalenicGroup -- oddb -- 24.03.2003 -- mhuggler@ywesee.com 

require 'util/persistence'
require 'util/language'
require 'model/galenicform'

module ODDB
	class GalenicGroup 
		include Language
		ODBA_SERIALIZABLE = [ '@descriptions' ]
    attr_accessor :route_of_administration
		attr_reader :oid, :galenic_forms
		def initialize
			super
			@galenic_forms = {} 
		end
		def add(a_galenic_form)
			@galenic_forms.store(a_galenic_form.oid, a_galenic_form)
			@galenic_forms.odba_isolated_store
			a_galenic_form
		end
		def create_galenic_form
			galenic_form = GalenicForm.new
			galenic_form.galenic_group = self
			@galenic_forms.store(galenic_form.oid, galenic_form)
		end
		def delete_galenic_form(oid)
			if(form = @galenic_forms.delete(oid.to_i))
				@galenic_forms.odba_isolated_store
				form
			end
		end
		def each_galenic_form(&block)
			@galenic_forms.each_value(&block)
		end
		def empty?
			@galenic_forms.empty?
		end
		def galenic_form(oid)
			@galenic_forms[oid.to_i]
		end
		def get_galenic_form(description)
			@galenic_forms.values.select { |galenic_form|
				galenic_form.has_description?(description)
			}.first
		end
		def remove(a_galenic_form)
			if(@galenic_forms.delete(a_galenic_form.oid))
				@galenic_forms.odba_isolated_store
			end
			a_galenic_form
		end
		def ==(other)
			@oid > 1 && super # Unknown group does not compare to any
		end
	end
end
