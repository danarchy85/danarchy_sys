# DanarchySys

Welcome to dAnarchy Systems! This gem will assist you in easing the setup of OpenStack instances for use of hosting various web applications.

## Installation

Requires bundler to be installed already: 'gem install bundler'

Download danarchy_sys, 'cd' into its directory, then run 'sh bin/setup'.\n
This will run bundler and install the required gems. It will then prompt for a new OpenStack setup.\n

dAnarchySys config setup will be located at danarchy_sys/config/danarchysys.yml in YAML format like this:\n

:connections:\n
  :your_connection:\n
    :openstack_auth_url: "http://openstack-provider.com:5000/v2.0/tokens"\n
    :openstack_username: "openstack_username"\n
    :openstack_api_key: "openstack_api_key"\n
    :openstack_tenant: "openstack_tenant"\n
:settings:\n
  :ssh_key_path: PATH_TO_SSH_KEYS\n


## Usage

ruby danarchy_sys 
OpenStack -> DreamCompute
Available Instances:
Id Instance Name\n
1. instance_01\n
2. instance_02\n          
3. instance_03\n
Which instance should we manage? (leave blank to create a new instance, enter 'exit' to leave): 1

Working with: instance_01	Status: SHUTOFF\n
Enter 'help' for all available commands.\n
command ~: help\n
dAnarchy_sys menu commands:\n
chooser: Return to instance selection\n
create: Create a new instance\n
commands: Outputs OpenStack Compute commands\n
help: Outputs this info\n

OpenStack Compute commands (must first choose an instance): \n
status: Current running status of instance\n
connect: Connect to instance through SSH\n
pause: Pause instance (to RAM)\n
unpause: Unpause instance from paused state\n
suspend: Suspend Instance (to disk)\n
resume: Resume instance from suspended state\n
start: Start a currently stopped instance\n
stop: Stop a currently running instance\n
delete: Destroy this instance\n
command ~:\n


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danarchy85/danarchy_sys.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

