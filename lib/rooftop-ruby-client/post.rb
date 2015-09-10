module RooftopRubyClient
  module Post
    def self.included(base)
      base.include RooftopRubyClient::Base
      base.include RooftopRubyClient::AuthorCoercion
      base.extend ClassMethods
      base.send(:collection_path,"posts")
    end

    module ClassMethods
      def post_type=(type)
        self.send(:default_scope, ->{ where(type: type) })
      end
    end
  end
end