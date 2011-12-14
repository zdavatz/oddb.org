#!/usr/bin/env ruby
# encoding: utf-8
# DefineEmptyClass -- ODDB -- 28.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'htmlgrid/template'
module SBSM
  class State; end
end
module ODDB
  module State
    module PayPal
      module Checkout; end
    end
    class Global < SBSM::State; end
    module User
      class Global < State::Global; end
      class DownloadExport < State::User::Global; end
    end
    module Companies
      class RootUser; end
      class Global < State::Global; end
      class CompanyResult < State::Companies::Global; end
      class CompanyList < CompanyResult; end
    end
  end
  module View
    class PublicTemplate < HtmlGrid::Template; end
    class ResultTemplate < PublicTemplate; end
  end
end
