module RooftopClient
  module Queries
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # We need to fix up the `where()` filter. WP-API expects a url format for filters like this:
      # /?filter[something]=foo.
      def where(args)
        args = HashWithIndifferentAccess.new(args)
        # the fact that 'slug' is referred to in the db as 'name' is irritating. Let's fix that
        # in queries so we can specify {slug: "foo"}
        if args.keys.collect(&:to_sym).include?(:slug)
          args[:name] = args[:slug]
          args.delete(:slug)
        end
        filters =  args.inject({}) {|hash,pair| hash["filter[#{pair.first}]"] = pair.last; hash}
        #Call the Her `where` method with our new filters
        super().where(filters)
      end
    end
  end
end