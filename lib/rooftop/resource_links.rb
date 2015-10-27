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

    class Collection < ::Array
      attr_reader :links
      def initialize(links)
        links.each do |link_type,links|
          links.each do |link|
            self << Rooftop::ResourceLinks::Link.new(link_type,link)
          end
        end
      end

      # Find links by attribute. Assume there will only be one attribute in the search
      def find_by(hash)
        raise ArgumentError, "you can only find a resource link by one attribute at a time" unless hash.length == 1
        attr = hash.first.first
        val = hash.first.last
        self.select {|l| l.send(attr) == val.to_s}
      end
    end

    class Link
      attr_accessor :link_type
      def initialize(link_type,args)
        @link_type = link_type
        args.each do |k,v|
          instance_variable_set("@#{k}", v)
          self.class.send(:attr_accessor, k)
        end
      end

      def resolve
        raise NotImplementedError, "TODO: resolve the link."
      end
    end

  end
end