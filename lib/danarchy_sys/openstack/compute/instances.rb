
# OpenStack Instance Management
class ComputeInstances
  def initialize(compute, instances, settings)
    @compute = compute
    @instances = instances
    @settings = settings
  end
  
  def all_instances(*filter)
    filter = filter.shift || {}
    @instances = @compute.servers(filters: filter)
  end

  def list_all_instances
    @instances.collect { |i| i.name }
  end

  def list_active_instances
    @instances.collect do |i|
      i.name if i.state == 'ACTIVE'
    end.compact!
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
    instance = get_instance(instance) if instance.class == String
    addrs = instance.addresses
    return nil if !addrs['public']
    addrs['public'].map{|a| a['addr']}
  end

  def get_private_addresses(instance)
    instance = get_instance(instance) if instance.class == String
    addrs = instance.addresses
    return nil if !addrs['private']
    addrs['public'].map{|a| a['addr']}
  end

  def pause(instance)
    instance = get_instance(instance) if instance.class == String

    return false unless instance.state == 'ACTIVE'
    instance.pause
  end

  def unpause(instance)
    instance = get_instance(instance) if instance.class == String

    return false unless instance.state == 'PAUSED'
    instance.start
  end

  def suspend(instance)
    instance = get_instance(instance) if instance.class == String

    return false unless instance.state == 'ACTIVE'
    instance.suspend
  end

  def resume(instance)
    instance = get_instance(instance) if instance.class == String

    return false unless instance.state == 'SUSPENDED'
    instance.start
  end

  def start(instance)
    instance = get_instance(instance) if instance.class == String

    return false unless instance.state == 'SHUTOFF'
    instance.start
  end

  def stop(instance)
    instance = get_instance(instance) if instance.class == String

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
    # add volumes
    # handle user_data with base64 encoding

    # Put error handling from instance_prompts here
    
    instance.wait_for { ready? }
    instance
  end

  def rebuild_instance(instance, image)
    instance = get_instance(instance) if instance.class == String

    instance.rebuild(image.id, instance.name)
    addrs = [get_public_addresses(instance),
             get_private_addresses(instance)].flatten.compact!
    addrs.each { |addr| system("ssh-keygen -R #{addr}") }

    instance.wait_for { ready? }
    instance
  end

  def delete_instance(instance)
    instance = get_instance(instance) if instance.class == String    
    return 1 if instance == false

    instance_name = instance.name
    @compute.delete_server(instance.id)

    attempt = 1
    until check_instance(instance_name) == false
      return false if attempt == 5
      sleep(5)
      attempt += 1
    end

    addrs = [get_public_addresses(instance),
             get_private_addresses(instance)].flatten.compact!
    addrs.each { |addr| system("ssh-keygen -R #{addr}") }

    return true
  end
end
