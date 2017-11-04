module Rooftop
  module WriteableAdvancedFields

    def self.included(base)
      base.send(:before_save, -> {
        self.write_advanced_fields = self.class.write_advanced_fields
      })

      base.extend ClassMethods

    end

    module ClassMethods
      attr_reader :advanced_fields_schema, :write_advanced_fields

      def write_advanced_fields=(truefalse)
        @write_advanced_fields = truefalse
        # load the schema now
        advanced_fields_schema
      end
      
      def advanced_fields_schema
        @advanced_fields_schema ||= options_raw(collection_path)[:parsed_data][:data][:schema][:properties][:advanced_fields_schema]
      end

      def advanced_fields
        advanced_fields_schema.collect {|fieldset| fieldset[:fields]}.flatten
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