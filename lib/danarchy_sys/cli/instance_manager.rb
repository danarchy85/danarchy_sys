require_relative 'instance_manager/prompts_create_instance'
require_relative 'instance_manager/instance_status'

class InstanceManager
  def self.manager(os_compute)
    comp_inst = os_compute.instances
    puts 'Instance Manager: enter \'help\' to view available commands or \'main\' for the main menu.'
    menu = Menus.numbered_menu('instance')
    instance = false

    loop do
      while instance == false
        instance = chooser(os_compute)
        return Menus.print_menu('main') if instance == 'main'
      end

      print "#{instance.name} ~: "
      cmd = gets.chomp

      next if cmd.empty?
      abort('Exiting!') if cmd == 'exit'

      if cmd =~ /^[0-9]*$/
        menu[cmd.to_i].map { |k, v| cmd = k } if menu.keys.include? cmd.to_i
      end

      if cmd == 'help'
        Menus.print_menu('instance')
      elsif cmd == 'main'
        return Menus.print_menu('main')
      elsif cmd == 'chooser'
        instance = chooser(os_compute)
      elsif cmd == 'create'
        PromptsCreateInstance.create_instance(os_compute, 'nil')
        instance = chooser(os_compute)
      elsif cmd == 'delete'
        print "Are you sure you wish to delete instance: #{instance.name}? (this is permanent!) (Y/N): "
        delete = comp_inst.delete_instance(instance.name) if gets.chomp =~ /^y(es)?$/i
        if delete == true
          puts "#{instance.name} has been deleted! Returning to the instance chooser."
          instance = chooser(os_compute)
        else
          puts "#{instance.name} was not deleted!"
        end
      elsif cmd == 'status'
        printf("%#{instance.name.size}s %0s %0s\n", instance.name, ' => ', instance.state)
      elsif %w(pause unpause suspend resume start stop).include?(cmd.to_s)
        status = instance.state

        if cmd =~ /e$/
          print "#{cmd.gsub(/e$/, 'ing')} #{instance.name} ."
        else
          print "#{cmd}ing #{instance.name} ."
        end

        response = comp_inst.send(cmd.to_s, instance.name.to_s)
        if response == false
          puts "\nInvalid action for #{instance.name}'s current status!"
          next
        end

        until status != instance.state
          instance = os_compute.instances.get_instance(instance.name)
          sleep(3)
          print ' .'
        end

        printf("\n%#{instance.name.size}s %0s %0s\n", instance.name, ' => ', instance.state)
      elsif cmd == 'rebuild'
        print "Should we rebuild #{instance.name}? (Y/N): "
        if gets.chomp =~ /^y(es)?$/i
          image = PromptsCreateInstance.image(os_compute.images)
          instance.rebuild(image.id, instance.name)

          print "Rebuilding #{instance.name} with #{image.name}"
          instance = os_compute.instances.get_instance(instance.name)
          until instance.state == 'ACTIVE'
            instance = os_compute.instances.get_instance(instance.name)
            sleep(3)
            print ' .'
          end

          addrs = os_compute.instances.get_public_addresses(instance.name)
          addrs.each { |ip| `ssh-keygen -R #{ip} &>/dev/null` }
          puts "\nRebuild successful!"
        else
          puts "Not rebuilding #{instance.name} at this time."
        end
      elsif cmd == 'connect'
        if instance.state == 'ACTIVE'
          connect = os_compute.ssh(instance.name)
          puts connect if connect != true
        else
          puts "Unable to connect: #{instance.name} is not running!"
        end
      else
        Menus.print_menu('instance')
        puts "\nCommand \'#{cmd}\' not available. Enter a command from above."
      end

      return Menus.print_menu('main') if instance == 'main'
    end
  end

  def self.chooser(os_compute)
    comp_inst = os_compute.instances
    instances = comp_inst.all_instances
    instances_numhash = Helpers.objects_to_numhash(comp_inst.all_instances)
    instance_name = nil
    instance = nil

    # Create a new instances if none exist
    if instances.empty?
      print 'No existing instances were found. Should we create a new one? (Y/N): '
      abort('Exiting!') unless gets.chomp =~ /^y(es)?$/i
      instance = PromptsCreateInstance.create_instance(os_compute, 'nil')
      puts "Working with: #{instance.name}\tStatus: #{instance.state}"
      return instance
    end

    puts 'Available instances:'
    istatus = InstanceStatus.new(os_compute)
    istatus.all_instances(instances)

    # Loop input until an existing instance is selected
    print 'Enter an instance to manage or enter a name for a new instance: '

    until comp_inst.check_instance(instance_name) == true
      instance_name = gets.chomp

      until instance_name.empty? == false
        print 'Input was blank! Enter an instance or Id from above: '
        instance_name = gets.chomp
      end

      abort('Exiting') if instance_name == 'exit'
      return 'main' if instance_name == 'main'

      # Accept instance Id as an entry
      if instance_name =~ /^[0-9]*$/
        until instances_numhash.keys.include?(instance_name.to_i)
          print "#{instance_name} is not a valid Id. Enter an Id from above: "
          instance_name = gets.chomp
        end

        instance_name = instances_numhash[instance_name.to_i][:name].to_s
      end

      unless comp_inst.check_instance(instance_name) == true
        print "#{instance_name} is not a valid instance.
Should we create a new instance named #{instance_name}? (Y/N): "

        if gets.chomp =~ /^y(es)?$/i
          PromptsCreateInstance.create_instance(os_compute, instance_name)
        else
          puts "Not creating new instance: #{instance_name}."
          return false
        end
      end
    end

    instance = comp_inst.get_instance(instance_name)
    Menus.print_menu('instance')
    puts "Managing instance: #{instance_name}\tStatus: #{instance.state}"
    instance
  end
end
