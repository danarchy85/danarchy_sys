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

      def secgroups
        ComputeSecgroups.new(@compute)
      end

      def ssh(instance_name)
        (comp_inst, comp_kp, comp_img) = instances, keypairs, images
        instance = comp_inst.get_instance(instance_name)
        keypair_name = instance.key_name
        pemfile = comp_kp.pemfile_path(keypair_name)
        
        addrs = comp_inst.get_public_addresses(instance_name)
        ipv4 = addrs.grep(/\./).first
        ipv6 = addrs.grep(/:/).first

        # Define user by image_id
        image_id = instance.image['id']
        image = comp_img.get_image_by_id(image_id)

        if image == nil
          puts "Image not found for #{instance.name}! This instance needs to be rebuild with a current image."
          return fallback_ssh(ipv4, pemfile)          
        end

        # CoreOS is an exception with user as simply 'core' and not 'coreos'
        user = 'ubuntu' if image.name =~ /ubuntu/i
        user = 'debian' if image.name =~ /debian/i
        user = 'centos' if image.name =~ /centos/i
        user = 'fedora' if image.name =~ /fedora/i
        user = 'core'   if image.name =~ /coreos/i

        puts "Connecting as user: #{user} => #{ipv4}"
        connect = "ssh #{user}@#{ipv4} -i '#{pemfile}'"
        ssh = system(connect)

        attempts = 1
        until ssh == true || attempts > 3
          puts "Connection failed. Attempting again after 5 seconds..."
          sleep(5)
          fallback_ssh(ipv4, pemfile)
          attempts += 1
        end
      end

      def fallback_ssh(ipv4, pemfile)
        users = ['ubuntu','debian','centos','fedora','core']
        ssh = false

        users.each do |user|
          puts "Attempting connection as user: #{user} => #{ipv4}"
          connect = "ssh #{user}@#{ipv4} -i '#{pemfile}'"
          ssh = system(connect)
          return true if ssh == true
        end

        if ssh == false
          puts 'Unable to connect after 3 tries!'
          return false
        end
      end
    end
  end
end
