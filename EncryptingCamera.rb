#!/usr/bin/env ruby

$LOAD_PATH << File.dirname( __FILE__ )

require 'optparse'
require 'libs/SetupCommand.rb'
require 'libs/ShowPublicKeyCommand.rb'
require 'libs/DecryptCommand.rb'

$options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  $options[:setup] = nil
  opts.on( '-s', '--setup', 'Setup private key' ) do
    $options[:setup] = true
  end

  $options[:showpubkey] = nil
  opts.on( '-p', '--show-pubkey', 'Show public key QR' ) do
    $options[:showpubkey] = true
  end

  $options[:decrypt] = nil
  opts.on( '-d', '--decrypt INPUT OUTPUT', 'Decrypt an .encc file') do |file|
    $options[:decrypt] = file
  end
end

def exit_with_message(optparse, msg)
  STDERR.puts "[!] #{msg}"
  STDERR.puts optparse
  exit(false)
end

begin
  optparse.parse!
rescue OptionParser::InvalidOption
  exit_with_message(optparse, "Invalid option")
rescue OptionParser::MissingArgument
  exit_with_message(optparse, "Missing argument")
end

command_count = ([
  $options[:setup],
  $options[:showpubkey],
  $options[:decrypt]
].reject { |c| c.nil? }).length

if command_count > 1
  exit_with_message(optparse, "Only one thing at a time!")
end

command = nil

if $options[:setup]
  command = SetupCommand.new
elsif $options[:showpubkey]
  command = ShowPublicKeyCommand.new
elsif $options[:decrypt]
  if ARGV.length != 1
    exit_with_message(optparse, "Please provide the output path.")
  end
  command = DecryptCommand.new
  command.source = $options[:decrypt]
  command.destination = ARGV[0]
else
  exit_with_message(optparse, "Please specify a command.")
end

command.run()
