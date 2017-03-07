
# OpenStack Instance Management
class ComputeInstances
  def self.all_instances(compute)
    compute.servers
  end

  def self.list_all_instances(compute)
    instances = all_instances(compute)
    instance_list = []

    instances.each do |i|
      instance_list.push(i.name)
    end

    instance_list
  end

  def self.list_active_instances(compute)
    instances = all_instances(compute)
    instance_list = []

    instances.each do |i|
      instance_list.push(i.name) if i.state == 'ACTIVE'
    end

    instance_list
  end

  def self.check_instance(compute, instance_name)
    instances = list_all_instances(compute)

    return true if instances.include?(instance_name)
    false
  end

  def self.get_instance(compute, instance_name)
    servers = all_instances(compute)

    # Get servers ID based on input instance_name
    instance = 'nil'
    servers.each do |i|
      instance = i if i.name.end_with?(instance_name)
    end

    return false unless instance
    instance
  end

  def self.get_addresses(compute, instance_name)
    instance = get_instance(compute, instance_name)

    addresses = instance.addresses['public']
    ipv6, ipv4 = addresses[0], addresses[1]
  end

  def self.pause_instance(compute, instance_name)
    instance = get_instance(compute, instance_name)
    compute.pause_server(instance.id)
  end

  def self.unpause_instance(compute, instance_name)
    instance = get_instance(compute, instance_name)
    compute.unpause_server(instance.id)
  end

  def self.suspend_instance(compute, instance_name)
    instance = get_instance(compute, instance_name)
    compute.suspend_server(instance.id)
  end

  def self.resume_instance(compute, instance_name)
    instance = get_instance(compute, instance_name)
    compute.resume_server(instance.id)
  end

  def self.start_instance(compute, instance_name)
    instance = get_instance(compute, instance_name)
    compute.start_server(instance.id)
  end

  def self.stop_instance(compute, instance_name)
    instance = get_instance(compute, instance_name)
    compute.stop_server(instance.id)
  end

  def self.create_instance(compute, instance_name, image_id, flavor_id, keypair_name)
    instance = compute.servers.create(name: instance_name,
                                      image_ref: image_id,
                                      flavor_ref: flavor_id,
                                      key_name: keypair_name)
    # add security_group

    # Put error handling from instance_prompts here
    
    instance.wait_for { ready? }
    instance
  end

  def self.delete_instance(compute, instance_name)
    # check for and delete instance
    instance = get_instance(compute, instance_name)
    return 1 if instance == false
    compute.delete_server(instance.id)

    attempt = 1
    until check_instance(compute, instance_name) == false
      return false if attempt == 5
      sleep(5)
      attempt += 1
    end

    return true
  end
end
