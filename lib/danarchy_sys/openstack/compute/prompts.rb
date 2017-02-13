require_relative 'flavors'
require_relative 'images'
require_relative 'instances'
require_relative 'keypairs'

# Prompts for creating a new OpenStack instance
class ComputePrompts
  def self.image(compute)
    image_list = ComputeImages.list_images(compute)
    images = ComputeImages.all_images(compute)
    image_name = 'nil'

    # Get user input (image name) and check if in array.
    print "images: #{image_list.sort}\n"
    until image_list.include?(image_name)
      print 'Which image should we use for this instance?: '
      image_name = gets.chomp
      puts "#{image_name} not found in list. Please enter an option from above." unless image_list.include?(image_name)
    end

    print "Image Name: #{image_name}\n"
    ComputeImages.get_image_by_name(compute, image_name)
  end

  def self.flavor(compute)
    flavor_list = ComputeFlavors.list_flavors(compute)
    flavors = ComputeFlavors.all_flavors(compute)
    flavor_name = 'nil'

    # Create array of RAM sizes to check user input against.
    puts "\nAvailable Instance Flavors:"
    puts sprintf("%-15s %-10s %-10s %0s", 'Name', 'RAM', 'VCPUs', 'Disk')
    flavors.sort_by(&:ram).each do |flavor|
      print sprintf("%-15s %-10s %-10s %0s %0s", flavor.name.split('.')[1], flavor.ram, flavor.vcpus, flavor.disk, "\n")
    end

    # Get user input (flavor name) and check if in array
    until flavor_list.include?(flavor_name)
      print "\nWhich flavor name should we use for this instance?: "
      flavor_name = gets.chomp
      puts "#{flavor_name} not found in list. Please enter an option from above." unless flavor_list.include?(flavor_name)
    end

    print "Flavor Name: #{flavor_name}\n"
    ComputeFlavors.get_flavor(compute, flavor_name)
  end

  def self.keypair(compute)
    keypairs = compute.key_pairs
    keypair_list = []
    keypair = 'nil'

    # create a list of existing keypair names
    keypairs.each do |kp|
      keypair_list.push(kp.name)
    end

    puts "\nExisting keypairs:", keypair_list

    print"\nEnter the name of a keypair above, or enter a new keypair name: "
    keypair_name = gets.chomp
    pemfile = "#{ENV['HOME']}/.ssh/fog_keys/openstack/fog_#{keypair_name}.pem"

    # If keypair does not exist, create it
    unless keypair_list.include?(keypair_name)
      puts "Creating keypair: #{keypair_name}!"
      instance_kp = ComputeKeyPairs.create_keypair(compute, keypair_name, pemfile)
    end

    keypairs = compute.key_pairs
    keypairs.each do |kp|
      keypair = kp if kp.name == keypair_name
    end

    [keypair, pemfile]
  end

  def self.create_instance(compute)
    image = image(compute)
    image_name = image.name
    image_id = image.id

    flavor = flavor(compute)
    flavor_name = flavor.name
    flavor_id = flavor.id

    keypair, pemfile = keypair(compute)
    keypair_name = keypair.name
    puts "Using keypair: #{keypair_name}"

    print "\nWhat should we name the instance?: "
    instance_name = gets.chomp

    until ComputeInstances.check_instance(compute, instance_name) == false
      print "\n#{instance_name} already exists! Try another name: "
      instance_name = gets.chomp
    end

    puts "\nCreating instance: #{instance_name}"
    puts "            Linux: #{image_name}"
    puts "    Instance Size: #{flavor_name}"
    puts "          Keypair: #{keypair_name}"

    print 'Should we continue with creating the instance? (Y/N): '
    continue = gets.chomp

    instance = 'nil'
    if continue =~ /^y(es)?$/i
      puts "Creating instance: #{instance_name}"
      instance = ComputeInstances.create_instance(compute, instance_name, image_id, flavor_id, keypair.name)
      puts "Instance #{instance.name} is ready!"
    else
      puts 'Exiting.'
      exit
    end

    instance
  end
end
