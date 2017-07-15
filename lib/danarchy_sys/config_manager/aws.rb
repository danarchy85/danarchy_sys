
module DanarchySys::ConfigManagerNew
  class AWS
    def initialize(provider)
      @provider = provider.to_sym
    end

    def add_connection(provider, aws_access_key_id, aws_secret_access_key)
#      config = load

      # config[:connections][provider.to_sym] = {
      #   aws_access_key_id: aws_access_key_id,
      #   aws_secret_access_key: aws_secret_access_key
      }
    end

    def delete_connection(provider)
#      config = load
#      config[:connections].delete(provider.to_sym)
    end
  end
end
