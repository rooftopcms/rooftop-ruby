# This module allows you to alias one field as another. There's a bit of a circuitous route to
# getting it done, because you need to push the after_find hook call onto the end of the hash of
# existing hook calls. See Rooftop::HookCalls for more details.

module Rooftop
  module FieldAliases
    def self.included(base)
      # Include Rooftop::HookCalls to allow us to push things into a list of hooks in the right order
      base.include Rooftop::HookCalls
      base.extend ClassMethods

      # Add the call to the :after_find hook to the list of hook calls, to be processed later.
      # This is where we iterate over our previously established list of field aliases.
      base.send(:add_to_hook, :after_find, ->(r){
        r.field_aliases.each do |old, new|
          if r.respond_to?(old)
            r.send("#{new}=",r.send(old))
          end
        end
      })

      base.send(:before_save, ->(r) {
        r.field_aliases.each do |old,new|
          r.send(:"restore_#{new}!")
        end
      })

    end

    module ClassMethods
      # Call alias_field(foo: :bar) in a class to alias the foo as bar.
      # @param aliases [Sym] a hash of old and new field names
      def alias_field(*aliases)
        @field_aliases ||= {}
        aliases.each do |alias_hash|
          @field_aliases.merge!(alias_hash)
        end
        @field_aliases
      end
    end

    # Class method to get the class's field aliases
    def field_aliases
      self.class.instance_variable_get(:"@field_aliases") || {}
    end
  end
end