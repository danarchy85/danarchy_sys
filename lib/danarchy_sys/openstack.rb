
require 'fog/openstack'

module DanarchySys
  module OpenStack
    # Load OpenStack compute requirements
    require_relative 'openstack/compute'
    require_relative 'openstack/compute/images'
    require_relative 'openstack/compute/flavors'
    require_relative 'openstack/compute/keypairs'
    require_relative 'openstack/compute/instances'
    require_relative 'openstack/compute/instance_prompts'
  end
end
