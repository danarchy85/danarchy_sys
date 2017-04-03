
class Instance
  def self.manager(os_compute)
    puts 'Instance Manager: enter \'help\' to view available commands or \'back\' for the main menu.'
    menu = Menus.numbered_menu('instance')
    instance = false

    loop do
      while instance == false
        instance = chooser(os_compute)
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
      elsif cmd == 'back'
        return Menus.print_menu('main')
      elsif cmd == 'chooser'
        instance = chooser(os_compute)
      elsif cmd == 'create'
        os_compute.create_instance_prompt('nil')
        instance = chooser(os_compute)
      elsif cmd == 'delete'
        print "Are you sure you wish to delete instance: #{instance.name}? (this is permanent!) (Y/N): "
        delete = os_compute.send(cmd.to_s, instance.name.to_s) if gets.chomp =~ /^y(es)?$/i
        if delete == true
          puts "#{instance.name} has been deleted! Returning to the instance chooser."
          instance = chooser(os_compute)
        else
          puts "#{instance.name} could not be deleted! Returning to the instance chooser."
          instance = chooser(os_compute)
        end
      elsif %w(status connect pause unpause suspend resume start stop).include?(cmd.to_s)
        response = os_compute.send(cmd.to_s, instance.name.to_s)
        puts response unless cmd == 'connect'
      else
        Menus.print_menu('instance')
        puts "\nCommand \'#{cmd}\' not available. Enter a command from above."
      end
    end
  end

  def self.chooser(os_compute)
    instances = Helpers.objects_to_numhash(os_compute.all_instances)
    instance_name = 'nil'

    # Create a new instances if none exist
    if instances.empty?
      print 'No existing instances were found. Should we create a new one? (Y/N): '
      abort('Exiting!') unless gets.chomp =~ /^y(es)?$/i
      instance = os_compute.create_instance_prompt
      puts "Working with: #{instance.name}\tStatus: #{instance.state}"
      return instance
    end

    # Display existing instances in numbered hash (scale name col by instance name size)
    iname_sizes = []
    instances.each_value { |i| iname_sizes.push(i[:name].length) }
    puts 'Available instances:'
    printf("%0s %-#{iname_sizes.max}s %0s\n", 'Id', 'Instance Name', 'Status')
    instances.each do |id, instance|
      printf("%0s. %-#{iname_sizes.max}s %0s\n", id, instance[:name], instance[:state])
    end

    # Loop input until an existing instance is selected
    print 'Enter an instance to manage or enter a name for a new instance: '

    until Helpers.check_nested_hash_value(instances, :name, instance_name) == true
      instance_name = gets.chomp

      until instance_name.empty? == false
        print 'Input was blank! Enter an instance or Id from above: '
        instance_name = gets.chomp
      end

      abort('Exiting') if instance_name == 'exit'

      # Accept instance Id as an entry
      if instance_name =~ /^[0-9]*$/
        until instances.keys.include?(instance_name.to_i)
          print "#{instance_name} is not a valid Id. Enter an Id from above: "
          instance_name = gets.chomp
        end

        instance_name = instances[instance_name.to_i][:name].to_s
      end

      unless Helpers.check_nested_hash_value(instances, :name, instance_name) == true
        print "#{instance_name} is not a valid instance.
Should we create a new instance named #{instance_name}? (Y/N): "

        if gets.chomp =~ /^y(es)?$/i
          return os_compute.create_instance_prompt(instance_name)
        else
          puts "Not creating new instance: #{instance_name}."
          return false
        end
      end
    end

    status = os_compute.status(instance_name)
    Menus.print_menu('instance')
    puts "Managing instance: #{instance_name}\tStatus: #{status}"
    os_compute.get_instance(instance_name)
  end
end
