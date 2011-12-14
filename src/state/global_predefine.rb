#!/usr/bin/env ruby
# encoding: utf-8
# State::GlobalPredefine -- oddb -- 08.03.2011 -- mhatakeyama@ywesee.com
# State::GlobalPredefine -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'sbsm/state'

module ODDB
  module State
    class Global < SBSM::State; end
    module Analysis
      class Global < State::Global; end
    end
    module Limit; end
    module Admin 
      class Global < State::Global; end
      module Root; end
      module Admin; end
      module CompanyUser; end
      module PowerUser; end
      module PowerLinkUser; end
      module LoginMethods; end
    end
    module Companies
      class Global < State::Global; end
    end
    module Drugs
      class Global < State::Global; end
      class Init < State::Drugs::Global; end
    end
    module Interactions 
      class Global < State::Global; end
    end
    module Substances 
      class Global < State::Global; end
    end
    module User 
      class Global < State::Global; end
    end
    module Doctors
      class Global < State::Global; end
    end
    module Hospitals
      class Global < State::Global; end
    end
    module Migel
      class Global < State::Global; end 
    end
  end
end
