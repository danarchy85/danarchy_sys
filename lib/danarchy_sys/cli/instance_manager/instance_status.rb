
class InstanceStatus
  def initialize(os_compute)
    @images = os_compute.images
    @flavors = os_compute.flavors
  end

  def all_instances(instances)
    istats = {}

    instances.map.with_index(1) do |instance, id|
      istats[id] = single_instance(instance)
    end

    fields = %w[name status image vcpus ram disk keypair]
    format = PrintFormats.printf_numhash_values(istats, fields)
    _header(format)

    istats.each do |id, i|
      printf("#{format}\n", "#{id}.",
             i['name'],
             i['status'],
             i['image'],
             i['vcpus'],
             i['ram'],
             i['disk'],
             i['keypair'],
            )
    end

    istats
  end

  def single_instance(instance)
    image  = @images.get_image_by_id(instance.image['id'])
    flavor = @flavors.get_flavor_by_id(instance.flavor['id'])

    image = NilImage.new if image == nil

    istats = { 'name'  => instance.name,
               'status' => instance.state,
               'image' => image.name,
               'vcpus' => flavor.vcpus,
               'ram'   => flavor.ram,
               'disk'  => flavor.disk,
               'keypair' => instance.key_name,
             }
  end

  def _header(format)
    printf("#{format}\n", 'Id', 'Name', 'Status', 'Image', 'VCPUS', 'RAM', 'Disk', 'KeyPair')
  end

  class NilImage
    def name
      'Not Found'
    end
  end
end

