
# OpenStack Security_Group Management
class SecurityGroups
  def initialize(net, settings)
    @net = net
    @settings = settings
  end

  def get_security_groups(*filter)
    filter = filter.shift || {}
    @net.security_groups(filters: filter)
  end

  def list_all_security_groups
    get_security_groups.collect { |n| n.name }
  end

  def get_security_group_by_name(sg_name)
    sg = get_security_groups({ 'name' => [sg_name] })
    return false if !sg.first
    return false if !sg.collect { |n| n.name }.include?(sg_name)

    if sg.count > 1
      puts " ! Warning: Multiple security_groups found for #{sg_name}!"
      puts "     Using: #{sg.first.id}"
    end

    sg.first
  end

  def create_security_group(sg_name, description)
    begin
      @net.create_security_group({ name: sg_name, description: description })
    rescue
      puts "Failed to create security group: #{sg_name}"
      raise
    ensure
      return get_security_group_by_name(sg_name)
    end
  end

  def update_security_group(sg, change)
    # ex: change = { name: 'new_sg_name' }
    begin
      @net.update_security_group(sg.id, change)
    rescue
      puts "Failed to update security group: #{sg.name}"
      raise
    ensure
      return get_security_group_by_name(sg_name)
    end
  end

  def delete_security_group(sg)
    # sg = get_security_group(sg) if sg.class == String
    # return 1 if sg == false

    sg_name = sg.name
    begin
      @net.delete_security_group(sg.id)
    rescue
      puts "Failed to delete security group: #{sg.name}"
      raise
    ensure
      get_security_group_by_name(sg_name) == false
    end
  end

  def get_security_group_rules(sg, filters)
    # filters = { direction:        ['ingress','egress'],
    #             port_range_min:   String,
    #             port_range_max:   String,
    #             ethertype:        ['IPv4','IPv6'],
    #             protocol:         ['tcp','udp','icmp'],
    #             remote_ip_prefix: String,
    #             remote_group_id:  String }

    sg_rules = []
    sg.security_group_rules.each do |sgr|
      verify = Hash.new

      filters = Helpers.object_to_hash(filters) if !filters.is_a?(Hash)
      filters.each do |k, v|
        verify[k.to_sym] = sgr.send(k)
      end

      sg_rules.push(sgr) if verify == filters
    end

    if sg_rules.empty?
      false
    elsif sg_rules.count > 1
      puts "#{sg_rules.count} rules matched filter."
      sg_rules
    else
      sg_rules.first
    end
  end

  def create_security_group_rule(sg, opts)
    # opts = { direction:        ['ingress','egress'],
    #          port_range_min:   String,
    #          port_range_max:   String,
    #          ethertype:        ['IPv4','IPv6'],
    #          protocol:         ['tcp','udp','icmp'],
    #          remote_ip_prefix: String,
    #          remote_group_id:  String }

    # sg = get_security_group_by_name(sg) if sg.class == String
    # return 1 if sg == false
    direction = opts[:direction]
    opts[:protocol] = opts[:protocol] ? opts[:protocol] : 'tcp'
    opts[:ethertype] = opts[:ethertype] ? opts[:ethertype] : 'IPv4'

    begin
      @net.create_security_group_rule(sg.id, direction, opts)
    rescue
      puts "Failed to create security group rule!"
      raise
    ensure
      sg = get_security_group_by_name(sg.name)
      get_security_group_rules(sg, opts)
    end

    sg
  end

  def delete_security_group_rule(sg, rule)
    # rule = get_security_group_rule(sg, filters)
    # if !rule
    #   puts "Security group rule does not exist!"
    #   return false
    # end

    begin
      @net.delete_security_group_rule(rule.id)
    rescue
      puts "Failed to delete security group rule!"
      raise
    ensure
      sg = get_security_group_by_name(sg.name)
      get_security_group_rules(sg, rule) == false
    end

    sg
  end
end

# sg = @net.security_groups.get_security_group('sg_danarchy_ctr')
# sg = secgroups.delete_security_group_rule(sg, {remote_ip_prefix: "173.114.132.244/32"})
# addr = Net::HTTP.get(uri)
# sg = secgroups.create_security_group_rule(sg, 'ingress', {port_range_min: '22', port_range_max: '22', ethertype: 'IPv4', protocol: 'tcp', remote_ip_prefix: addr})
