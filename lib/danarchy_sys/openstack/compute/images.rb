
# OpenStack Image Management
class ComputeImages
  def initialize(compute)
    @compute = compute
  end
  
  def all_images
    @compute.images
  end

  def list_images
    images = all_images
    image_list = []

    # Get image names into array
    images.each do |i|
      next unless i.status == 'ACTIVE'
      image_list.push(i.name)
    end

    image_list
  end

  def get_image_by_name(image_name)
    images = all_images

    # Get image based on input image_name.
    image = 'nil'
    images.each do |i|
      next unless i.name == image_name
      next unless i.status == 'ACTIVE'
      image = i
    end

    image
  end

  def get_image_by_id(image_id)
    images = all_images
p image_id
    # Get image based on input image_id.
    image = 'nil'
    images.each do |i|
      next unless i.id == image_id
      next unless i.status == 'ACTIVE'
      image = i
    end

    image
  end
end
