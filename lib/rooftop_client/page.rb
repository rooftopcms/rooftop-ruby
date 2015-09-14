module RooftopClient
  module Page
    def self.included(base)
      base.include RooftopClient::Base
      base.include RooftopClient::ParentCoercion
      base.extend ClassMethods
      base.send(:collection_path,"pages")

    end

    module ClassMethods

    end



  end
end