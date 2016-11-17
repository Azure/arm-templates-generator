module Azure::ARM::Network


    class Subnet < Azure::ARM::TypeBase

      def get_name_template
        'subnet'
      end

    end

end