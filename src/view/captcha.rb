#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Captcha -- oddb.org -- 16.12.2011 -- mhatakeyama@ywesee.com

module ODDB
	module View
module Captcha
  def challenge
  end
  def captcha(model)
    name = "captcha"
    HtmlGrid::InputText.new(name, model, @session, self)
  end
  def captcha_image(model)
  end
end
	end
end
