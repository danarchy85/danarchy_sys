
require 'fog/openstack'
require_relative 'danarchy_sys/version'
require_relative 'danarchy_sys/cli'

module DanarchySys
  module OpenStack
    require_relative 'danarchy_sys/openstack'
  end

  module AWS
    # Not yet implemented!
  end
end
