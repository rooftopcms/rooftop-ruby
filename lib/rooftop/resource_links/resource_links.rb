module Rooftop
  module ResourceLinks
    CUSTOM_LINK_RELATION_BASE = "http://docs.rooftopcms.com/link_relations"
    def self.included(base)
      # set up an attribute called resource_links, which is a collection of links
      # to other resources in the API.
      base.send(:after_find, ->(r) {
        if r.respond_to?(:"_links")
          r.resource_links = Rooftop::ResourceLinks::Collection.new(r._links)
        end
      })
    end

  end
end