require 'rbnacl'
require 'fileutils'
require 'yaml'

class PrivateKeyNotDecryptedError < StandardError
end

class ConfigNotLoadedError < StandardError
end

class WrongPassphraseError < StandardError
end

class ErrorLoadingConfigError < StandardError
end

class ErrorSavingConfigError < StandardError
end

# FIXME: get rid of the unqualified `rescue`s in this class.

class KeyConfiguration

  def initialize(config_dir)
    @config_dir = config_dir
    @config_file = File.join(config_dir, "privkey")
    # This gets set to the private key's bytes only after decryption.
    # If the private key isn't encrypted, load_config sets it.
    @key_bytes = nil
    load_config
  end

  def get_private_key
    ensure_config_loaded
    ensure_private_key_decrypted
    return RbNaCl::PrivateKey.new(@key_bytes)
  end

  def get_public_key
    ensure_config_loaded
    RbNaCl::PublicKey.new( @config["public_key_bytes"] )
  end

  def key_encrypted?
    ensure_config_loaded
    @config["key_encrypted"]
  end

  def decrypt_key(passphrase)
    ensure_config_loaded
    if key_encrypted?
      key = RbNaCl::PasswordHash.scrypt(
        passphrase,
        @config["key_enc_salt"],
        @config["key_enc_ops"],
        @config["key_enc_mem"],
        32
      )
      begin
      box = RbNaCl::SimpleBox.from_secret_key(key)
      @key_bytes = box.decrypt(@config["key_ciphertext"])
      rescue
        raise WrongPassphraseError.new
      end
    else
      # No encryption to remove.
      @key_bytes = @config["key_ciphertext"]
    end
  end

  # Re-create the configuration directory with a new private key.
  def create_new!(passphrase)
    if Dir.exist? @config_dir
      # Without :secure, it would follow symlinks and destroy things outside of
      # that folder. See docs for details.
      FileUtils.rm_rf( @config_dir, :secure => true )
    end
    Dir.mkdir(@config_dir, 0700)
    new_private_key = RbNaCl::PrivateKey.generate
    @config = {}
    if passphrase.nil?
      @config["key_encrypted"] = false
      @config["key_ciphertext"] = new_private_key.to_bytes
    else
      @config["key_encrypted"] = true
      @config["key_enc_salt"] = RbNaCl::Random.random_bytes(
        32
        #RbNaCl::PasswordHash::SCrypt::SALT_BYTES
        # FIXME: It's supposed to be the above, but that doesn't work??
      )
      @config["key_enc_ops"] = 2**22
      @config["key_enc_mem"] = 2**26
      key = RbNaCl::PasswordHash.scrypt(
        passphrase,
        @config["key_enc_salt"],
        @config["key_enc_ops"],
        @config["key_enc_mem"],
        32
      )
      box = RbNaCl::SimpleBox.from_secret_key(key)
      @config["key_ciphertext"] = box.encrypt(new_private_key.to_bytes)
    end
    @config["public_key_bytes"] = new_private_key.public_key.to_bytes
    save_config
  end

  def load_config
    yaml = File.read(@config_file)
    @config = YAML.load(yaml)
    unless key_encrypted?
      decrypt_key(nil)
    end
  rescue
    @config = nil
    raise ErrorLoadingConfigError.new
  end

  def save_config
    ensure_config_loaded
    yaml = YAML.dump(@config)
    File.open(@config_file, "w") do |f|
      f.write(yaml)
    end
  rescue
    raise ErrorSavingConfigError.new
  end

  def ensure_config_loaded
    if @config.nil?
      raise ConfigNotLoadedError.new
    end
  end

  def ensure_private_key_decrypted
    if @key_bytes.nil?
      raise PrivateKeyNotDecryptedError.new
    end
  end


end
