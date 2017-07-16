
class Providers
  def self.chooser
    danarchysys_config = DanarchySys::ConfigManager::Config.new
    providers = Helpers.array_to_numhash(danarchysys_config[:connections].keys)
    provider = 'nil'

    if providers.count == 1
      provider = providers['1']
      return provider
    end      

    fields = PrintFormats.printf_hash(providers)
    printf("#{fields}\n", 'Id', 'Provider')
    providers.each do |id, provider|
      printf("#{fields}\n", "#{id}.", provider)
    end

    until providers.values.include?(provider)
      print 'Which provider should we use? (enter \'exit\' to leave): '
      provider = gets.chomp

      abort('Exiting') if provider == 'exit'

      if provider =~ /^[0-9]*$/
        provider = providers[provider.to_i]
      else
        provider = provider.to_sym
      end
    end

    provider
  end
end
