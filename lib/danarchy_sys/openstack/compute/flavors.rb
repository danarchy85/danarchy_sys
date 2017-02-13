
# OpenStack Flavor Management
class ComputeFlavors
  def self.all_flavors(compute)
    compute.flavors
  end

  def self.list_flavors(compute)
    flavors = all_flavors(compute)
    flavor_list = []

    # Get flavor names into array
    flavors.each do |i|
      flavor_list.push(i.name.split('.')[1])
    end

    flavor_list
  end

  def self.get_flavor(compute, flavor_name)
    flavors = all_flavors(compute)

    # Get flavor object based on input flavor_name.
    flavor = 'nil'
    flavors.each do |f|
      flavor = f if f.name.end_with?(flavor_name)
    end

    flavor
  end
end
