module Rooftop
  module Base
    def self.included(base)
      @included_classes ||= []
      @included_classes << base unless @included_classes.include?(base)
      base.extend ClassMethods
      base.include Her::Model

      # Paths to get to the API
      base.api_namespace = Rooftop::DEFAULT_API_NAMESPACE
      base.api_version = Rooftop::DEFAULT_API_VERSION
      base.setup_path!

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

      # Add some useful scopes
      base.include Rooftop::Scopes

      # Date and Modified fields are pretty universal in responses from WP, so we can automatically
      # coerce these to DateTime.
      base.send(:coerce_field,date: ->(date) {DateTime.parse(date.to_s) unless date.nil?})
      base.send(:coerce_field,modified: ->(modified) {DateTime.parse(modified.to_s) unless modified.nil?})

      base.send(:after_find, ->(record) {
        record.title_object = record.title
        record.title = record.title[:rendered]
      })

      base.send(:before_save, ->(record) {
        record.title_object[:rendered] = record.title
        # record.restore_title!
      })

      # Having coerced the fields, we can alias them (order is important - coerce first.)
      base.send(:alias_field, date: :created_at)
      base.send(:alias_field, modified: :updated_at)

      # Set up the hooks identified in other mixins. This method is defined in Rooftop::HookCalls
      base.send(:"setup_hooks!")

    end

    def self.included_classes
      @included_classes
    end

    module ClassMethods
      attr_reader :api_namespace, :api_version, :api_endpoint

      def api_namespace=(ns)
        @api_namespace = ns
        setup_path!
      end

      def api_version=(v)
        @api_version = v
        setup_path!
      end

      def api_endpoint=(e)
        @api_endpoint = e
        setup_path!
      end

      def setup_path!
        @api_endpoint ||= collection_path
        self.collection_path "#{@api_namespace}/v#{@api_version}/#{@api_endpoint}"
      end

      # Allow calling 'first'
      def first
        all.first
      end

      def reload!
        self.class.find(self.id) if self.id
      end




    end

  end
end