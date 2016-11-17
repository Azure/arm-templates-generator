# Virtual Machines and Networks

The Virtual Machine and Networking resources are technically part of distinct IaaS services in Azure, but from a practical perspective, they are intrinsically linked: one is not very useful without the other. Therefore,
we shall cover both together here.

Because VMs require networks to be useful, ARMit does things by default when networks are not configured explicitly. If you create a VM (or set of VMs) without a network, one is created for you and added to the ARM template.

Thus, one of the simplest template definitions is one that completely ignores networking and just sets the image reference and credentials:

```
  user = add_parameter 'username', {type: 'string'}
  pwd  = add_parameter 'password', {type: 'securestring'}

  virtual_machine 'myVM' do
  	image Azure::ARM::Compute::VirtualMachine::WINDOWS_SERVER_2012_R2_DATACENTER
	os_profile admin_username: user, admin_password: pwd
  end
```

## Going Outside the Defaults

By default, a network with a single subnet will be created, along with a network interface card attached to the VM. The NIC will not have a public IP address, which means you have no means of
reaching it. Typically, you want at least one VM in your installation to serve as a 'jumpbox,' i.e. have a publically reachable IP address. This VM can then be used to reach others via the private
network.

To make this happen, you have to create a public IP address and then refer to it from the NIC. There's a configuration method `network_settings` that allows you to set various network attributes,
including the public IP address:

```
  virtual_machine 'jumpbox' do
    network_settings public_ipaddress: 'rubyarmjb'
  	image Azure::ARM::Compute::VirtualMachine::WINDOWS_SERVER_2012_R2_DATACENTER
	os_profile admin_username: user, pwd
  end  
```

## Being More Explicit

Network settings will pick up any virtual network you have already created and use the first one you find. If you want to be more specific, you should use the `network_profile` method, which
does not do any smart defaulting for you. It requires you to provide all the network data explictly, first creating resources and then referring to them in the VM configuration block:

```
pip = public_ipaddress 'rubyarmjb-addr' do
        dns_settings domain_name_label: 'rubyarmjb'
      end

vnet = virtual_network do
         address_space address_prefixes: [ '172.17.0.0/16' ]
         subnets address_prefix: '172.17.0.0/24'
       end
	 
nic = network_interface name do
        ip_configurations name: Azure::ARM::RandomName.new,
                          public_ipaddress: pip,
                          private_ipallocation_method: 'Dynamic',
                          subnet: vnet.properties.nil? ? nil : vnet.properties.subnets[0]		
      end
	  
virtual_machines 'vm-0' do
    
  network_profile network_interfaces: [ { id: nic.to_rsrcid.to_s }]
  add_dependency nic
  
end
```

## Load Balancing

When creating many VMs with the same purpose, typically for scaling a tier of your architecture, adding a load balancer is useful. Azure's support for load balancing is also available through
ARMit script configuration.

### Backend Address Pools

The load balancer itself is a (networking) resource, and it balances load among the NICs in its 'backend address pools.' Configuring LB means creating a load balancer
resource, configuring its backend pools, and then configuring NIC to participate in the pool

A simple helper method to add an HTTP load balancer in front of a web tier may look something like this:

```
    def add_load_balancer(name, port, ip_address)

      if name.nil?
        name = "lbweb"
      end

      if ip_address.is_a? String
        ip_address = public_ipaddress "#{name}-addr" do
          dns_settings domain_name_label: ip_address
        end
      end

      lb = load_balancer name do

        if ip_address.nil?
          fics = frontend_ipconfigurations name: name + '-feconf'
        else
          fics = frontend_ipconfigurations name: name + '-feconf',
                                           public_ipaddress: ip_address
        end

        pools = backend_address_pools name: name + '-pool'

        p = probes name: name + '-probe',
                   protocol: 'Tcp',
                   port: port,
                   number_of_probes: 2,
                   interval_in_seconds: 15

        load_balancing_rules name: 'httprule',
                             frontend_ipconfiguration: fics[0],
                             backend_address_pool: pools[0],
                             protocol: 'Tcp',
                             frontend_port: port,
                             backend_port: port,
                             idle_timeout_in_minutes: 15,
                             probe: p[0]
      end

    end
```

Note that the configuration script also sets up a probe, which will be testing each machine in the pool to see if it's available at a configured interval.

To configure virtual machines to participate in the load balancer's pool:

```
  pool = lb.backend_address_pools[0]

  WEBSERVER_COUNT.times do |i|
    virtual_machine "vm#{i}" do
      availability_set av
      network_settings pool
    end
  end
```

### Inbound NAT Rules

In addition to balancing load, the load balancer can also route traffic to specific VM by doing port mapping, which means that you can have direct access to 
the machines without a jumpbox or multiple public IP addresses. This is done by establishing inbound NAT rules for the load balancer. Helper methods to do that for RDP (Windows Remote Deskptop)
or SSH may look something like:

```
  module Network

    class LoadBalancer < Azure::ARM::ResourceBase

      def add_rdp_nat_rule(fe_port)
        rules = nil
        configure do |lb|
          fics = lb.frontend_ipconfigurations
          rules = inbound_nat_rules protocol: 'Tcp',
                                    frontend_port: fe_port,
                                    frontend_ipconfiguration: fics[0],
                                    backend_port: 3389
        end
        rules
      end

      def add_ssh_nat_rule(fe_port)
        rules = nil
        configure do |lb|
          fics = lb.frontend_ipconfigurations
          rules = inbound_nat_rules protocol: 'Tcp',
                                    frontend_port: fe_port,
                                    frontend_ipconfiguration: fics[0],
                                    backend_port: 22
        end
        rules
      end

    end
  end

end
```

These are then utilized by calling:

```
  WEBSERVER_COUNT.times do |i|
    lb.add_rdp_nat_rule(6000+i)
  end
  
  rdp_rules = lb.inbound_nat_rules
  pool = lb.backend_address_pools[0]

  WEBSERVER_COUNT.times do |i|
    virtual_machine "vm#{i}" do
      availability_set av
      network_settings pool, rdp_rules[i]
    end
  end
```

## Virtual Machine Settings

All the possible ARM settings for Virtual Machines are available in ARMit. This section will only go through a couple of them.

Besides configuring the network profile, there are a couple of fundamental things that virtual machines have to have defined:

1. An OS profile, which includes the machine name and credentials.
1. A storage profile, which defines disks and which operating system image to base the VM on. A set of well know image references is defined in the VirtualMachine class.
1. A HW profile, specifying the VM size. The default is 'Standard_A1'.
1. An optional availability set, used to improved the availability of a cluster of VMs.

The very first example showed how to set the credentials and the image reference. You don't have to explicitly define the URI for disks unless you have a particular location in mind -- one of the
storage accounts defined in the template will be used by default. To set the OS disk storage account explicitly, call 'os_disk' and pass in a reference (a name or account instance) to the account you
have in mind:

```

disks = 
    storage_account do
      account_type Azure::ARM::StorageAccount::Standard_LRS
    end

vm.configure do
  os_disk disks
end
```

The configuration blocks are generally pretty liberal in terms of what you can pass in. For example, while you technically speaking need to set the hardware_profile to a HardwareProfile instance, you can also
just pass in a hash of the properties that HardwareProfile contains, and the profile instance will be created behind the scenes:

```
vm.configure do
  hardware_profile: vm_size: 'Standard_A0'
end
``` 

The same goes for the other profiles -- the simplest way to set properties is to pass in a hash:
```
  user = add_parameter 'username', {type: 'string'}
  pwd  = add_parameter 'password', {type: 'securestring'}

  virtual_machine 'myVM' do
	os_profile admin_username: user, admin_password: pwd
  end
```

## Virtual Machine Scale Sets