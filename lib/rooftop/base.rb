module Rooftop
  module Base
    def self.included(base)
      base.include Her::Model
      # Coercions allow you to pass a block to do something with a returned field
      base.include Rooftop::Coercions
      # Aliases allow you to specify a field (or fields) to alias
      base.include Rooftop::FieldAliases
      # Queries mixin includes a fixup for there `where()` method
      base.include Rooftop::Queries
      # Links mixin handles the _links key in a response
      base.include Rooftop::ResourceLinks
      # Use the API instance we have configured - in a proc because we can't control load order
      base.send(:use_api,->{Rooftop.configuration.connection})

      # Turn calls to `content` into a collection of Rooftop::ContentField objects
      base.include Rooftop::Content

      # Date and Modified fields are pretty universal in responses from WP, so we can automatically
      # coerce these to DateTime.
      base.send(:coerce_field,date: ->(date) {DateTime.parse(date)})
      base.send(:coerce_field,modified: ->(modified) {DateTime.parse(modified)})

      # Having coerced the fields, we can alias them (order is important - coerce first.)
      base.send(:alias_field, date: :created_at)
      base.send(:alias_field, modified: :updated_at)

      base.extend ClassMethods

      # Set up the hooks identified in other mixins. This method is defined in Rooftop::HookCalls
      base.send(:"setup_hooks!")
    end

    module ClassMethods
      # Allow calling 'first'
      def first
        all.first
      end
    end

  end
end