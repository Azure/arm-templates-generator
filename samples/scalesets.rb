require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = {
    username: { value: 'tmpltest' },
    ssh_key: { value: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDMezrnhzOYP48RjJqLRZ4vkQ+bzmOVzRuyw3pHyc1/x86gCu693vcF2k/YWNlmCxqtcf8xKhAiPiS2Cop8YVp5cZX/uoPZuUBdmB72sIYSAHZKj0YXuokQObasceARoYTSzWBO6vmDoizfSrg9bdp9AHj2RFEal/hRzHfjNaNb6Q==' },
    instanceCount: { value: 5 },
    vmSize: { value: 'Standard_A1' }
}

VM_COUNT = 1

template = Azure::ARM::Template.create do

  linux_validation_rules

  add_linux_jumpbox 'ngruby'

  #
  # Create a number of VMs as a scale-set, with a parameterized count.
  #
  instances = add_parameter 'instanceCount', {type: 'int', maxValue: 12}
  vmSize = add_parameter 'vmSize', {type: 'string', defaultValue: 'Standard_A1' }

  lb = add_http_load_balancer 'scaleset', 'ngconsul'
  pool = lb.backend_address_pools 'scaleset-pool'

  vmss = virtual_machine_scale_set 'vsmss' do
    sku name: vmSize, tier: 'Standard', capacity: instances
    upgrade_policy mode: 'Manual'
    network_configuration pool
  end

end

template.save 'template', PARAMETERS