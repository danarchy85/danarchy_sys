
# OpenStack Router Management
class Routers
  def initialize(net, settings)
    @net = net
    @settings = settings
  end

  def all_routers(*filter)
    filter = filter.shift || {}
    @net.routers(filters: filter)
  end

  def list_all_routers
    all_routers.collect { |n| n.name }
  end

  def get_router(router_name)
    router = all_routers({ 'name' => [router_name] })
    return false if !router.first
    return false if !router.collect { |n| n.name }.include?(router_name)

    if router.count > 1
      puts " ! Warning: Multiple routers found for #{router_name}!"
      puts "     Using: #{router.first.id}"
    end

    router.first
  end
end
