
require 'yaml'

# dAnarchy_sys config management
class ConfigMgr
  def initialize
    @danarchysys_path = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    @config_file = File.join(@danarchysys_path, 'config', 'danarchysys.yml')
  end

  def config_template
    config_template = {
      :connections => {},
      :settings => {}
    }
  end

  def load
    if File.exists?(@config_file)
      return YAML.load_file(@config_file)
    else
      return config_template
    end
  end

  def save(param_hash)
    File.write(@config_file, param_hash.to_yaml)
  end

  def connection_add(provider, openstack_auth_url, openstack_username, openstack_api_key, openstack_tenant)
    danarchysys_config = load

    danarchysys_config[:connections][provider.to_sym] = {
      openstack_auth_url: openstack_auth_url,
      openstack_username: openstack_username,
      openstack_api_key: openstack_api_key,
      openstack_tenant: openstack_tenant
    }

    danarchysys_config
  end

  def connection_delete(provider)
    danarchysys_config = load

    danarchysys_config[:connections].delete(provider.to_sym)

    danarchysys_config
  end

  def setting_add(name, value)
    danarchysys_config = load

    danarchysys_config[:settings][name.to_sym] = value

    danarchysys_config
  end

  def setting_delete(name)
    danarchysys_config = load

    danarchysys_config[:settings].delete(name.to_sym)

    danarchysys_config
  end
end
