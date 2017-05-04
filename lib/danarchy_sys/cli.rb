
require 'optparse'
require 'fog/openstack'
require_relative '../danarchy_sys'

module DanarchySys
  class CLI
    def initialize
      require_relative 'cli/menus'
      require_relative 'cli/providers'
      require_relative 'cli/instance'

      provider = Providers.chooser
      puts "OpenStack -> #{provider}"
      @os_compute = DanarchySys::OpenStack::Compute.new provider
      console
    end

    def instance_chooser
      inst_mgr = Instance.new(@os_compute)
      instance = inst_mgr.chooser

      until instance != false
        puts "\nReturning to Instance Chooser"
        instance = inst_mgr.chooser
      end

      menus('main')
      puts "\nWorking with: #{instance.name}\tStatus: #{instance.state}"
      console(instance.name)
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
          Instance.manager(@os_compute)
        elsif cmd == 'keypair'
          puts 'Keypair Manager not yet implemented!'
          # Keypair.manager(@os_compute)
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
