require "yaml"

module ODDB
  class SwiyuRoles
    CONFIG_PATH = File.expand_path("../../etc/swiyu_roles.yml", __dir__)

    def self.instance
      @instance ||= new
    end

    def self.reload!
      @instance = new
    end

    def initialize(path = CONFIG_PATH)
      @config = YAML.safe_load(File.read(path), permitted_classes: []) || {}
      @users = @config["users"] || {}
    end

    def accepted_issuer_did
      @config["accepted_issuer_did"]
    end

    DEFAULT_CONFIG = {
      "roles" => ["org.oddb.PowerUser"],
      "permissions" => [
        {"action" => "login", "key" => "org.oddb.PowerUser"},
        {"action" => "view", "key" => "org.oddb"}
      ]
    }.freeze

    def user_config(gln)
      @users[gln.to_s] || DEFAULT_CONFIG
    end

    def roles_for(gln)
      user_config(gln).dig("roles") || []
    end
  end
end
