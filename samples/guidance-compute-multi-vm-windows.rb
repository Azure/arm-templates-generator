require 'json'
require 'arm_templates'
require 'helpers'

parameters = JSON.parse(File.read('parameters.json'))

IMAGE_REFERENCE =  {
    publisher: 'MicrosoftWindowsServer',
    offer: 'WindowsServer',
    sku: '2012-R2-Datacenter',
    version: 'latest'
}

def script_extension_iis
  {
      publisher: 'Microsoft.Powershell',
      type: 'DSC',
      type_handler_version: '2.20',
      settings: {
          modulesUrl: 'https://raw.githubusercontent.com/mspnp/reference-architectures/master/guidance-compute-multi-vm/extensions/windows/iisaspnet.ps1.zip',
          configurationFunction: "iisaspnet.ps1\\iisaspnet"
      }
  }
end

def create_load_balancer(parameters, public_ipaddr)
  frnt_end_ip_config_id = "[resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations','#{parameters['loadBalancers_ra_multi_vm_lb_name']}','#{parameters['loadBalancers_ra_multi_vm_lb_name']}-fe-config1')]"
  bk_end_address_pool_id = "[resourceId('Microsoft.Network/loadBalancers/backendAddressPools','#{parameters['loadBalancers_ra_multi_vm_lb_name']}','#{parameters['loadBalancers_ra_multi_vm_lb_name']}-bep1')]"
  probe_id = "[resourceId('Microsoft.Network/loadBalancers/probes','#{parameters['loadBalancers_ra_multi_vm_lb_name']}','#{parameters['loadBalancers_ra_multi_vm_probe_name']}')]"

  frnt_end_ip_config = frontend_ipconfigurations do
    name "#{parameters['loadBalancers_ra_multi_vm_lb_name']}-fe-config1"
    private_ipallocation_method  'Dynamic'
    public_ipaddress public_ipaddr
  end

  ibnd_nat_rules_1 = inbound_nat_rules do
    name 'rdp-vm1'
    frontend_port 50000
    backend_port 3389
    protocol 'Tcp'
    frontend_ipconfiguration ({ id: frnt_end_ip_config_id })
  end

  ibnd_nat_rules_2 = inbound_nat_rules do
    name 'rdp-vm2'
    frontend_port 50001
    backend_port 3389
    protocol 'Tcp'
    frontend_ipconfiguration ({ id: frnt_end_ip_config_id })
  end

  lb_rules = load_balancing_rules do
    name 'lbr1'
    frontend_port 80
    backend_port 80
    enable_floating_ip false
    idle_timeout_in_minutes 4
    protocol 'Tcp'
    load_distribution 'Default'
    frontend_ipconfiguration ({ id: frnt_end_ip_config_id })
    backend_address_pool ({ id: bk_end_address_pool_id })
    probe ({ id: probe_id })
  end

  bknd_addr_pools = backend_address_pools do
    name "#{parameters['loadBalancers_ra_multi_vm_lb_name']}-bep1"
  end

  lb = load_balancer do
    name parameters['loadBalancers_ra_multi_vm_lb_name']
    load_balancing_rules lb_rules
    frontend_ipconfigurations frnt_end_ip_config
    backend_address_pools bknd_addr_pools
    probes_hash = {
        name: parameters['loadBalancers_ra_multi_vm_probe_name'],
        properties: {
            protocol: 'Http',
            port: 80,
            request_path: '/',
            interval_in_seconds: 15,
            number_of_probes: 2
        }
    }
    probes probes_hash
    inbound_nat_rules [ibnd_nat_rules_1, ibnd_nat_rules_2]
    outbound_nat_rules []
    inbound_nat_pools []
  end

  lb.add_dependency public_ipaddr

  lb
end

template = Azure::ARM::Template.create do
  nic_array, sp_array, dns_settings_array, vm_array = [], [], [], []
  private_ip_addresses = %w{10.0.1.4, 10.0.1.5}

  av = availability_set parameters['availabilitySets_ra_multi_vm_as_name']

  public_ipaddr = public_ipaddress do
    name parameters['publicIPAddresses_ra_multi_vm_lb_fe_config1_pip_name']
    public_ipallocation_method 'Static'
    idle_timeout_in_minutes 4
  end

  lb = create_load_balancer parameters, public_ipaddr

  sr_1 = security_rules do
    name 'default-allow-rdp'
    properties ({
        protocol: 'Tcp',
        source_port_range: '*',
        destination_port_range: '3389',
        source_address_prefix: '*',
        destination_address_prefix: '*',
        access: 'Allow',
        priority: 100,
        direction: 'Inbound'
    })
  end

  sr_2 = security_rules do
    name 'default-allow-http'
    properties ({
        protocol: 'Tcp',
        source_port_range: '*',
        destination_port_range: '80',
        source_address_prefix: '*',
        destination_address_prefix: '*',
        access: 'Allow',
        priority: 110,
        direction: 'Inbound'
    })
  end

  nsg = network_security_group do
    name parameters['networkSecurityGroups_ra_multi_vm_nsg_name']
    security_rules [sr_1, sr_2]
  end

  vn = virtual_network do
    name parameters['virtualNetworks_ra_multi_vm_vnet_name']
    address_space ({ address_prefixes: ['10.0.0.0/16'] })
    dhcp_options ({ dns_servers: [] })
    subnets ({
        name: 'web',
        properties: {
            address_prefix: '10.0.1.0/24',
            network_security_group: {
                id: nsg.to_rsrcid.to_s
            }
        }
    })
  end
  vn.add_dependency nsg

  sa = storage_account parameters['storageAccounts_name'] do
    account_type 'Premium_LRS'
  end

  vn_id = vn.to_rsrcid.to_s
  lb_id = lb.to_rsrcid.to_s

  2.times do |i|
    dns_settings_array[i] = network_interface_dns_settings do
      dns_servers []
    end

    nic_array[i] = network_interface parameters['networkInterfaces_ra_multi_nic1_names'][i] do |nc|
      dns_settings dns_settings_array[i]
      enable_ipforwarding false
      ip_config_hash = {
          name: 'ipconfig1',
          properties: {
              private_ipaddress: private_ip_addresses[i],
              private_ipallocation_method: 'Dynamic',
              subnet: { id: "[concat(#{vn_id.slice(1..vn_id.length-2)},'/subnets/web')]" },
              load_balancer_backend_address_pools: { id: "[concat(#{lb_id.slice(1..lb_id.length-2)},'/backendAddressPools/#{parameters['loadBalancers_ra_multi_vm_lb_name']}-bep1')]" },
              load_balancer_inbound_nat_rules: { id: "[concat(#{lb_id.slice(1..lb_id.length-2)},'/inboundNatRules/rdp-vm#{i+1}')]" }
          }
      }
      ip_configurations ip_config_hash
      nc.add_dependency vn
    end

    sp_array[i] = storage_profile "sp#{i}" do
      image_reference IMAGE_REFERENCE

      os_disk_hash = {
          name: "#{parameters['virtualMachines_ra_multi_vm_names'][i]}-os.vhd",
          create_option: 'FromImage',
          caching: 'ReadWrite',
          vhd: { uri: "http://#{parameters['storageAccounts_name']}.blob.core.windows.net/vhds/#{parameters['virtualMachines_ra_multi_vm_names'][i]}-os.vhd" }
      }
      os_disk os_disk_hash

      data_disk_hash = {
          lun: 0.to_f,
          name: 'dataDisk1',
          create_option: 'Empty',
          caching: 'None',
          disk_size_gb: '128',
          vhd: { uri: "http://#{parameters['storageAccounts_name']}.blob.core.windows.net/vhds/#{parameters['virtualMachines_ra_multi_vm_names'][i]}-dataDisk1.vhd" }
      }
      data_disks data_disk_hash
    end

    vm_array[i] = virtual_machine "#{parameters['virtualMachines_ra_multi_vm_names'][i]}" do |vmx|
      availability_set av
      hardware_profile_hash = {
          vm_size: 'Standard_DS1_v2'
      }
      hardware_profile hardware_profile_hash

      storage_profile sp_array[i]

      network_profile_hash = {
          network_interfaces: [
              {
                id: nic_array[i].to_rsrcid.to_s,
                properties: {
                  primary: true
                }
              }
          ]
      }
      network_profile network_profile_hash

      os_profile_hash = {
          computer_name: parameters['computer_names'][i],
          admin_username: parameters['virtualMachines_ra_multi_vm_adminUsername'],
          admin_password: parameters['virtualMachines_ra_multi_vm_adminPassword'],
          secrets: [],
          windows_configuration: {
              provision_vmagent: true,
              enable_automatic_updates: true
          }
      }
      os_profile os_profile_hash

      vmx.add_dependency nic_array[i]
      vmx.add_dependency av
      vmx.add_dependency sa
    end

    vm_extension vm_array[i], 'iis-config-ext' do
      properties script_extension_iis
    end

  end
end

template.save 'scenario-1', {}