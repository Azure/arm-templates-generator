# ARM Template Expressions

ARM templates define a simple expression language, allowing templates to defer evaluation of some data until deployment time, as well as refer to variables and parameters from within resource definitions.

ARMit support that expression language directly in the script framework, where the ARM functions and properties appear as normal Ruby expressions. Under the covers, the code builds data structures
to represent the expressions, which are then turned into the ARM template language expression syntax when the template is saved.

Expressions are formed from literals and function calls. There is a small set of functions, all defined by ARM and represented in ARMit as a module Azure::ARM::PredefinedExpressions, which
is mixed in to the Template as well as ResourceBase classes, so that they are available without qualification in all templates and resources. There is no means of defining additional ARM functions to
include in template expressions, ARM doesn't allow it. You can, of course, define Ruby methods that build expressions for your script, but that is a definition-time concept, not
deployment-time.

With the ARMit support for expressions, it's easy to use them directly in your code, as in this example which assigns the ARM expression `[concat("strge", uniqueString(resourceGroup().id))]` to a Ruby variable:

```
template = Azure::ARM::Template.create do
  
  group_id_name = concat('strge', uniqueString(resourceGroup().id))

end
```

This expression may then be used wherever expressions are allowed by ARM, which is a lot of places. Just about anywhere a String, Boolean, or Number is used, an expression can be used instead. 

With the exception of literals, ARMit expressions are not typed. This means that the correctness of expressions are not determined at template definition time, it's done at the service when
deploying the template. For example, if the expression above is something like `concat('strge', uniqueString(resourceGroup().identifier))`, the error in the last element will not be found until
you deploy the template to the ARM deployment service. 

## Functions

As previously mentioned, the expression ARMit fully supports the use of [ARM template functions](https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-functions/).

The following example illustrates the use of the ARM `resourceGroup` function:

```
template = Azure::ARM::Template.create do

  storage_account resourceGroup().name do
    account_type Azure::ARM::StorageAccount::Standard_LRS
  end
  
end
```

This script produces the following ARM template (the location value has nothing to do with our use of expressions here, it's just the default location value):

```
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "name": "[resourceGroup().name]",
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2015-06-15",
      "location": "[resourceGroup().location]",
      "properties": {
        "accountType": "Standard_LRS"
      }
    }
  ]
}
```

ARMit currently supports the following set of functions:

- Numeric Functions
  - `add`
  - `div`
  - `int`
  - `length`
  - `mod`
  - `mul`
  - `sub`

- String Functions
  - `base64`
  - `concat`
  - `padLeft`
  - `replace`
  - `split`
  - `string`
  - `substring`
  - `toLower`
  - `toUpper`
  - `trim`
  - `uniqueString`
  - `uri`

- Array Functions
  - `length`
  - `split`

- Deployment Functions
  - `deployment`

- Resource Functions
  - `listKeys`
  - `providers`
  - `reference`
  - `resourceGroup`
  - `resourceId`
  - `subscription`
