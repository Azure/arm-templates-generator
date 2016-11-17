# ARMit Templates

ARMit represents an ARM template as a script, that is, a Ruby file that creates an ARMit template. It's been an explicit design goal to make the code look as declarative as possible, but the
code is regular Ruby, so all the normal imperative language constructs are available for use. In documentation and most samples, we'll use do...end to represent multi-line blocks, since that
is the common Ruby convention, but if you prefer an even more declarative style, using {...} even for multi-line blocks may be a choice.  

A skeleton ARMit script looks like this:

```
require 'arm_templates'

PARAMETERS = { }

template = Azure::ARM::Template.create do

...

end

template.save 'template', PARAMETERS
```

The `create` class method creates a template instance and invokes the do...end (configuration) block on it before returning it. Within the scope of the block, you would typically create a number of ARM resources.
Within the block, the `self` reference is set to refer to the created template.

Configuration can be done in increments, by invoking the `configure` method on an existing template instance:

```
template.configure do

...

end
```

This allows you to separate concerns and share configuration code between template scripts.

Once the template has been fully configured, you can save it to a file using `save`, which takes a template name and, optionally, a set of default parameter values. In the example, a file `template.json` containing the 
resource definitions, and a file `template.paramters.json,` will be created.

There aren't a lot of properties to set on the template itself -- most of the methods defined are related to resource creation. One exception is definition of parameters and variables, which you have to create
through the respective template methods before using in resources created. More on this in the sections on [parameters](parameters.md) and [variables](variables.md).

## Defaults

The ARMit code goes to some lengths to set reasonable defaults for you, automatically, at least when no harm is done by doing so. For example, if you create a virtual machine with no network interface, the code will add one for you. Further, it will automatically
connect it to a virtual network, as long as there's only one. It will not, however, create a public IP address automatically, that requires explicit code since it makes the VM available on the Internet.

Similarly, the code will pick a storage account for any OS disks, or even create one, unless you specify it. It will also make up names and set the location of resources automatically, if they are not provided. The location is
set to that of the resource group by default, something that may be the right choice in almost all situations.

For many situations, there are no "brain-dead" obvious defaults, so your script will have to be explicit about them. If you don't want to clutter up your template-defining code with such details, they can sometimes be added later,
during template validation.


## Applying Validation Rules

Another property on the template is the set of validation rules, that is, userd-defined methods that are run before the template is saved. They are meant to give you a means to validate that your resources
conform to rules you have established, but can, effectively, be used for any post-processing, such as setting defaults. 

For example, in this script creating a template with 5 web servers, a method `linux_validation_rules` which you would define somewhere and bring into scope yourself, would be invoked before the template is saved:

```
require_relative 'helpers'

WEBSERVER_COUNT = 5

template = Azure::ARM::Template.create do

  linux_validation_rules
  
  av = availability_set
  
  WEBSERVER_COUNT.times do |i|
    virtual_machine "vm#{i}" do
      availability_set av
    end
  end
  
end
```

To implement the validation, I placed this code in a file `helpers.rb`. The code sets the default image references on any virtual machines that haven't got it set:

```
module Azure::ARM

  class Template

    def windows_validation_rules

      template_validation_rule { finish_configuration }

      resource_validation_rule(Azure::ARM::Compute::VirtualMachine) do |vm|
        validate_vm_images vm, Azure::ARM::Compute::VirtualMachine::WINDOWS_SERVER_2012_R2_DATACENTER
      end

    end

    def linux_validation_rules

      template_validation_rule { finish_configuration }

      resource_validation_rule(Azure::ARM::Compute::VirtualMachine) do |vm|
        validate_vm_images vm, Azure::ARM::Compute::VirtualMachine::UBUNTU_LTS
      end

    end

    def finish_configuration

      configure do

        user = add_parameter 'username', {type: 'string'}
        pwd  = add_parameter 'password', {type: 'securestring'}

      end

    end
	
    def validate_vm_images(vm, image_ref)

        vm.configure do
          os_profile admin_username: parameter('username').to_s, admin_password: parameter('password').to_s
          if vm.storage_profile.nil? or vm.storage_profile.image_reference.nil?
            image image_ref
          end
      end
    end
```

Note that the methods are added to the Template class directly -- an easy way to bring them into scope within the template configuration block. Note, also, that the logic doesn't work to reject bad templates,
it's "validation" is more constructive, fixing up missing data elements rather than just rejecting things.

The actual template methods dealing with setting validation rules are `template_validation_rule` and `resource_validation_rule`. Procs passed to the former will each be invoked once and be passed the template instance
as the 'self' reference, while procs passed to the latter will be invoked once for each resource matching the type passed (in this case, virtual machines). Passing 'nil' for the resource type means the
proc will be called for each resource. Validation rules are invoked in the order they are registered. As you can see, the sample code takes advantage of the parameters having been created before they are used in the VM validation logic.

Validation interacts with script defaulting logic, so this topic is discussed in further detail in [Setting Defaults and Validating Templates](defaults.md).

## Generating Template Files

Once a template has been populated with content, the resulting ARM template can be retrieved by calling the `save` method on the template object. The method takes two parameters. First, the base name of the file to
which the template will be saved; the extension `.json` will be added to this string. Second, you can supply a hash of parameter defaults, in the same format as you would send across when deploying a template.
The hash will be saved as a file with the extentsion `.parameters.json`.

For example:

```
PARAMETERS = {
    username: { value: 'tmpltest' },
    password: { value: 'Foobar2001' },
    vmCount:  { value: 2 }
}

template = Azure::ARM::Template.create do

   ...

end

template.save 'template', PARAMETERS
```
