
# OpenStack Image Management
class ComputeImages
  def initialize(compute)
    @compute = compute
  end

  def all_images(*filter)
    filter = filter.shift || {'status' => ['ACTIVE']}
    @compute.images(filters: filter)
  end

  def get_image_by_name(image_name)
    all_images.collect do |i|
      next unless i.status == 'ACTIVE'
      next unless i.name == image_name
      i
    end.compact!.first
  end

  def get_image_by_id(image_id)
    all_images.collect do |i|
      i if i.id == image_id
    end.compact!.first
  end
end
