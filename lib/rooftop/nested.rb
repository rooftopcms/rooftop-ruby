module Rooftop
  module Nested

    def root
      ancestors.last || resource_links.find_by(link_type: 'self').first
    end

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
      if respond_to?(:resource_links) && resource_links
        ancestors.first
      end
    end

    def siblings
      self.class.find(parent.id).children.reject! {|c| c.id == self.id}
    end
  end
end