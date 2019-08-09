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
      @os_network = DanarchySys::OpenStack::Networking.new(connection, @settings)
      console
    end

    def console
      menu = Menus.numbered_menu('main')
      Menus.print_menu('main')

      loop do
        print 'command ~: '
        cmd = gets
        cmd = cmd ? cmd.chomp : abort('Exiting!')

        if cmd =~ /^[0-9]*$/
          cmd = menu[cmd.to_i] ? menu[cmd.to_i].keys.first : nil
        end

        if cmd == 'instance'
          InstanceManager.manager(@os_compute, @os_network, @settings)
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
