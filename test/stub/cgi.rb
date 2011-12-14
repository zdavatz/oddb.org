#!/usr/bin/env ruby
# encoding: utf-8
# CGI -- htmlgrid -- hwyss@ywesee.com	

require 'cgi'

class CGI
  attr_accessor :params
  def initialize throwaway=nil
    extend Html4Tr
    element_init()
    extend HtmlExtension
		extend QueryExtension
    @params = {}
  end
  def cookies
    {}
  end
  def []key
    @params[key]  
  end
  def []=key, value
    @params[key] = value
  end
end
