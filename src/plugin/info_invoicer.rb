#!/usr/bin/env ruby
# InfoInvoicer -- oddb.org -- 26.02.2008 -- hwyss@ywesee.com

require 'plugin/invoicer'

module ODDB
  class InfoInvoicer < Invoicer
    attr_accessor :invoice_number
    def run(day = @@today)
      send_daily_invoices(day - 1)
      send_annual_invoices(day)
    end
    def active_companies
      active_companies = []
      @app.invoices.each_value { |inv|
        inv.items.each_value { |item|
          if(item.type == :annual_fee && (ptr = item.item_pointer) \
            && (seq = pointer_resolved(ptr)) && seq.is_a?(parent_item_class) \
            && (company = seq.company))
            active_companies.push(company.odba_instance)
          end
        }
      }
      active_companies.uniq!
      active_companies
    end
    def adjust_annual_fee(company, items)
      if(date = company.invoice_date(@infotype))
        diy = (date - (date << 12)).to_f
        short = date << 1
        items.each { |item|
          if(item.type == :annual_fee)
            tim = item.time
            item_date = Date.new(tim.year, tim.month, tim.day)
            exp = (!company.limit_invoice_duration && item_date > short) \
              ? (date >> 12) : date
            exp_time = Time.local(exp.year, exp.month, exp.day)
            days = (exp - item_date).to_f
            factor = days/diy
            item.data ||= {}
            item.data.update({:last_valid_date => exp, :days => days})
            item.quantity = factor
            item.expiry_time = exp_time
          end
        }
      end
    end
    def adjust_company_fee(company, items)
      price = company.price(@infotype).to_i
      if(price > 0)
        items.each { |item|
          if(item.type == :annual_fee)
            item.price = price
          end
        }
      end
    end
    def adjust_overlap_fee(date, items)
      first_invoice = items.any? { |item| item.type == :activation }
      date_end = (date >> 12)
      exp_time = Time.local(date_end.year, date_end.month, date_end.day)
      diy = (date_end - date).to_f
      items.each { |item|
        days = diy
        date_start = date
        if(!first_invoice && (tim = item.expiry_time))
          valid = Date.new(tim.year, tim.month, tim.day)
          if(valid > date_start)
            date_start = valid
            days = (date_end - valid).to_f
            factor = days/diy
            item.quantity = factor
          end
        end
        item.expiry_time = exp_time
        if(item.type == :annual_fee)
          item.data ||= {}
          item.data.update({
            :days => days,
            :first_valid_date => date_start, 
            :last_valid_date => date_end,
          })
        end
      }
    end
    def annual_items
      active = active_infos
      ## all items for which the product still exists 
      slate_items.select { |item| 
        # but only once per sequence.
        item.type == :annual_fee && active.delete(unique_name(item))
      }
    end
    def all_items
      active = active_infos
      ## all items for which the product still exists 
      slate_items.reverse.select { |item| 
        # but only once per sequence.
        (item.type == :processing) || active.delete(unique_name(item))
      }
    end
    def filter_paid(items, date=@@today)
      ## Prinzipielles Vorgehen
      # Für jedes item in items:
      # Gibt es ein Invoice, welches nicht expired? ist 
      # und welches ein Item beinhaltet, das den typ 
      # :annual_fee hat und den selben unique_name wie item

      items = items.sort_by { |item| item.time }

      ## Vorgeschlagener Algorithmus
      # 1. alle invoices von app
      # 2. davon alle items, die nicht expired? und den 
      #    typ :annual_fee haben
      # 3. davon den unique_name
      # 4. -> neue Collection pointers
      fee_names = []
      prc_names = []
      @app.invoices.each_value { |invoice|
        invoice.items.each_value { |item|
          if(name = unique_name(item))
            if(item.type == :annual_fee && !item.expired?(date))
              fee_names.push(name)
            elsif(item.type == :processing && !item.expired?(date))
              prc_names.push(name)
            end
          end
        }
      }
      fee_names.uniq!
      prc_names.uniq!
      
      # 5. Duplikate löschen
      result = []
      items.each { |item| 
        ## as patinfos/fachinfos can be assigned to other sequences, check at
        #  least all sequences in the current registration for non-expired
        #  invoices
        names = neighborhood_unique_names(item)
        if(name = unique_name(item))
          if(item.type == :annual_fee && (fee_names & names).empty?)
            fee_names.push(name)
            result.push(item)
          elsif(item.type == :processing && (prc_names & names).empty?)
            prc_names.push(name)
            result.push(item)
          end
        end
      }
      result
    end
    def group_by_company(items)
      active_comps = active_companies
      companies = {}
      items.each { |item| 
        ptr = item.item_pointer
        if(seq = pointer_resolved(ptr))
          ## correct the item's stored name (it may have changed in Packungen.xls)
          (item.data ||= {})[:name] = seq.name if seq.respond_to?(:name)
          (companies[seq.company.odba_instance] ||= []).push(item)
        end
      }
      price = activation_fee
      companies.each { |company, items|
        time = items.collect { |item| item.time }.min
        unless(active_comps.include?(company))
          item = AbstractInvoiceItem.new
          item.price = price
          item.text = "Aufschaltgeb\374hr"
          item.time = time
          item.type = :activation
          item.unit = 'Einmalig'
          item.vat_rate = VAT_RATE
          items.unshift(item)
        end
      }
      companies
    end
    def html_items(day)
      [] # does not apply for fachinfos
    end
    def neighborhood_unique_names(item)
      [] # does not apply for fachinfos
    end
    def parent_item_class
      Object
    end
    def pointer_resolved(pointer)
      pointer.resolve(@app)
    rescue StandardError
    end
    def recent_items(day) # also takes a range of Dates
      fd = nil
      ld = nil
      if(day.is_a?(Range))
        fd = day.first
        ld = day.last.next
      else
        fd = day
        ld = day.next
      end
      ft = Time.local(fd.year, fd.month, fd.mday)
      lt = Time.local(ld.year, ld.month, ld.mday)
      range = ft...lt
      recents = all_items.select { |item|
        range.include?(item.time)
      }
      ## remove duplicate processing items
      active = active_infos
      recents.reject { |item| 
        item.type == :processing && !active.delete(unique_name(item))
      }
    end
    def send_annual_invoices(day = @@today, company_name=nil, invoice_date=day)
      items = annual_items
      ## augment with active html-patinfos
      items += html_items(day)
      time = Time.local(day.year + 1, day.month, day.day) + 1
      payable_items = filter_paid(items, time)
      groups = group_by_company(payable_items)
      groups.each { |company, items|
        ## if autoinvoice is disabled, but a preferred invoice_date is set, 
        ## invoice-start and -end-dates should be adjusted to that date.
        if(company.invoice_disabled?(@infotype))
          if(date = company.invoice_date(@infotype))
            if(date == day)
              date = company.invoice_dates[@infotype] = date + 1
              company.odba_store
            end
            time = Time.local(date.year, date.month, date.day)
            items.each { |item|
              if(item.respond_to?(:odba_store))
                item.expiry_time = time
                item.odba_store
              end
            }
          end
        elsif(email = company.invoice_email)
          if(!company.invoice_date(@infotype))
            time = items.collect { |item| item.time }.min
            date = Date.new(time.year, time.month, time.day)
            company.invoice_dates[@infotype] = date
            company.odba_store
          elsif(company_name == company.name)
            company.invoice_dates[@infotype] = day
            company.odba_store
          end
          if(company_name == company.name \
            || (company_name.nil? && day == company.invoice_date(@infotype)))
            ## work with duplicates
            items = items.collect { |item| item.dup }
            ## adjust the annual fee according to company settings
            adjust_company_fee(company, items)
            ## adjust the fee according to date
            adjust_overlap_fee(day, items)
            ensure_yus_user(company)
            ## first send the invoice 
            ydim_id = send_invoice(invoice_date, email, items, day)
            ## then store it in the database
            create_invoice(email, items, ydim_id)
          elsif((day >> 12) == company.invoice_date(@infotype))
            ## if the date has been set to one year from now,
            ## this invoice has already been sent manually.
            ## store the items anyway to prevent sending a 2-year
            ## invoice on the following day..
            create_invoice(email, items, nil)
          end
        end
      }
    end
    def send_daily_invoices(day, company_name=nil, invoice_date=day)
      items = recent_items(day)
      payable_items = filter_paid(items, day)
      groups = group_by_company(payable_items)
      groups.each { |company, items|
        if(!company.invoice_disabled?(@infotype) \
           && (email = company.invoice_email) \
           && (company_name.nil? || company_name == company.name))
          ## work with duplicates
          items = items.collect { |item| item.dup }
          ## adjust the annual fee according to company settings
          adjust_company_fee(company, items)
          ## adjust the annual fee according to date
          adjust_annual_fee(company, items)
          ensure_yus_user(company)
          ## first send the invoice 
          ydim_id = send_invoice(invoice_date, email, items, day)
          ## then store it in the database
          create_invoice(email, items, ydim_id)
        end
      }
      nil
    end
    def slate_items
      @app.slate(@infotype).items.values.sort_by { |item|
        item.time
      }
    end
  end
end
