
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

  def self.objects_to_numhash(objects)
    numbered_object_hash = {}

    count = 1
    objects.each do |obj|
      numbered_object_hash[count.to_s] = obj.all_attributes
      count += 1
    end

    numbered_object_hash
  end

  def self.hash_largest_value(hash)
    hash.values.max_by(&:length).length
  end

  # Search for a given value within a given key within a given nested hash
  def self.check_nested_hash_value(hash, key, value)
    check = false

    hash.each_value do |val|
      check = true if val[key].end_with?(value)
    end

    check
  end
end
