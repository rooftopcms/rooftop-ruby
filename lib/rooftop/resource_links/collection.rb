module Rooftop
  module ResourceLinks
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
  end
end
