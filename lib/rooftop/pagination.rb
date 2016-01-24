module Rooftop
  module Pagination
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def new_collection(parsed_data)
        parsed_data[:metadata] ||= {}
        parsed_data[:metadata][:pagination] = parsed_data[:pagination]

        Her::Model::Attributes.initialize_collection(self, parsed_data)
      end
    end
  end
end
