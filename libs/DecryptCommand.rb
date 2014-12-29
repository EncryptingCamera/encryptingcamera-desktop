require 'libs/Paths.rb'
require 'libs/KeyConfiguration.rb'
require 'json'
require 'base64'

class DecryptCommand
  attr_accessor :source, :destination
  def run
    json = File.read(@source)
    parsed = JSON.parse(json)

    if parsed["version"] == 1
      keyconfig = KeyConfiguration.new( Paths.config_dir )
      our_private_key = keyconfig.get_private_key

      public_key_binary = Base64.strict_decode64( parsed["public_key"] )
      ciphertext_binary = Base64.strict_decode64( parsed["ciphertext"] )

      sender_public_key = RbNaCl::PublicKey.new( public_key_binary )
      box = RbNaCl::SimpleBox.from_keypair(sender_public_key, our_private_key)
      plaintext = box.decrypt( ciphertext_binary )

      File.open( @destination, "w") do |f|
        f.write(plaintext)
      end
    else
      STDERR.puts "Unsupported version."
      exit(false)
    end
  end
end
