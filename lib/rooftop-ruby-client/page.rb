module RooftopRubyClient
  module Page
    def self.included(base)
      base.include RooftopRubyClient::Base
      base.include RooftopRubyClient::AuthorCoercion
      base.extend ClassMethods
      base.send(:collection_path,"pages")
    end

    module ClassMethods

    end
  end
end