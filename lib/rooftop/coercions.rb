module Rooftop
  module Coercions
    def self.included(base)
      # Include Rooftop::HookCalls to allow us to push things into a list of hooks in the right order
      base.include Rooftop::HookCalls
      base.extend ClassMethods

      # Add the call to the :after_find hook to the list of hook calls, to be processed later.
      # This is where we iterate over our previously established list of coercions, and call each
      # in turn
      base.send(:add_to_hook, :after_find, ->(r){
        r.coercions.each do |field,coercion|
          if r.respond_to?(field)
            r.send("#{field}=",coercion.call(r.send(field)))
          end
        end
      })
      base.send(:before_save, ->(r) {
        r.coercions.each do |field,coercion|
          r.send(:"restore_#{field}!") unless r.new?
        end
      })
    end

    module ClassMethods
      # Call coerce_field() in a class to do something with the attribute. Useful for parsing dates etc.
      # For example: coerce_field(date: ->(date_string) { DateTime.parse(date_string)}) to get a DateTime object from a string field. The date field will now be a DateTime.

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
      self.class.instance_variable_get(:"@coercions") || {}
    end
  end
end