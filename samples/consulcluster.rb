require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = {
    username: { value: 'consul' },
    ssh_key: { value: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDMezrnhzOYP48RjJqLRZ4vkQ+bzmOVzRuyw3pHyc1/x86gCu693vcF2k/YWNlmCxqtcf8xKhAiPiS2Cop8YVp5cZX/uoPZuUBdmB72sIYSAHZKj0YXuokQObasceARoYTSzWBO6vmDoizfSrg9bdp9AHj2RFEal/hRzHfjNaNb6Q==' }
}

def script_extension(command)
  {
    publisher: 'Microsoft.OSTCExtensions',
      type: 'CustomScriptForLinux',
      type_handler_version: '1.2',
      settings: { fileUris: [
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/bootstrapsetup.sh',
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/bootstrap.json',
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/server.conf',
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/server.json',
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/clientsetup.sh',
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/client.conf',
                    'https://raw.githubusercontent.com/NiklasGustafsson/armconsul/master/client.json'],
                  commandToExecute: command
      }
  }
end

SERVER_ADDR_START = 10
CLIENT_ADDR_START = 20

#
# Sets up a cluster of three (it should always be an odd number) of Consul servers, which will
# keep the truth. Then, create any number of clients, which just act as the public interface to the
# servers, keeping no state. They can be load balanced via a publicly available address / DNS entry.
#
# Once the VMs have been created, you should use the jumpbox to get into the system. First, upload the
# RSA private key whose corresponding public key was used as the SSH key in the creation of VMs. This
# will allow you seamless SSH access to the various VMs in your system.
#
# Then, log into one of the servers, start consul in bootstrap mode manually. From a second terminal,
# log into the other two servers, sequentially and start the 'consul' service. Use 'consul members'
# to verify that all three servers are seeing each other. Kill the boostrap server, and start it the
# same way as on the other machines, i.e. using 'sudo start consul'.
#
# Log into each of the clients and start the consul service there, too. You're done.
#
#

template = Azure::ARM::Template.create do

  linux_validation_rules

  #
  # Set up a jump box with a public IP address. This will be used only to
  # access other resources.
  #
  virtual_machine('jumpbox') {
    public_ipaddress 'ngconsuljmp'
  }

  #
  # Create a number of VMs within an availability set.
  # None of the VMs will have a public IP address.
  #
  servers = availability_set 'av-servers'
  clients = availability_set 'av-clients'

  #
  # Create a cluster of three servers
  #
  3.times do |i|

    addr = "10.1.0.#{SERVER_ADDR_START+i}"

    vm = virtual_machine "server#{i}" do
      availability_set servers
      network_settings private_ipaddress: "10.1.0.#{SERVER_ADDR_START+i}"
    end

    vm_extension vm, 'setupscript' do |ext|
      properties script_extension("sh bootstrapsetup.sh #{vm.name} #{addr}")
    end

  end

  #
  # Create a load balancer for the public client tier.
  #
  lb = add_load_balancer 'consullb', [8500, 8600], 'ngconsul'

  pool = lb.backend_address_pools 'consullb-pool'

  2.times do |i|

    group = network_security_group do
      security_rules [ ALLOW_DNS, ALLOW_HTTP ]
    end

    addr = "10.1.0.#{CLIENT_ADDR_START+i}"

    vm = virtual_machine "client#{i}" do
      availability_set clients
      network_settings pool, private_ipaddress: addr do
        network_security_group group
      end

    end

    vm_extension vm, 'setupscript' do |ext|
      properties script_extension("sh clientsetup.sh #{vm.name} #{addr}")
      ext.add_dependency vm
    end

  end

end

template.save 'template', PARAMETERS