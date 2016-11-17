# Setting Defaults and Validating Templates

The simplification ARMit offers comes from the ability to specify ARM infrastructure using a combination of logic and data, not just one or the other. One of the things the addition of complex logic capabilities
affords us is the ability to perform smart defaulting of resources and their attributes.

Some defaults are simple, some are complex, some require involvement from the script writer.

## Simple Defaults

In this category falls basic value defaulting for things like resource and sub-resource names, location, api version, etc. 

For example, when creating an availability set just about everything can be defaulted unless you care about its name:

```
  av = availability_set
```

The output looks like this:

```
    {
      "name": "as-0",
      "type": "Microsoft.Compute/availabilitySets",
      "apiVersion": "2015-06-15",
      "location": "[resourceGroup().location]",
      "properties": {
        "platformUpdateDomainCount": 2
      }
    }
```  

The name, location, api version, and the domain count have all be defaulted. In the case of the type, it's not really a default, since no other value than the one ARMit set is valid; it's the resource type discriminator, after all.

## Complex Defaults

Of the availability set defaults, only the domain count required some sort of intelligence, the value comes from a small piece of hand-written code in the ARMit framework. The rest are generic defaults, generated from the availability set resource
type specification schema.

A more interesting example is what happens when we create a virtual machine without any arguments or configuration block:

```
    {
      "name": "vm-2",
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2015-06-15",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces','vm-2-nic')]"
      ],
      "location": "[resourceGroup().location]",
      "properties": {
        "hardwareProfile": {
          "vmSize": "Standard_A1"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces','vm-2-nic')]"
            }
          ]
        }
      }
    }
```

Since a virtual machine is pretty useless without a network interface card, if you didn't create one and add it to the virtual machine in the script, the code will simply add one for you. You may feel this is too much magic, but the
situations in which setting a default involves creating a new resource are rare and only where it's "obviously" the right thing to do.

A less "magic" situation is setting the vm size to 'Standard_A1,' which is just a guess on the part of the system, just like the AV set domain count.

## Script Defaults

Some defaults are so non-obvious, that the script has to supply them. In a sense, they are not really defaults at all, but we call them out since the approach to setting the values is similar to how the system sets its defaults. What
the library does is post-process all resources and either setting default values or raising exceptions for things that need to be set but for which no obvious default is available.

You get to tap into this post-processing, which means that your mainline script code can avoid having to specify values for some resources, instead applying them after the fact in generic "helper" methods. Much of your script will
be concerned with the structure of the infrastructure definition, not configuration details, so it can clean up the script significantly if you are able to move the configuration logic out.

To make this more clear, consider creating a number of Windows VMs -- a VM to hold a SQL database, a jumpbox (with a public IP address, which is then used to reach other machines), and a set of web servers. To be realistic,
we need a load balancer and some security rules, too.

The script can look something like this:

```
template = Azure::ARM::Template.create do

  windows_validation_rules

  sa_name = add_variable 'storageAccount',
                         concat(uniqueString(resourceGroup().id), 'account')

  storage_account sa_name do
    account_type Azure::ARM::Storage::StorageAccount::Standard_LRS
  end

  virtual_network do
    address_space address_prefixes: [ '10.0.0.0/16' ]
    subnets address_prefix: '10.0.0.0/24'
  end

  virtual_machine 'jumpbox' do
    network_settings public_ipaddress: 'rubyarmjb'
  end

  sec_group = network_security_group 'nsg-rdp' do
    security_rules Azure::ARM::Network::SecurityRules::ALLOW_INBOUND_RDP
  end

  virtual_machine 'database' do
    image Azure::ARM::Compute::VirtualMachine::WINDOWS_SQL_SERVER_2014
    network_settings do
      network_security_group sec_group
    end
  end

  lb = add_http_load_balancer('loadb', 'rubyarmlb')

  WEBSERVER_COUNT.times do |i|
    lb.add_rdp_nat_rule(6000+i)
  end

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
```
To make the script realistic, a load balancer was added, taking up a bunch of space in the script.

Note that only the database has an explicit setting of the VM image to use, the rest of the VMs do not have the image reference set. Those will be set later, when the template is being validated. The hook into the 
post-processing system is established by the `windows_validation_rules` call at the top of the template configuration block. This call adds a couple of post-processing methods, which will be called before the
system post-processing code:

```
    def windows_validation_rules

      template_validation_rule { finish_configuration }

      resource_validation_rule(Azure::ARM::Compute::VirtualMachine) do |vm|
        validate_vm_images vm, Azure::ARM::Compute::VirtualMachine::WINDOWS_SERVER_2012_R2_DATACENTER
      end

    end
```
These are not defined by the ARMit system, these are method you define.

The actual template methods dealing with setting validation rules are `template_validation_rule` and `resource_validation_rule`. Procs passed to the former will each be invoked once and be passed the template instance
as the 'self' reference, while procs passed to the latter will be invoked once for each resource matching the type passed (in this case, virtual machines). Passing 'nil' for the resource type means the
proc will be called for each resource, regardless of type.

Validation rules are invoked in the order they are registered. As you can see, the sample code takes advantage of the parameters having been created before they are used in the VM validation logic.
```
    def finish_configuration

      configure do

        user = add_parameter 'username', {type: 'string'}
        pwd  = add_parameter 'password', {type: 'securestring'}

      end

    end

    def validate_vm_images(vm, image_ref)

      vm.configure do
          os_profile admin_username: parameter('username'), admin_password: parameter('password')
          if vm.storage_profile.nil? or vm.storage_profile.image_reference.nil?
            image image_ref
          end
      end
    end
```

## Validation

The post-processing where defaults can be set is technically meant to be used for validation of templates, where you are expected to raise exceptions for any invalid configuration that is found. Defaulting
just takes advantage of the fact that, during validation, you can just fix the problem rather than complaining about it, if you choose.

As an example of user-supplied validation, a simple rule to verify that all virtual machines have a network interface card configured can be expressed this way:

```
    def validate_vm_nics
      find_resources(Azure::ARM::Compute::VirtualMachine).each do |vm|
        if vm.network_profile.nil? or
            vm.network_profile.network_interfaces.nil? or
            vm.network_profile.network_interfaces.length == 0
          raise ArgumentError, 'All virtual machines must have at least one network interface configured.'
        end
      end
    end
```
Since your validation logic is run before the system's, doing something like this can be a good way of overriding ARMit's default behavior, which is to add a network interface for each virtual machine that doesn't have one.
Maybe you want to hold your scripts to a higher standard?

