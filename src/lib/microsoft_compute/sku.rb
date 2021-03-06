# encoding: utf-8
# Code generated by Microsoft (R) AutoRest Code Generator 0.17.0.0
# Changes may cause incorrect behavior and will be lost if the code is
# regenerated.

require_relative '../arm/module_definition'
require_relative './module_definition'

module Azure::ARM::Compute
    #
    # Model object.
    #
    class Sku < Azure::ARM::TypeBase

      # @return [String]
      attr_accessor :name

      # @return [String]
      attr_accessor :tier

      # @return
      attr_accessor :capacity

      #
      # Validate the object. Throws ValidationError if validation fails.
      #
      def validate
        fail ArgumentError, 'property name is nil' if @name.nil?
        fail ArgumentError, 'property capacity is nil' if @capacity.nil?
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

        serialized_property = object.capacity
        if serialized_property.is_a? Azure::ARM::Expression
          unless serialized_property.nil?
            serialized_property = serialized_property.to_s
          end
        end
        output_object[:capacity] = serialized_property unless serialized_property.nil?

        serialized_property = object.tier
        output_object[:tier] = serialized_property unless serialized_property.nil?

        output_object
      end

      def to_h
        hash = {}
        Sku.serialize_object(hash,self)
        hash
      end

      def self.ds_properties
        result = Array.new 
        result.push :tier
        result.push :capacity
        result
      end

      #
      # Deserializes given Ruby Hash into Model object.
      # @param object [Hash] Ruby Hash object to deserialize.
      # @return [Sku] Deserialized object.
      #
      def self.deserialize_object(output_object, object)
        return if object.nil?
        conf = Configurator.new
        conf.parent = output_object

        if object.key?(:name)
          conf.name object[:name]
          object.delete :name
        end

        if object.key?(:capacity)
          conf.capacity object[:capacity]
          object.delete :capacity
        end

        if object.key?(:tier)
          conf.tier object[:tier]
          object.delete :tier
        end

        output_object
      end

      def get_name_template
        's'
        end

      def initialize(parent, init)
        super(parent)
        if init.is_a? Hash
          Sku.deserialize_object self, init.clone
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
        # @param tier
        #        String
        def tier(props)
          if props.is_a? String or props.is_a? Azure::ARM::Expression
            @parent.tier = props
            return
          end
          @parent.tier
        end
        # @param capacity
        #        Expression
        #        Fixnum
        def capacity(props)
          if @parent.capacity.nil? and props.is_a? Azure::ARM::Expression
            @parent.capacity = props
          end
          if props.is_a? Fixnum or props.is_a? Azure::ARM::Expression
            @parent.capacity = props
            return
          end
          @parent.capacity
        end
        def create(init=nil,&block)
          @parent = Sku.new nil, init
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
