
module Azure::ARM::Network

    #
    # Microsoft.Network/publicIPAddresses
    #
    class PublicIPAddress < Azure::ARM::ResourceBase

      def prepare

        @properties = PublicIPAddressesProperties.new self, nil if @properties.nil?
        @properties.public_ipallocation_method = 'Dynamic' if @properties.public_ipallocation_method.nil?
        @properties.idle_timeout_in_minutes = 15 if @properties.idle_timeout_in_minutes.nil?
      end

    end
end
