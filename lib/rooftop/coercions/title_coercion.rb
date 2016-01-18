module Rooftop
  module Coercions
    module TitleCoercion
      def self.included(base)
        base.send(:after_find, ->(record) {
          if record.respond_to?(:title) && record.title.is_a?(ActiveSupport::HashWithIndifferentAccess)
            record.title_object = record.title
            record.title = record.title[:rendered]
          end
        })

        base.send(:before_save, ->(record) {
          if record.respond_to?(:title)
            record.title_object[:rendered] = record.title
          end
        })

        base.send(:after_save, ->(record) {
          if record.respond_to?(:title) && record.title.is_a?(ActiveSupport::HashWithIndifferentAccess)
            record.title_object = record.title
            record.title = record.title[:rendered]
          end
        })
      end
    end
  end
end
