# DanarchySys

Welcome to dAnarchy Systems! This gem will assist you in easing the setup of OpenStack instances for use of hosting various web applications.

## Installation

Proper installation has not yet been set up. You will first need to set up an OpenStack connection configuration at your $HOME/.danarchysys_connection.rb which should contain something like this:

# Connection Settings for OpenStack
class Connection

  def self.openstack
    @os_connection_params = {
      openstack_auth_url:       "http://openstack-provider.com:5000/v2.0/tokens",
      openstack_username:       "openstack_username",
      openstack_api_key:        "openstack_api_key",
      openstack_tenant:         "openstack_tenant",
    }
  end
end

Once you have created ~/.danarchysys_connection.rb, simply run 'bin/danarchy_sys' to initiate the DanarchySys CLI.

## Usage

ruby danarchy_sys 
OpenStack -> DreamCompute
Available Instances:
Id Instance Name         
1. instance_01
2. instance_02            
3. instance_03
Which instance should we manage? (leave blank to create a new instance, enter 'exit' to leave): 1
Working with: instance_01	Status: SHUTOFF
Enter 'help' for all available commands.
command ~: help
dAnarchy_sys menu commands:
chooser: Return to instance selection
create: Create a new instance
commands: Outputs OpenStack Compute commands
help: Outputs this info

OpenStack Compute commands (must first choose an instance): 
status: Current running status of instance
connect: Connect to instance through SSH
pause: Pause instance (to RAM)
unpause: Unpause instance from paused state
suspend: Suspend Instance (to disk)
resume: Resume instance from suspended state
start: Start a currently stopped instance
stop: Stop a currently running instance
delete: Destroy this instance
command ~:


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danarchy85/danarchy_sys.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

