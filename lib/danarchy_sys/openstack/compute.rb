require_relative 'compute/instances'
require_relative 'compute/keypairs'
require_relative 'compute/images'
require_relative 'compute/flavors'
require 'shellwords'

module DanarchySys
  module OpenStack
    class Compute
      def initialize(connection, settings)
        @settings = settings
        @compute = Fog::OpenStack::Compute.new(connection)
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

      def ssh(instance, *cmd)
        instance = instances.get_instance(instance) if instance.class == String
        pemfile = keypairs.pemfile_path(instance.key_name)
        addrs = instances.get_public_addresses(instance)

        opts = { quiet: true }
        opts[:command] = cmd ? cmd.shift : nil
        connector = { ipv4: addrs.grep(/\./).first,
                      ipv6: addrs.grep(/:/).first,
                      ssh_key: pemfile,
                      ssh_user: nil }
        # Define user by image_id
        image = images.get_image_by_id(instance.image['id'])
        if image == nil
          puts "Image not found for #{instance.name}! This instance needs to be rebuild with a current image."
          puts "Attempting to determine the correct username and log in..."
          connector = fallback_ssh(connector)
        else
          connector[:ssh_user] = 'gentoo' if image.name =~ /gentoo/i
          connector[:ssh_user] = 'ubuntu' if image.name =~ /ubuntu/i
          connector[:ssh_user] = 'debian' if image.name =~ /debian/i
          connector[:ssh_user] = 'centos' if image.name =~ /centos/i
          connector[:ssh_user] = 'fedora' if image.name =~ /fedora/i
          connector[:ssh_user] = 'core'   if image.name =~ /coreos/i
        end

        return if ! connector[:ssh_user]
        SSH.new(connector, opts)
      end

      def fallback_ssh(connector)
        users = %w[gentoo debian ubuntu centos fedora core]
        fb_opts = { quiet: true, command: 'uptime' }

        users.each do |username|
          connector[:ssh_user] = username
          print 'Attempting connection as user: '
          print connector[:ssh_user], ' @ ', connector[:ipv4], ' => '
          fallback_result = SSH.new(connector, fb_opts)

          if fallback_result[:stdout]
            puts 'success'
            break
          else
            puts 'failed'
            connector[:ssh_user] = nil
          end
        end

        puts 'Unable to determine user or SSHd is not running!' if ! connector[:ssh_user]
        connector
      end
    end
  end
end
