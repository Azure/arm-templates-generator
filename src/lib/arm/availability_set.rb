module Azure::ARM::Compute
  #
  # Microsoft.Compute/availabilitySets
  #
  class AvailabilitySet < Azure::ARM::ResourceBase

    def prepare
      @properties = AvailabilitySetsProperties.new self, nil if @properties.nil?
      @properties.platform_update_domain_count = 2 if @properties.platform_update_domain_count.nil?
    end
  end

end
