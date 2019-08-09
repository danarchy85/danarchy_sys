
# CLI Prompt to create a new instance
class PromptsCreateInstance
  def initialize(os_compute, os_network, settings)
    @os_compute = os_compute
    @os_network = os_network
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

    # Prompt for Network
    puts "\nSelect one or more networks for #{instance_name}."
    network = self.network

    # Prompt for userdata
    print "\nEnter a path to userdata for #{instance_name} or leave blank for no userdata: "
    file, userdata = self.userdata

    # Print summary and prompt to continue
    puts "\n================= Instance Summary ==================="
    puts "\nInstance Name: #{instance_name}"
    puts "        Linux: #{image.name}"
    puts "       Flavor: #{flavor.name}"
    puts "      Keypair: #{keypair.name}"
    puts "      Network: #{network}"
    puts "     UserData: #{file}"
    puts "\n --- UserData --- \n#{userdata}\n --- End UserData ---\n" if userdata
    puts "\n=============== End Instance Summary ================="
    print 'Should we continue with creating the instance? (Y/N): '
    instance = nil
    continue = gets.chomp

    if continue =~ /^y(es)?$/i
      puts "Creating instance: #{instance_name}"
      instance = @os_compute.instances.create_instance(instance_name, image.id, flavor.id, keypair.name, {nics: network, user_data: userdata} )
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
    images = Helpers.objects_to_numarray(@os_compute.images.all_images)
    image  = item_chooser(images, 'image', multiple: false, create: false).first
    puts "Selected: #{image.name}"
    image
  end

  def flavor
    flavors = Helpers.objects_to_numarray(@os_compute.flavors.all_flavors.sort_by(&:ram))
    flavor  = item_chooser(flavors, 'flavor', multiple: false, create: false).first
    puts "Selected: #{flavor.name}"
    flavor
  end

  def keypair
    keypairs = Helpers.objects_to_numarray(@os_compute.keypairs.all_keypairs)
    puts "\nEnter a new keypair name or select an existing keypair for this instance."
    keypair, create = item_chooser(keypairs, 'keypair', multiple: false, create: true)

    if create
      keypair = @os_compute.keypairs.create_keypair(keypair)
      puts "Created keypair: #{keypair.name}"
    end

    puts "Selected: #{keypair.name}"
    keypair
  end

  def network
    networks = Helpers.objects_to_numarray(
      @os_network.networks.all_networks.sort_by do |n|
        [ n.name == 'public' ? 0 : 1, n.name ]
      end)

    if networks.count == 1
      network = networks.first.pop
      puts "\nA single network was found. Adding instance to network: #{network.name}"
      nics.push({ net_id: network.id })
    else
      # List available networks
      puts "\nEnter one or more networks (comma separated) for this instance."
      puts "  Ex: '1, 2, 3' or 'public, network-1, network-2'."
      puts "    Order matters; 'public' should probably be entered first in most cases."
      networks = item_chooser(networks, 'networks', multiple: true)
    end

    nics = []
    networks.each do |n|
      if ! n.nil?
        puts "Added network: #{n.name}"
        nics.push({ net_id: n.id })
      end
    end

    nics
  end

  def securitygroup
    # to-do
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

    [file, userdata]
  end

  private
  def item_chooser(items_numbered, item, multiple: false, create: false)
    selection = []
    all_items = items_numbered.each_value.map(&:name)

    format = PrintFormats.printf_numhash_values(items_numbered, [:name])
    printf("#{format}\n", 'Id ', item)
    items_numbered.each do |id, i|
      printf("#{format}\n", "#{id}. ", i.name)
    end
    print "Select #{item} to use for this instance "
    print "or enter a name to create a new #{item}" if create
    print ': '

    iter = 0
    until selection & all_items == selection && ! selection.empty?
      print "Invalid input: #{selection}. Please enter values from above: " if iter > 0
      selection = gets.chomp.gsub(/ /, '').split(',')
      iter += 1

      if selection.all? { |s| s =~ /^[0-9]*$/ }
        all_nums = items_numbered.keys
        selection = selection.map(&:to_i)

        if selection & all_nums != selection
          redo
        else
          selection = selection.collect { |s| items_numbered[s].name }
        end
      end

      if ! multiple && selection.count > 1
        puts "Enter only a single value for #{item}."
        redo
      end

      if create && selection & all_items != selection
        puts "Creating new #{item}: #{selection.first}"
        return selection.first, create
      end
    end

    items_numbered.values.collect { |i| i if selection.include?(i.name) }.compact
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
