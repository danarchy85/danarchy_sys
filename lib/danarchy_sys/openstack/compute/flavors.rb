
# OpenStack Flavor Management
class ComputeFlavors
  def initialize(compute)
    @compute = compute
  end

  def all_flavors
    @compute.flavors
  end

  def list_flavors
    flavors = all_flavors
    flavor_list = []

    # Get flavor names into array
    flavors.each do |i|
      flavor_list.push(i.name.split('.')[1])
    end

    flavor_list
  end

  def get_flavor(flavor_name)
    flavors = all_flavors

    # Get flavor object based on input flavor_name.
    flavor = 'nil'
    flavors.each do |f|
      flavor = f if f.name.end_with?(flavor_name)
    end

    flavor
  end

  def get_flavor_by_id(flavor_id)
    flavors = all_flavors

    # Get flavor based on input flavor_id.
    flavor = 'nil'
    flavors.each do |i|
      flavor = i if i.id == flavor_id
    end

    flavor
  end
end
