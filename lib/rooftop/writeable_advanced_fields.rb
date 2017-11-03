module Rooftop
  module WriteableAdvancedFields

    def self.included(base)
      base.send(:before_save, -> {
        self.write_advanced_fields = self.class.write_advanced_fields
      })

      base.extend ClassMethods


    end

    module ClassMethods
      attr_accessor :write_advanced_fields
      attr_reader :advanced_fields_schema

      def advanced_fields_schema=(schema)
        # todo in due course this should not be necessary because we can interrogate the schema from the endpoint
        @advanced_fields_schema = schema
      end

      def advanced_fields_schema
        # todo interrogate the schema from the endpoint and memoize like this:
        # @advanced_fields_schema ||= self.get_some_endpoint_to_retrieve_schema
        @advanced_fields_schema
      end

    end

    def advanced_fields_schema
      # todo in future this needn't be memoized because it'll be done in the class method
      self.class.advanced_fields_schema ||= super
    end

  end


end