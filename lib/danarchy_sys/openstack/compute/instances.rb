
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
    all_instances.collect do |i|
      i.name if i.state == 'ACTIVE'
    end.compact!
  end

  def check_instance(instance_name)
    return false if instance_name == nil || instance_name.empty?
    return true if get_instance(instance_name)
    false
  end

  def get_instance(instance_name)
    instance = all_instances({ 'name' => [instance_name] })
    return false if !instance.first
    return false if !instance.collect{ |i| i.name }.include?(instance_name)

    if instance.count > 1
      puts " ! Warning: Multiple instances found matching #{instance_name}!"
      puts "     Using: #{instance.first.id} => #{instance.name}"
    end

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

  def create_instance(instance_name, image_id, flavor_id, keypair_name, opts = {})
    # opts = {nics: [{:net_id=>"NetworkID"}], user_data: "#!/bin/bash\n Shell Content"
    nics = opts[:nics] ? opts[:nics] : nil
    user_data = opts[:user_data] ? opts[:user_data] : nil

    instance = @compute.servers.create(name:      instance_name,
                                      image_ref:  image_id,
                                      flavor_ref: flavor_id,
                                      key_name:   keypair_name,
                                      nics:       opts[:nics] ? opts[:nics] : nil,
                                      user_data:  opts[:user_data] ? opts[:user_data] : nil)
    
    # add security_group
    # add volumes

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
    addrs.each { |addr| system("ssh-keygen -R #{addr} &>/dev/null") }

    return true
  end

  def rebuild_instance(instance, image)
    instance = get_instance(instance) if instance.class == String

    instance.rebuild(image.id, instance.name)
    addrs = [get_public_addresses(instance),
             get_private_addresses(instance)].flatten.compact!
    addrs.each { |addr| system("ssh-keygen -R #{addr} &>/dev/null") }

    # instance.wait_for { ready? }
    get_instance(instance.name)
  end

  def ssh_connector(instance)
    addrs = get_public_addresses(instance.name)
    { ipv4: addrs.grep(/\./).first,
      ipv6: addrs.grep(/:/).first,
      ssh_user: user,
      ssh_key: pemfile }
  end
end
