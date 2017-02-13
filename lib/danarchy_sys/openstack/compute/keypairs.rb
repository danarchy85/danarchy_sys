
# OpenStack Keypair Management
class ComputeKeyPairs
  def self.pemfile_path(keypair_name)
    "#{ENV['HOME']}/.ssh/fog_keys/openstack/fog_#{keypair_name}.pem"
  end

  def self.pemfile_check(pemfile)
    return true if File.exist?(pemfile)
    false
  end

  def self.all_keypairs(compute)
    compute.key_pairs
  end

  def self.keypair_list(compute)
    keypair_list = []
    keypairs = all_keypairs(compute)

    keypairs.each do |kp|
      keypair_list.push(kp.name)
    end

    keypair_list
  end

  def self.keypair_check(compute, keypair_name)
    keypairs = keypair_list(compute)

    return true if keypairs.include?(keypair_name)
    false
  end

  def self.keypair_get(compute, keypair_name)
    keypairs = all_keypairs(compute)
    keypair = 'nil'

    keypairs.each do |kp|
      keypair = kp if kp.name == keypair_name
    end

    keypair
  end

  def self.create_keypair(compute, keypair_name, pemfile)
    keypair = compute.create_key_pair(keypair_name)

    # create pemfile at ~/.ssh/fog_keys/openstack/
    keyhash = keypair.body['keypair']
    private_key = keyhash['private_key']
    file = File.open(pemfile, 'w') if private_key && ENV.key?('HOME')
    file.puts(private_key)
    file.chmod(0o600)

    # Verify and return keypair & pemfile
    keypair = keypair_get(compute, keypair_name)
    [keypair, pemfile] if keypair_check(compute, keypair_name) == true && pemfile_check(pemfile) == true
  end

  def self.delete_keypair(compute, keypair_name, pemfile)
    # check for and delete key and .pem file
    pem_check = pemfile_check(pemfile)
    kp_check = keypair_check(compute, keypair_name)

    compute.delete_key_pair(keypair_name) if kp_check  == true
    File.delete(pemfile) if pem_check == true
  end
end
