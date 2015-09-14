module RooftopClient
  module Page
    def self.included(base)
      base.include RooftopClient::Base
      base.extend ClassMethods
      base.send(:collection_path,"pages")
      base.send(:coerce_field, parent: ->(p) { base.send(:resolve_parent_id,p) })
    end

    module ClassMethods
      def resolve_parent_id(id)
        if id == 0
          #no parent
          nil
        else
          self.send(:find, id)
        end
      end
    end



  end
end