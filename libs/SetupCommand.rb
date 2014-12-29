require 'libs/Paths.rb'
require 'libs/KeyConfiguration.rb'
require 'io/console'

class SetupCommand
  def run
    if Dir.exist? Paths.config_dir
      puts "The configuration directory already exists."
      puts "This will destroy your private key and create a new one."
      print "Continue? [y/N] "
      choice = STDIN.gets.chomp
      if choice.downcase != "y"
        # STOP!
        return
      end
    end

    puts "Your private key will be protected with a passphrase."
    print "Passphrase: "
    passphrase = STDIN.noecho(&:gets).chomp
    print "\n"
    print "Repeat passphrase: "
    passphrase2 = STDIN.noecho(&:gets).chomp
    print "\n"
    if passphrase != passphrase2
      puts "You didn't type the same thing twice. Try again."
      return
    end

    if passphrase.empty?
      puts "WARNING: Your key is not protected with a passphrase!"
      passphrase = nil
    end

    key_config = KeyConfiguration.new(Paths.config_dir)
    key_config.create_new!(passphrase)

  #rescue
  #  STDERR.puts "Setup failed."
  end
end
