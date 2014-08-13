#!/usr/bin/env ruby
# encoding: utf-8

require 'htmlgrid/composite'
require 'htmlgrid/span'
require 'util/zsr'
require 'json'

module ODDB
  module View
    module Helpers
      def Helpers.saveFieldValueForLaterUse(field, field_id, default_value)
        if field.is_a?(HtmlGrid::InputRadio)
          field.set_attribute('onClick', "
                                  var new_value = sessionStorage.getItem('#{field_id}');
                                  sessionStorage.setItem('#{field_id}', '#{default_value}');
                                ")
          field_id = field_id.to_s  + '_' + default_value.to_s
        else
          js_snippet_change = "if (this.value == '' || this.value == '#{default_value}')
                                {     sessionStorage.removeItem('#{field_id}');
                                } else { sessionStorage.setItem('#{field_id}', this.value);
                                }
                                console.log('#{field_id} changed to ' + this.value);
                                "
          field.set_attribute('onFocus', "
                                var new_value = sessionStorage.getItem('#{field_id}');
                                  if (this.value == '#{default_value}') { this.value = '' ; }
                                ")
          field.set_attribute('onBlur',   js_snippet_change)
          field.set_attribute('onChange', js_snippet_change)
        end
        field.set_attribute('id', field_id)
        field.value = default_value unless field.value
      end
    end
    class ZsrDetails < HtmlGrid::Composite
      COMPONENTS = {
        [0,0] => :details,
      }
      CSS_CLASS = 'composite'
      def init
        @zsr_id = @session.zsr_id
        @zsr_info = ZSR.info(@zsr_id) if @zsr_id
        $stdout.puts "ZsrDetails zsr_id is #{@zsr_id} with #{@zsr_info}"
         super
      end
      def details(model, session=@session)
        return unless @zsr_info and @zsr_info.size > 0
        isPrinting = @session.request_path.index('/print')
        prefixes = {'phone' => :phone, 'fax' => :fax_label}
        fields = []
        %w[title first_name last_name street pobox zip city phone fax].each do |field|
          key = "prescription_#{field}".to_sym
          span = HtmlGrid::Span.new(model, session, self)
          field_value = eval("@zsr_info[:#{field}]")
          next unless field_value
          span.value = field_value + '&nbsp;'
          if prefixes.keys.index(field) and not isPrinting
            txt = HtmlGrid::Span.new(model, session, self)
            txt.value =  @lookandfeel.lookup(prefixes[field]) + '&nbsp;'
            txt.set_attribute('class', 'bold')
            fields << txt
          end
          fields << span
          fields << "<br>" if %w[gln_id last_name pobox city phone].index(field)
        end
        if isPrinting
          span_zsr_id = HtmlGrid::Span.new(@model, @session, self)
          span_zsr_id.value = @session.zsr_id
          span_zsr_id.set_attribute('type', 'hidden')
          span_zsr_id.set_attribute('id', :prescription_zsr_id)
          fields <<  '<BR>ZSR&nbsp;'
          fields << span_zsr_id

          gln_id = @zsr_id ? @zsr_info[:gln_id] : nil
          span_gln_id = HtmlGrid::Span.new(@model, @session, self)
          span_gln_id.value = gln_id
          span_gln_id.set_attribute('id', :prescription_gln_id)
          Helpers.saveFieldValueForLaterUse(span_gln_id, :prescription_gln_id, '')
          span_gln_id.set_attribute('type', 'hidden')
          fields <<  '<BR>EAN&nbsp;'
          fields << span_gln_id
          $stdout.puts "Did set span_zsr_id.value = #{ @session.zsr_id} and span_gln_id.value = #{gln_id}"
        end
        fields
      end 
    end
  end
end
