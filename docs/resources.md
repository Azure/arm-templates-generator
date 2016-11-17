# Azure Resources

The core ARMit concept is that of a resource. Configuring and creating resources is what ARM template deployment is all about, after all.

Resources are organized by their resource type, of which there are many. The ARMit prototype supports a significant subset of the available resource types. Each type is represented by a Ruby class,
and has a factory method available on the Template class, which organizes all such factories. Resource types are strings comprised of the resource provider name and the type, and usually expressed in
English plural. The corresponding ARMit class will use singular.

For example, the resource type representing storage account is `Microsoft.Storage/storageAccounts` and the Ruby class in ARMit is called `Azure::ARM::Storage::StorageAccount`, while the corresponding 
template factory method is `storage_account`.

The ARMit snippet:

```
template = Azure::ARM::Template.create do

  storage_account do	# Creates an instance of Azure::ARM::Storage::StorageAccount
    ...
  end
  
end
```
represents the following ARM template document fragment:
```
  {
      "name": "[variables('storageAccount0')]",
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2015-06-15",
      "location": "[resourceGroup().location]",
      "properties": {
        "accountType": "Standard_LRS"
      }
  }
```
The change from plural to singular is a deliberate choice that was made in order to follow common conventions around naming of classes in Ruby.  

Creating resources directly using their class constructors is not recommended. The factory methods on the Template class do a lot more than just create the instance, it also establishes relationships
between resources that depend on each other and sets some important defaults.

When creating a resource, you typically don't pass any data to the factory method itself, instead, the configuration happens within the body of the block passed. If data is passed, it
should be a string, and expression, or a Ruby Hash. In the case of strings and expressions, the data is them assumed to be the name of the resource. In the case of a Hash, it should hold data elements
for the resource.

For example, instad of configuring the storage account resource using a block, you can pass in data directly:

```
  storage_account name: 'foobar', account_type: 'Standard_LRS'
  
  storage_account 'foobar' do
    account_type 'Standard_LRS'
  end
```

Which method you use is a matter of personal preference. For many resources, configuration may require more complex logic, in which case doing the configuration
in blocks makes more sense.


## Resource Names

Each resource has to have a specific name, which represents its identity within a resource group. The rules for what names are valid varies from resource type 
to resource type. Similarly, some resource names need to be unique for the Azure region, while others only need to be unique within the resource group used
for its deployment.

ARMit simplifies resource naming by implementing default name creation when the script does not pass them in, but the name choices may appear rather arbitrary
after deployment. Many default names are created from the resource group id, which is an opaque string. If you care about the names your resources have, it is
necessary to configure names directly in the script.

The example above passes in resource names as strings. Another approach is to create a template [variable](variables.md) and use that when creating resources.

```
name = add_variable 'name-1', concat('sa', resourceGroup().id)

storage_account name do
  ...
end
```

## Child Resources

Some resources exist only in the context of a "parent" resource. For example, SQL databases are created as children of SQL server resources. This relationship is
reflected in the resource type name: `Microsoft.Sql/servers/databases`. Child resources are created not in context of the template, but under the parent resource.

```
Azure::ARM::Template.create do

  server 'mysqlserver' do
    version '2.0'
  
    administrator_login 'niklasg'
    administrator_login_password 'Niklas1020Gustafsson'
  
    database 'firstDB' do
      edition 'Basic'
      max_size_bytes '104857600'
    end
  end
  
end
```

## Configuration

As mentioned earlier, configuration of resources may be done by passing in a Hash to the factory method, or by calling configuration methods within the
block attached to the factory method. Configuration may involve setting resource properties, adding child resources, or adding references to other top-level resources.

As an example of adding a resource reference, consider the following, which creates a number of virtual machines all belonging to the same availability set:

```
  #
  # Create a number of VMs within an availability set.
  # None of the VMs will have a public IP address.
  #
  av = availability_set

  VM_COUNT.times do
    virtual_machine do
      availability_set av
    end
  end
```

Availability sets and virtual machines are both top-level resources, which means that they will appear directly in the template's resource list. When the script calls the
`availability_set` method from within the configuration block for the virtual machines, it is setting a reference to the availability set, not creating a new resource.

The output looks like this:

```
"resources": [
    {
      "name": "as-0",
      "type": "Microsoft.Compute/availabilitySets",
      "apiVersion": "2015-06-15",
      "location": "[resourceGroup().location]",
      "properties": {
        "platformUpdateDomainCount": 2
      }
    },
    {
      "name": "vm-2",
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2015-06-15",
      "dependsOn": [
        "[resourceId('Microsoft.Compute/availabilitySets','as-0')]",
        "[resourceId('Microsoft.Network/networkInterfaces','vm-2-nic')]",
        "[resourceId('Microsoft.Storage/storageAccounts','foobar')]"
      ],
      "location": "[resourceGroup().location]",
      "properties": {
        "availabilitySet": {
          "id": "[resourceId('Microsoft.Compute/availabilitySets','as-0')]"
        },
        ...
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
Note that the resource reference appears both in the `dependsOn` property and under the `availabilitySet` property. The first is used during the deployment to determine the resource creation order, while the second
is the actual, functional, reference to an availability set. You can see that the same is true for the network interface resource the virtual machine depends on, `vm-nic-2`.