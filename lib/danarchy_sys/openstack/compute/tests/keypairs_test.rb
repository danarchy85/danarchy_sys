#!/usr/bin/env ruby
require 'fog/openstack'
require_relative '../../../../danarchy_sys'

provider = 'os_dreamcompute'.to_sym
config = ConfigMgr.new
danarchysys_config = config.load

connection = danarchysys_config[:connections][provider]
settings = danarchysys_config[:settings]
compute = Fog::Compute::OpenStack.new(connection)

keypair_names = ["test", "test01", "test02", "test03", "test04"]
# keypair, pemfile = InstancePrompts.keypair(compute)
# puts "Keypair: #{keypair.name}"
# puts "   .pem: #{pemfile}"
# keypair_name = keypair.name

# keypair_name = 'test02'
# pemfile = ComputeKeyPairs.pemfile_path(keypair_name)
# puts "Creating keypair: #{keypair_name}"
# keypair, pemfile = ComputeKeyPairs.create_keypair(compute, keypair_name, pemfile)
# keypair = ComputeKeyPairs.keypair_get(compute, keypair_name)
# puts "Keypair: #{keypair.name}"
# puts "   .pem: #{pemfile}"

puts "\nListing keypairs...", ComputeKeyPairs.list_keypairs(compute)

# print "\npemfile_check: ", ComputeKeyPairs.pemfile_check(pemfile)
# print "\nkeypair_check: ", ComputeKeyPairs.keypair_check(compute, keypair_name)

keypair_names.each do |keypair_name|
  puts "\nDeleting keypair: #{keypair_name}!"
  ComputeKeyPairs.delete_keypair(settings, compute, keypair_name)
  print "\nPost delete keypair_check: ", ComputeKeyPairs.check_keypair(compute, keypair_name), "\n"
end

#  print "\nPost delete pemfile_check: ", ComputeKeyPairs.pemfile_check(pemfile)
