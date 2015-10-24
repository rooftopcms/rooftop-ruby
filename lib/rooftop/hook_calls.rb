# This module exists because call order on the hooks provided by Her is important in some cases.
# For example in Rooftop::FieldAliases we are aliasing the content of a field, which might need to
# have been coerced first. So we control the order by writing (in a known order) to @hook_calls, and
# then iterating over them.
module Rooftop
  module HookCalls
    def self.included(base)
      base.extend ClassMethods
      # Iterate over an instance var which is a hash of types of hook, and blocks to call
      # like this {after_find: [->{something}, ->{something}]}
      base.instance_variable_set(:"@hook_calls", base.instance_variable_get(:"@hook_calls") || {})
    end

    module ClassMethods
      # Add something to the list of hook calls, for a particular hook. This is called in other mixins where something is being added to a hook (probably :after_find). For example Rooftop::FieldAliases and Rooftop::FieldCoercions
      def add_to_hook(hook, block)
        # get existing hook calls
        hook_calls = instance_variable_get(:"@hook_calls")
        # add new one for the appropriate hook
        if hook_calls[hook].is_a?(Array)
          hook_calls[hook] << block
        else
          hook_calls[hook] = [block]
        end
        instance_variable_set(:"@hook_calls",hook_calls)
      end

      # A method to call the hooks. This iterates over each of the types of hook (:after_find,
      # :before_save etc, identified here: https://github.com/remiprev/her#callbacks) and sets up
      # the actual hook. All this is worth it to control order.
      def setup_hooks!
        instance_variable_get(:"@hook_calls").each do |type, calls|
          calls.each do |call|
            self.send(type, call)
          end
        end
      end
    end
  end
end