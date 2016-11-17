# encoding: utf-8
# Code generated by Microsoft (R) AutoRest Code Generator 0.17.0.0
# Changes may cause incorrect behavior and will be lost if the code is
# regenerated.

require_relative '../arm/module_definition'
require_relative './module_definition'

module Azure::ARM::Network
    #
    # Model object.
    #
    class IpConfiguration < Azure::ARM::TypeBase

      # @return [String]
      attr_accessor :name

      # @return [IpConfigurationProperties]
      attr_accessor :properties

      #
      # Validate the object. Throws ValidationError if validation fails.
      #
      def validate
        fail ArgumentError, 'property name is nil' if @name.nil?
        fail ArgumentError, 'property properties is nil' if @properties.nil?
        @properties.validate unless @properties.nil?
      end

      #
      # Serializes given Model object into Ruby Hash.
      # @param object Model object to serialize.
      # @return [Hash] Serialized object in form of Ruby Hash.
      #
      def self.serialize_object(output_object, object)
        Azure::ARM::TypeBase.serialize_object(output_object, object)
        object.validate

        serialized_property = object.name
        output_object[:name] = serialized_property unless serialized_property.nil?

        serialized_property = object.properties
        unless serialized_property.nil?
          serialized_property = serialized_property.to_h
        end
        output_object[:properties] = serialized_property unless serialized_property.nil?

        output_object
      end

      def to_h
        hash = {}
        IpConfiguration.serialize_object(hash,self)
        hash
      end

      def self.ds_properties
        result = Array.new 
        result.push :properties
        result
      end

      #
      # Deserializes given Ruby Hash into Model object.
      # @param object [Hash] Ruby Hash object to deserialize.
      # @return [IpConfiguration] Deserialized object.
      #
      def self.deserialize_object(output_object, object)
        return if object.nil?
        conf = Configurator.new
        conf.parent = output_object

        if object.key?(:name)
          conf.name object[:name]
          object.delete :name
        end

        if object.key?(:properties)
          conf.properties object[:properties]
        end

                unless object.key?(:properties)
          conf.properties object
        end

        output_object
      end

      def get_name_template
        'ic'
        end

      def initialize(parent, init)
        super(parent)
        if init.is_a? Hash
          IpConfiguration.deserialize_object self, init.clone
        end
      end

      # Configuration code
      class Configurator < Azure::ARM::ResourceConfigurator
        attr_accessor :parent
        # @param name
        #        String
        def name(props)
          if props.is_a? String or props.is_a? Azure::ARM::Expression
            @parent.name = props
            return
          end
          @parent.name
        end
        # @param properties
        #        IpConfigurationProperties
        def properties(props)
          if @parent.properties.nil? and props.is_a? IpConfigurationProperties
            @parent.properties = props
            @parent.properties.parent = @parent
            @parent.properties._rsrcpath = 'properties'
          end
          if @parent.properties.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, IpConfigurationProperties)
            @parent.properties = IpConfigurationProperties.new(@parent, props)
            @parent.properties._rsrcpath = 'properties'
          end
          @parent.properties
        end
        # @param subnet
        #        Id
        def subnet(props)
          @parent.properties = (IpConfigurationProperties.new @parent, nil) if @parent.properties.nil?
          if @parent.properties.subnet.nil? and props.is_a? Id
            @parent.properties.subnet = props
            @parent.properties.subnet.parent = @parent
            @parent.properties.subnet._rsrcpath = 'subnet'
          end
          if @parent.properties.subnet.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            @parent.properties.subnet = Id.new(@parent, props)
            @parent.properties.subnet._rsrcpath = 'subnet'
          end
          if @parent.properties.subnet.nil? and (props.respond_to? :to_rsrcid)
            @parent.properties.subnet = Id.new(@parent, id: props.to_rsrcid.to_s)
            if props.is_a? Azure::ARM::TypeBase and !props.containing_resource.nil?
              @parent.containing_resource.add_dependency props.containing_resource
            end
          end
          @parent.properties.subnet
        end
        # @param private_ipaddress
        #        String
        def private_ipaddress(props)
          @parent.properties = (IpConfigurationProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? String or props.is_a? Azure::ARM::Expression
            @parent.properties.private_ipaddress = props
            return
          end
          @parent.properties.private_ipaddress
        end
        # @param private_ipallocation_method
        #        A string, one of 'Dynamic','Static'
        #        Expression
        def private_ipallocation_method(props)
          @parent.properties = (IpConfigurationProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? String
            fail ArgumentError, "#{props} is an invalid value for @parent.properties.private_ipallocation_method" unless ['Dynamic','Static'].index(props)
            @parent.properties.private_ipallocation_method = props
            return
          end
          if @parent.properties.private_ipallocation_method.nil? and props.is_a? Azure::ARM::Expression
            @parent.properties.private_ipallocation_method = props
          end
          @parent.properties.private_ipallocation_method
        end
        # @param public_ipaddress
        #        Id
        def public_ipaddress(props)
          @parent.properties = (IpConfigurationProperties.new @parent, nil) if @parent.properties.nil?
          if @parent.properties.public_ipaddress.nil? and props.is_a? Id
            @parent.properties.public_ipaddress = props
            @parent.properties.public_ipaddress.parent = @parent
            @parent.properties.public_ipaddress._rsrcpath = 'publicIPAddress'
          end
          if @parent.properties.public_ipaddress.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            @parent.properties.public_ipaddress = Id.new(@parent, props)
            @parent.properties.public_ipaddress._rsrcpath = 'publicIPAddress'
          end
          if @parent.properties.public_ipaddress.nil? and (props.respond_to? :to_rsrcid)
            @parent.properties.public_ipaddress = Id.new(@parent, id: props.to_rsrcid.to_s)
            if props.is_a? Azure::ARM::TypeBase and !props.containing_resource.nil?
              @parent.containing_resource.add_dependency props.containing_resource
            end
          end
          @parent.properties.public_ipaddress
        end
        # @param load_balancer_backend_address_pools
        #        Array<Id>
        def load_balancer_backend_address_pools(props)
          @parent.properties = (IpConfigurationProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? Array
            @parent.properties.load_balancer_backend_address_pools = Array.new if @parent.properties.load_balancer_backend_address_pools.nil?
            props.each { |p| @parent.properties.load_balancer_backend_address_pools.push _load_balancer_backend_address_pools_id(p) }
            return @parent.properties.load_balancer_backend_address_pools
          end
          _element = nil
          if _element.nil? and props.is_a? Id
            _element = props
            _element.parent = @parent
            _element._rsrcpath = 'loadBalancerBackendAddressPools'
          end
          if _element.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            _element = Id.new(@parent, props)
            _element._rsrcpath = 'loadBalancerBackendAddressPools'
          end
          if _element.nil? and (props.respond_to? :to_rsrcid)
            _element = Id.new(@parent, id: props.to_rsrcid.to_s)
            if props.is_a? Azure::ARM::TypeBase and !props.containing_resource.nil?
              @parent.containing_resource.add_dependency props.containing_resource
            end
          end
          unless _element.nil?
            @parent.properties.load_balancer_backend_address_pools = Array.new if @parent.properties.load_balancer_backend_address_pools.nil?
            @parent.properties.load_balancer_backend_address_pools.push _element
          end
          @parent.properties.load_balancer_backend_address_pools
        end
        def _load_balancer_backend_address_pools_id(props)
          if props.is_a? Id
            props.parent = @parent
            props._rsrcpath = 'loadBalancerBackendAddressPools'
            return props
          end
          if (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            _properties = Id.new(@parent, props)
            _properties._rsrcpath = 'loadBalancerBackendAddressPools'
            return _properties
          end
          if props.respond_to? :to_rsrcid
            return Id.new(@parent, id: props.to_rsrcid.to_s)
          end
        end
        # @param load_balancer_inbound_nat_rules
        #        Array<Id>
        def load_balancer_inbound_nat_rules(props)
          @parent.properties = (IpConfigurationProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? Array
            @parent.properties.load_balancer_inbound_nat_rules = Array.new if @parent.properties.load_balancer_inbound_nat_rules.nil?
            props.each { |p| @parent.properties.load_balancer_inbound_nat_rules.push _load_balancer_inbound_nat_rules_id(p) }
            return @parent.properties.load_balancer_inbound_nat_rules
          end
          _element = nil
          if _element.nil? and props.is_a? Id
            _element = props
            _element.parent = @parent
            _element._rsrcpath = 'loadBalancerInboundNatRules'
          end
          if _element.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            _element = Id.new(@parent, props)
            _element._rsrcpath = 'loadBalancerInboundNatRules'
          end
          if _element.nil? and (props.respond_to? :to_rsrcid)
            _element = Id.new(@parent, id: props.to_rsrcid.to_s)
            if props.is_a? Azure::ARM::TypeBase and !props.containing_resource.nil?
              @parent.containing_resource.add_dependency props.containing_resource
            end
          end
          unless _element.nil?
            @parent.properties.load_balancer_inbound_nat_rules = Array.new if @parent.properties.load_balancer_inbound_nat_rules.nil?
            @parent.properties.load_balancer_inbound_nat_rules.push _element
          end
          @parent.properties.load_balancer_inbound_nat_rules
        end
        def _load_balancer_inbound_nat_rules_id(props)
          if props.is_a? Id
            props.parent = @parent
            props._rsrcpath = 'loadBalancerInboundNatRules'
            return props
          end
          if (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            _properties = Id.new(@parent, props)
            _properties._rsrcpath = 'loadBalancerInboundNatRules'
            return _properties
          end
          if props.respond_to? :to_rsrcid
            return Id.new(@parent, id: props.to_rsrcid.to_s)
          end
        end
        def create(init=nil,&block)
          @parent = IpConfiguration.new nil, init
          self.instance_exec(@parent,&block) if block
          @parent
        end
      end
      def configure(&block)
        conf = Configurator.new
        conf.parent = self
        conf.instance_exec(self,&block) if block
        self
      end
    end
end