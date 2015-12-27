module Rooftop
  module Menus
    class Item < OpenStruct
      def initialize(args)
        args[:object_type] = args[:object]
        super
        # If this menu item has children, create a MenuItem for each one
        if self.children
          self.children = children.collect do |child|
            Item.new(child)
          end
        end

      end

      def object
        if self.type == "post_type"
          begin
            klass = Rooftop.configuration.post_type_mapping[self.object_type] || self.object_type.classify.constantize
            klass.find_by(slug: self.slug).first
          rescue
            raise UnmappedObjectError, "Couldn't find an mapping between the #{self.object_type} post type and a class in your code."
          end
        end
      end
    end
  end
end