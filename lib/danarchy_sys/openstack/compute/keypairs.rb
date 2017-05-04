
# OpenStack Keypair Management
class ComputeKeyPairs
  def self.pemfile_path(settings, keypair_name)
    "#{settings[:ssh_key_path]}/fog_#{keypair_name}.pem"
  end

  def self.pemfile_check(pemfile)
    return true if File.exist?(pemfile)
    false
  end

  def self.all_keypairs(compute)
    compute.key_pairs
  end

  def self.list_keypairs(compute)
    keypair_list = []
    keypairs = all_keypairs(compute)

    keypairs.each do |kp|
      keypair_list.push(kp.name)
    end

    keypair_list
  end

  def self.check_keypair(compute, keypair_name)
    keypairs = list_keypairs(compute)

    return true if keypairs.include?(keypair_name)
    false
  end

  def self.get_keypair(compute, keypair_name)
    keypairs = all_keypairs(compute)
    keypair = 'nil'

    keypairs.each do |kp|
      keypair = kp if kp.name == keypair_name
    end

    keypair
  end

  def self.create_keypair(settings, compute, keypair_name)
    keypair = compute.create_key_pair(keypair_name)
    pemfile = pemfile_path(settings, keypair_name)

    # create pemfile at pemfile_path
    keyhash = keypair.body['keypair']
    private_key = keyhash['private_key']
    File.open(pemfile, 'w') do |f|
      f.puts(private_key)
      f.chmod(0600)
    end

    # Verify and return keypair & pemfile
    keypair_check = check_keypair(compute, keypair_name)
    pemfile_check = pemfile_check(pemfile)
    if keypair_check == true && pemfile_check == true
      puts "Created keypair and pemfile for #{keypair_name}!"
      return get_keypair(compute, keypair_name)
    else
      abort("Error: Could not create keypair: #{keypair}") if keypair_check == false
      abort("Error: Could not create pemfile: #{pemfile}") if pemfile_check == false
    end
  end

  def self.delete_keypair(settings, compute, keypair_name)
    # check for and delete key and .pem file
    pemfile = pemfile_path(settings, keypair_name)
    pem_check = pemfile_check(pemfile)
    kp_check = check_keypair(compute, keypair_name)

    compute.delete_key_pair(keypair_name) if kp_check  == true
    File.delete(pemfile) if pem_check == true
  end
end
