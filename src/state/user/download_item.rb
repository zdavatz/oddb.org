#!/usr/bin/env ruby
# encoding: utf-8
# State::User::DownloadItem -- oddb -- 21.08.2012 -- yasaka@ywesee.com

require 'state/global_predefine'
require 'state/paypal/checkout'
require 'state/paypal/return'
require 'state/user/register_download'
require 'state/user/download_export'
require 'view/user/export'
require 'view/user/download_item'

module ODDB
  module State
    module User
class DownloadItem < State::User::RegisterDownload
  include View::User::Export
  VIEW = View::User::DownloadItem
  DIRECT_EVENT = :download_item
  def init
    keys  = [:buy, :month, :compression] # month and compression are optional
    input = user_input(keys, [:buy])
    items = [] # as container (one item)
    dir = File.expand_path('../../../data/downloads', File.dirname(__FILE__))
    filename = nil
    # All files have .zip compressed version without epub and prc.
    # Some items have only .zip and .tar.gz only.
    if file = input[:buy]
      filename = File.exists?(File.join(dir, File.basename(file, '.zip') + '.zip')) ? file : nil
      unless filename # epub, prc format
        filename = File.exists?(File.join(dir, file)) ? file : nil
      end
    end
    if filename
      suffix = ''
      unless DOWNLOAD_UNCOMPRESSED.include?(filename)
        suffix = case input[:compression]
                 when 'compr_gz'
                   ['.gz', '.tar.gz'].select { |sfx|
                     File.exist?(File.join(dir, filename + sfx))
                   }.first
                 else
                   '.zip'
                 end
      end
      item = AbstractInvoiceItem.new
      item.text = filename + suffix
      item.type = :download
      item.unit = 'Download'
      item.vat_rate = VAT_RATE
      months = input[:month] || default_month(filename).to_i
      item.quantity = months.to_f
      price_mth    = 'price'
      duration_mth = 'duration'
      if (months == '12')
        price_mth    = 'subscription_' << price_mth
        duration_mth = 'subscription_' << duration_mth
      end
      klass = State::User::DownloadExport
      item.total_netto = klass.send(price_mth, filename)
      item.duration    = klass.send(duration_mth, filename)
      items.push(item)
    end
    if (items.empty?)
      @errors.store(:download, create_error('e_no_download_selected', :download, nil))
    end
    if (error?)
      State::User::DownloadExport.new(@session, @model)
    else
      pointer = Persistence::Pointer.new(:invoice)
      invoice = Persistence::CreateItem.new(pointer)
      invoice.carry(:items, items)
      @model = invoice
    end
  end
end
    end
  end
end
