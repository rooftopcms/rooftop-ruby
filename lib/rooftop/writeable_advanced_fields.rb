module Rooftop
  module WriteableAdvancedFields

    def self.included(base)
      base.send(:before_save, -> {
        self.write_advanced_fields = true
      })

      base.extend ClassMethods


    end

    module ClassMethods
      attr_reader :write_advanced_fields

      def write_advanced_fields=(tf)
        @write_advanced_fields = tf
      end
    end

  end


end