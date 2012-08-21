#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::DownloadItem -- oddb.org -- 21.08.2012 -- yasaka@ywesee.com

require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'view/paypal/invoice'
require 'view/publictemplate'
require 'view/datadeclaration'
require 'view/form'
require 'view/user/autofill'
require 'view/user/export'
require 'view/user/download_export'

module ODDB
  module View
    module User
class DownloadItemForm < Form
  include AutoFill
  include HtmlGrid::ErrorMessage
  include Export
  COMPONENTS = {
    [0,0]  => :email,
    [0,1]  => :salutation,
    [0,2]  => :name_last,
    [0,3]  => :name_first,
    [0,4]  => :company_name,
    [0,5]  => :address,
    [0,6]  => :plz,
    [0,7]  => :city,
    [0,8]  => :phone,
    [0,9]  => :business_area,
    [1,10] => :submit,
  }
  CSS_CLASS = 'component'
  HTML_ATTRIBUTES = {
    'style' => 'width:30%',
  }
  EVENT = :checkout
  LABELS = true
  CSS_MAP = {
    [0,0,4,11] => 'list',
  }
  COMPONENT_CSS_MAP = {
    [1,0,3,10] => 'standard',
  }
  SYMBOL_MAP = {
    :salutation    => HtmlGrid::Select,
    :business_area => HtmlGrid::Select,
    :pass          => HtmlGrid::Pass,
    :set_pass_2    => HtmlGrid::Pass,
  }
  LEGACY_INTERFACE = false
  def init
    unless @session.logged_in?
      hash_insert_row(components, [0,1], :pass)
      components.store([3,1], :set_pass_2)
      css_map.store([0,11,4], 'list')
      component_css_map.store([1,10], 'standard')
    end
    super
    if @session.error?
      error = RuntimeError.new('e_need_all_input')
      __message(error, 'processingerror')
    end
  end
  def hidden_fields(context)
    hidden = super
    if (!@session.error? and file = @session.user_input(:buy))
      hidden << context.hidden("download[#{file}]", '')
      if (month = @session.user_input(:month))
        hidden << context.hidden("months[#{file}]", month)
      else
        hidden << context.hidden("months[#{file}]", default_month(file))
      end
    end
    hidden
  end
end
# See also:
#  View::User::RegisterDownload
#  View::User::DownloadExportInnerComposite
class DownloadItemComposite < View::User::DownloadExportInnerComposite
  include View::PayPal::InvoiceMethods
  include View::DataDeclaration
  COMPONENTS = {
    [0,0]   => SelectSearchForm,
    [0,1,0] => "register_download",
    [0,1,1] => 'dash_separator',
    [0,1,2] => :data_declaration,
    [0,2]   => "register_download_descr",
    [0,3]   => :register_download_form,
    [1,3]   => :invoice_item,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0]   => 'right',
    [0,1,2] => 'th',
    [0,2]   => 'list',
  }
  COLSPAN_MAP = {
    [0,0] => 2,
    [0,1] => 2,
    [0,2] => 2,
  }
  LEGACY_INTERFACE = false
  def register_download_form(model)
    if(@session.logged_in?)
      model = @session.user
    end
    DownloadItemForm.new(model, @session, self)
  end
  def invoice_item(model)
    fields = []
    fields << invoice_items(model)
    fields << '<br/>'
    fields << datadesc_item(model)
    fields << '<br/>'
    fields << example_item(model)
    fields
  end
  private
  # call methods via User::DownloadExportInnerComposite
  def example_item(model)
    if file = @session.user_input(:buy)
      example_method = ('example_' + file.gsub(/\./, '_').downcase).intern
      if respond_to?(example_method)
        self.send(example_method, model, @session)
      end
    end
  end
  def datadesc_item(model)
    if file = @session.user_input(:buy)
      desc_method = ('datadesc_' + file.gsub(/\./, '_').downcase).intern
      if self.respond_to?(desc_method)
        self.send(desc_method, model, @session)
      elsif File.exists?(
        @lookandfeel.resource_global(:downloads, File.join('dadadesc', "#{file}.txt"))
      )
        datadesc(file)
      end
    end
  end
end
class DownloadItem < View::PublicTemplate
  JAVASCRIPTS = ['autofill']
  CONTENT = View::User::DownloadItemComposite
end
    end
  end
end
