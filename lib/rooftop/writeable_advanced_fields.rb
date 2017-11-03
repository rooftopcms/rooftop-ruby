module Rooftop
  module WriteableAdvancedFields

    def self.included(base)
      base.send(:before_save, -> {
        self.write_advanced_fields = self.class.write_advanced_fields
      })

      base.extend ClassMethods


    end

    module ClassMethods
      attr_reader :write_advanced_fields

      def write_advanced_fields=(tf)
        @write_advanced_fields = tf
      end
    end

    def advanced_fields_schema
      # todo in due course this should return a class-level memoized attribute which interrogates the schema on the endpoint
      super
    end

  end


end