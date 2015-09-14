module RooftopClient
  module Base
    def self.included(base)
      base.include Her::Model
      # Coercions allow you to pass a block to do something with a returned field
      base.include RooftopClient::Coercions
      # Queries mixin includes a fixup for there `where()` method
      base.include RooftopClient::Queries
      # Use the API instance we have configured - in a proc because we can't control load order
      base.send(:use_api,->{RooftopClient.configuration.connection})
      # WP returns an uppercase attribute for ID. Annoying.
      # base.send(:primary_key, :"ID")
      # Date and Modified fields are pretty universal in responses from WP, so we can automatically
      # coerce these to DateTime.
      base.send(:coerce_field,date: ->(date) {DateTime.parse(date)})
      base.send(:coerce_field,modified: ->(modified) {DateTime.parse(modified)})
      base.extend ClassMethods
    end

    module ClassMethods
      # Allow calling 'first'
      def first
        all.first
      end
    end

    # Utility method to make the 'created' field have a more rubyish name
    def created_at
      date
    end

    # Utility method to make the 'updated' field have a more rubyish name
    def updated_at
      modified
    end

  end
end