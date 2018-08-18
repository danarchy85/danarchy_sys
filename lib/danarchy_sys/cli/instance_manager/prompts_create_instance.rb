
# CLI Prompt to create a new instance
class PromptsCreateInstance
  def initialize(os_compute, settings)
    @os_compute = os_compute
    @settings = settings
  end

  def create_instance(instance_name)
    # Prompt for and check that instance_name is unused
    if instance_name == nil
      print "\nWhat should we name the instance?: "
      instance_name = gets.chomp
    end

    # Make sure instance_name isn't already in use
    until @os_compute.instances.check_instance(instance_name) == false
      print "\n#{instance_name} already exists! Try another name: "
      instance_name = gets.chomp
    end

    puts "Creating instance: #{instance_name}"

    # Prompt for image
    puts "\nSelect an image (operating system) for #{instance_name}"
    image = self.image

    # Prompt for flavor
    puts "\nSelect a flavor (instance size) for #{instance_name}"
    flavor = self.flavor

    # Prompt for keypair
    puts "\nSelect a keypair (SSH key) for #{instance_name}"
    keypair = self.keypair

    # Prompt for userdata
    print "\nEnter a path to userdata for #{instance_name} or leave blank for no userdata: "
    file, userdata = self.userdata

    # Print summary and prompt to continue
    puts "\n================= Instance Summary ==================="
    puts "\nInstance Name: #{instance_name}"
    puts "        Linux: #{image.name}"
    puts "Instance Size: #{flavor.name}"
    puts "      Keypair: #{keypair.name}"
    puts "     UserData: #{file}"
    puts "\n --- UserData --- \n#{userdata}\n --- End UserData ---\n" if userdata
    puts "\n=============== End Instance Summary ================="
    print 'Should we continue with creating the instance? (Y/N): '
    instance = nil
    continue = gets.chomp

    if continue =~ /^y(es)?$/i
      puts "Creating instance: #{instance_name}"
      instance = @os_compute.instances.create_instance(instance_name, image.id, flavor.id, keypair.name, userdata)
    else
      puts "Abandoning creation of #{instance_name}! Returning to chooser."
      instance = nil
    end

    instance_check = instance ? @os_compute.instances.check_instance(instance_name) : false
    if !instance
      return false
    elsif instance_check == true
      puts "Instance #{instance.name} is ready!"
      return instance
    elsif instance_check == false
      puts "Error: Could not create instance: #{instance_name}"
    end

    instance
  end

  def image
    images_numbered = Helpers.array_to_numhash(@os_compute.images.all_images)

    # List available images in a numbered hash.
    puts "\nAvailable Images:"
    i_name_length = images_numbered.values.collect{|i| i.name}.max.size
    printf("%0s %-#{i_name_length}s\n", 'Id', 'Image')
    images_numbered.each do |id, image|
      printf("%0s %-#{i_name_length}s\n", "#{id}.", image.name)
    end

    image_name = item_chooser(images_numbered, 'image')
    print "Image Name: #{image_name}\n"
    @os_compute.images.get_image_by_name(image_name)
  end

  def flavor
    flavors_numbered = Helpers.array_to_numhash(@os_compute.flavors.all_flavors.sort_by(&:ram))

    puts "\nAvailable Instance Flavors:"
    puts sprintf("%0s %-15s %-10s %-10s %0s", 'Id', 'Name', 'RAM', 'VCPUs', 'Disk')
    flavors_numbered.each do |id, flavor|
      print sprintf("%0s %-15s %-10s %-10s %0s\n",
                    "#{id}.", flavor.name.split('.')[1], flavor.ram, flavor.vcpus, flavor.disk)
    end

    flavor_name = item_chooser(flavors_numbered, 'flavor')
    print "Flavor Name: #{flavor_name.split('.')[1]}\n"
    @os_compute.flavors.get_flavor_by_name(flavor_name)
  end

  def keypair
    keypairs = Helpers.objects_to_numhash(@os_compute.keypairs.all_keypairs)
    keypair_name = nil

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
          return @os_compute.keypairs.create_keypair(keypair_name)
        else
          print 'Please enter an option from above: '
        end
      end
    end

    @os_compute.keypairs.get_keypair(keypair_name)
  end

  def userdata
    userdata = nil
    file = gets.chomp

    return ['-- no userdata --', nil] if file.empty?
    file = File.expand_path(file)
    userdata = File.exist?(file) ? File.read(file) : ''
    if userdata.empty?
      print 'File is empty!'
      userdata = editor(file)
    else
      puts userdata + "\n\n"
      print "Do any changes need to be made to '#{file}'? (Y/N): "

      if gets.chomp =~ /^y(es)?$/i
        userdata = editor(file)
      end
    end

    return [file, userdata]
  end

  private
  def item_chooser(items_numbered, item)
    # Loop input until existing object is selected
    item_name = nil
    print "Which #{item} should we use for this instance?: "

    until items_numbered.values.collect{|i| i.name}.include?(item_name)
      item_name = gets.chomp

      if item_name =~ /^[0-9]*$/
        until items_numbered.keys.include?(item_name.to_i)
          print "#{item_name} is not a valid Id. Enter an Id from above: "
          item_name = gets.chomp
        end

        item_name = items_numbered[item_name.to_i].name
      end

      item_check = items_numbered.values.collect{|i| i.name}.include?(item_name)
      print "#{item_name} is not a valid item. Please enter an option from above: " if item_check == false
    end
    item_name
  end

  def editor(file)
    require 'fileutils'
    FileUtils.cp(file, "#{file}.bkp")
    editor = ENV['EDITOR'] || '/bin/nano'
    puts "Opening #{file} in #{File.basename(editor)}"
    sleep(2)
    system("#{editor} #{file}")
    puts "Backed up #{file} to #{file}.bkp"
    File.read(file)
  end
end
