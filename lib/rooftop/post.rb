module Rooftop
  module Post
    def self.included(base)
      base.include Rooftop::Base
      base.extend ClassMethods
      base.send(:collection_path, "posts")
    end

    module ClassMethods
      def post_type=(type)
        self.send(:collection_path,type.humanize.pluralize.underscore.gsub(" ","_"))
      end
    end
  end
end