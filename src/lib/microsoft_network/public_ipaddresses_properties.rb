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
    class PublicIPAddressesProperties < Azure::ARM::TypeBase

      # @return Microsoft.Network/publicIPAddresses: Public IP allocation
      # method
      attr_accessor :public_ipallocation_method

      # @return Microsoft.Network/publicIPAddresses: Idle timeout in minutes
      attr_accessor :idle_timeout_in_minutes

      # @return Microsoft.Network/publicIPAddresses: DNS settings
      attr_accessor :dns_settings

      #
      # Validate the object. Throws ValidationError if validation fails.
      #
      def validate
      end

      #
      # Serializes given Model object into Ruby Hash.
      # @param object Model object to serialize.
      # @return [Hash] Serialized object in form of Ruby Hash.
      #
      def self.serialize_object(output_object, object)
        Azure::ARM::TypeBase.serialize_object(output_object, object)
        object.validate

        serialized_property = object.public_ipallocation_method
        if serialized_property.is_a? Azure::ARM::Expression
          unless serialized_property.nil?
            serialized_property = serialized_property.to_s
          end
        end
        output_object[:publicIPAllocationMethod] = serialized_property unless serialized_property.nil?

        serialized_property = object.idle_timeout_in_minutes
        if serialized_property.is_a? Azure::ARM::Expression
          unless serialized_property.nil?
            serialized_property = serialized_property.to_s
          end
        end
        output_object[:idleTimeoutInMinutes] = serialized_property unless serialized_property.nil?

        serialized_property = object.dns_settings
        if serialized_property.is_a? PublicIPAddressDnsSettings
          unless serialized_property.nil?
            serialized_property = serialized_property.to_h
          end
        end
        if serialized_property.is_a? Azure::ARM::Expression
          unless serialized_property.nil?
            serialized_property = serialized_property.to_s
          end
        end
        output_object[:dnsSettings] = serialized_property unless serialized_property.nil?

        output_object
      end

      def to_h
        hash = {}
        PublicIPAddressesProperties.serialize_object(hash,self)
        hash
      end

      def self.ds_properties
        result = Array.new 
        result.push :public_ipallocation_method
        result.push :idle_timeout_in_minutes
        result.push :dns_settings
        result
      end

      #
      # Deserializes given Ruby Hash into Model object.
      # @param object [Hash] Ruby Hash object to deserialize.
      # @return [PublicIPAddressesProperties] Deserialized object.
      #
      def self.deserialize_object(output_object, object)
        return if object.nil?
        conf = Configurator.new
        conf.parent = output_object

        if object.key?(:public_ipallocation_method)
          conf.public_ipallocation_method object[:public_ipallocation_method]
          object.delete :public_ipallocation_method
        end

        if object.key?(:idle_timeout_in_minutes)
          conf.idle_timeout_in_minutes object[:idle_timeout_in_minutes]
          object.delete :idle_timeout_in_minutes
        end

        if object.key?(:dns_settings)
          conf.dns_settings object[:dns_settings]
          object.delete :dns_settings
        end

        output_object
      end

      def get_name_template
        'pipap'
        end

      def initialize(parent, init)
        super(parent)
        if init.is_a? Hash
          PublicIPAddressesProperties.deserialize_object self, init.clone
        end
      end

      # Configuration code
      class Configurator < Azure::ARM::ResourceConfigurator
        attr_accessor :parent
        # @param public_ipallocation_method
        #        A string, one of 'Dynamic','Static'
        #        Expression
        def public_ipallocation_method(props)
          if props.is_a? String
            fail ArgumentError, "#{props} is an invalid value for @parent.public_ipallocation_method" unless ['Dynamic','Static'].index(props)
            @parent.public_ipallocation_method = props
            return
          end
          if @parent.public_ipallocation_method.nil? and props.is_a? Azure::ARM::Expression
            @parent.public_ipallocation_method = props
          end
          @parent.public_ipallocation_method
        end
        # @param idle_timeout_in_minutes
        #        Fixnum
        #        Expression
        def idle_timeout_in_minutes(props)
          if props.is_a? Fixnum or props.is_a? Azure::ARM::Expression
            @parent.idle_timeout_in_minutes = props
            return
          end
          if @parent.idle_timeout_in_minutes.nil? and props.is_a? Azure::ARM::Expression
            @parent.idle_timeout_in_minutes = props
          end
          @parent.idle_timeout_in_minutes
        end
        # @param dns_settings
        #        PublicIPAddressDnsSettings
        #        Expression
        def dns_settings(props)
          if @parent.dns_settings.nil? and props.is_a? PublicIPAddressDnsSettings
            @parent.dns_settings = props
            @parent.dns_settings.parent = @parent
            @parent.dns_settings._rsrcpath = 'dnsSettings'
          end
          if @parent.dns_settings.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, PublicIPAddressDnsSettings)
            @parent.dns_settings = PublicIPAddressDnsSettings.new(@parent, props)
            @parent.dns_settings._rsrcpath = 'dnsSettings'
          end
          if @parent.dns_settings.nil? and props.is_a? Azure::ARM::Expression
            @parent.dns_settings = props
          end
          @parent.dns_settings
        end
        def create(init=nil,&block)
          @parent = PublicIPAddressesProperties.new nil, init
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
