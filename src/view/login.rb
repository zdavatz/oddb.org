#!/usr/bin/env ruby
# LoginView -- oddb -- hwyss@ywesee.com

require 'view/publictemplate'
require 'view/logohead'
require 'view/logincomposite'

module ODDB
  class LoginView < PublicTemplate
		CONTENT = LoginComposite
		HEAD = LogoHead
  end
end
