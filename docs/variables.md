# Template Variables

Like is the case with [parameters](parameters.md), template variables are mostly useful when the ARMit script is used mainly to produce a template that is then used repeatedly. Variables make it easy to
customize the template when parameters are going too far.

For example, you may wish to use a particular name for a storage account, and the name should be the same for all uses of the template, but the name may change in the future. It's not going to vary for
each deployment, but it's used in a lot of places in the template, so changing it without using a variable is risky (you may miss one spot).

Variables are created and used in much the same fashion as parameters, calling `add_variable` from within the template configuration block, as illustrated by this storage account example:

```
template = Azure::ARM::Template.create do
  
  name = add_variable 'storageAccount', concat('strge', uniqueString(resourceGroup().id))

  storage_account name do
    account_type 'Standard_LRS'
  end
  
end
```

When saved, the following section ends up in the template JSON document:

```
  "variables": {
    "storageAccount": "[concat('strge',uniqueString(resourceGroup().id))]",
  }  
```

As you would expect, the storage account is then defined as:

```
  {
	"name": "[variables('storageAccount')]",
	"type": "Microsoft.Storage/storageAccounts",
	"apiVersion": "2015-06-15",
	"location": "[resourceGroup().location]",
	"properties": {
  	  "accountType": "Standard_LRS"
	}
  }  
```