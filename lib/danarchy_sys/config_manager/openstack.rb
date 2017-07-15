
module DanarchySys::ConfigManager
  class OpenStack
    def initialize(provider, config)
      (@provider, @config) = provider, config
      return
    end
    
    def add_connection(provider, openstack_auth_url, openstack_username, openstack_api_key, openstack_tenant)
      @config[:connections][provider.to_sym] = {
        openstack_auth_url: openstack_auth_url,
        openstack_username: openstack_username,
        openstack_api_key: openstack_api_key,
        openstack_tenant: openstack_tenant,
      }
    end

    def delete_connection
      config = load
      config.delete(@provider)
    end

    def add_setting(name, value)
      config = load
      # probably need to check if :settings exist first
      config[@provider][:settings][name.to_sym] = value
    end

    def delete_setting(name)
      config = load
      # check if name exists
      config[@provider][:settings].delete(name.to_sym)
    end

    def verify_connection
      
    end

    def new_connection_prompt
      print "OpenStack Auth URL\t(Example: http://openstack-host.com:5000/v2.0/tokens)\nEnter URL: "
      openstack_auth_url = gets.chomp
      print 'OpenStack Username: '
      openstack_username = gets.chomp
      print 'OpenStack API Key: '
      openstack_api_key = gets.chomp
      print 'OpenStack Tenant ID: '
      openstack_tenant = gets.chomp

      add_connection(@provider, openstack_auth_url, openstack_username, openstack_api_key, openstack_tenant)
      @config
    end
  end  
end
