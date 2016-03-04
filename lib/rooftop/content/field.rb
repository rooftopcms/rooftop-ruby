module Rooftop
  module Content
    class Field < ::OpenStruct

      #todo - this would be nice to get working. For a relationship, we should be returning the object not a big hash
      # def initialize(hash=nil)
      #   if hash.has_key?(:type) && hash[:type] == "relationship"
      #     related_objects = [hash[:value]].flatten
      #     hash[:value] = related_objects.inject([]) do |array,object|
      #       begin
      #         klass = Rooftop.configuration.post_type_mapping[object[:post_type].to_sym] || object[:post_type].to_s.classify.constantize
      #         array << klass.new(object).run_callbacks(:find)
      #       rescue
      #         array << object
      #       end
      #     end
      #     super
      #   else
      #     super
      #   end
      # end



      def to_s
        value if respond_to?(:value)
      end
    end
  end
end