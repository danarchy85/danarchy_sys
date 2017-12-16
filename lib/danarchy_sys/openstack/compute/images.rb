
# OpenStack Image Management
class ComputeImages
  def initialize(compute, images)
    @compute = compute
    @images = images
  end

  def all_images(*filter)
    filter = filter.shift || {'status' => ['ACTIVE']}
    @images = @compute.images(filters: filter)
  end

  def get_image_by_name(image_name)
    @images.collect do |i|
      next unless i.status == 'ACTIVE'
      next unless i.name == image_name
      i
    end.compact!.first
  end

  def get_image_by_id(image_id)
    @images.collect do |i|
      i if i.id == image_id
    end.compact!.first
  end
end
