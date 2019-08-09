
# OpenStack Network Management
class Networks
  def initialize(net, settings)
    @net = net
    @settings = settings
  end

  def all_networks(*filter)
    filter = filter.shift || {}
    @net.networks(filters: filter)
  end

  def list_all_networks
    all_networks.collect { |n| n.name }
  end

  def get_network(network_name)
    network = all_networks({ 'name' => [network_name] })
    return false if network.empty?
    return false if !network.collect { |n| n.name }.include?(network_name)

    if network.count > 1
      puts " ! Warning: Multiple networks found for #{network_name}!"
      puts "     Using: #{network.first.id}"
    end

    network.first
  end

  def create_network(network_name)
    begin
      @net.create_network(name: network_name)
    rescue
      puts "Failed to create network: #{network_name}"
      raise
    ensure
      return get_network(network_name)
    end
  end

  def delete_network(network)
    network = get_network(network) if network.class == String
    return 1 if network == false

    network_name = network.name
    begin
      @net.delete_network(network.id)
    rescue
      puts "Failed to delete network: #{network_name}"
      raise
    ensure
      get_network(network_name) == false
    end
  end
end
