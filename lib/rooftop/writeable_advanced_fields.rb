module Rooftop
  module WriteableAdvancedFields

    def self.included(base)
      base.send(:before_save, -> {
        self.write_advanced_fields = self.class.write_advanced_fields
      })

      base.extend ClassMethods

    end

    module ClassMethods
      attr_reader :advanced_fields_schema

      def write_advanced_fields
        @write_advanced_fields || false
      end

      def write_advanced_fields=(val)
        @write_advanced_fields = val
        # load the schema now
        reload_advanced_fields_schema!
      end
      
      def advanced_fields_schema
        @advanced_fields_schema ||= reload_advanced_fields_schema!
      end

      def advanced_fields
        advanced_fields_schema.collect {|fieldset| fieldset[:fields]}.flatten
      end

      def reload_advanced_fields_schema!
        @advanced_fields_schema = options_raw(collection_path)[:parsed_data][:data][:schema][:properties][:advanced_fields_schema]
      end

    end

    def advanced_fields_schema
      self.class.advanced_fields_schema
    end

    def advanced_fields
      self.class.advanced_fields
    end

  end


end