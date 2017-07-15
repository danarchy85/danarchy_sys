
# OpenStack Instance Management
class ComputeInstances
  def initialize(compute, settings)
    @compute = compute
    @settings = settings
  end
  
  def all_instances
    @compute.servers
  end

  def list_all_instances
    instances = all_instances
    instances.map(&:name)
  end

  def list_active_instances
    instances = all_instances
    instance_list = []

    instances.each do |i|
      instance_list.push(i.name) if i.state == 'ACTIVE'
    end

    instance_list
  end

  def check_instance(instance_name)
    instances = list_all_instances

    return true if instances.include?(instance_name)
    false
  end

  def get_instance(instance_name)
    servers = all_instances

    # Get servers ID based on input instance_name
    instance = 'nil'
    servers.each do |i|
      instance = i if i.name.end_with?(instance_name)
    end

    return false unless instance
    instance
  end

  def get_addresses(instance_name)
    instance = get_instance(instance_name)
   (ipv6, ipv4) = nil, nil
   addresses = instance.addresses['public']

    addresses.each do |i|
      ipv4 = i['addr'] if i['addr'].include?('.')
      ipv6 = i['addr'] if i['addr'].include?(':')
    end

    return ipv4, ipv6
  end

  def pause(instance_name)
    instance = get_instance(instance_name)
    return false unless instance.state == 'ACTIVE'
    @compute.pause_server(instance.id)
  end

  def unpause(instance_name)
    instance = get_instance(instance_name)
    return false unless instance.state == 'PAUSED'
    @compute.unpause_server(instance.id)
  end

  def suspend(instance_name)
    instance = get_instance(instance_name)
    return false unless instance.state == 'ACTIVE'
    @compute.suspend_server(instance.id)
  end

  def resume(instance_name)
    instance = get_instance(instance_name)
    return false unless instance.state == 'SUSPENDED'
    @compute.resume_server(instance.id)
  end

  def start(instance_name)
    instance = get_instance(instance_name)
    return false unless instance.state == 'SHUTOFF'
    @compute.start_server(instance.id)
  end

  def stop(instance_name)
    instance = get_instance(instance_name)
    return false unless instance.state == 'ACTIVE'
    @compute.stop_server(instance.id)
  end

  def create_instance(instance_name, image_id, flavor_id, keypair_name)
    instance = @compute.servers.create(name: instance_name,
                                      image_ref: image_id,
                                      flavor_ref: flavor_id,
                                      key_name: keypair_name)
    # add security_group

    # Put error handling from instance_prompts here
    
    instance.wait_for { ready? }
    instance
  end

  def delete_instance(instance_name)
    # check for and delete instance
    instance = get_instance(instance_name)
    return 1 if instance == false
    @compute.delete_server(instance.id)

    attempt = 1
    until check_instance(instance_name) == false
      return false if attempt == 5
      sleep(5)
      attempt += 1
    end

    return true
  end
end
