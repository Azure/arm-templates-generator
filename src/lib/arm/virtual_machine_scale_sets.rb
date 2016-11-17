module Azure::ARM
  module Compute


    class VirtualMachineScaleSet <  Azure::ARM::ResourceBase

      def prepare
        @properties = VirtualMachinesProperties.new self, nil if @properties.nil?
        @properties.virtual_machine_profile = VirtualMachineProfile.new @properties, nil if @properties.virtual_machine_profile.nil?

        conf = Configurator.new self.template
        conf.parent = self
        conf.sku name: 'Standard_A1', tier: 'Standard', capacity: 3 if @properties.sku.nil?
        # @properties.virtual_machine_profile.network_settings if @properties.virtual_machine_profile.network_profile.nil?

        unless @properties.os_profile.nil?
          @properties.virtual_machine_profile.os_profile.computer_name = self.name if @properties.virtual_machine_profile.os_profile.computer_name.nil?
        end

        if !@properties.virtual_machine_profile.storage_profile.nil? and @properties.virtual_machine_profile.storage_profile.os_disk.nil?
          conf.os_disk
        end

      end

      #
      # Extensions to the Configurator class
      #
      # noinspection RubyResolve,RubyResolve,RubyResolve,RubyResolve
      class Configurator < Azure::ARM::ResourceConfigurator

        #
        # Creates a network interface for a VM scale set
        #
        def network_configuration(*args, &block)

          template = parent.nil? ? nil : parent.template

          return nil if template.nil?

          if args and args.length > 0
            props = args.find { |a| a.is_a? Hash}
          end

          if props.nil?
            props = Hash.new
          end

          unless args.nil?
            args.each do |a|
              if a.is_a? Azure::ARM::Network::BackendAddressPools
                props[:load_balancer_backend_address_pools] = a
              end
            end
          end

          vmss = parent
          name = nil
          unless vmss.copy
            name = vmss.generate_name(vmss.name+'nic')
          end

          unless props.nil?
            lbbep = props[:load_balancer_backend_address_pools]
          end

          nic = template.network_interface_configuration name do |nic|

            if vmss.copy
              copy vmss.copy.count
            end

            vnet = template.find_resource Azure::ARM::Network::VirtualNetwork

            if vnet.nil?
              vnet = template.virtual_network do
                address_space address_prefixes: [ '10.1.0.0/16' ]
                subnets address_prefix: '10.1.0.0/24'
              end
            end

            vmss.add_dependency vnet

            conf = Azure::ARM::Compute::IpConfiguration::Configurator.new
            config = conf.create name: nic.name + 'ipc',
                                 subnet: { id: vnet.properties.nil? ? nil : vnet.properties.subnets[0].to_rsrcid }
            conf.parent = config
            config.parent = nic

            nic.parent = vmss

            unless lbbep.nil?
              config.configure do
                load_balancer_backend_address_pools lbbep
              end
            end

            primary true

            ip_configurations config

          end

          vmss.prepare()

          vmss.properties.virtual_machine_profile.configure do
            network_profile network_interface_configurations: [ nic ]
          end

          nic.configure &block if block

        end
        #
        # Define the OS image to use
        #
        def image(reference)
          if parent.properties.nil? or parent.properties.virtual_machine_profile.nil? or parent.properties.virtual_machine_profile.storage_profile.nil?
            storage_profile image_reference: reference
          else
            parent.properties.virtual_machine_profile.storage_profile.image_reference = reference
          end
        end

        def network_settings

        end

        #
        # Creates an OS disk for a VM scale set template
        #
        def os_disk(account=nil)

          if account.nil?

            template = parent.nil? ? nil : parent.template
            return nil if template.nil?

            found = template.find_resources(Azure::ARM::Storage::StorageAccount)

            if found.nil? or found.length == 0
              account = template.storage_account do
                account_type Azure::ARM::Storage::StorageAccount::Standard_LRS
              end
            elsif found.length == 1
              account = found[0]
            else
              fail ArgumentError, 'cannot determine which storage account to use of the VM disks'
            end

          elsif account.is_a? String

            template = parent.nil? ? nil : parent.template
            return nil if template.nil?

            found = template.find_resource(Azure::ARM::Storage::StorageAccount, account)

            if found.nil?
              account = template.storage_accounts account do
                account_type Azure::ARM::Storage::StorageAccount::Standard_LRS
              end
            else
              account = found
            end

          end

          parent.add_dependency account

          name = concat(parent.name, parent.generate_name('dsk'))

          props = { name: name,
                    caching: 'ReadWrite',
                    create_option: 'FromImage',
                    vhd_containers: [ concat('https://', account.name, '.blob.core.windows.net/', name) ]
                  }

          if parent.properties.nil? or parent.properties.virtual_machine_profile.storage_profile.nil?
            storage_profile os_disk: props
          else
            parent.properties.virtual_machine_profile.storage_profile.os_disk =
                VirtualMachineScaleSetOSDisk.new parent.properties.virtual_machine_profile.storage_profile, props
          end

        end
      end

    end
  end
end
