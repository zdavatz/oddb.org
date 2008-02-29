#!/usr/bin/env ruby
# PatinfoInvoicer -- oddb -- 16.08.2005 -- jlang@ywesee.com

require 'plugin/info_invoicer'

module ODDB
  class PatinfoInvoicer < InfoInvoicer
    def initialize(*args)
      @infotype = :patinfo
      super
    end
    def activation_fee
      PI_UPLOAD_PRICES[:activation]
    end
    def active_infos
      @app.active_pdf_patinfos.keys.inject({}) { |inj, key|
        inj.store(key[0,8], 1)
        inj
      }
    end
    def html_items(first)
      invoiced = {}
      items = []
      last = first >> 12
      @app.companies.each_value { |company|
        if(company.invoice_htmlinfos && company.invoice_date(:patinfo) == first)
          company.registrations.each { |reg|
            if(reg.active?)
              reg.each_sequence { |seq|
                if(seq.public_package_count > 0 && !seq.pdf_patinfo \
                   && (patinfo = seq.patinfo.odba_instance) \
                   && !invoiced.include?(patinfo))
                  invoiced.store(patinfo, true)
                  item = AbstractInvoiceItem.new
                  item.price = PI_UPLOAD_PRICES[:annual_fee]
                  item.text = [reg.iksnr, seq.seqnr].join(' ')
                  item.time = Time.now
                  item.type = :annual_fee
                  item.unit = 'Jahresgebühr'
                  item.vat_rate = VAT_RATE
                  item.item_pointer = seq.pointer
                  items.push(item)
                end
              }
            end
          }
        end
      }
      items
    end
    def neighborhood_unique_names(item)
      names = [unique_name(item)].compact
      if((ptr = item.item_pointer) && (seq = ptr.resolve(@app)))
        active = seq.pdf_patinfo
        seq.registration.sequences.each_value { |other|
          if(other.pdf_patinfo == active)
            names.push([other.iksnr, other.seqnr].join('_'))
          end
        }
      end
      names.uniq
    end
    def parent_item_class
      Sequence
    end
    def unique_name(item)
      name = item.text
      if(/^[0-9]{5} [0-9]{2}$/.match(name))
        name.tr(' ', '_')
      elsif((ptr = item.item_pointer) && (seq = ptr.resolve(@app)))
        [seq.iksnr, seq.seqnr].join('_')
      end
    end
  end
end
