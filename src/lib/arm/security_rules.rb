module Azure::ARM::Network
  #
  # Model object.
  #
  class SecurityRules < Azure::ARM::TypeBase

    ALLOW_INBOUND_RDP = {
        description: 'Allow RDP',
        destination_port_range: '3389',
        source_port_range: '*',
        source_address_prefix: 'Internet',
        destination_address_prefix: '*',
        access: 'Allow',
        priority: 110,
        direction: 'Inbound',
        protocol: 'Tcp'
    }

    ALLOW_INBOUND_HTTP = {
        description: 'Allow HTTP',
        destination_port_range: '80',
        source_port_range: '*',
        source_address_prefix: 'Internet',
        destination_address_prefix: '*',
        access: 'Allow',
        priority: 120,
        direction: 'Inbound',
        protocol: 'Tcp'
    }

    ALLOW_INBOUND_HTTPS = {
        description: 'Allow HTTPS',
        destination_port_range: '443',
        source_port_range: '*',
        source_address_prefix: 'Internet',
        destination_address_prefix: '*',
        access: 'Allow',
        priority: 130,
        direction: 'Inbound',
        protocol: 'Tcp'
    }

    ALLOW_INBOUND_SSH = {
        description: 'Allow SSH',
        destination_port_range: '22',
        source_port_range: '*',
        source_address_prefix: 'Internet',
        destination_address_prefix: '*',
        access: 'Allow',
        priority: 100,
        direction: 'Inbound',
        protocol: 'Tcp'
    }

  end

end