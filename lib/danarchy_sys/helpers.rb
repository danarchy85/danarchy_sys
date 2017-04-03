
# Routine methods for DanarchySys
class Helpers
  def self.array_to_numhash(array)
    numbered_hash = {}
    
    count = 1
    array.sort.each do |item|
      numbered_hash[count.to_s] = item
      count += 1
    end

    numbered_hash
  end

  def self.hash_to_numhash(hash)
    numbered_hash = {}

    hash.map.with_index do | (k, v), index |
      index += 1
      numbered_hash[index] = {k => v}
    end

    numbered_hash
  end

  def self.objects_to_numhash(objects)
    numbered_object_hash = {}

    objects.map.with_index do | obj, index |
      index += 1
      numbered_object_hash[index] = obj.all_attributes
    end

    numbered_object_hash
  end

  def self.hash_largest_key(hash)
    hash.keys.map(&:to_s).max_by(&:length)
  end

  def self.hash_largest_value(hash)
    hash.values.max_by(&:length)
  end

  def self.check_nested_hash_value(hash, key, value)
    check = false

    hash.each_value do |val|
      check = true if val[key].end_with?(value)
    end

    check
  end
end
