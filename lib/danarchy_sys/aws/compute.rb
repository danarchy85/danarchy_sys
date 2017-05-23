module DanarchySys
  module AWS
    class Compute
      def initialize(provider)
        config = ConfigMgr.new
        danarchysys_config = config.load
        connection = danarchysys_config[:connections][provider]
        @settings = danarchysys_config[:settings]
        @compute = Fog::Compute::AWS.new(connection)
      end
    end
  end
end
