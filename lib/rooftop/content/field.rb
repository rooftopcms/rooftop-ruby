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
          begin
            related_ids = value.collect do |related|
              if related.is_a?(Hash)
                related[:ID]
              else
                related
              end
            end
            klass = Rooftop.configuration.post_type_mapping[relationship[:class].to_sym] || relationship[:class].to_s.classify.constantize
            resolved = klass.where(id: related_ids, order_by: :post__in).to_a
            # there might be an empty array if all the related_ids resolve to posts which are in draft but we don't
            # have Rooftop.include_drafts set to true. If this is the case, we should return nil
            if resolved.length == 0
              nil
            elsif resolved.length == 1
              resolved.first
            else
              resolved
            end
          rescue
            nil
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