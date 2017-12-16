
# OpenStack Flavor Management
class ComputeFlavors
  def initialize(compute, flavors)
    @compute = compute
    @flavors = flavors
  end

  def all_flavors(*filter)
    filter = filter.shift || {'status' => ['ACTIVE']}
    @flavors = @compute.flavors(filters: filter)
  end

  def get_flavor_by_name(flavor_name)
    @flavors.collect do |f|
      f if f.name.end_with?(flavor_name)
    end.compact!.first
  end

  def get_flavor_by_id(flavor_id)
    @flavors.collect do |i|
      i if i.id == flavor_id
    end.compact!.first
  end
end
