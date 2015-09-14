# Coerce any field called 'parent' which returns an ID into an actual object
module RooftopClient
  module ParentCoercion
    def self.included(base)
      base.extend ClassMethods
      base.send(:coerce_field, parent: ->(p) { base.send(:resolve_parent_id,p) })
    end

    module ClassMethods
      def resolve_parent_id(id)
        if id.is_a?(Fixnum)
          if id == 0
            #no parent
            return nil
          else
            return self.send(:find, id)
          end
        else
          return id
        end

      end
    end
  end

end
