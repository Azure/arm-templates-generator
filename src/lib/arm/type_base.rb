
module Azure::ARM

  # noinspection RubyClassVariableUsageInspection,RubyResolve,RubyResolve
    class TypeBase

      include Azure::ARM::PredefinedExpressions

      attr_accessor :parent
      attr_writer :_rsrcpath

      def initialize(parent)
        @parent = parent
        if self.respond_to?(:name) and self.name.nil?
          prefix = self.get_name_template
          self.name = generate_name(prefix) unless prefix.nil?
        end
      end

      def to_rsrcid
        if self.respond_to? :name and @_rsrcpath
          name = self.name
          concat(@parent.to_rsrcid, "/#{@_rsrcpath}/#{name}")
        end
      end

      def get_name_template
        'gnrc'
      end

      def generate_name(prefix)

        key = prefix.to_sym
        number = @@numbers[key]
        unless number
          number = 0
        end
        @@numbers[key] = number + 1

        "#{prefix}#{number}"
      end

      def normalize_name(name)

        if name and name.is_a? String
          if name[0] == ?@
            name = parameters(name[1..-1])
          elsif name[0] == ?#
            name = variables(name[1..-1])
          else
            name = "#{name}"
          end
        end

        name
      end

      def containing_resource
        if parent.nil? or !parent.respond_to? :containing_resource
          return nil
        end
        parent.containing_resource
      end

      def self.validate(object)
        # empty on purpose
      end

      def self.serialize_object(output_object, object)
        # empty on purpose
      end

      def method_missing(key, *args)
        # Try looking for the missing method in a few places:
        # 1. a 'properties' accessor
        # 2.
        if self.respond_to? :properties
          self.properties.public_send(key, *args)
        end
      end

      # @param object [Hash] Ruby Hash object to deserialize.
      # @param parent [TypeBase] A parent object
      # @param types [Type[]] A list of types that should be tried.
      # @return Deserialized object.

      def self.deserialize_object(object, parent, *types)

        matched_type = nil

        types.each do |t|

          # match the values of the hash 'object' against the properties of the type 't'

          if t.respond_to? :ds_properties

            if matches_type object, t
              fail ArgumentError, 'ambiguous mapping of input hash to type' unless matched_type.nil?
              matched_type = t
            end

          end

        end

        matched_type.new parent, object unless matched_type.nil?

      end

      def self.matches_type(object, type)
        if !object.empty?
          # We need to find at least one of the keys of the hash in the target type
          vars = type.ds_properties
          if vars.length > 0
            object.any? { |k, _| vars.include? k }
          else
            # Trivial match -- the type has no properties, so it always matches.
            true
          end
        else
          false
        end
      end

      def add_dependency(dep)
        unless @parent.nil?
          @parent.add_dependency dep
        end
      end
      private

      @@numbers = Hash.new

    end

end