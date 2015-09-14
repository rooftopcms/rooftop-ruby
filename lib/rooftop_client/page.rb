module RooftopClient
  module Page
    def self.included(base)
      base.include RooftopClient::Base
      #TODO instead of the silly coercion, we should be able to use Her to do this
      # has_one :parent, data_field: :parent, class_name: "Page", path: "/pages"
      base.include RooftopClient::ParentCoercion
      base.extend ClassMethods
      base.send(:collection_path,"pages")
    end

    module ClassMethods

    end



  end
end