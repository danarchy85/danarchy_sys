
# OpenStack Keypair Management
class ComputeKeypairs
  def initialize(compute, settings)
    @compute = compute
    @settings = settings
  end

  def pemfile_path(keypair_name)
    "#{@settings[:ssh_key_path]}/#{keypair_name}.pem"
  end

  def pemfile_check(pemfile)
    return true if File.exist?(pemfile)
    false
  end

  def all_keypairs
    @compute.key_pairs
  end

  def list_keypairs
    keypair_list = []
    keypairs = all_keypairs

    keypairs.each do |kp|
      keypair_list.push(kp.name)
    end

    keypair_list
  end

  def check_keypair(keypair_name)
    keypairs = list_keypairs

    return true if keypairs.include?(keypair_name)
    false
  end

  def get_keypair(keypair_name)
    keypairs = all_keypairs
    keypair = 'nil'

    keypairs.each do |kp|
      keypair = kp if kp.name == keypair_name
    end

    keypair
  end

  def create_keypair(keypair_name)
    keypair = @compute.create_key_pair(keypair_name)
    pemfile = pemfile_path(keypair_name)

    # create pemfile at pemfile_path
    keyhash = keypair.body['keypair']
    private_key = keyhash['private_key']
    File.open(pemfile, 'w') do |f|
      f.puts(private_key)
      f.chmod(0600)
    end

    # Verify and return keypair & pemfile
    keypair_check = check_keypair(keypair_name)
    pemfile_check = pemfile_check(pemfile)
    if keypair_check == true && pemfile_check == true
      puts "Created keypair and pemfile for #{keypair_name}!"
      return get_keypair(keypair_name)
    else
      abort("Error: Could not create keypair: #{keypair}") if keypair_check == false
      abort("Error: Could not create pemfile: #{pemfile}") if pemfile_check == false
    end
  end

  def delete_keypair(keypair_name)
    # check for and delete key and .pem file
    pemfile = pemfile_path(keypair_name)
    pem_check = pemfile_check(pemfile)
    kp_check = check_keypair(keypair_name)

    if kp_check  == true
      @compute.delete_key_pair(keypair_name)
      puts "Deleted keypair: #{keypair_name}"
    end

    if pem_check == true
      File.delete(pemfile)
      puts "Deleted pemfile: #{pemfile}"
    end

    return true if check_keypair(keypair_name) == false
    false
  end
end
