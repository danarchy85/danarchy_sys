
class Instance
  def self.chooser(os_compute)
    instances = Helpers.objects_to_numhash(os_compute.all_instances)
    instance_name = 'nil'

    # Create a new instances if none exist
    if instances.empty?
      print 'No existing instances were found. Should we create a new one? (Y/N): '
      abort('Exiting!') unless gets.chomp =~ /^y(es)?$/i
      instance = os_compute.create_prompt
      puts "Working with: #{instance.name}\tStatus: #{instance.state}"
      return instance
    end

    # Display existing instances in numbered hash (scale name col by instance name size)
    iname_sizes = []
    instances.each_value { |i| iname_sizes.push(i[:name].length) }
    puts 'Available instances:'
    printf("%0s %-#{iname_sizes.max}s %0s\n", 'Id', 'Instance Name', 'Status')
    instances.each do |id, instance|
      printf("%0s %-#{iname_sizes.max}s %0s\n", "#{id}.", instance[:name], instance[:state])
    end

    # Loop input until an existing instance is selected
    print 'Enter an instance to manage or enter a name for a new instance. (enter \'exit\' to leave): '

    until Helpers.check_nested_hash_value(instances, :name, instance_name) == true
      instance_name = gets.chomp

      until instance_name.empty? == false
        print 'Input was blank! Enter an instance or Id from above: '
        instance_name = gets.chomp
      end

      abort('Exiting') if instance_name == 'exit'

      # Accept instance Id as an entry
      if instance_name =~ /^[0-9]*$/
        until instances.keys.include?(instance_name)
          print "#{instance_name} is not a valid Id. Enter an Id from above: "
          instance_name = gets.chomp
        end

        instance_name = instances[instance_name.to_s][:name].to_s
      end

      unless Helpers.check_nested_hash_value(instances, :name, instance_name) == true
        print "#{instance_name} is not a valid instance.
Should we create a new instance named #{instance_name}? (Y/N): "

        if gets.chomp =~ /^y(es)?$/i
          return os_compute.create_instance_prompt(instance_name)
        else
          puts 'Not creating a new instance.'
          chooser(os_compute)
        end
      end
    end

    os_compute.get_instance(instance_name)
  end
end
