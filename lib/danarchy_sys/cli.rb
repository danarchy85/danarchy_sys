
require 'optparse'
require 'fog/openstack'
require_relative '../danarchy_sys'

module DanarchySys
  module CLI
    module OpenStack
      class Compute
        def initialize
          require_relative 'cli/console_help'
          require_relative 'cli/providers'
          require_relative 'cli/instance'
          
          provider = Providers.chooser
          puts "OpenStack -> #{provider}"
          @os_compute = DanarchySys::OpenStack::Compute.new provider
          instance_chooser
        end

        def instance_chooser
          instance = Instance.chooser(@os_compute)
          if instance == false
            puts "\nReturning to Instance Chooser"
            instance = Instance.chooser(@os_compute)
          end
          console_help('commands')
          puts "\nWorking with: #{instance.name}\tStatus: #{instance.state}"
          console(instance.name)
        end

        def console(instance_name)
          puts 'Enter \'help\' for all available commands.'
          loop do
            print 'command ~: '
            cmd = gets.chomp

            next if cmd == ''
            abort('Exiting!') if cmd == 'exit'

            if %w(help commands).include?(cmd.to_s)
              console_help(cmd.to_s)
            elsif cmd == 'chooser'
              instance_chooser
            elsif cmd == 'create'
              @os_compute.create_instance_prompt('nil')
              instance_chooser
            elsif cmd == 'destroy'
              print 'Are you sure you wish to destroy this instance? (this is permanent!) (Y/N): '
              destroy = @os_compute.send(cmd.to_s, instance_name.to_s) if gets.chomp =~ /^y(es)?$/i
              if destroy == true
                puts "#{instance_name} has been destroyed! Returning to the instance chooser."
                instance_chooser
              else
                puts "#{instance_name} could not be destroyed! Returning to the instance chooser."
                instance_chooser
              end
            elsif %w(status connect pause unpause suspend resume start stop destroy).include?(cmd.to_s)
              response = @os_compute.send(cmd.to_s, instance_name.to_s)
              puts response unless cmd == 'connect'
            else
              console_help('commands')
              puts "\nCommand \'#{cmd}\' not available. Enter a command from above."
            end
          end
        end
      end
    end
  end
end
