require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = {
    username: { value: 'ansible' },
    ssh_key: { value: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDMezrnhzOYP48RjJqLRZ4vkQ+bzmOVzRuyw3pHyc1/x86gCu693vcF2k/YWNlmCxqtcf8xKhAiPiS2Cop8YVp5cZX/uoPZuUBdmB72sIYSAHZKj0YXuokQObasceARoYTSzWBO6vmDoizfSrg9bdp9AHj2RFEal/hRzHfjNaNb6Q==' }
}

VM_COUNT = 3

template = Azure::ARM::Template.create do

  linux_validation_rules

  group = network_security_group do
    security_rules [ Azure::ARM::Network::SecurityRules::ALLOW_INBOUND_HTTP,
                     Azure::ARM::Network::SecurityRules::ALLOW_INBOUND_HTTPS,
                     Azure::ARM::Network::SecurityRules::ALLOW_INBOUND_SSH
                   ]
  end

  VM_COUNT.times do |i|

    pip = public_ipaddress do
      dns_settings domain_name_label: "ngansible#{i+1}"
    end

    #
    # Set up a jump box with a public IP address. This will be used only to
    # access other resources.
    #
    virtual_machine "server#{i+1}" do
      network_settings public_ipaddress: pip do
        network_security_group group
      end
    end

  end

end

template.save 'template', PARAMETERS