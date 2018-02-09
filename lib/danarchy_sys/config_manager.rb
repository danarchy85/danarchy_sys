require 'fileutils'
require 'json'
require_relative 'config_manager/openstack'

# dAnarchy_sys config management
module DanarchySys
  module ConfigManager
    class Config
      def self.new
        danarchysys_cfg_path = File.join(File.realpath(ENV['HOME']), '.danarchy_sys')
        config_json = File.join(danarchysys_cfg_path, 'danarchy_sys.json')

        if File.exists?(config_json)
          return JSON.parse(File.read(config_json), symbolize_names: true)
        else
          puts 'No existing configuration found!'
          return new_config(danarchysys_cfg_path, config_json)
        end
      end
      
      def self.providers
        ['openstack'] # , 'aws']
      end

      def self.config_template
        config_template = {
          global_settings: {
            ssh_key_path: nil
          },
          accounts: {}
        }
      end

      def self.new_config(danarchysys_cfg_path, config_json)
        config = config_template
        ssh_path = File.join(danarchysys_cfg_path, 'ssh')

        puts "dAnarchy_sys config location: #{danarchysys_cfg_path}"
        FileUtils.mkdir_p(danarchysys_cfg_path, mode: 0700) unless Dir.exist?(danarchysys_cfg_path)

        print "Default ssh key location: #{ssh_path}. Is this location okay?: (Y/N) "
        answer = gets.chomp

        until answer =~ /^y(es)?$/i
          print 'Enter a path for SSH keys: '
          ssh_path = gets.chomp
          print "Setting SSH key path to: #{ssh_path}. Is this location okay? (Y/N): "
          answer = gets.chomp
        end

        puts "SSH key path set to: #{ssh_path}"
        FileUtils.mkdir_p(ssh_path, mode: 0700) unless Dir.exist?(ssh_path)
        global_setting_add(config, 'ssh_key_path', ssh_path)

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
              if num_providers.keys.include?(provider.to_i)
                provider = num_providers[provider.to_i]
              else
                print "#{provider} is not a valid Id. "
              end
            end

            if provider.empty? || providers.include?(provider) == false
              print 'Invalid input! '
            end
          end
        else
          provider = providers[0] # default to OpenStack
        end

        if provider == 'danarchy'
          puts 'Need to implement setup for dAnarchy!'
        elsif provider == 'openstack'
          puts 'Adding a new OpenStack account!'
          print 'Enter a provider name for this account: '
          provider = gets.chomp
          cfg_openstack = DanarchySys::ConfigManager::OpenStack.new(provider, config)
          config = cfg_openstack.new_account_prompt
        elsif provider == 'aws'
          # Placeholder
          puts 'AWS not yet implemented!'
        end

        save(config_json, config)
        puts "Configuration has been saved to #{config_json}"
        puts "Copy any existing #{provider} SSH keys to: #{ssh_path}"
        config
      end

      def self.save(config_file, param_hash)
        File.write(config_file, JSON.pretty_generate(param_hash))
      end


      def self.global_setting_add(config, name, value)
        config[:global_settings][name.to_sym] = value
      end

      def self.global_setting_delete(config, name)
        config[:global_settings].delete(name.to_sym)
      end
    end
  end
end
