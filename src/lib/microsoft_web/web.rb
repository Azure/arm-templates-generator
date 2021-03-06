# encoding: utf-8
# Code generated by Microsoft (R) AutoRest Code Generator 0.17.0.0
# Changes may cause incorrect behavior and will be lost if the code is
# regenerated.

require_relative '../arm/module_definition'
require_relative './module_definition'

module Azure::ARM::Web
    #
    # Model object.
    #
    class Web < Azure::ARM::TypeBase

      # @return [web_name] Possible values include: 'web'
      attr_accessor :name

      # @return [WebProperties]
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
        Web.serialize_object(hash,self)
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
      # @return [Web] Deserialized object.
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
        'w'
        end

      def initialize(parent, init)
        super(parent)
        @name = 'web' if @name.nil?
        if init.is_a? Hash
          Web.deserialize_object self, init.clone
        end
      end

      # Configuration code
      class Configurator < Azure::ARM::ResourceConfigurator
        attr_accessor :parent
        # @param properties
        #        WebProperties
        def properties(props)
          if @parent.properties.nil? and props.is_a? WebProperties
            @parent.properties = props
            @parent.properties.parent = @parent
            @parent.properties._rsrcpath = 'properties'
          end
          if @parent.properties.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, WebProperties)
            @parent.properties = WebProperties.new(@parent, props)
            @parent.properties._rsrcpath = 'properties'
          end
          @parent.properties
        end
        # @param php_version
        #        String
        def php_version(props)
          @parent.properties = (WebProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? String or props.is_a? Azure::ARM::Expression
            @parent.properties.php_version = props
            return
          end
          @parent.properties.php_version
        end
        # @param net_framework_version
        #        String
        def net_framework_version(props)
          @parent.properties = (WebProperties.new @parent, nil) if @parent.properties.nil?
          if props.is_a? String or props.is_a? Azure::ARM::Expression
            @parent.properties.net_framework_version = props
            return
          end
          @parent.properties.net_framework_version
        end
        def create(init=nil,&block)
          @parent = Web.new nil, init
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
