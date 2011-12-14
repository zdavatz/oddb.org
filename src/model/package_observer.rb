#!/usr/bin/env ruby
# encoding: utf-8
# PackageObserver -- de.oddb.org -- 24.11.2006 -- hwyss@ywesee.com

module ODDB
  module PackageObserver
    attr_reader :packages
    def initialize
      super
      @packages = []
    end
    def add_package(package)
      @packages.push(package)
      @packages.odba_isolated_store
      @packages.last
    end
    def empty?
      @packages.empty?
    end
    def package_count
      @packages.size
    end
    def remove_package(package)
      if(@packages.delete(package))
        @packages.odba_isolated_store
        package
      end
    end
  end
end
