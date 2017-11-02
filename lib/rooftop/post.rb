module Rooftop
  module Post
    def self.included(base)
      base.include Rooftop::Base
      base.include Rooftop::Nested
      base.include Rooftop::Preview
      base.include Rooftop::WriteableAdvancedFields
      base.extend ClassMethods
    end

    module ClassMethods
      def post_type=(type)
        Rooftop.configuration.post_type_mapping.merge!(type => self)
        self.api_endpoint = type.pluralize
      end
    end
  end
end