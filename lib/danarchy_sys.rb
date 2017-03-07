
require 'fog/openstack'
require_relative 'danarchy_sys/version'
require_relative 'danarchy_sys/helpers'
require_relative 'danarchy_sys/config'

module DanarchySys
  module OpenStack
    require_relative 'danarchy_sys/openstack'
  end

  module AWS
    # Not yet implemented!
  end
end
