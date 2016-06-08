module Rooftop
  module Coercions
    module TitleCoercion
      def self.included(base)
        base.send(:after_find, :coerce_title_to_string)
        base.send(:after_save, :coerce_title_to_string)

        base.send(:before_save, ->(record) {
          if record.respond_to?(:title) && record.respond_to?(:title_object)
            record.title_object ||= {}
            if record.title.nil?
              record.reset_title!
              record.reset_title_object!
            else
              record.title_object[:rendered] = record.title
            end
          end
        })

      end

      def coerce_title_to_string
        record = self
        if record.respond_to?(:title) && record.title.is_a?(ActiveSupport::HashWithIndifferentAccess)
          record.title_object = record.title
          record.title = record.title[:rendered]
        end
      end
    end
  end
end
