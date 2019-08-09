require_relative 'networking/networks'
require_relative 'networking/routers'
require_relative 'networking/security_groups'

module DanarchySys
  module OpenStack
    class Networking
      def initialize(connection, settings)
        @settings = settings
        @net = Fog::OpenStack::Network.new(connection)
      end

      def networks
        Networks.new(@net, @settings)
      end

      def routers
        Routers.new(@net, @settings)
      end

      def security_groups
        SecurityGroups.new(@net, @settings)
      end
    end
  end
end
