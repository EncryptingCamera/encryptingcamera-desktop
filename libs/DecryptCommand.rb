# encoding: US-ASCII
require 'libs/Paths.rb'
require 'libs/KeyConfiguration.rb'
require 'json'
require 'base64'

class DecryptCommand

  VER1_REGEXP = Regexp.compile("\\A(\x01)([\x00-\xFF]{32})([\x00-\xFF]*)\\Z")

  attr_accessor :source, :destination

  def run
    file_contents = File.read(@source).force_encoding("BINARY")

    match = VER1_REGEXP.match(file_contents)

    if match
      public_key_bytes = match[2]
      ciphertext_bytes = match[3]
      sender_public_key = RbNaCl::PublicKey.new( public_key_bytes )

      keyconfig = KeyConfiguration.new( Paths.config_dir )
      our_private_key = keyconfig.get_private_key

      box = RbNaCl::SimpleBox.from_keypair(sender_public_key, our_private_key)
      plaintext = box.decrypt( ciphertext_bytes )

      File.open( @destination, "w") do |f|
        f.write(plaintext)
      end
    else
      STDERR.puts "Unsupported version."
      exit(false)
    end
  end
end
