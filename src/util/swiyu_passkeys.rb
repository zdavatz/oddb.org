require "json"
require "fileutils"
require "securerandom"
require "time"

module ODDB
  # Passkeys (WebAuthn), die ein Nutzer nach einem swiyu-Login einrichten
  # kann. Ein Passkey gehoert zu einer GLN und gilt nur so lange wie der
  # swiyu-Nachweis, mit dem er eingerichtet wurde (valid_until = exp des
  # SD-JWT). Jeder neue swiyu-Login setzt valid_until aller Passkeys dieser
  # GLN auf das exp des gerade vorgelegten Nachweises.
  #
  # Gespeichert wird als JSON-Datei (chmod 600). Sie enthaelt nur oeffentliche
  # Schluessel, aber auch Namen und GLN - deshalb nicht im Repo.
  class SwiyuPasskeys
    STORE_PATH = File.expand_path("../../data/swiyu/passkeys.json", __dir__)

    def self.instance
      @instance ||= new
    end

    def initialize(path = STORE_PATH)
      @path = path
      @mutex = Mutex.new
    end

    # Stabile, nicht sprechende WebAuthn-User-ID pro GLN (base64url).
    def user_handle(gln)
      update do |data|
        data["users"][gln] ||= SecureRandom.urlsafe_base64(32, false)
      end
    end

    def add(credential_id:, public_key:, sign_count:, gln:, first_name:, last_name:, valid_until:, label: nil)
      now = Time.now.utc.iso8601
      update do |data|
        data["credentials"][credential_id] = {
          "public_key" => public_key,
          "sign_count" => sign_count.to_i,
          "gln" => gln,
          "first_name" => first_name,
          "last_name" => last_name,
          "valid_until" => valid_until.utc.iso8601,
          "label" => label,
          "created_at" => now,
          "last_used_at" => nil
        }
      end
    end

    def find(credential_id)
      read["credentials"][credential_id]
    end

    def for_gln(gln)
      read["credentials"].select { |_, c| c["gln"] == gln }
    end

    def valid?(record, now = Time.now)
      !record.nil? && Time.parse(record["valid_until"]) > now
    end

    def touch(credential_id, sign_count)
      update do |data|
        if (record = data["credentials"][credential_id])
          record["sign_count"] = sign_count.to_i
          record["last_used_at"] = Time.now.utc.iso8601
        end
      end
    end

    # Neuer swiyu-Login: Gueltigkeit an den aktuellen Nachweis koppeln.
    def renew(gln, valid_until)
      update do |data|
        data["credentials"].each_value do |c|
          c["valid_until"] = valid_until.utc.iso8601 if c["gln"] == gln
        end
      end
    end

    def delete(credential_id)
      update { |data| !data["credentials"].delete(credential_id).nil? }
    end

    def delete_gln(gln)
      update do |data|
        before = data["credentials"].size
        data["credentials"].delete_if { |_, c| c["gln"] == gln }
        before - data["credentials"].size
      end
    end

    def purge_expired(now = Time.now)
      update do |data|
        before = data["credentials"].size
        data["credentials"].delete_if { |_, c| !valid?(c, now) }
        before - data["credentials"].size
      end
    end

    def all
      read["credentials"]
    end

    private

    def read
      @mutex.synchronize { load }
    end

    def update
      @mutex.synchronize do
        data = load
        result = yield data
        save(data)
        result
      end
    end

    def load
      return empty unless File.exist?(@path)
      data = JSON.parse(File.read(@path))
      empty.merge(data)
    end

    def empty
      {"users" => {}, "credentials" => {}}
    end

    # Atomar schreiben, damit ein Absturz mitten im Schreiben keine
    # halbe Datei hinterlaesst.
    def save(data)
      FileUtils.mkdir_p(File.dirname(@path), mode: 0o700)
      tmp = "#{@path}.#{Process.pid}.tmp"
      File.open(tmp, File::WRONLY | File::CREAT | File::TRUNC, 0o600) do |f|
        f.write(JSON.pretty_generate(data))
      end
      File.rename(tmp, @path)
    end
  end
end
