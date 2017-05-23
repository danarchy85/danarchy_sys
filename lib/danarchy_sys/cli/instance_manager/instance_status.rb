
class InstanceStatus
  def self.all_instances(os_compute, instances)
    istats = {}

    id = 1
    instances.each do |instance|
      istats[id] = single_instance(os_compute, instance)
      id += 1
    end

    fields = %w[name state image ram disk keypair]
    format = PrintFormats.printf_numhash_values(istats, fields)
    _header(format)
    
    istats.each do |id, i|
      printf("#{format}\n", "#{id}.",
             i['name'],
             i['state'],
             i['image'],
             i['ram'],
             i['disk'],
             i['keypair'],
            )
    end
  end

  def self.single_instance(os_compute, instance)
    comp_inst = os_compute.compute_instances
    comp_imgs = os_compute.compute_images
    comp_flvs = os_compute.compute_flavors

    image  = comp_imgs.get_image_by_id(instance.image['id'])
    flavor = comp_flvs.get_flavor_by_id(instance.flavor['id'])

    istats = { 'name'  => instance.name,
               'state' => instance.state,
               'image' => image.name,
               'ram'   => flavor.ram,
               'disk'  => flavor.disk,
               'keypair' => instance.key_name,
             }
  end

  def self._header(format)
    printf("#{format}\n", 'Id', 'Name', 'State', 'Image', 'RAM', 'Disk', 'KeyPair')
  end
end
