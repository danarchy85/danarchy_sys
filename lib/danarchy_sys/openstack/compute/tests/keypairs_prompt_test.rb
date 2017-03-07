#!/usr/bin/env ruby
require 'fog/openstack'
require '../../../../danarchy_sys'
require '../../../helpers'
require '../instance_prompts'

os_connection_params = Connection.os_dreamcompute
compute = Fog::Compute::OpenStack.new(os_connection_params)
config = Config.os_dreamcompute

#@config = Config.os_dreamcompute
p ComputePrompts.keypair(config, compute)
