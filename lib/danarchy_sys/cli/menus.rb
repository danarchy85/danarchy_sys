
class Menus
  def self.get_menu(menu)
    YAML.load_file(File.realpath('./lib/danarchy_sys/cli/menus/menus.yml'))[menu]
  end

  def self.numbered_menu(menu)
    Helpers.hash_to_numhash(get_menu(menu))
  end

  def self.print_menu(menu)
    if menu == 'main'
      puts 'dAnarchy_sys main menu commands:'
      puts 'Enter \'help\' to view available commands or \'exit\' to leave.'
    elsif menu == 'instance'
      puts 'Instance Manager commands: '
      puts 'Enter enter \'chooser\' to select an instance, \'help\' to view available commands or \'main\' for the main menu.'
    elsif menu == 'keypair'
      puts 'Keypair Manager commands: '
      puts 'Enter enter \'chooser\' to select a keypair, \'help\' to view available commands or \'main\' for the main menu.'
    elsif menu == 'network'
      puts 'Network Manager commands: '
      puts 'Not yet implemented!'
      return
    end

    numbered_menu = numbered_menu(menu)
    fields = PrintFormats.printf_numhash(numbered_menu)

    numbered_menu.each do |id, v|
      v.each do |name, info|
        printf("#{fields}\n", "#{id}.", "#{name}:", info)
      end
    end
  end
end
