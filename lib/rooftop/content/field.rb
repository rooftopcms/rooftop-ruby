module Rooftop
  module Content
    class Field < ::OpenStruct


      def to_s
        value if respond_to?(:value)
      end

    end
  end
end