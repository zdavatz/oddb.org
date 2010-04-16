require 'odba/drbwrapper'
require 'remote/package'
require 'util/currency'

module ODDB
  class ReadonlyServer
    def get_currency_rate(symbol)
      ODDB::Currency.rate('CHF', symbol)
    end
    def remote_comparables(package)
      package = ODDB::Remote::Package.new(package)
      sequence = package.sequence
      comparables = []
      atcs = ODBA.cache.retrieve_from_index('atc_index', sequence.atc_code)
      if(atcs.size == 1 && atc = atcs.first)
        atc.sequences.each { |seq|
          if(sequence.comparable?(seq))
            comparables.concat seq.packages.values.select { |pac|
              package.comparable?(pac)
            }
          end
        }
      end
      ODBA::DRbWrapper.new comparables
    end
    def remote_each_atc_class(&block)
      ODDB::AtcClass.odba_extent do |atc|
        block.call ODBA::DRbWrapper.new(atc)
      end
    end
    def remote_each_company(&block) # for migration to ch.oddb.org
      ODDB::Company.odba_extent.each do |comp|
        block.call ODBA::DRbWrapper.new(comp)
      end
      nil # don't try to pass all registrations across DRb-Land
    end
    def remote_each_package(&block)
      ODDB::Package.odba_extent.each do |pac|
        if(pac.public? && !pac.narcotic?)
          block.call ODBA::DRbWrapper.new(pac)
        end
      end
      nil # don't try to pass all registrations across DRb-Land
    end
    def remote_export(name)
      ODDB::Exporter.new(self).export_helper(name) { |path|
        yield path
      }
    end
    def remote_packages(query)
		  seqs = ODBA.cache.retrieve_from_index('sequence_index_exact', query)
      if(seqs.empty?)
        seqs = ODBA.cache.\
          retrieve_from_index('substance_index_sequence', query)
      end
      ODBA::DRbWrapper.new seqs.collect { |seq|
        seq.public_packages
      }.flatten
    end
  end
end
