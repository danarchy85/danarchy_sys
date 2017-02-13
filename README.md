# DanarchySys

Welcome to dAnarchy Systems! This gem will assist you in easing the setup of OpenStack instances for use of hosting various web applications.

## Installation

Proper installation has not yet been set up. You will first need to set up an OpenStack connection configuration at your $HOME/.danarchysys_connection.rb which should contain something like this:

# Connection Settings for OpenStack
class Connection<br />
<br />
  def self.openstack<br />
    @os_connection_params = {<br />
      openstack_auth_url:       "http://openstack-provider.com:5000/v2.0/tokens",<br />
      openstack_username:       "openstack_username",<br />
      openstack_api_key:        "openstack_api_key",<br />
      openstack_tenant:         "openstack_tenant",<br />
    }<br />
  end<br />
end<br />
<br />
Once you have created ~/.danarchysys_connection.rb, simply run 'bin/danarchy_sys' to initiate the DanarchySys CLI.

## Usage

ruby danarchy_sys <br />
OpenStack -> DreamCompute<br />
Available Instances:<br />
Id Instance Name <br />
1. instance_01<br />
2. instance_02<br />      
3. instance_03<br />
Which instance should we manage? (leave blank to create a new instance, enter 'exit' to leave): 1<br />
Working with: instance_01	Status: SHUTOFF<br />
Enter 'help' for all available commands.<br />
command ~: help<br />
dAnarchy_sys menu commands:<br />
chooser: Return to instance selection<br />
create: Create a new instance<br />
commands: Outputs OpenStack Compute commands<br />
help: Outputs this info<br />

OpenStack Compute commands (must first choose an instance): <br />
status: Current running status of instance<br />
connect: Connect to instance through SSH<br />
pause: Pause instance (to RAM)<br />
unpause: Unpause instance from paused state<br />
suspend: Suspend Instance (to disk)<br />
resume: Resume instance from suspended state<br />
start: Start a currently stopped instance<br />
stop: Stop a currently running instance<br />
delete: Destroy this instance<br />
command ~:<br />
<br />

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danarchy85/danarchy_sys.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

