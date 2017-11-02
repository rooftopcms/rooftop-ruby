module Rooftop
  module Content
    class Field < ::OpenStruct

      def initialize(hash=nil)
        if hash.has_key?(:class)
          hash[:type] = hash[:class]
        end
        super
      end

      def resolve
        if respond_to?(:type) && type == "relationship"
          related_ids = value.collect do |related|
            if related.is_a?(Hash)
              related[:ID]
            else
              related
            end
          end
          klass = Rooftop.configuration.post_type_mapping[relationship[:class].to_sym] || relationship[:class].to_s.classify.constantize
          resolved = klass.where(id: related_ids).to_a
          if resolved.length == 1
            resolved.first
          else
            resolved
          end
        else
          value
        end
      end



      def to_s
        if respond_to?(:value) && value.is_a?(String)
          value
        else
          inspect
        end
      end
    end
  end
end