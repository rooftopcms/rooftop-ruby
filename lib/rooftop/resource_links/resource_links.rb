module Rooftop
  module ResourceLinks
    CUSTOM_LINK_RELATION_BASE = "http://docs.rooftopcms.com/link_relations"

    def self.included(base)
      # set up an attribute called resource_links, which is a collection of links
      # to other resources in the API.
      base.send(:after_find, :generate_resource_links)
      base.send(:after_save, :generate_resource_links)
      base.extend ClassMethods
      base.configure_resource_link_mapping
    end

    def generate_resource_links
      if self.respond_to?(:"_links")
        self.resource_links = Rooftop::ResourceLinks::Collection.new(self._links, self.class)
      end
    end

    module ClassMethods
      # This class-level attribute allows us to set a mapping between a resource link name (which is probably
      # an href, but might be "up" or something) and a class. It means that when we try to resolve a link of a
      # given name, we know what type of class to instantiate
      attr_accessor :resource_link_mapping

      def configure_resource_link_mapping
        @resource_link_mapping ||= {}
        @resource_link_mapping.merge!({
                                      "author" => Rooftop::Author,
                                      "https://api.w.org/attachment" => Rooftop::MediaItem,
                                      "self" => self,
                                      "up" => self,
                                      "http://docs.rooftopcms.com/link_relations/ancestors" => self,
                                      "http://docs.rooftopcms.com/link_relations/children" => self
                                    })
      end
    end


  end
end