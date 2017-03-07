#!/usr/bin/env ruby
require 'fog/openstack'
require '../../connection'
require_relative '../images'

@os_connection_params = Connection.os_dreamcompute
@compute = Fog::Compute::OpenStack.new(@os_connection_params)

p ComputeImages.image_list(@compute)

print "Which image should we test? : "
image_name = gets.chomp

p ComputeImages.image_get(@compute, image_name)
