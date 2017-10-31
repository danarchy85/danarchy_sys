
class Menus
  def self.get_menu(menu)
    menus = { 'main' => { 'instance'    => 'Instance Manager',
                          'keypair'     => 'Keypair Manager',
                          'help'        => 'Outputs commands for current the menu level',
                          'exit'        => 'Exit dAnarchy_sys'
                        },
              'instance' => { 'status'  => 'Current running status of instance',
                              'connect' => 'Connect to instance through SSH',
                              'start'   => 'Start a currently stopped instance',
                              'stop'    => 'Stop a currently running instance',
                              'pause'   => 'Pause instance (to RAM)',
                              'unpause' => 'Unpause instance from paused state',
                              'suspend' => 'Suspend Instance (to disk)',
                              'resume'  => 'Resume instance from suspended state',
                              'rebuild' => 'Rebuilds instance with a chosen image',
                              'create'  => 'Create a new instance',
                              'delete'  => 'Delete this instance'
                            },
              'keypair' => { 'info'   => 'View information about this keypair',
                             'create' => 'Create a new keypair',
                             'delete' => 'Delete an existing keypair'
                           }
            }

    menus[menu]
  end

  def self.numbered_menu(menu)
    numbered_menu = Helpers.hash_to_numhash(get_menu(menu))
  end

  def self.print_menu(menu)
    if menu == 'main'
      puts 'dAnarchy_sys main menu commands:'
      puts 'Enter \'help\' to view available commands or \'exit\' to leave.'
      # print_menu(menu)
    elsif menu == 'instance'
      puts 'Instance Manager commands: '
      puts 'Enter enter \'chooser\' to select an instance, \'help\' to view available commands or \'main\' for the main menu.'
      # print_menu(menu)
    elsif menu == 'keypair'
      puts 'Keypair Manager commands: '
      puts 'Enter enter \'chooser\' to select a keypair, \'help\' to view available commands or \'main\' for the main menu.'
    # print_menu(menu)
    elsif menu == 'storage'
      puts 'Storage Manager commands: '
      puts 'Not yet implemented!'
      return
      # print_menu(menu)
    end

    # numbered_menu = Helpers.hash_to_numhash(menu)
    numbered_menu = numbered_menu(menu)
    menu = get_menu(menu)
    
    fields = PrintFormats.printf_numhash(numbered_menu)

    numbered_menu.each do |id, v|
      v.each do |name, info|
        printf("#{fields}\n", "#{id}.", "#{name}:", info)
      end
    end
  end
end
