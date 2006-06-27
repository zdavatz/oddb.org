#!/usr/bin/env ruby
# View::User::AutoFill -- oddb -- 22.06.2006 -- hwyss@ywesee.com

module ODDB
  module View
    module User
module AutoFill
  def email(model, session=@session)
    input = HtmlGrid::InputText.new(:email, model, @session, self)
    url = @lookandfeel._event_url(:ajax_autofill, {:email => nil})
    if(@session.logged_in?)
      input.set_attribute('disabled', true)
    else
      input.set_attribute('onChange', "autofill(this.form, 'email', '#{url}');")
    end
    input
  end
end
    end
  end
end
