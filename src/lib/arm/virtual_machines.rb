module Azure::ARM

  class Template
    #
    # Disambiguate the multiple 'extension' methods that are contributed to the
    # top-level Template class.
    #
    def vm_extension(vm, name, init=nil, &block)
      conf = Azure::ARM::Compute::Extension::Configurator.new self

      name = concat(vm.name, '/', name)
      if init.nil?
        init = {}
      end
      init[:name] = name

      conf.create init
      conf.instance_exec(conf.parent,&block) if block
      conf.parent.add_dependency vm
      conf.parent
    end

    def web_extension(init=nil,&block)
      conf = Azure::ARM::Web::Extension::Configurator.new self
      conf.create init
      conf.instance_exec(conf.parent,&block) if block
      conf.parent
    end

  end

  module Compute


      #
      # Microsoft.Compute/virtualMachines
      #
      class VirtualMachine < Azure::ARM::ResourceBase

        def prepare
          @properties = VirtualMachinesProperties.new self, nil if @properties.nil?
          conf = Configurator.new self.template
          conf.parent = self
          conf.hardware_profile vm_size: 'Standard_A1' if @properties.hardware_profile.nil?
          conf.network_settings if @properties.network_profile.nil?

          unless @properties.os_profile.nil?
            @properties.os_profile.computer_name = self.name if @properties.os_profile.computer_name.nil?
          end

          if !@properties.storage_profile.nil? and @properties.storage_profile.os_disk.nil?
            conf.os_disk
          end

        end

        #
        # Extensions to the Configurator class
        #
        # noinspection RubyResolve,RubyResolve,RubyResolve,RubyResolve
        class Configurator < Azure::ARM::ResourceConfigurator

          #
          # Creates a network interface for a VM
          #
          def network_settings(*args, &block)

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
                if a.is_a? Azure::ARM::Network::PublicIPAddress
                  props[:public_ipaddress] = a
                end
                if a.is_a? Azure::ARM::Network::BackendAddressPools
                  props[:load_balancer_backend_address_pools] = a
                end
                if a.is_a? Azure::ARM::Network::InboundNatRules
                  props[:load_balancer_inbound_nat_rules] = a
                end
              end
            end

            vm = parent
            name = 'server'
            unless vm.copy
              name = vm.generate_name(vm.name+'nic')
            end

            unless props.nil?
              pip = props[:public_ipaddress]
              lbbep = props[:load_balancer_backend_address_pools]
              lbinr = props[:load_balancer_inbound_nat_rules]
              priv_addr = props[:private_ipaddress]
            else
              pip = lbbep = lbinr = priv_addr = nil
            end

            if !pip.nil? and pip.is_a? String
              pip = public_ipaddress pip do
                dns_settings domain_name_label: pip
              end
            end

            nic = template.network_interface name do |nic|

              if vm.copy
                copy vm.copy.count
              end

              vnet = template.find_resource Azure::ARM::Network::VirtualNetwork

              if vnet.nil?
                vnet = template.virtual_network do
                    address_space address_prefixes: [ '10.1.0.0/16' ]
                    subnets address_prefix: '10.1.0.0/24'
                end
              end

              nic.add_dependency vnet

              config = { name: vm.generate_name(name+'ip'),
                         public_ipaddress: unless pip.nil? then pip end,
                         load_balancer_backend_address_pools: unless lbbep.nil? then lbbep end,
                         load_balancer_inbound_nat_rules: unless lbinr.nil? then lbinr end,
                         subnet: vnet.properties.nil? ? nil : vnet.properties.subnets[0] }

              if priv_addr.nil?
                config[:private_ipallocation_method] = 'Dynamic'
              else
                config[:private_ipaddress] = priv_addr
                config[:private_ipallocation_method] = 'Static'
              end

              ip_configurations config

            end

            network_profile network_interfaces: [ { id: nic.to_rsrcid.to_s }]

            parent.add_dependency nic

            nic.configure &block if block

          end

          def public_ipaddress(address,&block)

            if address.is_a? String
              address = template.public_ipaddress { dns_settings domain_name_label: address }
            end

            network_settings public_ipaddress: address

            address.configure &block if block

          end

          #
          # Creates an OS disk for a VM
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

            name = parent.generate_name(parent.name.to_s + 'dsk')

            if parent.copy
              disk_uri = concat('http://', account.name, '.blob.core.windows.net/disks/', name, copyIndex(), '.vhd')
            else
              disk_uri = concat('http://', account.name, '.blob.core.windows.net/disks/', name, '.vhd')
            end

            props = { name: name,
                      caching: 'ReadWrite',
                      create_option: 'FromImage',
                      vhd: { uri: disk_uri } }

            if parent.properties.nil? or parent.properties.storage_profile.nil?
              storage_profile os_disk: props
            else
              parent.properties.storage_profile.os_disk = OsDisk.new parent.properties.storage_profile, props
            end

          end

          #
          # Define the OS image to use
          #
          def image(reference)
            if parent.properties.nil? or parent.properties.storage_profile.nil?
              storage_profile image_reference: reference
            else
              parent.properties.storage_profile.image_reference = reference
            end
          end

          #
          # Set the VM size
          #
          def vm_size(size)
            if parent.properties.nil? or parent.properties.hardware_profile.nil?
              hardware_profile vm_size: size
            else
              parent.properties.hardware_profile.vm_size = size
            end
          end

        end

        #
        # Operating system image reference values
        #
        WINDOWS_SQL_SERVER_2014 = {
            publisher: 'MicrosoftSQLServer',
            offer: 'SQL2014SP1-WS2012R2',
            sku: 'Web',
            version: 'latest'
        }

        WINDOWS_SERVER_2012_R2_DATACENTER =  {
            publisher: 'MicrosoftWindowsServer',
            offer: 'WindowsServer',
            sku: '2012-R2-Datacenter',
            version: 'latest'
        }

        CENTOS = {
            publisher: 'OpenLogic',
            offer: 'CentOS',
            sku: '7.2',
            version: 'latest'
        }

        COREOS = {
            publisher: 'CoreOS',
            offer: 'CoreOS',
            sku: 'Stable',
            version: 'latest'
        }

        DEBIAN = {
            publisher: 'credativ',
            offer: 'Debian',
            sku: '8',
            version: 'latest'
        }

        OPEN_SUSE = {
            publisher: 'SUSE',
            offer: 'openSUSE',
            sku: '13.2',
            version: 'latest'
        }
        RHEL = {
            publisher: 'RedHat',
            offer: 'RHEL',
            sku: '7.2',
            version: 'latest'
        }
        SLES = {
            publisher: 'SUSE',
            offer: 'SLES',
            sku: '12-SP1',
            version: 'latest'
        }

        UBUNTU_LTS = {
            publisher: 'Canonical',
            offer: 'UbuntuServer',
            sku: '14.04.4-LTS',
            version: 'latest'
        }

        UBUNTU_15_10 =  {
            publisher: 'Canonical',
            offer: 'UbuntuServer',
            sku: '15.10',
            version: 'latest'
        }

        #
        # Standard Virtual Machine sizes
        #
        Standard_A0 = { vm_size: 'Standard_A0'}
        Standard_A1 = { vm_size: 'Standard_A1'}
        Standard_A2 = { vm_size: 'Standard_A2'}
        Standard_A3 = { vm_size: 'Standard_A3'}
        Standard_A4 = { vm_size: 'Standard_A4'}
        Standard_A5 = { vm_size: 'Standard_A5'}
        Standard_A6 = { vm_size: 'Standard_A6'}
        Standard_A7 = { vm_size: 'Standard_A7'}

        Standard_D1 = { vm_size: 'Standard_D1'}
        Standard_D2 = { vm_size: 'Standard_D2'}
        Standard_D3 = { vm_size: 'Standard_D3'}
        Standard_D4 = { vm_size: 'Standard_D4'}
        Standard_D11 = { vm_size: 'Standard_D11'}
        Standard_D12 = { vm_size: 'Standard_D12'}
        Standard_D13 = { vm_size: 'Standard_D13'}
        Standard_D14 = { vm_size: 'Standard_D14'}

        Standard_D1_v2 = { vm_size: 'Standard_D1_v2'}
        Standard_D2_v2 = { vm_size: 'Standard_D2_v2'}
        Standard_D3_v2 = { vm_size: 'Standard_D3_v2'}
        Standard_D4_v2 = { vm_size: 'Standard_D4_v2'}
        Standard_D5_v2 = { vm_size: 'Standard_D5_v2'}
        Standard_D11_v2 = { vm_size: 'Standard_D11_v2'}
        Standard_D12_v2 = { vm_size: 'Standard_D12_v2'}
        Standard_D13_v2 = { vm_size: 'Standard_D13_v2'}
        Standard_D14_v2 = { vm_size: 'Standard_D14_v2'}
        Standard_D15_v2 = { vm_size: 'Standard_D15_v2'}

        Standard_DS1 = { vm_size: 'Standard_DS1'}
        Standard_DS2 = { vm_size: 'Standard_DS2'}
        Standard_DS3 = { vm_size: 'Standard_DS3'}
        Standard_DS4 = { vm_size: 'Standard_DS4'}
        Standard_DS11 = { vm_size: 'Standard_DS11'}
        Standard_DS12 = { vm_size: 'Standard_DS12'}
        Standard_DS13 = { vm_size: 'Standard_DS13'}
        Standard_DS14 = { vm_size: 'Standard_DS14'}

        Standard_DS1_v2 = { vm_size: 'Standard_DS1_v2'}
        Standard_DS2_v2 = { vm_size: 'Standard_DS2_v2'}
        Standard_DS3_v2 = { vm_size: 'Standard_DS3_v2'}
        Standard_DS4_v2 = { vm_size: 'Standard_DS4_v2'}
        Standard_DS5_v2 = { vm_size: 'Standard_DS5_v2'}
        Standard_DS11_v2 = { vm_size: 'Standard_DS11_v2'}
        Standard_DS12_v2 = { vm_size: 'Standard_DS12_v2'}
        Standard_DS13_v2 = { vm_size: 'Standard_DS13_v2'}
        Standard_DS14_v2 = { vm_size: 'Standard_DS14_v2'}
        Standard_DS15_v2 = { vm_size: 'Standard_DS15_v2'}

        Standard_G1 = { vm_size: 'Standard_G1'}
        Standard_G2 = { vm_size: 'Standard_G2'}
        Standard_G3 = { vm_size: 'Standard_G3'}
        Standard_G4 = { vm_size: 'Standard_G4'}
        Standard_G5 = { vm_size: 'Standard_G5'}

        Standard_GS1 = { vm_size: 'Standard_GS1'}
        Standard_GS2 = { vm_size: 'Standard_GS2'}
        Standard_GS3 = { vm_size: 'Standard_GS3'}
        Standard_GS4 = { vm_size: 'Standard_GS4'}
        Standard_GS5 = { vm_size: 'Standard_GS5'}

      end
  end

end
