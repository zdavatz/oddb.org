#!/usr/bin/env ruby
# View::Admin::SwissmedicSource -- oddb.org -- 03.04.2008 -- hwyss@ywesee.com

module ODDB
  module View
    module Admin
module SwissmedicSource
  def format_source(keys, source, str='')
    keys.each { |key| 
      value = source[key]
      case key
      when :import_date, :registration_date, :expiry_date
        value = value && value.strftime('%d.%m.%Y')
      end
      str << sprintf("%-32s: %s\n", @lookandfeel.lookup(key){ key.to_s }, value)
    }
    str
  end
  def registration_source(registration)
    if(sourced = registration.packages.find { |pac| pac.swissmedic_source })
      keys = [ :import_date, :iksnr, :company, :product_group,
               :index_therapeuticus, :production_science, :registration_date,
               :expiry_date ]
      seqkeys = [ :seqnr, :name_base, :substances, :composition ]
      source = format_source(keys, sourced.swissmedic_source)
      registration.sequences.sort.each { |seqnr, seq|
        source << "\n" << sequence_source(seq, seqkeys)
      }
      source
    else
      registration.source.to_s
    end
  end
  def sequence_source(sequence, keys = nil)
    if(sourced = sequence.packages.values.find { |pac| pac.swissmedic_source })
      keys ||= [ :import_date, :iksnr, :seqnr, :name_base, :company,
                 :product_group, :index_therapeuticus, :production_science,
                 :registration_date, :expiry_date, :substances, :composition ]
      packeys = [ :ikscd, :size, :unit, :ikscat ]
      source = format_source(keys, sourced.swissmedic_source)
      sequence.packages.sort.each { |ikscd, pac| 
        source << "\n" << package_source(pac, packeys)
      }.compact
      source
    else
      sequence.source.to_s
    end
  end
  def package_source(package, keys = nil)
    if(source = package.swissmedic_source)
      keys ||= [ :import_date, :iksnr, :seqnr, :name_base, :company,
                 :product_group, :index_therapeuticus, :production_science,
                 :registration_date, :expiry_date, :ikscd, :size, :unit,
                 :ikscat, :substances, :composition ]
      format_source(keys, source)
    else
      package.source.to_s
    end
  end
end
    end
  end
end
