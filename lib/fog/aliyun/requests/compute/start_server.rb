module Fog
  module Compute
    class Aliyun
      class Real
        # Start the server.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server to be started.
        # === Returns
        # * success <~Boolean>
        def start_server(server_id)
          
          _action = 'StartInstance'
          _sigNonce = randonStr()
          _time = Time.new.utc

          _parameters = defalutParameters(_action, _sigNonce, _time)
          _pathURL  = defaultAliyunUri(_action, _sigNonce, _time)
          
          _parameters['InstanceId']=server_id
          _pathURL += '&InstanceId='+server_id
            
          _signature = sign(@aliyun_accesskey_secret, _parameters)
          _pathURL += '&Signature='+_signature
          
          request(
            :expects => [200, 204],
            :method => 'GET',
            :path   => _pathURL
          )
        end # def start_server
      end # class Real

      class Mock
        def start_server(server_id)
          true
        end # def start_server
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog