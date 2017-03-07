# DanarchySys

Welcome to dAnarchy Systems! This gem will assist you in easing the setup of OpenStack instances for use of hosting various web applications.

## Installation

Requires bundler to be installed already: 'gem install bundler'

Download danarchy_sys, 'cd' into its directory, then run 'sh bin/setup'.  
This will run bundler and install the required gems. It will then prompt for a new OpenStack setup.  

dAnarchySys config setup will be located at danarchy_sys/config/danarchysys.yml in YAML format like this:

:connections:
  :your_connection:  
    :openstack_auth_url: http://openstack-provider.com:5000/v2.0/tokens  
    :openstack_username: openstack_username  
    :openstack_api_key: openstack_api_key  
    :openstack_tenant: openstack_tenant  
:settings:  
  :ssh_key_path: PATH_TO_SSH_KEYS  


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

Bug reports are welcome on GitHub at https://github.com/danarchy85/danarchy_sys.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

