#!/usr/bin/env ruby

$LOAD_PATH << File.dirname( __FILE__ )

require 'libs/KeyConfiguration.rb'
require 'libs/Paths.rb'

ephemeral_private_key = RbNaCl::PrivateKey.generate
ephemeral_public_key = ephemeral_private_key.public_key

keyconfig = KeyConfiguration.new(Paths.config_dir)
destination_public_key = keyconfig.get_public_key

box = RbNaCl::SimpleBox.from_keypair(destination_public_key, ephemeral_private_key)

image_bytes = File.read("./test-image.jpg").force_encoding("BINARY")

File.open("test.encc", "w") do |f|
  f.write("\x01")
  f.write(ephemeral_public_key.to_bytes)
  f.write(box.encrypt(image_bytes))
end
