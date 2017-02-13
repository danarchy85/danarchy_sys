
# OpenStack Image Management
class ComputeImages
  def self.all_images(compute)
    compute.images
  end

  def self.list_images(compute)
    images = all_images(compute)
    image_list = []

    # Get image names into array
    images.each do |i|
      image_list.push(i.name)
    end

    image_list
  end

  def self.get_image_by_name(compute, image_name)
    images = all_images(compute)

    # Get image based on input image_name.
    image = 'nil'
    images.each do |i|
      image = i if i.name == image_name
    end

    image
  end

  def self.get_image_by_id(compute, image_id)
    images = all_images(compute)

    # Get image based on input image_id.
    image = 'nil'
    images.each do |i|
      image = i if i.id == image_id
    end

    image
  end
end
