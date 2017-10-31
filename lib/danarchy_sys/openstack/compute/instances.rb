
# OpenStack Instance Management
class ComputeInstances
  def initialize(compute, settings)
    @compute = compute
    @settings = settings
  end
  
  def all_instances(*filter)
    filter = filter.shift || {}
    @compute.servers(filters: filter)
  end

  def list_all_instances
    all_instances.collect { |i| i.name }
  end

  def list_active_instances
    all_instances({ 'status' => ['ACTIVE'] }).collect { |i| i.name }
  end

  def check_instance(instance_name)
    return false if instance_name == nil || instance_name.empty? == true
    return true if get_instance(instance_name)
    false
  end

  def get_instance(instance_name)
    instance = all_instances({ 'name' => [instance_name] })
    return false if !instance.first
    return false if !instance.collect{ |i| i.name }.include?(instance_name)
    instance.first
  end

  def get_public_addresses(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    addrs = instance.addresses
    return false if !addrs['public']
    addrs['public'].map{|a| a['addr']}
  end

  def get_private_addresses(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    addrs = instance.addresses
    return false if !addrs['private']
    addrs['public'].map{|a| a['addr']}
  end

  def pause(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    return false unless instance.state == 'ACTIVE'
    instance.pause
  end

  def unpause(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    return false unless instance.state == 'PAUSED'
    instance.start
  end

  def suspend(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    return false unless instance.state == 'ACTIVE'
    instance.suspend
  end

  def resume(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    return false unless instance.state == 'SUSPENDED'
    instance.start
  end

  def start(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    return false unless instance.state == 'SHUTOFF'
    instance.start
  end

  def stop(instance)
    if instance.class == String
      instance = get_instance(instance)
    end

    return false unless instance.state == 'ACTIVE'
    instance.stop
  end

  def create_instance(instance_name, image_id, flavor_id, keypair_name, *user_data)
    user_data = nil if user_data.empty?

    instance = @compute.servers.create(name: instance_name,
                                      image_ref: image_id,
                                      flavor_ref: flavor_id,
                                      key_name: keypair_name,
                                      user_data: user_data)
    
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
