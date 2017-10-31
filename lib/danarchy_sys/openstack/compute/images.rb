
# OpenStack Image Management
class ComputeImages
  def initialize(compute)
    @compute = compute
  end

  def all_images(*filter)
    filter = filter.shift || {}
    @compute.images(filters: filter)
  end

  def list_all_images
    all_images.collect { |i| i.name }
  end

  def list_active_images
    all_images({'status' => 'ACTIVE'})
  end

  def get_image_by_name(image_name)
    all_images({
                 'status' => 'ACTIVE',
                 'name'   => image_name
               }).first
    # .first may become a problem here
    # if names are duplicates
  end

  def get_image_by_id(image_id)
    image = nil
    
    all_images.each do |i|
      image = i if i.id == image_id
    end

    image
  end
end
