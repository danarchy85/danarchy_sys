#!/usr/bin/env ruby
require 'optparse'
require 'fog/openstack'

# Fog.mock!

module DanarchySys
  module CLI
    module OpenStack
      class Compute
        def initialize
          require_relative 'cli/console_help'
          require_relative 'cli/general'
          puts 'OpenStack -> DreamCompute'
          @os_compute = DanarchySys::OpenStack::Compute.new
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
              @os_compute.create_prompt
              instance_chooser
            elsif cmd == 'delete'
              print 'Are you sure you wish to destroy this instance? (this is permanent!) (Y/N): '
              @os_compute.send(cmd.to_s, instance_name.to_s) if gets.chomp =~ /^y(es)?$/i
              instance_chooser
            else
              response = @os_compute.send(cmd.to_s, instance_name.to_s)
              puts response unless cmd == 'connect'
            end
          end
        end

        def instance_chooser
          instances_numbered = General.array_to_numhash(@os_compute.all_instances)
          instance_name = 'nil'
          instance = 'nil'

          if instances_numbered.empty?
            print 'No running instances were found. Should we create a new one? (Y/N): '
            abort('Exiting!') unless gets.chomp =~ /^y(es)?$/i
            puts 'Creating a new instance...'
            instance = @os_compute.create_prompt
            puts "Working with: #{instance.name}\tStatus: #{instance.state}"
            return instance
          end

          puts 'Available Instances:'
          longest_value = instances_numbered.values.max_by(&:length)
          printf("%0s %-#{longest_value.length}s\n", 'Id', 'Instance Name')
          instances_numbered.each do |id, i_name|
            printf("%0s %-#{longest_value.length}s\n", "#{id}.", i_name)
          end

          # Loop input until instance_name matches existing instances
          until instances_numbered.values.include?(instance_name)
            print 'Which instance should we manage? (leave blank to create a new instance, enter \'exit\' to leave): '
            instance_name = gets.chomp

            abort('Exiting') if instance_name == 'exit'

            if instance_name == ''
              puts 'Creating a new instance...'
              instance = @os_compute.create_prompt
              instance_name = instance.name
              puts "Created instance: #{instance_name}"
            end

            if instance_name =~ /^[0-9]*$/ # select by Id
              until instances_numbered.keys.include?(instance_name)
                print "#{instance_name} is not a valid Id. Enter and Id from above: "
                instance_name = gets.chomp
              end

              instance_name = instances_numbered[instance_name.to_s]
            end

            instance = @os_compute.get_instance(instance_name)
            instances_numbered = General.array_to_numhash(@os_compute.all_instances)
          end

          puts "Working with: #{instance.name}\tStatus: #{instance.state}"
          instance
        end
      end
    end
  end
end
