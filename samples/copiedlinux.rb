require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = {
    username: { value: 'tmpltest' },
    password: { value: 'Foobar2001' },
    vmCount:  { value: 2 },
    saCount: { value: 5 }
}

template = Azure::ARM::Template.create do

  linux_validation_rules

  #
  # We'll need a storage account for the VM disks.
  #
  storage_account {
    copy 5
    name concat('accnt', copyIndex())
    account_type 'Standard_LRS'
  }

  #
  # Set up a jump box with a public IP address. This will be used only to
  # access other resources.
  #
  # virtual_machine('jumpbox') {
  #   public_ipaddress 'ngfirstruby'
  # }

  #
  # Create a number of VMs within an availability set.
  # None of the VMs will have a public IP address.
  #
  av = availability_set

  virtual_machine {
    copy 'vmCount'
    availability_set av
  }

end

template.save 'template', PARAMETERS