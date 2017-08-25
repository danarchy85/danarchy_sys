require_relative 'compute/instances'
require_relative 'compute/keypairs'
require_relative 'compute/images'
require_relative 'compute/flavors'

module DanarchySys
  module OpenStack
    class Compute
      def initialize(provider)
        danarchysys_config = DanarchySys::ConfigManager::Config.new
        connection = danarchysys_config[:connections][provider.to_sym]
        @settings = danarchysys_config[:global_settings]
        @compute = Fog::Compute::OpenStack.new(connection)
      end

      def instances
        ComputeInstances.new(@compute, @settings)
      end

      def keypairs
        ComputeKeypairs.new(@compute, @settings)
      end

      def images
        ComputeImages.new(@compute)
      end

      def flavors
        ComputeFlavors.new(@compute)
      end

      def ssh(instance_name)
        (comp_inst, comp_kp, comp_img) = instances, keypairs, images
        instance = comp_inst.get_instance(instance_name)
        keypair_name = instance.key_name
        pemfile = comp_kp.pemfile_path(keypair_name)
        
        # Define user by image_id
        image_info = instance.image
        image_id = image_info['id']
        image = comp_img.get_image_by_id(image_id)

        # CoreOS is an exception with user as simply 'core' and not 'coreos'
        user = ''
        if image.name =~ /CoreOS/i
          user = 'core'
        else
          user = image.name.downcase.split('-')[0]
        end

        ipv4, ipv6 = comp_inst.get_addresses(instance_name)

        ssh = "ssh #{user}@#{ipv4} -i '#{pemfile}'"
        system(ssh)
      end
    end
  end
end
