require_relative './menus'
require_relative './keypair_manager/keypair_status'

class KeypairManager
  def self.manager(os_compute)
    comp_kp = os_compute.keypairs
    puts 'Keypair Manager: enter \'help\' to view available commands or \'main\' for the main menu.'
    menu = Menus.numbered_menu('keypair')
    keypair = false

    loop do
      while keypair == false
        keypair = chooser(os_compute)
        return Menus.print_menu('main') if keypair == 'main'

        if keypair == 'keypair'
          Menus.print_menu('keypair')
          keypair = false
        end
      end
      
      print "#{keypair.name} ~: " if keypair
      cmd = gets.chomp

      next if cmd.empty?
      abort('Exiting!') if cmd == 'exit'
      
      if cmd =~ /^[0-9]*$/
        menu[cmd.to_i].map { |k, v| cmd = k } if menu.keys.include? cmd.to_i
      end

      if cmd == 'help'
        Menus.print_menu('keypair')
      elsif cmd == 'main'
        return Menus.print_menu('main')
      elsif cmd == 'info'
        KeypairStatus.single_keypair(keypair)
      elsif cmd == 'chooser'
        keypair = chooser(os_compute)
      elsif cmd == 'create'
        print 'Enter a new keypair name: '
        keypair_name = gets.chomp
        keypair = comp_kp.create_keypair(keypair_name)
        puts "Keypair: #{keypair_name} created!"
        Menus.print_menu('keypair')
        puts "Managing keypair: #{keypair_name}"
      elsif cmd == 'delete'
        print "Are you sure you wish to delete keypair: #{keypair.name}? (this is permanent!) (Y/N): "
        delete = comp_kp.delete_keypair(keypair.name) if gets.chomp =~ /^y(es)?$/i
        if delete == true
          puts "#{keypair.name} has been deleted! Returning to the keypair chooser."
          keypair = chooser(os_compute)
        else
          puts "#{keypair.name} was not deleted!"
        end
      else
        Menus.print_menu('keypair')
        puts "\nCommand \'#{cmd}\' not available. Enter a command from above."
      end

      return Menus.print_menu('main') if keypair == 'main'
    end
  end

  def self.chooser(os_compute)
    comp_kp = os_compute.keypairs
    keypairs = comp_kp.list_keypairs
    keypair_numhash = Helpers.array_to_numhash(keypairs)
    keypair_name = 'nil'
    keypair = 'nil'

    # Create a new keypairs if none exist
    if keypair_numhash.empty?
      print 'No existing keypairs were found. Should we create a new one? (Y/N): '
      abort('Exiting!') unless gets.chomp =~ /^y(es)?$/i
      keypair = PromptsCreateKeypair.create_keypair(os_compute, 'nil')
      puts "Working with: #{keypair.name}\tStatus: #{keypair.state}"
      return keypair
    end

    puts 'Available keypairs:'
    fields = PrintFormats.printf_hash(keypair_numhash)
    keypair_numhash.each do |k, v|
      printf("#{fields}\n", "#{k}.", v)
    end
    
    # Loop input until an existing keypair is selected
    print 'Enter an keypair to manage or enter a name for a new keypair: '

    until keypairs.include?(keypair_name)
      keypair_name = gets.chomp

      until keypair_name.empty? == false
        print 'Input was blank! Enter an keypair or Id from above: '
        keypair_name = gets.chomp
      end

      abort('Exiting') if keypair_name == 'exit'
      return 'main' if keypair_name == 'main'
      return 'keypair' if keypair_name == 'help'

      # Accept keypair Id as an entry
      if keypair_name =~ /^[0-9]*$/
        until keypair_numhash.keys.include?(keypair_name.to_i)
          print "#{keypair_name} is not a valid Id. Enter an Id from above: "
          keypair_name = gets.chomp
        end

        keypair_name = keypair_numhash[keypair_name.to_i]
      end

      if comp_kp.check_keypair(keypair_name) == false
        print "#{keypair_name} is not a valid keypair.
Should we create a new keypair named #{keypair_name}? (Y/N): "

        if gets.chomp =~ /^y(es)?$/i
          keypair = comp_kp.create_keypair(keypair_name)
          KeypairStatus.single_keypair(keypair)
        else
          puts "Not creating new keypair: #{keypair_name}."
          return false
        end
      end

      keypairs = comp_kp.list_keypairs
    end

    keypair = comp_kp.get_keypair(keypair_name)
    Menus.print_menu('keypair')
    puts "Managing keypair: #{keypair_name}"
    keypair
  end
end
