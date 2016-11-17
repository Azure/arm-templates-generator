require 'json'
require 'arm_templates'
require 'helpers'

parameters = {
    availabilitySets_ad_as_name: 'ad-as',
    availabilitySets_sql_as_name: 'sql-as',
    publicIPAddresses_ra_ntier_sql_jb_vm1_nic1_pip_name: 'ra-ntier-sql-jb-vm1-nic1-pip',
    virtualNetworks_ra_ntier_sql_vnet_name: 'ra-ntier-sql-vnet',
    storage_accounts_name: %w(vm7qlxvkud4d3fqst1sadm vma6yqhnjyuqklsst1sadm vma6yqhnjyuqklsst2sadm vmc75ecini3ssbist1sadm vmwm6cvnqc2qanust1sadm vmwm6cvnqc2qanust2sadm),
    network_interface_name: %w(ra-ntier-sql-ad-vm1-nic1 ra-ntier-sql-ad-vm2-nic1 ra-ntier-sql-fsw-vm1-nic1 ra-ntier-sql-jb-vm1-nic1 ra-ntier-sql-vm1-nic1 ra-ntier-sql-vm2-nic1),
    loadBalancers_ra_ntier_sql_lb_name: 'ra-ntier-sql-lb',
    vm_name: %w(ra-ntier-sql-ad-vm1 ra-ntier-sql-ad-vm2 ra-ntier-sql-fsw-vm1 ra-ntier-sql-jb-vm1 ra-ntier-sql-vm1 ra-ntier-sql-vm2),
    computer_name: %w(ad1 ad2 fsw1 jb1 sql1 sql2)

}

IMAGE_REFERENCE =  {
    publisher: 'MicrosoftWindowsServer',
    offer: 'WindowsServer',
    sku: '2012-R2-Datacenter',
    version: 'latest'
}

SQL_IMAGE_REFERENCE = {
    publisher: 'MicrosoftSQLServer',
    offer: 'SQL2014SP1-WS2012R2',
    sku: 'Enterprise',
    version: 'latest'
}

def get_value(i)
  return 4 if i.equal? 0
  return 5 if i.equal? 1
  return 3 if i.equal? 2
  return 0 if i.equal? 3
  return 1 if i.equal? 4
  return 2 if i.equal? 5
end

def get_size(i)
  return '1000' if i == 4 || i == 5
  '128'
end

def get_subnet(subnet_name, subnet_address_prefix)
  created_subnet = subnet do
    name subnet_name
    address_prefix subnet_address_prefix
  end
  created_subnet
end

def script_extension_forest
  {
      publisher: 'Microsoft.Compute',
      type: 'CustomScriptExtension',
      type_handler_version: '1.8',
      settings: {
          fileUris: [
              'https://raw.githubusercontent.com/mspnp/reference-architectures/master/guidance-compute-n-tier-sql/extensions/adds-forest.ps1'
          ],
          commandToExecute: "powershell -ExecutionPolicy Unrestricted -Command \"& {.\\adds-forest.ps1 -DomainName \\\"contoso.com\\\" -DomainNetbiosName \\\"contoso\\\" -SafeModePassword \\\"DdadaU8987\\\" }\""
      }
  }
end

def script_extension_name
  {
      publisher: 'Microsoft.Compute',
      type: 'CustomScriptExtension',
      type_handler_version: '1.8',
      settings: {
          fileUris: [
              'https://raw.githubusercontent.com/mspnp/reference-architectures/master/guidance-compute-n-tier-sql/extensions/adds.ps1'
          ],
          commandToExecute: "powershell -ExecutionPolicy Unrestricted -Command \"& {.\\adds.ps1 -SafeModePassword \\\"Saf3M0de@PW\\\" -DomainName \\\"contoso.com\\\" -AdminUser \\\"testuser\\\" -AdminPassword \\\"DdadaU8987\\\" -SiteName \\\"Default-First-Site-Name\\\"}\""
      }
  }
end

def script_extension_filesharewitness
  {
      publisher: 'Microsoft.Powershell',
      type: 'DSC',
      type_handler_version: '2.16',
      settings: {
          modulesURL: 'https://raw.githubusercontent.com/mspnp/reference-architectures/master/guidance-compute-n-tier-sql/extensions/CreateFileShareWitness.ps1.zip',
          configurationFunction: "CreateFileShareWitness.ps1\\CreateFileShareWitness",
          properties: {
              domainName: 'contoso.com',
              SharePath: 'sql-fs',
              adminCreds: {
                  userName: 'testuser',
                  password: 'DdadaU8987'
              }
          }
      }
  }
end

def script_extension_iaasantimalware
  {
      publisher: 'Microsoft.Azure.Security',
      type: 'IaaSAntimalware',
      type_handler_version: '1.3',
      settings: {
          AntimalwareEnabled: true,
          RealtimeProtectionEnabled: 'true',
          ScheduledScanSettings: {
              isEnabled: 'false',
              day: '7',
              time: '120',
              scanType: 'Quick'
          },
          Exclusions: {
              Extensions: '',
              Paths: '',
              Processes: ''
          }
      }
  }
end

def script_extension_sqlaoprepare
  {
      publisher: 'Microsoft.Powershell',
      type: 'DSC',
      type_handler_version: '2.19',
      settings: {
          modulesURL: 'https://raw.githubusercontent.com/mspnp/reference-architectures/master/guidance-compute-n-tier-sql/extensions/PrepareAlwaysOnSqlServer.ps1.zip',
          configurationFunction: "PrepareAlwaysOnSqlServer.ps1\\PrepareAlwaysOnSqlServer",
          properties: {
              domainName: 'contoso.com',
              sqlAlwaysOnEndpointName: 'ra-ntier-sql-hadr',
              adminCreds: {
                  userName: 'testuser',
                  password: 'DdadaU8987'
              },
              sqlServiceCreds: {
                  userName: 'sqlservicetestuser',
                  password: 'DdadaU8987'
              },
              NumberOfDisks: '2',
              WorkloadType: 'GENERAL'
          }
      }
  }
end

def script_extension_alwayson
  {
      publisher: 'Microsoft.Powershell',
      type: 'DSC',
      type_handler_version: '2.19',
      settings: {
          modulesURL: 'https://raw.githubusercontent.com/mspnp/reference-architectures/master/guidance-compute-n-tier-sql/extensions/CreateFailoverCluster.ps1.zip',
          configurationFunction: "CreateFailoverCluster.ps1\\CreateFailoverCluster",
          properties: {
              domainName: 'contoso.com',
              clusterName: 'ra-ntier-sql-fc',
              sharePath: "\\\\fsw1\\sql-fs",
              nodes: %w(sql1 sql2),
              sqlAlwaysOnEndpointName: 'ra-ntier-sql-hadr',
              sqlAlwaysOnAvailabilityGroupName: 'alwayson-ag',
              sqlAlwaysOnAvailabilityGroupListenerName: 'alwayson-ag-listener',
              SqlAlwaysOnAvailabilityGroupListenerPort: '1433',
              databaseNames: 'AutoHa-sample',
              lbName: 'ra-ntier-sql-lb',
              lbAddress: '10.0.3.100',
              primaryReplica: 'sql2',
              secondaryReplica: 'sql1',
              dnsServerName: 'ad1',
              adminCreds: {
                  userName: 'testuser',
                  password: 'DdadaU8987'
              },
              sqlServiceCreds: {
                  userName: 'sqlservicetestuser',
                  password: 'DdadaU8987'
              },
              SQLAuthCreds: {
                  userName: 'sqlsa',
                  password: 'DdadaU8987'
              },
              NumberOfDisks: '2',
              WorkloadType: 'GENERAL'
          }
      }
  }
end

def create_load_balancer(parameters, vn)
  frnt_end_ip_config_id = "[resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations','#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}','#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}fe1')]"
  bk_end_address_pool_id = "[resourceId('Microsoft.Network/loadBalancers/backendAddressPools','#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}','#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}-bep1')]"
  probe_id = "[resourceId('Microsoft.Network/loadBalancers/probes','#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}','#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}p1')]"

  vn_id = vn.to_rsrcid.to_s
  probes_hash = {
    name: "#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}p1",
    properties: {
      protocol: 'Tcp',
      port: 59999,
      interval_in_seconds: 15,
      number_of_probes: 2
    }
  }

  frnt_end_ip_config = frontend_ipconfigurations do
    name "#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}fe1"
    private_ipallocation_method  'Static'
    private_ipaddress '10.0.3.100'
    subnet ({ id: "[concat(#{vn_id.slice(1..vn_id.length-2)},'/subnets/sql')]" })
  end

  bknd_addr_pools = backend_address_pools do
    name "#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}-bep1"
  end

  lb_rules = load_balancing_rules do
    name 'SQLAlwaysOnEndPointListener'
    frontend_port 1433
    backend_port 1433
    enable_floating_ip true
    idle_timeout_in_minutes 4
    protocol 'Tcp'
    load_distribution 'Default'
    frontend_ipconfiguration ({ id: frnt_end_ip_config_id })
    backend_address_pool ({ id: bk_end_address_pool_id })
    probe ({ id: probe_id })
  end

  lb = load_balancer do
    name parameters[:loadBalancers_ra_ntier_sql_lb_name]
    frontend_ipconfigurations frnt_end_ip_config
    backend_address_pools bknd_addr_pools
    load_balancing_rules lb_rules
    probes probes_hash
    inbound_nat_rules  []
    outbound_nat_rules []
    inbound_nat_pools  []
  end

  lb.add_dependency vn
  lb
end

template = Azure::ARM::Template.create do
  static_private_ips = %w{10.0.4.4 10.0.4.5}
  dynamic_private_ips = %w{10.0.3.5 10.0.0.132 10.0.3.4 10.0.3.6}
  ad_as = availability_set parameters[:availabilitySets_ad_as_name]
  sql_as = availability_set parameters[:availabilitySets_sql_as_name]
  public_ipaddr = public_ipaddress do
    name parameters[:publicIPAddresses_ra_ntier_sql_jb_vm1_nic1_pip_name]
    public_ipallocation_method 'Static'
    idle_timeout_in_minutes 4
  end

  sp_array, storage_accounts_array, nic_array, dns_settings_array, vm_array = [], [], [], [], []

  6.times do |i|
    storage_accounts_array[i] = storage_account parameters[:storage_accounts_name][i] do
      account_type 'Premium_LRS'
    end
  end

  web_subnet  = get_subnet 'web',  '10.0.1.0/24'
  biz_subnet  = get_subnet 'biz',  '10.0.2.0/24'
  sql_subnet  = get_subnet 'sql',  '10.0.3.0/24'
  ad_subnet   = get_subnet 'ad',   '10.0.4.0/24'
  mgmt_subnet = get_subnet 'mgmt', '10.0.0.128/25'

  vn = virtual_network do
    name parameters[:virtualNetworks_ra_ntier_sql_vnet_name]
    address_space ({ address_prefixes: ['10.0.0.0/16'] })
    dhcp_options ({ dns_servers: static_private_ips })
    subnets [web_subnet, biz_subnet, sql_subnet, ad_subnet, mgmt_subnet]
  end

  lb = create_load_balancer(parameters, vn)

  vn_id  = vn.to_rsrcid.to_s
  lb_id  = lb.to_rsrcid.to_s

  dns_settings_array[0] = network_interface_dns_settings do
    dns_servers []
  end
  dns_settings_array[1] = network_interface_dns_settings do
    dns_servers static_private_ips
  end

  2.times do |i|
    nic_array[i] = network_interface parameters[:network_interface_name][i] do |nic|
      dns_settings dns_settings_array[0]
      enable_ipforwarding false
      ip_config_hash = {
          name: 'ipconfig1',
          properties: {
              private_ipaddress: static_private_ips[i],
              private_ipallocation_method: 'Static',
              subnet: { id: "[concat(#{vn_id.slice(1..vn_id.length-2)},'/subnets/ad')]" }
          }
      }
      ip_configurations ip_config_hash
      nic.add_dependency vn
    end
  end

  nic_array[2] = network_interface parameters[:network_interface_name][2] do |nic|
    dns_settings dns_settings_array[1]
    enable_ipforwarding false
    ip_config_hash = {
        name: 'ipconfig1',
        properties: {
            private_ipaddress: dynamic_private_ips[0],
            private_ipallocation_method: 'Dynamic',
            subnet: { id: "[concat(#{vn_id.slice(1..vn_id.length-2)},'/subnets/sql')]" }
        }
    }
    ip_configurations ip_config_hash
    nic.add_dependency vn
  end

  nic_array[3] = network_interface parameters[:network_interface_name][3] do |nic|
    dns_settings dns_settings_array[0]
    enable_ipforwarding false
    ip_config_hash = {
        name: 'ipconfig1',
        properties: {
            private_ipaddress: dynamic_private_ips[1],
            private_ipallocation_method: 'Dynamic',
            subnet: { id: "[concat(#{vn_id.slice(1..vn_id.length-2)},'/subnets/mgmt')]" },
            public_ipaddress: { id: public_ipaddr.to_rsrcid.to_s }
        }
    }
    ip_configurations ip_config_hash
    nic.add_dependency vn
    nic.add_dependency public_ipaddr
  end

  (4..5).each do |i|
    nic_array[i] = network_interface parameters[:network_interface_name][i] do |nic|
      dns_settings dns_settings_array[1]
      enable_ipforwarding false
      ip_config_hash = {
          name: 'ipconfig1',
          properties: {
              private_ipaddress: dynamic_private_ips[i-2],
              private_ipallocation_method: 'Dynamic',
              subnet: { id: "[concat(#{vn_id.slice(1..vn_id.length-2)},'/subnets/sql')]" },
              load_balancer_backend_address_pools: { id: "[concat(#{lb_id.slice(1..lb_id.length-2)},'/backendAddressPools/#{parameters[:loadBalancers_ra_ntier_sql_lb_name]}-bep1')]" }
          }
      }
      ip_configurations ip_config_hash
      nic.add_dependency vn
      nic.add_dependency lb
    end
  end

  hardware_profile_hash = {
      vm_size: 'Standard_DS1_v2'
  }

  6.times do |i|
    sp_array[i] = storage_profile "sp#{i}" do
      if(i != 4 && i != 5)
        image_reference IMAGE_REFERENCE
      else
        image_reference SQL_IMAGE_REFERENCE
      end

      os_disk_hash = {
          name: "#{parameters[:vm_name][i]}-os.vhd",
          create_option: 'FromImage',
          caching: 'ReadWrite',
          vhd: { uri: "http://#{parameters[:storage_accounts_name][get_value(i)]}.blob.core.windows.net/vhds/#{parameters[:vm_name][i]}-os.vhd" }
      }
      os_disk os_disk_hash

      data_disk_hash = {
          lun: 0.to_f,
          name: 'dataDisk1',
          create_option: 'Empty',
          caching: 'None',
          disk_size_gb: get_size(i),
          vhd: { uri: "http://#{parameters[:storage_accounts_name][get_value(i)]}.blob.core.windows.net/vhds/#{parameters[:vm_name][i]}-dataDisk1.vhd" }
      }

      if(i == 4 || i == 5)
        data_disk_hash_2 = {
            lun: 0.to_f,
            name: 'dataDisk2',
            create_option: 'Empty',
            caching: 'None',
            disk_size_gb: get_size(i),
            vhd: { uri: "http://#{parameters[:storage_accounts_name][get_value(i)]}.blob.core.windows.net/vhds/#{parameters[:vm_name][i]}-dataDisk2.vhd" }
        }
        data_disks [data_disk_hash, data_disk_hash_2]
      else
        data_disks data_disk_hash
      end

    end

    vm_array[i] = virtual_machine parameters[:vm_name][i] do |vmx|
      if(i == 0 || i == 1)
        availability_set ad_as
        vmx.add_dependency ad_as
      end

      if(i == 4 || i == 5)
        availability_set sql_as
        vmx.add_dependency sql_as
      end

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
          computer_name: "#{parameters[:computer_name][i]}",
          admin_username: 'testuser',
          admin_password: 'DdadaU8987',
          secrets: [],
          windows_configuration: {
              provision_vmagent: true,
              enable_automatic_updates: true
          }
      }
      os_profile os_profile_hash

      vmx.add_dependency nic_array[i]
      vmx.add_dependency storage_accounts_array[get_value(i)]

    end
  end

  vm_extension vm_array[0], 'install-adds-forest' do
    properties script_extension_forest
  end

  vm_extension vm_array[1], 'install-adds' do
    properties script_extension_name
  end

  vm_extension vm_array[2], 'CreateFileShareWitness' do
    properties script_extension_filesharewitness
  end

  vm_extension vm_array[3], 'IaaSAntimalware' do
    properties script_extension_iaasantimalware
  end

  vm_extension vm_array[4], 'sqlAOPrepare' do
    properties script_extension_sqlaoprepare
  end

  vm_extension vm_array[5], 'configuringAlwaysOn' do
    properties script_extension_alwayson
  end

end

template.save 'scenario-2', {}