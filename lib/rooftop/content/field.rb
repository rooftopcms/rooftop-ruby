module Rooftop
  module Content
    class Field
      include ActiveModel::Dirty
      OpenStruct

      attr_reader :value
      define_attribute_methods :value

      def initialize(hash={})
        if hash.has_key?(:class)
          hash[:type] = hash.delete(:class)
        end
        hash.each do |k,v|
          instance_variable_set("@#{k}", v)
          self.class.send(:attr_accessor, k.to_sym) unless k.to_sym == :value # we set value in a method, no need for the accessor
        end
      end

      def attributes
        instance_values.with_indifferent_access
      end

      alias :to_h :attributes

      def value=(new_value)
        value_will_change!
        @value = new_value
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