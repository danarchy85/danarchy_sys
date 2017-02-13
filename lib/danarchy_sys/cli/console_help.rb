
def console_help(cmd)
  menu_cmds = { chooser: 'Return to instance selection',
                create: 'Create a new instance',
                commands: 'Outputs OpenStack Compute commands',
                help: 'Outputs this info' }

  compute_cmds = { status: 'Current running status of instance',
                   connect: 'Connect to instance through SSH',
                   pause: 'Pause instance (to RAM)',
                   unpause: 'Unpause instance from paused state',
                   suspend: 'Suspend Instance (to disk)',
                   resume: 'Resume instance from suspended state',
                   start: 'Start a currently stopped instance',
                   stop: 'Stop a currently running instance',
                   delete: 'Destroy this instance' }

  if cmd == 'help'
    puts 'dAnarchy_sys menu commands:'
    menu_cmds.each { |c, i| printf("%5s %0s\n", "#{c}:", i) }
    puts "\nOpenStack Compute commands (must first choose an instance): "
    compute_cmds.each { |c, i| printf("%5s %0s\n", "#{c}:", i) }
  elsif cmd == 'commands'
    puts 'OpenStack Compute commands (must first choose an instance): '
    compute_cmds.each { |c, i| printf("%5s %0s\n", "#{c}:", i) }
  end
end
