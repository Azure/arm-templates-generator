module Azure::ARM::Network

    #
    # Model object.
    #
    class NetworkInterface < Azure::ARM::ResourceBase
      def get_name_template
        'nic'
      end
    end

end
