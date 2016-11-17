
module Azure::ARM

    class ResourceConfigurator

      def template
        if self.respond_to? :parent and self.parent.respond_to? :template
          self.parent.template
        else
          nil
        end
      end

      def depends_on(dep)
        if self.respond_to? :parent
          self.parent.add_dependency(dep)
        end
      end

      def copy(copy)
        if self.respond_to? :parent and self.parent.respond_to? :set_copy
          self.parent.set_copy copy
        end
      end

      def method_missing(key, *args)
        t = template
        if t.respond_to? key
          t.send(key,*args)
        end
      end

    end

end