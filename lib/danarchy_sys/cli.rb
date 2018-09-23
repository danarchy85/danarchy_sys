require_relative 'cli/menus'
require_relative 'cli/accounts'
require_relative 'cli/instance_manager'
require_relative 'cli/keypair_manager'

module DanarchySys
  class CLI
    def initialize
      danarchysys_config = DanarchySys::ConfigManager::Config.new
      account = Accounts.chooser(danarchysys_config)
      connection = danarchysys_config[:accounts][account]
      puts "OpenStack -> #{account}"
      @settings   = danarchysys_config[:global_settings]
      @os_compute = DanarchySys::OpenStack::Compute.new(connection, @settings)
      console
    end

    def console
      menu = Menus.numbered_menu('main')
      Menus.print_menu('main')

      loop do
        print 'command ~: '
        cmd = gets.chomp

        next if cmd.empty?
        if cmd =~ /^[0-9]*$/
          menu[cmd.to_i].map { |k, v| cmd = k } if menu.keys.include? cmd.to_i
        end

        if cmd == 'instance'
          InstanceManager.manager(@os_compute, @settings)
        elsif cmd == 'keypair'
          KeypairManager.manager(@os_compute)
        elsif cmd == 'help'
          Menus.print_menu('main')
        elsif cmd == 'exit'
          abort('Exiting!')
        else
          Menus.print_menu('main')
          puts "\nCommand \'#{cmd}\' not available. Enter a command from above."
        end
      end
    end
  end
end
