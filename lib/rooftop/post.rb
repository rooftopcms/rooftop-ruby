module Rooftop
  module Post
    def self.included(base)
      base.include Rooftop::Base
      base.include Rooftop::Nested
      base.extend ClassMethods
    end

    module ClassMethods
      def post_type=(type)
        self.api_endpoint = type.pluralize
      end
    end
  end
end