# encoding: utf-8
module ODDB
	module View
module Captcha
  def challenge
    @challenge ||= @lookandfeel.generate_challenge
  end
  def captcha(model)
    name = "captcha[#{challenge.id}]"
    HtmlGrid::InputText.new(name, model, @session, self)
  end
  def captcha_image(model)
    img = HtmlGrid::Image.new(:file, challenge, @session, self)
    img.attributes["src"] = File.join('', 'resources', 'captchas', challenge.file)
    img
  end
end
	end
end
