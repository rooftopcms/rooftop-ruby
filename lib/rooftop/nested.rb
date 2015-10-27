module Rooftop
  module Nested

    def ancestors
      if respond_to?(:resource_links)
        resource_links.find_by(link_type: "#{Rooftop::ResourceLinks::CUSTOM_LINK_RELATION_BASE}/ancestors")
      else
        []
      end
    end

    def children
      if respond_to?(:resource_links)
        resource_links.find_by(link_type: "#{Rooftop::ResourceLinks::CUSTOM_LINK_RELATION_BASE}/children")
      else
        []
      end
    end

    def parent
      if respond_to?(:resource_links)
        resource_links.find_by(link_type: "up").first
      end
    end
  end
end