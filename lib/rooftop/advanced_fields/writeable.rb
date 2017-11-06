module Rooftop
  module AdvancedFields
    module Writeable

      def self.included(base)
        base.send(:before_save, -> {
          self.write_advanced_fields = self.class.write_advanced_fields
        })
        base.extend ClassMethods

      end

      module ClassMethods
        
        def write_advanced_fields
          @write_advanced_fields || false
        end

        alias :write_advanced_fields? :write_advanced_fields

        def write_advanced_fields=(val)
          @write_advanced_fields = val
        end

      end


    end
  end
end