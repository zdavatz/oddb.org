module ODDB
  # next two classes are only needed when run via suite.rb!
  class ConfigStub
    attr_reader :mail_from, :smtp_authtype,
        :smtp_server, :smtp_domain, :smtp_port, :smtp_user, :smtp_pass, :smtp_auth,
        :testenvironment1, :mail_to
    def app_user_agent
      'app_user_agent'
    end
  end
  def ODDB.config
    ConfigStub.new
  end
end