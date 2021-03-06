require 'fog/openstack'

module DanarchySys
  module OpenStack
    # Load OpenStack compute requirements
    require_relative 'openstack/compute'
    require_relative 'openstack/networking'
  end
end
