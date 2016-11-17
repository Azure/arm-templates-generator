require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = {
    username: { value: 'ansible' },
    ssh_key: { value: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDMezrnhzOYP48RjJqLRZ4vkQ+bzmOVzRuyw3pHyc1/x86gCu693vcF2k/YWNlmCxqtcf8xKhAiPiS2Cop8YVp5cZX/uoPZuUBdmB72sIYSAHZKj0YXuokQObasceARoYTSzWBO6vmDoizfSrg9bdp9AHj2RFEal/hRzHfjNaNb6Q==' }
}

VM_COUNT = 1

template = Azure::ARM::Template.create do

  linux_validation_rules

  virtual_machine 'server0' do
    public_ipaddress 'ngansible'
  end

end

template.save 'template', PARAMETERS
