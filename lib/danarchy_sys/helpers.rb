
# Routine methods for DanarchySys
class Helpers
  def self.array_to_numhash(array)
    numbered_hash = {}
    
    count = 1
    array.sort.each do |item|
      numbered_hash[count] = item
      count += 1
    end

    numbered_hash
  end

  def self.hash_to_numhash(hash)
    numbered_hash = {}

    hash.map.with_index(1) do | (k, v), index |
      numbered_hash[index] = {k => v}
    end

    numbered_hash
  end

  def self.objects_to_numhash(objects)
    numbered_object_hash = {}

    objects.map.with_index(1) do | obj, index |
      numbered_object_hash[index] = obj.all_attributes
    end

    numbered_object_hash
  end

  def self.hash_largest_key(hash)
    hash.keys.map(&:to_s).max_by(&:size)
  end

  def self.hash_largest_value(hash)
    hash.values.map(&:to_s).max_by(&:size)
  end

  def self.hash_largest_nested_key(hash)
    hash.each_value.flat_map(&:keys).max_by(&:size)
  end

  def self.hash_largest_nested_value(hash)
    hash.each_value.flat_map(&:values).max_by(&:size)
  end

  def self.check_nested_hash_value(hash, key, value)
    check = false

    hash.each_value do |val|
      check = true if val[key].end_with?(value)
    end

    check
  end
end
