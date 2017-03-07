#!/usr/bin/env ruby
require_relative '../lib/danarchy_sys'

# dAanarchySys config file setup
class DanarchySysConfig
  def initialize
    @config_mgr = ConfigMgr.new
  end

  def load_config
    @config_mgr.load
  end

  def ssh_key_path
    danarchysys_config = load_config

    ssh_key_path = "#{File.expand_path('..', File.dirname(__FILE__))}/config/ssh"
    Dir.mkdir(ssh_key_path) unless Dir.exist?(ssh_key_path)
    danarchysys_config[:settings][:ssh_key_path] = ssh_key_path

    @config_mgr.save(danarchysys_config)
  end

  def new_connection
    danarchysys_config = load_config

    if danarchysys_config[:connections].count.zero?
      puts 'Creating a new configuration.'
    else
      puts 'Adding a new OpenStack connection to existing configuration.'
    end

    print 'Provider name: '
    provider_name = gets.chomp
    print "OpenStack Auth URL\t(Example: http://openstack-host.com:5000/v2.0/tokens)\nEnter URL: "
    openstack_auth_url = gets.chomp
    print 'OpenStack Username: '
    openstack_username = gets.chomp
    print 'OpenStack API Key: '
    openstack_api_key = gets.chomp
    print 'OpenStack Tenant ID: '
    openstack_tenant = gets.chomp

    danarchysys_config[:connections][provider_name.to_sym] = {
      openstack_auth_url: openstack_auth_url,
      openstack_username: openstack_username,
      openstack_api_key: openstack_api_key,
      openstack_tenant: openstack_tenant
    }

    @config_mgr.save(danarchysys_config)
  end
end

config = DanarchySysConfig.new
danarchysys_config = config.load_config
puts 'Beginning danarchysys configuration setup.'

if danarchysys_config[:connections].count.zero?
  config.new_connection
else
  puts 'Available OpenStack Connections: '
  danarchysys_config[:connections].each_key { |k| puts k }
end

continue = false
until continue == true
  print 'Should we add another connection? (Y/N): '

  if gets.chomp =~ /^y(es)?$/i
    config.new_connection
  else
    continue = true
  end
end

config.ssh_key_path

danarchysys_config = config.load_config

puts 'Available OpenStack Connections: '
danarchysys_config[:connections].each_key { |k| puts k }
puts "SSH key location: #{danarchysys_config[:settings][:ssh_key_path]}"
puts "Config saved to: #{File.expand_path('..', File.dirname(__FILE__))}/config/danarchysys.yml"
puts "dAnarchySys setup is finished. Run \'/usr/bin/ruby danarchy_sys/bin/danarchy_sys\' to begin!"
