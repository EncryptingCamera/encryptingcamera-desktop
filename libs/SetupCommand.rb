require 'libs/Paths.rb'
require 'libs/KeyConfiguration.rb'

class SetupCommand
  def run
    if Dir.exist? Paths.config_dir
      puts "The configuration directory already exists."
      puts "This will destroy your private key and create a new one."
      print "Continue? [y/N] "
      choice = gets.chomp
      if choice.downcase != "y"
        # STOP!
        return
      end
    end

    key_config = KeyConfiguration.new(Paths.config_dir)
    key_config.create_new!

  rescue
    STDERR.puts "Setup failed."
  end
end
