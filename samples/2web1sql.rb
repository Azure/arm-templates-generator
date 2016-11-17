require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = {
    username: { value: 'tmpltest' },
    password: { value: 'Foobar2001' }
}

DEPLOYMENT_NAME = 'directfromruby'

WEBSERVER_COUNT = 5

#
# Create and configure the logical structure of the deployment template, i.e. create
# the resources and link them to each other. We can defer some of the configuration to
# a later point.
#
template = Azure::ARM::Template.create do

  windows_validation_rules

  sa_name = add_variable 'storageAccount',
                         concat(uniqueString(resourceGroup().id), 'account')

  #
  # If we don't create a storage account, there's no control over the name.
  #
  storage_account sa_name do
    account_type Azure::ARM::Storage::StorageAccount::Standard_LRS
  end

  #
  # We need a virtual network with at least one subnet.
  #
  virtual_network do
    address_space address_prefixes: [ '10.0.0.0/16' ]
    subnets address_prefix: '10.0.0.0/24'
  end

  #
  # Create the jumpbox VM
  #
  virtual_machine 'jumpbox' do
    network_settings public_ipaddress: 'rubyarmjb'
  end

  #
  # Create the database server VM
  #
  sec_group = network_security_group 'nsg-rdp' do
    security_rules Azure::ARM::Network::SecurityRules::ALLOW_INBOUND_RDP
  end

  virtual_machine 'database' do
    image Azure::ARM::Compute::VirtualMachine::WINDOWS_SQL_SERVER_2014
    network_settings do
      network_security_group sec_group
    end
  end

  #
  # Create a load balancer for the web (HTTP) tier.
  #
  lb = add_http_load_balancer('loadb', 'rubyarmlb')

  WEBSERVER_COUNT.times do |i|
    lb.add_rdp_nat_rule(6000+i)
  end

  #
  # Create a number of VMs within an availability set. None of the VMs will have a public IP address,
  # but they will all be in the load-balancer's backend pool.
  #
  av = availability_set 'webavset'

  rdp_rules = lb.inbound_nat_rules
  pool = lb.backend_address_pools 'loadb-pool'

  WEBSERVER_COUNT.times do |i|
    virtual_machine "vm#{i}" do
      availability_set av
      network_settings pool, rdp_rules[i]
    end
  end

end

template.save 'template', PARAMETERS