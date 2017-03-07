
class Providers
  def self.chooser
    config = ConfigMgr.new
    danarchysys_config = config.load
    providers = Helpers.array_to_numhash(danarchysys_config[:connections].keys)
    provider = 'nil'

    if providers.count == 1
      provider = providers['1']
      return provider
    end      
    
    printf("%0s %-5s\n", 'Id', 'Provider')
    providers.each { |id, provider| printf("%0s. %-5s\n", id, provider) }

    until providers.values.include?(provider)
      print 'Which provider should we use? (enter \'exit\' to leave): '
      provider = gets.chomp

      abort('Exiting') if provider == 'exit'

      if provider =~ /^[0-9]*$/ # select by Id
        provider = providers[provider.to_s]
      end
    end

    provider
  end
end
