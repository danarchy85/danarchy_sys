#!/usr/bin/env ruby
require 'fog/openstack'
require '../../../../../config/danarchysys.config'
require '../../../helpers'
require '../prompts'

os_connection_params = Connection.os_dreamcompute
compute = Fog::Compute::OpenStack.new(os_connection_params)

p ComputePrompts.flavor(compute)
