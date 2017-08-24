
# CLI Prompt to create a new instance
class PromptsCreateInstance
  def self.create_instance(os_compute, instance_name)
    comp_inst = os_compute.compute_instances
    comp_imgs = os_compute.compute_images
    comp_flvs = os_compute.compute_flavors
    comp_keys = os_compute.compute_keypairs

    # Prompt for and check that instance_name is unused
    if instance_name == 'nil'
      print "\nWhat should we name the instance?: "
      instance_name = gets.chomp
    end

    # Make sure instance_name isn't already in use
    until comp_inst.check_instance(instance_name) == false
      print "\n#{instance_name} already exists! Try another name: "
      instance_name = gets.chomp
    end

    puts "Creating instance: #{instance_name}"

    # Prompt for image
    puts "\nSelect an image (operating system) for #{instance_name}"
    image = PromptsCreateInstance.image(comp_imgs)

    # Prompt for flavor
    puts "\nSelect a flavor (instance size) for #{instance_name}"
    flavor = PromptsCreateInstance.flavor(comp_flvs)

    # Prompt for keypair
    puts "\nSelect a keypair (SSH key) for #{instance_name}"
    keypair = PromptsCreateInstance.keypair(comp_keys)

    # Print summary and prompt to continue
    puts "\nInstance Name: #{instance_name}"
    puts "        Linux: #{image.name}"
    puts "Instance Size: #{flavor.name}"
    puts "      Keypair: #{keypair.name}"

    print 'Should we continue with creating the instance? (Y/N): '
    instance = 'nil'
    continue = gets.chomp

    if continue =~ /^y(es)?$/i
      puts "Creating instance: #{instance_name}"
      instance = comp_inst.create_instance(instance_name, image.id, flavor.id, keypair.name)
    else
      puts "Abandoning creation of #{instance_name}"
      return false
    end

    instance_check = comp_inst.check_instance(instance_name)

    if instance_check == true
      puts "Instance #{instance.name} is ready!"
      return instance
    else
      raise "Error: Could not create instance: #{instance_name}" if instance_check == false
    end
  end

  def self.image(comp_imgs)
    images_numbered = Helpers.array_to_numhash(comp_imgs.list_images)
    image_name = 'nil'

    # List available images in a numbered hash.
    puts "\nAvailable Images:"
    i_name_length = Helpers.hash_largest_value(images_numbered).length
    printf("%0s %-#{i_name_length}s\n", 'Id', 'Image')
    images_numbered.each do |id, i_name|
      printf("%0s %-#{i_name_length}s\n", "#{id}.", i_name)
    end

    # Loop input until existing image is selected
    print 'Which image should we use for this instance?: '
    until images_numbered.values.include?(image_name)
      image_name = gets.chomp

      if image_name =~ /^[0-9]*$/
        until images_numbered.keys.include?(image_name.to_i)
          print "#{image_name} is not a valid Id. Enter an Id from above: "
          image_name = gets.chomp
        end

        image_name = images_numbered[image_name.to_i]
      end

      image_check = images_numbered.values.include?(image_name)
      print "#{image_name} is not a valid image. Please enter an option from above: " if image_check == false
    end

    print "Image Name: #{image_name}\n"
    comp_imgs.get_image_by_name(image_name)
  end

  def self.flavor(comp_flvs)
    flavors = Helpers.objects_to_numhash(comp_flvs.all_flavors.sort_by(&:ram))
    flavor_name = 'nil'

    puts "\nAvailable Instance Flavors:"
    puts sprintf("%0s %-15s %-10s %-10s %0s", 'Id', 'Name', 'RAM', 'VCPUs', 'Disk')
    flavors.each do |id, flavor|
      print sprintf("%0s %-15s %-10s %-10s %0s\n",
                    "#{id}.", flavor[:name].split('.')[1], flavor[:ram], flavor[:vcpus], flavor[:disk])
    end

    print 'Which flavor should we use for this instance?: '
    flavor_check = false

    until flavor_check == true
      flavor_name = gets.chomp

      if flavor_name =~ /^[0-9]*$/
        until flavors.keys.include?(flavor_name.to_i)
          print "#{flavor_name} is not a valid Id. Enter an Id from above: "
          flavor_name = gets.chomp
        end

        flavor_name = flavors[flavor_name.to_i][:name].split('.')[1]
      end
      
      flavors.each_value do |flavor|
        flavor_check = true if flavor[:name].end_with?(flavor_name)
      end

      print "#{flavor_name} is not a valid flavor. Please enter an option from above: " if flavor_check == false
    end

    print "Flavor Name: #{flavor_name}\n"
    comp_flvs.get_flavor(flavor_name)
  end

  def self.keypair(comp_keys)
    keypairs = Helpers.objects_to_numhash(comp_keys.all_keypairs)
    keypair_name = 'nil'

    # List available keypairs
    puts "\nAvailable Keypairs:"
    print sprintf("%0s %-15s\n", 'Id', 'KeyPair Name')
    keypairs.each do |id, key|
      print sprintf("%0s %-15s\n", "#{id}.", key[:name])
    end

    # Loop input until existing flavor is selected or create a new one
    print 'Enter a keypair to use for this instance or enter a name for a new keypair : '
    keypair_check = false

    until keypair_check == true
      keypair_name = gets.chomp

      # Accept keypair Id as an entry
      if keypair_name =~ /^[0-9]*$/
        until keypairs.keys.include?(keypair_name.to_i)
          print "#{keypair_name} is not a valid Id.
Enter an Id from above, or \'return\' to restart keypair selection. : "
          keypair_name = gets.chomp
          return keypair(settings, compute) if keypair_name == 'return'
        end

        keypair_name = keypairs[keypair_name.to_i][:name]
      end

      keypair_check = Helpers.check_nested_hash_value(keypairs, :name, keypair_name)

      if keypair_check == false
        print "#{keypair_name} is not an existing keypair.
Should we create a new keypair named #{keypair_name}? (Y/N): "

        if gets.chomp =~ /^y(es)?$/i
          puts "Creating keypair: #{keypair_name}!"
          return comp_keys.create_keypair(keypair_name)
        else
          print 'Please enter an option from above: '
        end
      end
    end

    comp_keys.get_keypair(keypair_name)
  end
end
