
module DanarchySys
  module OpenStack
    class Compute
      def initialize
        @os_connection_params = Connection.os_dreamcompute
        @compute = Fog::Compute::OpenStack.new(@os_connection_params)
      end

      def all_instances
        ComputeInstances.list_all_instances(@compute)
      end

      def active_instances
        ComputeInstances.list_active_instances(@compute)
      end

      def create_prompt
        ComputePrompts.create_instance(@compute)
      end

      def get_instance(instance_name)
        ComputeInstances.get_instance(@compute, instance_name)
      end

      def check(instance_name)
        ComputeInstances.check_instance(@compute, instance_name)
      end

      def status(instance_name)
        ComputeInstances.get_instance(@compute, instance_name).state
      end

      def create(instance_name, image_id, flavor_id, keypair_name)
        ComputeInstances.create_instance(@compute, instance_name, image_id, flavor_id, keypair_name)
      end

      def delete(instance_name)
        ComputeInstances.delete_instance(@compute, instance_name)
      end

      def pause(instance_name)
        ComputeInstances.pause_instance(@compute, instance_name)
      end

      def unpause(instance_name)
        ComputeInstances.unpause_instance(@compute, instance_name)
      end

      def suspend(instance_name)
        ComputeInstances.suspend_instance(@compute, instance_name)
      end

      def resume(instance_name)
        ComputeInstances.resume_instance(@compute, instance_name)
      end

      def start(instance_name)
        ComputeInstances.start_instance(@compute, instance_name)
      end

      def stop(instance_name)
        ComputeInstances.stop_instance(@compute, instance_name)
      end

      def ipv4(instance_name)
        ipv4_interface = ComputeInstances.get_addresses(@compute, instance_name)[1]
        ipv4_interface['addr']
      end

      def ipv6(instance_name)
        ipv6_interface = ComputeInstances.get_addresses(@compute, instance_name)[0]
        ipv6_interface['addr']
      end

      def pemfile(instance_name)
        instance = get_instance(instance_name)

        keypair_name = instance.key_name
        ComputeKeyPairs.pemfile_path(keypair_name)
      end

      def user(instance_name)
        # Use image_id to get OS version so we can figure out the user
        image_info = get_instance(instance_name).image
        image_id = image_info['id']
        image = ComputeImages.get_image_by_id(@compute, image_id)

        return 'core' if image.name =~ /CoreOS/i
        return image.name.downcase.split('-')[0]
      end
      
      def connect(instance_name)
        ipv4 = ipv4(instance_name)
        pemfile = pemfile(instance_name)
        user = user(instance_name)

        ssh = "ssh #{user}@#{ipv4} -i '#{pemfile}'"
        system(ssh)
      end
    end
  end
end
