
class KeypairStatus
  def self.all_keypairs(os_compute)
    keypairs = os_compute.keypairs.all_keypairs

    keypairs.each do |keypair|
      single_keypair(keypair)
    end

  end

  def self.single_keypair(keypair)
    istats = { 'Name'        => keypair.name,
               'Fingerprint' => keypair.fingerprint,
               'Public Key'  => keypair.public_key, }

    format = "%#{istats.keys.max.size + 2}s"

    istats.each do |k, v|
      printf("#{format} %0s\n", "#{k}:", v)
    end
  end
end
