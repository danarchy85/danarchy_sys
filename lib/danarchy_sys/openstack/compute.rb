require_relative 'compute/instances'
require_relative 'compute/keypairs'
require_relative 'compute/images'
require_relative 'compute/flavors'

module DanarchySys
  module OpenStack
    class Compute
      def initialize(connection, settings)
        @settings = settings
        @compute = Fog::Compute::OpenStack.new(connection)
        @instances = @compute.servers
        @images = @compute.images(filters: {'status' => ['ACTIVE']})
        @flavors = @compute.flavors
      end

      def instances
        ComputeInstances.new(@compute, @instances, @settings)
      end

      def keypairs
        ComputeKeypairs.new(@compute, @settings)
      end

      def images
        ComputeImages.new(@compute, @images)
      end

      def flavors
        ComputeFlavors.new(@compute, @flavors)
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

        ssh, user = nil
        if image == nil
          puts "Image not found for #{instance.name}! This instance needs to be rebuild with a current image."
          puts "Attempting to determine the correct username and log in..."
          ssh, user = fallback_ssh(ipv4, pemfile)
        else
          user = 'ubuntu' if image.name =~ /ubuntu/i
          user = 'debian' if image.name =~ /debian/i
          user = 'centos' if image.name =~ /centos/i
          user = 'fedora' if image.name =~ /fedora/i
          user = 'core'   if image.name =~ /coreos/i
        end

        return if !user

        print "Connecting as user: #{user} @ #{ipv4} " + cmd + "\n"
        connect = "/usr/bin/ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o PasswordAuthentication=no -i '#{pemfile}' #{user}@#{ipv4}"
        system(connect)
      end

      def fallback_ssh(ipv4, pemfile)
        users = %w[debian ubuntu centos fedora core]
        ssh, user = nil

        users.each do |username|
          print "Attempting connection as user: #{username} @ #{ipv4} => "
          connect = "/usr/bin/ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o PasswordAuthentication=no -i '#{pemfile}' #{username}@#{ipv4}"
          ssh = system("#{connect} 'uptime' &>/dev/null")

          if ssh == true
            puts 'success'
            user = username
            break
          else
            puts 'failed'
          end
        end

        if ssh == false
          puts 'Unable to connect! User unknown or SSHd is not running on the instance.' 
          return ssh, nil
        else
          return [ssh, user]
        end
      end
    end
  end
end
