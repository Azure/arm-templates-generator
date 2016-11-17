require 'arm_templates'

ALLOW_HTTP = {
    description: 'Allow Consul HTTP',
    destination_port_range: '8500',
    source_port_range: '*',
    source_address_prefix: 'Internet',
    destination_address_prefix: '*',
    access: 'Allow',
    priority: 110,
    direction: 'Inbound',
    protocol: 'Tcp'
}

ALLOW_DNS = {
    description: 'Allow Consul DNS',
    destination_port_range: '8600',
    source_port_range: '*',
    source_address_prefix: 'Internet',
    destination_address_prefix: '*',
    access: 'Allow',
    priority: 100,
    direction: 'Inbound',
    protocol: 'Tcp'
}

module Azure::ARM

  class Template

    #
    # Set up a jump box with a public IP address. This will be used only to
    # access other resources.
    # @param name [String] The public DNS name for the jumpbox
    def add_linux_jumpbox name
      virtual_machine name+'jbx' do
        public_ipaddress name
        image Azure::ARM::Compute::VirtualMachine::UBUNTU_LTS
      end
    end

    #
    # Set up a jump box with a public IP address. This will be used only to
    # access other resources.
    # @param name [String] The public DNS name for the jumpbox
    def add_windows_jumpbox name
      virtual_machine name+'jbx' do
        public_ipaddress name
        image Azure::ARM::Compute::VirtualMachine::WINDOWS_SERVER_2012_R2_DATACENTER
      end
    end

    #
    # Post-processing for Windows VMs
    #
    def windows_validation_rules

      template_validation_rule { finish_windows_configuration }

      resource_validation_rule(Azure::ARM::Compute::VirtualMachine) do |vm|
        validate_vm_images vm, Azure::ARM::Compute::VirtualMachine::WINDOWS_SERVER_2012_R2_DATACENTER
      end

    end

    #
    # Post-processing for Linux VMs and VM scale sets
    #
    def linux_validation_rules

      template_validation_rule { finish_linux_configuration }

      resource_validation_rule(Azure::ARM::Compute::VirtualMachine) do |vm|
        vm.configure do
          os_profile admin_username: parameter('username'),
                     linux_configuration: {
                         disable_password_authentication: true,
                         ssh: { public_keys:
                             { path: concat('/home/',parameters('username'),'/.ssh/authorized_keys'),
                               key_data: parameter('ssh_key') }
                         }
                     }
          if vm.storage_profile.nil? or vm.storage_profile.image_reference.nil?
            image Azure::ARM::Compute::VirtualMachine::UBUNTU_LTS
          end
        end
      end

      resource_validation_rule(Azure::ARM::Compute::VirtualMachineScaleSet) do |vmss|

        vmss.configure do

            vmss.properties.virtual_machine_profile.configure do |profile|

              if profile.os_profile.nil?
                os_profile admin_username: parameter('username'),
                           computer_name_prefix: vmss.name,
                           linux_configuration: {
                               disable_password_authentication: true,
                               ssh: { public_keys:
                                          { path: concat('/home/',parameters('username'),'/.ssh/authorized_keys'),
                                            key_data: parameter('ssh_key') }
                               }
                           }
              end

              if profile.storage_profile.nil? or profile.storage_profile.image_reference.nil?

                storage_profile (vmss.template.virtual_machine_scale_set_storage_profile image_reference: Azure::ARM::Compute::VirtualMachine::UBUNTU_LTS)

              end

            end

            os_disk

            network_configuration

        end

      end

    end

    #
    # Further configure the template with some of the information that isn't really about
    # the structure or logic of the deployment template. Then save and/or deploy the template.
    #
    def finish_windows_configuration

      configure do

        user = add_parameter 'username', {type: 'string'}
        pwd  = add_parameter 'password', {type: 'securestring'}

      end

    end

    #
    # Further configure the template with some of the information that isn't really about
    # the structure or logic of the deployment template. Then save and/or deploy the template.
    #
    def finish_linux_configuration

      configure do

        user = add_parameter 'username', {type: 'string'}
        pwd  = add_parameter 'ssh_key',  {type: 'string'}

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

    def validate_vm_nics
      find_resources(Azure::ARM::Compute::VirtualMachine).each do |vm|
        if vm.network_profile.nil? or
            vm.network_profile.network_interfaces.nil? or
            vm.network_profile.network_interfaces.length == 0
          puts 'All virtual machines must have at least one network interface configured.'
        end
      end
    end

    #
    # Add a load balancer for port 80 (HTTP)
    # @param name [String] The name of the load balancer
    # @param id_address [String/IPAddress] A public IP address or string.
    def add_http_load_balancer(name, ip_address=nil)

      add_load_balancer name, 80, ip_address

    end

    #
    # Add a load balancer for a given port and public ip address
    # @param name [String] The name of the load balancer
    # @param ports [Integer / Array<Integer>] The ports to load balance
    # @param id_address [String/IPAddress] A public IP address or string.
    def add_load_balancer(name, ports, ip_address)

      unless ports.is_a? Array
        ports = [ ports ]
      end

      if name.nil?
        name = "lb#{RandomName.create(5,3)}"
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

        ports.each do |port|

          p = probes name: name + "-probe#{port}",
                     protocol: 'Tcp',
                     port: port,
                     number_of_probes: 2,
                     interval_in_seconds: 15

          load_balancing_rules name: "rule#{port}",
                               frontend_ipconfiguration: fics[0],
                               backend_address_pool: pools[0],
                               protocol: 'Tcp',
                               frontend_port: port,
                               backend_port: port,
                               idle_timeout_in_minutes: 15,
                               probe: p[0]
        end

      end

    end

  end

  module Network

    class LoadBalancer < Azure::ARM::ResourceBase

      #
      # Add a NAT rule for RDP (port 3389)
      # @param fe_port [Integer] The front-end port number to route to 3389
      # @return [Array<NatRule>] The NAT rules array.
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

      #
      # Adds a NAT rule for SSH (port 22)
      # @param fe_port [Integer] The front-end port number to route to 22
      # @return [Array<NatRule>] The NAT rules array.
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
