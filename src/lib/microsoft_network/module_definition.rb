# encoding: utf-8
# Code generated by Microsoft (R) AutoRest Code Generator 0.17.0.0
# Changes may cause incorrect behavior and will be lost if the code is
# regenerated.

module Azure end
module Azure::ARM end
module Azure::ARM::Network end

require_relative 'public_ipaddress_dns_settings'
require_relative 'network_interface_dns_settings'
require_relative 'id'
require_relative 'ip_configuration'
require_relative 'ip_configuration_properties'
require_relative 'address_space'
require_relative 'dhcp_options'
require_relative 'subnet_properties'
require_relative 'subnet'
require_relative 'frontend_ipconfigurations_external_properties'
require_relative 'frontend_ipconfigurations_internal_properties'
require_relative 'frontend_ipconfigurations'
require_relative 'frontend_ipconfigurations_properties'
require_relative 'backend_address_pools'
require_relative 'load_balancing_rules_properties'
require_relative 'load_balancing_rules'
require_relative 'probe_properties'
require_relative 'probes'
require_relative 'inbound_nat_rules_properties'
require_relative 'inbound_nat_rules'
require_relative 'inbound_nat_pools_properties'
require_relative 'inbound_nat_pools'
require_relative 'outbound_nat_rules_properties'
require_relative 'outbound_nat_rules'
require_relative 'securityrule_properties'
require_relative 'security_rules'
require_relative 'route_properties'
require_relative 'routes'
require_relative 'public_ipaddresses_properties'
require_relative 'network_interfaces_properties'
require_relative 'virtual_networks_properties'
require_relative 'load_balancers_properties'
require_relative 'network_security_groups_properties'
require_relative 'route_tables_properties'
require_relative 'public_ipaddresses'
require_relative 'network_interfaces'
require_relative 'virtual_networks'
require_relative 'load_balancers'
require_relative 'network_security_groups'
require_relative 'route_tables'

class Azure::ARM::Template
  def public_ipaddress(init=nil,&block)
    conf = Azure::ARM::Network::PublicIPAddress::Configurator.new self
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def network_interface(init=nil,&block)
    conf = Azure::ARM::Network::NetworkInterface::Configurator.new self
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def virtual_network(init=nil,&block)
    conf = Azure::ARM::Network::VirtualNetwork::Configurator.new self
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def load_balancer(init=nil,&block)
    conf = Azure::ARM::Network::LoadBalancer::Configurator.new self
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def network_security_group(init=nil,&block)
    conf = Azure::ARM::Network::NetworkSecurityGroup::Configurator.new self
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def route_table(init=nil,&block)
    conf = Azure::ARM::Network::RouteTable::Configurator.new self
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def public_ipaddress_dns_settings(init=nil,&block)
    conf = Azure::ARM::Network::PublicIPAddressDnsSettings::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def network_interface_dns_settings(init=nil,&block)
    conf = Azure::ARM::Network::NetworkInterfaceDnsSettings::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def id(init=nil,&block)
    conf = Azure::ARM::Network::Id::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def ip_configuration(init=nil,&block)
    conf = Azure::ARM::Network::IpConfiguration::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def ip_configuration_properties(init=nil,&block)
    conf = Azure::ARM::Network::IpConfigurationProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def address_space(init=nil,&block)
    conf = Azure::ARM::Network::AddressSpace::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def dhcp_options(init=nil,&block)
    conf = Azure::ARM::Network::DhcpOptions::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def subnet_properties(init=nil,&block)
    conf = Azure::ARM::Network::SubnetProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def subnet(init=nil,&block)
    conf = Azure::ARM::Network::Subnet::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def frontend_ipconfigurations_external_properties(init=nil,&block)
    conf = Azure::ARM::Network::FrontendIPConfigurationsExternalProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def frontend_ipconfigurations_internal_properties(init=nil,&block)
    conf = Azure::ARM::Network::FrontendIPConfigurationsInternalProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def frontend_ipconfigurations(init=nil,&block)
    conf = Azure::ARM::Network::FrontendIPConfigurations::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def backend_address_pools(init=nil,&block)
    conf = Azure::ARM::Network::BackendAddressPools::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def load_balancing_rules_properties(init=nil,&block)
    conf = Azure::ARM::Network::LoadBalancingRulesProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def load_balancing_rules(init=nil,&block)
    conf = Azure::ARM::Network::LoadBalancingRules::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def probe_properties(init=nil,&block)
    conf = Azure::ARM::Network::ProbeProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def probes(init=nil,&block)
    conf = Azure::ARM::Network::Probes::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def inbound_nat_rules_properties(init=nil,&block)
    conf = Azure::ARM::Network::InboundNatRulesProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def inbound_nat_rules(init=nil,&block)
    conf = Azure::ARM::Network::InboundNatRules::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def inbound_nat_pools_properties(init=nil,&block)
    conf = Azure::ARM::Network::InboundNatPoolsProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def inbound_nat_pools(init=nil,&block)
    conf = Azure::ARM::Network::InboundNatPools::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def outbound_nat_rules_properties(init=nil,&block)
    conf = Azure::ARM::Network::OutboundNatRulesProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def outbound_nat_rules(init=nil,&block)
    conf = Azure::ARM::Network::OutboundNatRules::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def securityrule_properties(init=nil,&block)
    conf = Azure::ARM::Network::SecurityruleProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def security_rules(init=nil,&block)
    conf = Azure::ARM::Network::SecurityRules::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def route_properties(init=nil,&block)
    conf = Azure::ARM::Network::RouteProperties::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
  def routes(init=nil,&block)
    conf = Azure::ARM::Network::Routes::Configurator.new
    conf.create init
    conf.instance_exec(conf.parent,&block) if block
    conf.parent
  end
end

