#!/usr/bin/env ruby
require 'fog/openstack'
require '../../connection'
require '../instance_manage'

@os_connection_params = Connection.os_dreamcompute
@compute = Fog::Compute::OpenStack.new(@os_connection_params)

instances = InstanceManage.list_instances(@compute)
puts instances

print "Let's create a new instance.\nWhat should we name it? : "
instance_name = gets.chomp

puts "Creating instance..."
instance = 
