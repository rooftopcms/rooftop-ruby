module Rooftop
  module ResourceLinks
    CUSTOM_LINK_RELATION_BASE = "http://docs.rooftopcms.com/link_relations"
    def self.included(base)
      # set up an attribute called resource_links, which is a collection of links
      # to other resources in the API.
      # base.send(:after_find, ->(r) {
      #   if r.respond_to?(:"_links")
      #     r.resource_links = Rooftop::ResourceLinks::Collection.new(r._links)
      #     byebug
      #   end
      # })

      base.send(:after_find, :generate_resource_links)
      base.send(:after_save, :generate_resource_links)

      base.extend ClassMethods

    end

    def generate_resource_links
      if self.respond_to?(:"_links")
        self.resource_links = Rooftop::ResourceLinks::Collection.new(self._links)
      end
    end

    module ClassMethods
      def with_embedded_relations
        where(:_embed => true)
      end
    end

  end
end