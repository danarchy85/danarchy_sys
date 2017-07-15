require 'yaml'
require_relative 'config_manager/openstack'

# dAnarchy_sys config management
module DanarchySys
  module ConfigManager
    class Config
      def self.new
        @danarchysys_path = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
        @config_file = File.join(@danarchysys_path, 'config', 'danarchysys.yml')

        if File.exists?(@config_file)
          return YAML.load_file(@config_file)
        else
          puts 'No existing configuration found!'
          return new_config
        end
      end
      
      def self.providers
        ['openstack'] # , 'aws']
      end

      def self.config_template
        config_template = {
          global_settings: {
            ssh_key_path: "#{@danarchysys_path}/config/ssh"
          },
          connections: {}
        }
      end

      def self.new_config
        config = config_template
        
        provider = nil
        if providers.count > 1
          num_providers = Helpers.array_to_numhash(providers)
          fields = PrintFormats.printf_hash(num_providers)

          printf("#{fields}\n", 'Id', 'Provider')
          num_providers.each do |k, v|
            printf("#{fields}\n", "#{k}.", v)
          end

          provider = nil
          until providers.include?(provider)
            print 'Please choose a provider: '
            provider = gets.chomp

            if provider =~ /^[0-9]*$/
              if num_providers.keys.include?(provider)
                provider = num_providers[provider]
              else
                print "#{provider} is not a valid Id. "
              end
            end

            if provider.empty? || providers.include?(provider) == false
              print 'Invalid input! '
            end
          end
        else
          provider = providers[0]
        end

        if provider == 'openstack'
          puts 'Creating a new OpenStack connection!'
          print 'Enter a provider name for this connection: '
          provider = gets.chomp
          cfg_os = DanarchySys::ConfigManager::OpenStack.new(provider, config)
          config = cfg_os.new_connection_prompt
        elsif provider == 'aws'
          # Placeholder
          puts 'AWS not yet implemented!'
        end

        save(config)
        puts 'Configuration has been saved!'
        config
      end

      def self.save(param_hash)
        File.write(@config_file, param_hash.to_yaml)
      end


      def self.global_setting_add(name, value)
        config = load
        config[:global_settings][name.to_sym] = value
      end

      def self.global_setting_delete(name)
        config = load
        config[:global_settings].delete(name.to_sym)
      end
    end
  end
end
