# encoding: utf-8
# Code generated by Microsoft (R) AutoRest Code Generator 0.17.0.0
# Changes may cause incorrect behavior and will be lost if the code is
# regenerated.

require_relative '../arm/module_definition'
require_relative './module_definition'

module Azure::ARM::Storage
    #
    # Microsoft.Storage/storageAccounts
    #
    class StorageAccount < Azure::ARM::ResourceBase

      # @return [StorageAccountsProperties]
      attr_accessor :properties

      #
      # Validate the object. Throws ValidationError if validation fails.
      #
      def validate
        fail ArgumentError, 'property type is nil' if self.type.nil?
        fail ArgumentError, 'property api_version is nil' if self.api_version.nil?
        fail ArgumentError, 'property properties is nil' if self.properties.nil?
        @properties.validate unless @properties.nil?
      end

      #
      # Serializes given Model object into Ruby Hash.
      # @param object Model object to serialize.
      # @return [Hash] Serialized object in form of Ruby Hash.
      #
      def self.serialize_object(output_object, object)
        Azure::ARM::ResourceBase.serialize_object(output_object, object)
        object.validate

        serialized_property = object.properties
        unless serialized_property.nil?
          serialized_property = serialized_property.to_h
        end
        output_object[:properties] = serialized_property unless serialized_property.nil?

        output_object
      end

      def to_h
        self.validate
        hash = {}
        StorageAccount.serialize_object(hash,self)
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
      # @return [StorageAccount] Deserialized object.
      #
      def self.deserialize_object(output_object, object)
        return if object.nil?
        object.delete :name
        object.delete :type
        object.delete :api_version
        object.delete :location
        object.delete :tags
        object.delete :copy
        object.delete :comments
        conf = Configurator.new output_object.template
        conf.parent = output_object

        if object.key?(:properties)
          conf.properties object[:properties]
        end

        unless object.key?(:properties)
          conf.properties object
        end

        output_object
      end

      def get_name_template
        'sa'
      end

      def initialize(parent, init)
        super(parent, init)
        self.type = 'Microsoft.Storage/storageAccounts' if self.type.nil?
        self.api_version = '2015-06-15' if self.api_version.nil?
        if init.is_a? Hash
          StorageAccount.deserialize_object self, init.clone
        end 
      end

      # Configuration code
      class Configurator < Azure::ARM::ResourceConfigurator
        attr_accessor :parent
        attr_accessor :template
        # @param api_version
        #        A string, one of '2015-05-01-preview','2015-06-15'
        def api_version(props)
          if props.is_a? String
            fail ArgumentError, "#{props} is an invalid value for @parent.api_version" unless ['2015-05-01-preview','2015-06-15'].index(props)
            @parent.api_version = props
            return
          end
          @parent.api_version
        end
        # @param properties
        #        StorageAccountsProperties
        def properties(props)
          if @parent.properties.nil? and props.is_a? StorageAccountsProperties
            @parent.properties = props
            @parent.properties.parent = @parent
            @parent.properties._rsrcpath = 'properties'
          end
          if @parent.properties.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, StorageAccountsProperties)
            @parent.properties = StorageAccountsProperties.new(@parent, props)
            @parent.properties._rsrcpath = 'properties'
          end
          @parent.properties
        end
        # @param account_type
        #        String
        def account_type(props)
          @parent.properties = (StorageAccountsProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? String or props.is_a? Azure::ARM::Expression
            @parent.properties.account_type = props
            return
          end
          @parent.properties.account_type
        end
        def initialize(template)
          @template = template
        end
        def create(init=nil,&block)
          @parent = StorageAccount.new @template,init
          @template.resources.push @parent
          self.instance_exec(@parent,&block) if block
          @parent
        end
      end
      def configure(&block)
        conf = Configurator.new self.template
        conf.parent = self
        conf.instance_exec(self,&block) if block
        self
      end
    end
end
