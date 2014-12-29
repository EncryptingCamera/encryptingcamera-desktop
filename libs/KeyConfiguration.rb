require 'rbnacl'
require 'fileutils'

class KeyConfiguration
  def initialize(config_dir)
    @config_dir = config_dir
    @config_file = File.join(config_dir, "privkey")
  end

  def get_private_key
    key_bytes = File.read(@config_file).force_encoding("BINARY")
    return RbNaCl::PrivateKey.new(key_bytes)
  end

  def get_public_key
    return get_private_key.public_key
  end

  # Re-create the configuration directory with a new private key.
  def create_new!
    if Dir.exist? @config_dir
      # Without :secure, it would follow symlinks and destroy things outside of
      # that folder. See docs for details.
      FileUtils.rm_rf( @config_dir, :secure => true )
    end
    Dir.mkdir(@config_dir, 0700)
    new_private_key = RbNaCl::PrivateKey.generate
    File.open(@config_file, "w") do |f|
      f.write(new_private_key.to_bytes)
    end
  end

end
