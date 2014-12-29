#!/usr/bin/env ruby

$LOAD_PATH << File.dirname( __FILE__ )

require 'json'
require 'base64'
require 'libs/KeyConfiguration.rb'
require 'libs/Paths.rb'

file = { "version" => nil, "public_key" => nil, "ciphertext" => nil }

ephemeral_private_key = RbNaCl::PrivateKey.generate
ephemeral_public_key = ephemeral_private_key.public_key

keyconfig = KeyConfiguration.new(Paths.config_dir)
destination_public_key = keyconfig.get_public_key

box = RbNaCl::SimpleBox.from_keypair(destination_public_key, ephemeral_private_key)

image_bytes = File.read("./test-image.jpg").force_encoding("BINARY")

file["version"] = 1
file["public_key"] = Base64.strict_encode64(ephemeral_public_key.to_bytes)
file["ciphertext"] = Base64.strict_encode64(box.encrypt(image_bytes))

json = JSON.dump(file)
File.open("test.encc", "w") do |f|
  f.write(json)
end
