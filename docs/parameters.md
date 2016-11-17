# Template Parameters

There are two main scenarios for scripting with ARMit: in the first, you define the ARM template in the script and then use the Ruby Azure SDK to deploy directly.
The template itself only lives in memory while the script is executing. In this situation, where data such as names of resources or the size of VMs lives is not particularly important.

On the other hand, you may be scripting with ARMit to produce a template that you, or your colleagues, may repeatedly use for deploying infrastructure in Azure. In this case, the script
should place some of the deployment input data in parameters. For example, in one use of a template, you may want to use small VM instances, in another really big instances. The VM size
should be in a parameter, so that it's a deployment-time decision which size to allocate.

To do so, ARMit supports creating template parameters, which end up in the 'parameters' section at the beginning of the document. At deployment time, you must then supply values for
all parameters that do not have default values.

Creating a template parameters is straight-forward: you call `add_parameter` inside the template configuration block. It returns an expression referencing the parameter, which you
can then use when creating resources. In the example below, parameters are introduced for the user name and password for the VM that the template defines.

```
require 'arm_templates'

template = Azure::ARM::Template.create do

	user = add_parameter 'username', {type: 'string'}
    pwd  = add_parameter 'password', {type: 'securestring'}
		
	virtual_machine do
       os_profile admin_username: user, admin_password: pwd
    end
end
```

The hash that is passed in to `add_parameter` is a nested hash, so it should have the curly braces around its values. 'type' is the most common element to pass in the hash, but
anything that ARM templates expect in a parameter definition may be passed here. The code above will result in the following parameters section:

```
  "parameters": {
    "username": {
      "type": "string"
    },
    "password": {
      "type": "securestring"
    }
  }
```

When saving a template, you may (but do not have to) pass a hash with parameter values, which will then be saved in a separate document, following the ARM standard. For example,
if you want to distribute a template with a parameters document, you can do the following:

```
PARAMETERS = {
    username: { value: 'tmpltest' },
    password: { value: 'Foobar2001' }
}

template.save 'template', PARAMETERS
```

This produces two files -- template.json, and template.parameters.json. The latter will look like this:

```
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "username": {
      "value": "tmpltest"
    },
    "password": {
      "value": "Foobar2001"
    }
  }
}
```