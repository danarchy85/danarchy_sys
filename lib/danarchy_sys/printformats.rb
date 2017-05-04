
class PrintFormats
  def self.printf_numhash(hash)
    (fields, a) = [], []

    fields.push("%-#{Helpers.hash_largest_key(hash).size + 1}s")
    fields.push("%#{Helpers.hash_largest_nested_key(hash).size + 1}s")
    fields.push("%-#{Helpers.hash_largest_nested_value(hash).size}s")

    fields.join(' ')
  end

  def self.printf_hash(hash)
    (fields, a) = [], []

    fields.push("%-#{Helpers.hash_largest_key(hash).size}s")
    fields.push("%-#{Helpers.hash_largest_value(hash).size}s")

    fields.join(' ')
  end

  def self.printf_numhash_values(hash, fields_arr)
    (fields, a) = [], []

    fields.push("%-#{Helpers.hash_largest_key(hash).size + 1}s")

    fields_arr.each do |f|
      hash.each_value do |v|
        next if v[f] == nil
        a.push(v[f].size)
      end

      fields.push("%-#{a.max}s")
      a = []
    end

    fields.join(' ')
  end
end
