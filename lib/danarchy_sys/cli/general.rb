
# General methods for DanarchySys::CLI
class General
  def self.array_to_numhash(array)
    numbered_hash = {}
    
    count = 1
    array.each do |item|
      numbered_hash[count.to_s] = item
      count += 1
    end

    numbered_hash
  end
end
