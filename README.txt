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

OpenStack -> os_dreamcompute
dAnarchy_sys main menu commands:
Enter 'help' to view available commands or 'exit' to leave.
1. instance: Instance Manager
2.  keypair: Keypair Manager (Not yet implemented!)
3.     help: Outputs commands for current the menu level
4.     exit: Exit dAnarchy_sys
command ~: 1

Instance Manager: enter 'help' to view available commands or 'back' for the main menu.
Available instances:
Id Instance Name          Status
1. danarchy_sys_centos7   SHUTOFF
2. dh_testing             SHUTOFF
3. openstack_in_openstack SHUTOFF
Enter an instance to manage or enter a name for a new instance: 1

Instance Manager commands:
Enter 'help' to view available commands or 'back' for the main menu.
 1.  status: Current running status of instance
 2. connect: Connect to instance through SSH
 3.   start: Start a currently stopped instance
 4.    stop: Stop a currently running instance
 5.   pause: Pause instance (to RAM)
 6. unpause: Unpause instance from paused state
 7. suspend: Suspend Instance (to disk)
 8.  resume: Resume instance from suspended state
 9.  create: Create a new instance
10.  delete: Delete this instance

Managing instance: danarchy_sys_centos7	Status: SHUTOFF
danarchy_sys_centos7 ~: start
true
danarchy_sys_centos7 ~: status
ACTIVE
danarchy_sys_centos7 ~: connect
Last login: Fri Apr  7 23:15:42 2017
[centos@danarchy-sys-centos7 ~]$ uname -s -r
Linux 3.10.0-514.10.2.el7.x86_64
[centos@danarchy-sys-centos7 ~]$  exit
logout
Connection closed.
danarchy_sys_centos7 ~: exit
Exiting!


## Contributing

Bug reports are welcome on GitHub at https://github.com/danarchy85/danarchy_sys.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

