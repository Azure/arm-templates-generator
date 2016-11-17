# Copying Resources

ARM templates provide an important mechanism by which a single resource definition can be duplicated in the final deployment some number of times with minor differences.
This happens when a `copy` property is added to a resource definition.

Consider the following example, which uses a single resource definition for a storage account, but at deployment time provisions 5 storage accounts.

```
  storage_account do
	copy 5
    name concat('accnt', copyIndex())
    account_type 'Standard_LRS'
  end
```

This script produces the following ARM template fragment:

```
  {
      "name": "[concat(variables('storageAccount0'),copyIndex())]",
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2015-06-15",
      "location": "[resourceGroup().location]",
      "copy": {
        "name": "[concat(variables('storageAccount0'),'-cpy')]",
        "count": 5
      },
      "properties": {
        "accountType": "Standard_LRS"
      }
  }
```
The `copy` function accepts a number, or an expression representing the number of copies to make. Passing the number of resource copies to create as a template parameter is a main scenario for copying, so it gets special treatment. 
You can also pass in a string, as in the example, in which case ARMit will treat it as a [parameter](parameters.md) holding the number.

Directly passing a string is the equivalent of:

```
cnt = add_parameter('saCount')

...
  
storage_account do
  copy parameters('saCount')
  name concat('accnt', copyIndex())
  account_type 'Standard_LRS'
end   
```