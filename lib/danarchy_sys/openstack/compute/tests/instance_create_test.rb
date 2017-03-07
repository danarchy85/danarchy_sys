#!/usr/bin/env ruby
require 'fog/openstack'
require '../../connection'
require '../instance_prompts'
require '../instance_params'
require '../instance_manage'

@os_connection_params = Connection.os_danarchy
@compute = Fog::Compute::OpenStack.new(@os_connection_params)

prompts = InstancePrompts.new
instance = prompts.create_instance(@compute)

p instance
