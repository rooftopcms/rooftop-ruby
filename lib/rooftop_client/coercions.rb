module RooftopClient
  module Coercions
    def self.included(base)
      base.extend ClassMethods
      # `after_find` is a method provided by Her; we iterate over our coercions and call each lambda
      base.send(:after_find, ->(r){
        r.coercions.each do |field,coercion|
          if r.respond_to?(field)
            r.send("#{field}=",coercion.call(r.send(field)))
          end
        end
      })
    end

    module ClassMethods
      # Call coerce_field() in a class to do something with the attribute. Useful for parsing dates etc.
      # @param coercion [Hash] the coercion to apply - key is the field, value is a lambda
      def coerce_field(*coercions)
        @coercions ||= {}
        coercions.each do |coercions_hash|
          @coercions.merge!(coercions_hash)
        end
        @coercions
      end
    end

    # Instance method to get the class's coercions
    def coercions
      self.class.instance_variable_get(:"@coercions")
    end
  end
end