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
    class Secret < Azure::ARM::TypeBase

      # @return [Id]
      attr_accessor :source_vault

      # @return [Array<VaultCertificateUrl>]
      attr_writer :vault_certificates
      def vault_certificates(name=nil)
        if name and @vault_certificates and @vault_certificates.is_a? Array
          return @vault_certificates.find { | p | p.name == name } if name.is_a? String
          return @vault_certificates[name] if name.is_a? Integer
        end
        @vault_certificates
      end

      #
      # Validate the object. Throws ValidationError if validation fails.
      #
      def validate
        fail ArgumentError, 'property source_vault is nil' if @source_vault.nil?
        fail ArgumentError, 'property vault_certificates is nil' if @vault_certificates.nil?
        @source_vault.validate unless @source_vault.nil?
        @vault_certificates.each{ |e| e.validate if e.respond_to?(:validate) } unless @vault_certificates.nil?
      end

      #
      # Serializes given Model object into Ruby Hash.
      # @param object Model object to serialize.
      # @return [Hash] Serialized object in form of Ruby Hash.
      #
      def self.serialize_object(output_object, object)
        Azure::ARM::TypeBase.serialize_object(output_object, object)
        object.validate

        serialized_property = object.source_vault
        unless serialized_property.nil?
          serialized_property = serialized_property.to_h
        end
        output_object[:sourceVault] = serialized_property unless serialized_property.nil?

        serialized_property = object.vault_certificates
        unless serialized_property.nil?
          serializedarray = []
          serialized_property.each do |element|
            unless element.nil?
              element = element.to_h
            end
            serializedarray.push(element)
          end
          serialized_property = serializedarray
        end
        output_object[:vaultCertificates] = serialized_property unless serialized_property.nil?

        output_object
      end

      def to_h
        hash = {}
        Secret.serialize_object(hash,self)
        hash
      end

      def self.ds_properties
        result = Array.new 
        result.push :source_vault
        result.push :vault_certificates
        result
      end

      #
      # Deserializes given Ruby Hash into Model object.
      # @param object [Hash] Ruby Hash object to deserialize.
      # @return [Secret] Deserialized object.
      #
      def self.deserialize_object(output_object, object)
        return if object.nil?
        conf = Configurator.new
        conf.parent = output_object

        if object.key?(:source_vault)
          conf.source_vault object[:source_vault]
          object.delete :source_vault
        end

        if object.key?(:vault_certificates)
          conf.vault_certificates object[:vault_certificates]
          object.delete :vault_certificates
        end

        output_object
      end

      def get_name_template
        's'
        end

      def initialize(parent, init)
        super(parent)
        if init.is_a? Hash
          Secret.deserialize_object self, init.clone
        end
      end

      # Configuration code
      class Configurator < Azure::ARM::ResourceConfigurator
        attr_accessor :parent
        # @param source_vault
        #        Id
        def source_vault(props)
          if @parent.source_vault.nil? and props.is_a? Id
            @parent.source_vault = props
            @parent.source_vault.parent = @parent
            @parent.source_vault._rsrcpath = 'sourceVault'
          end
          if @parent.source_vault.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, Id)
            @parent.source_vault = Id.new(@parent, props)
            @parent.source_vault._rsrcpath = 'sourceVault'
          end
          if @parent.source_vault.nil? and (props.respond_to? :to_rsrcid)
            @parent.source_vault = Id.new(@parent, id: props.to_rsrcid.to_s)
            if props.is_a? Azure::ARM::TypeBase and !props.containing_resource.nil?
              @parent.containing_resource.add_dependency props.containing_resource
            end
          end
          @parent.source_vault
        end
        # @param vault_certificates
        #        Array<VaultCertificateUrl>
        def vault_certificates(props)
          if props.is_a? Array
            @parent.vault_certificates = Array.new if @parent.vault_certificates.nil?
            props.each { |p| @parent.vault_certificates.push _vault_certificates_vaultcertificateurl(p) }
            return @parent.vault_certificates
          end
          _element = nil
          if _element.nil? and props.is_a? VaultCertificateUrl
            _element = props
            _element.parent = @parent
            _element._rsrcpath = 'vaultCertificates'
          end
          if _element.nil? and (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, VaultCertificateUrl)
            _element = VaultCertificateUrl.new(@parent, props)
            _element._rsrcpath = 'vaultCertificates'
          end
          unless _element.nil?
            @parent.vault_certificates = Array.new if @parent.vault_certificates.nil?
            @parent.vault_certificates.push _element
          end
          @parent.vault_certificates
        end
        def _vault_certificates_vaultcertificateurl(props)
          if props.is_a? VaultCertificateUrl
            props.parent = @parent
            props._rsrcpath = 'vaultCertificates'
            return props
          end
          if (props.is_a? Hash) and (Azure::ARM::TypeBase.matches_type props, VaultCertificateUrl)
            _properties = VaultCertificateUrl.new(@parent, props)
            _properties._rsrcpath = 'vaultCertificates'
            return _properties
          end
        end
        def create(init=nil,&block)
          @parent = Secret.new nil, init
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