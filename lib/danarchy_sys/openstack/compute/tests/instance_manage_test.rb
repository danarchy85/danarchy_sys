#!/usr/bin/env ruby
require 'fog/openstack'
require '../../../../danarchy_sys'
require '../instances'

os_connection_params = Connection.os_dreamcompute
compute = Fog::Compute::OpenStack.new os_connection_params

p ComputeInstances.all_instances compute

puts 'Existing Instances:', ComputeInstances.list_all_instances(compute)
print 'Which instance should we check?: '
instance_name = gets.chomp

puts "Checking: #{instance_name}", ComputeInstances.check_instance(compute, instance_name)

puts "Getting: #{instance_name}"
instance = ComputeInstances.get_instance(compute, instance_name)

addresses = instance.addresses['public']
ipv6, ipv4 = addresses[0], addresses[1]
#ipv4 = addresses[1]
print 'ipv6: ', ipv6['addr'], "\n"
print 'ipv4: ', ipv4['addr'], "\n"
