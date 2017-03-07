
def console_help(cmd)
  menu_cmds = { chooser: 'Return to instance selection',
                create: 'Create a new instance',
                commands: 'Outputs OpenStack Compute commands',
                help: 'Outputs this info',
                exit: 'Exits danarchy_sys' }

  instance_cmds = { status: 'Current running status of instance',
                    connect: 'Connect to instance through SSH',
                    pause: 'Pause instance (to RAM)',
                    unpause: 'Unpause instance from paused state',
                    suspend: 'Suspend Instance (to disk)',
                    resume: 'Resume instance from suspended state',
                    start: 'Start a currently stopped instance',
                    stop: 'Stop a currently running instance',
                    destroy: 'Destroy this instance' }

  if cmd == 'help'
    puts 'dAnarchy_sys menu commands:'
    length = menu_cmds.keys.max_by(&:length).length + 1
    menu_cmds.each { |c, i| printf("%#{length}s %0s\n", "#{c}:", i) }
    puts "\nInstance commands (available after choosing an instance): "
    length = instance_cmds.keys.max_by(&:length).length + 1
    instance_cmds.each { |c, i| printf("%#{length}s %0s\n", "#{c}:", i) }
  elsif cmd == 'commands'
    puts 'Instance commands (available after choosing an instance): '
    length = instance_cmds.keys.max_by(&:length).length + 1
    instance_cmds.each { |c, i| printf("%#{length}s %0s\n", "#{c}:", i) }
  end
end
