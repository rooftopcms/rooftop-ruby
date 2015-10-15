# Coerce any field called 'parent' which returns an ID into an actual object
module Rooftop
  module Coercions
    module ParentCoercion
      def self.included(base)
        base.extend ClassMethods
        # base.send(:after_find, ->(r) {
        #   if r.has_parent?
        #     r.instance_variable_set(:"parent_#{base.to_s.underscore}", resolve_parent_id())
        #     r.class.send(:attr_reader, :"parent_#{base.to_s.underscore}")
        #   end
        # })
        # base.send(:coerce_field, parent: ->(p) { base.send(:resolve_parent_id,p) })
      end

      module ClassMethods
        def add_parent_reference
          define_method :"parent_#{self.to_s.underscore}" do
            puts "hello"
          end
        end
      end

      def has_parent?
        respond_to?(:parent) && parent.is_a?(Fixnum) && parent != 0
      end

      def resolve_parent_id
        if respond_to?(:parent)
          if parent.is_a?(Fixnum)
            if parent == 0
              #no parent
              return nil
            else
              return self.class.send(:find, id)
            end
          else
            return parent
          end

        end

      end
    end
  end

end
